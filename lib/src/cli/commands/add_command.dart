import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/cli/commands/gen_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/modules/module_integration_generator.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:agentic_base/src/modules/project_mutation_journal.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Installs a module into the current agentic_base project.
///
/// Usage: `agentic_base add <module_name>`
///
/// Available modules: analytics, crashlytics, auth, local_storage,
///   connectivity, permissions, secure_storage, logging
class AddCommand extends Command<int> {
  AddCommand({
    required AgenticLogger logger,
    ProcessRunner? processRunner,
    String Function()? projectPathProvider,
  }) : _logger = logger,
       _processRunner = processRunner ?? runProcess,
       _projectPathProvider = projectPathProvider;

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;

  @override
  String get name => 'add';

  @override
  String get description => 'Install a module into the current project.';

  @override
  String get invocation => 'agentic_base add <module_name>';

  @override
  Future<int> run() async {
    final args = argResults!;
    final rest = args.rest;

    if (rest.isEmpty) {
      _logger
        ..err('No module name provided.')
        ..info('')
        ..info('Available modules: ${ModuleRegistry.allNames.join(', ')}');
      return 1;
    }

    final moduleName = rest.first.trim();
    final projectPath = _projectPathProvider?.call() ?? Directory.current.path;
    final config = AgenticConfig(projectPath: projectPath);

    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    // Resolve module — validate early.
    final module = ModuleRegistry.find(moduleName);
    if (module == null) {
      _logger.err(
        'Unknown module "$moduleName". '
        'Available: ${ModuleRegistry.allNames.join(', ')}',
      );
      return 1;
    }

    final metadata = config.readMetadata(
      fallbackProjectName: p.basename(projectPath),
      fallbackToolVersion: AgenticBaseCliRunner.version,
    );
    final projectName = metadata.projectName;
    final stateManagement = metadata.stateManagement;
    final installed = List<String>.from(metadata.modules);

    // Guard: already installed.
    if (installed.contains(moduleName)) {
      _logger.warn('Module "$moduleName" is already installed.');
      return 0;
    }

    // Guard: conflicts.
    final conflicts = ModuleRegistry.findConflicts(
      moduleName,
      installed: installed,
    );
    if (conflicts.isNotEmpty) {
      _logger.err(
        'Module "$moduleName" conflicts with installed modules: '
        '${conflicts.join(', ')}',
      );
      return 1;
    }

    // Auto-install prerequisites.
    final missing = ModuleRegistry.missingPrerequisites(
      moduleName,
      installed: installed,
    );
    final journal = ProjectMutationJournal();
    for (final prereq in missing) {
      _logger.info('Auto-installing prerequisite: $prereq');
      final prereqResult = await _installOne(
        name: prereq,
        projectPath: projectPath,
        projectName: projectName,
        stateManagement: stateManagement,
        installed: installed,
        journal: journal,
      );
      if (prereqResult != 0) {
        journal.rollback();
        return prereqResult;
      }
      installed.add(prereq);
    }

    final result = await _installOne(
      name: moduleName,
      projectPath: projectPath,
      projectName: projectName,
      stateManagement: stateManagement,
      installed: installed,
      journal: journal,
    );
    if (result != 0) {
      journal.rollback();
      return result;
    }

    final nextModules = <String>[
      ...metadata.modules,
      for (final name in [...missing, moduleName])
        if (!metadata.modules.contains(name)) name,
    ];

    const ModuleIntegrationGenerator().sync(
      ProjectContext(
        projectPath: projectPath,
        projectName: projectName,
        stateManagement: stateManagement,
        installedModules: List.unmodifiable(nextModules),
        mutationJournal: journal,
      ),
    );

    // Run flutter pub get.
    final pubProgress = _logger.progress('Running flutter pub get');
    final pubResult = await _processRunner('flutter', [
      'pub',
      'get',
    ], workingDirectory: projectPath);
    if (pubResult.exitCode != 0) {
      pubProgress.fail('flutter pub get failed');
      _logger.err(pubResult.stderr.toString());
      journal.rollback();
      return 1;
    }
    pubProgress.complete('Dependencies installed');

    final codegenResult = await runProjectCodeGeneration(
      logger: _logger,
      projectRoot: projectPath,
      processRunner: _processRunner,
    );
    if (codegenResult != 0) {
      journal.rollback();
      return codegenResult;
    }

    config.writeMetadata(
      metadata.copyWith(
        toolVersion: AgenticBaseCliRunner.version,
        modules: nextModules,
        provenance: {
          ...metadata.provenance,
          'tool_version': MetadataProvenance.explicit,
          'modules': MetadataProvenance.explicit,
        },
      ),
    );

    // Print platform steps.
    if (module.platformSteps.isNotEmpty) {
      _logger
        ..info('')
        ..info('Manual platform steps required:');
      for (final step in module.platformSteps) {
        _logger.info('  * $step');
      }
    }

    _logger.success('Module "$moduleName" installed successfully.');
    return 0;
  }

  Future<int> _installOne({
    required String name,
    required String projectPath,
    required String projectName,
    required String stateManagement,
    required List<String> installed,
    required ProjectMutationJournal journal,
  }) async {
    final mod = ModuleRegistry.findOrThrow(name);
    final ctx = ProjectContext(
      projectPath: projectPath,
      projectName: projectName,
      stateManagement: stateManagement,
      installedModules: List.unmodifiable(installed),
      mutationJournal: journal,
    );
    final progress = _logger.progress('Installing $name');
    try {
      await mod.install(ctx);
      progress.complete('$name installed');
      return 0;
    } on Exception catch (e) {
      progress.fail('Failed to install $name');
      _logger.err('$e');
      return 1;
    }
  }
}
