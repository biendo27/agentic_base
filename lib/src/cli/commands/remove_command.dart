import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/cli/commands/gen_command.dart';
import 'package:agentic_base/src/cli/dry_run.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/modules/module_integration_generator.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:agentic_base/src/modules/project_mutation_journal.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Removes a module from the current agentic_base project.
///
/// Usage: `agentic_base remove <module_name>`
class RemoveCommand extends Command<int> {
  RemoveCommand({
    required AgenticLogger logger,
    ProcessRunner? processRunner,
    String Function()? projectPathProvider,
    FlutterToolchainDetector? toolchainDetector,
  }) : _logger = logger,
       _processRunner = processRunner ?? runProcess,
       _projectPathProvider = projectPathProvider,
       _toolchainDetector = toolchainDetector ?? detectFlutterToolchain {
    addDryRunFlag(argParser);
  }

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;
  final FlutterToolchainDetector _toolchainDetector;

  @override
  String get name => 'remove';

  @override
  String get description =>
      'Remove an installed module from the current project.';

  @override
  String get invocation => 'agentic_base remove <module_name>';

  @override
  Future<int> run() async {
    final args = argResults!;
    final rest = args.rest;
    final dryRun = isDryRunEnabled(args);

    if (rest.isEmpty) {
      _logger.err('No module name provided.');
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

    // Validate module exists in registry.
    if (ModuleRegistry.find(moduleName) == null) {
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

    // Guard: not installed.
    if (!installed.contains(moduleName)) {
      _logger.warn('Module "$moduleName" is not installed.');
      return 0;
    }

    // Guard: other installed modules depend on this one.
    final dependents = ModuleRegistry.dependentsOf(
      moduleName,
      installed: installed,
    );
    if (dependents.isNotEmpty) {
      _logger.err(
        'Cannot remove "$moduleName" — the following installed modules '
        'depend on it: ${dependents.join(', ')}.\n'
        'Remove those modules first.',
      );
      return 1;
    }

    if (dryRun) {
      final reporter =
          DryRunReporter(
              logger: _logger,
              commandName: 'remove',
            )
            ..read('$projectPath/.info/agentic.yaml')
            ..note('would remove module: $moduleName')
            ..delete('$projectPath/module-owned integration files')
            ..write('$projectPath/pubspec.yaml')
            ..write('$projectPath/.info/agentic.yaml')
            ..toolchainContract(metadata.harness.sdk)
            ..command(
              flutterCommandForManager(metadata.harness.sdk.preferredManager, [
                'pub',
                'get',
              ]),
              workingDirectory: projectPath,
            )
            ..command(
              dartCommandForManager(metadata.harness.sdk.preferredManager, [
                'run',
                'build_runner',
                'build',
                '--delete-conflicting-outputs',
              ]),
              workingDirectory: projectPath,
            )
            ..command(
              dartCommandForManager(metadata.harness.sdk.preferredManager, [
                'format',
                'lib',
                'test',
              ]),
              workingDirectory: projectPath,
            );
      return reporter.complete();
    }

    final toolchain = resolveProjectFlutterToolchain(
      projectPath: projectPath,
      contract: metadata.harness.sdk,
      detector: _toolchainDetector,
    );

    final module = ModuleRegistry.findOrThrow(moduleName);
    final journal = ProjectMutationJournal();
    final ctx = ProjectContext(
      projectPath: projectPath,
      projectName: projectName,
      stateManagement: stateManagement,
      installedModules: List.unmodifiable(installed),
      mutationJournal: journal,
    );

    final progress = _logger.progress('Removing $moduleName');
    try {
      await module.uninstall(ctx);
      progress.complete('$moduleName removed');
    } on Exception catch (e) {
      progress.fail('Failed to remove $moduleName');
      _logger.err('$e');
      journal.rollback();
      return 1;
    }

    const ModuleIntegrationGenerator().sync(
      ProjectContext(
        projectPath: projectPath,
        projectName: projectName,
        stateManagement: stateManagement,
        installedModules: List.unmodifiable(
          installed.where((entry) => entry != moduleName).toList(),
        ),
        mutationJournal: journal,
      ),
    );

    // Run flutter pub get to reflect removed dependencies.
    final pubProgress = _logger.progress('Running flutter pub get');
    final pubCommand = toolchain.flutterCommand(['pub', 'get']);
    final pubResult = await _processRunner(
      pubCommand.executable,
      pubCommand.arguments,
      workingDirectory: projectPath,
    );
    if (pubResult.exitCode != 0) {
      pubProgress.fail('flutter pub get failed');
      _logger.err(pubResult.stderr.toString());
      journal.rollback();
      return 1;
    }
    pubProgress.complete('Dependencies updated');

    final codegenResult = await runProjectCodeGeneration(
      logger: _logger,
      projectRoot: projectPath,
      toolchain: toolchain,
      processRunner: _processRunner,
    );
    if (codegenResult != 0) {
      journal.rollback();
      return codegenResult;
    }

    config.writeMetadata(
      metadata.copyWith(
        toolVersion: AgenticBaseCliRunner.version,
        modules:
            metadata.modules.where((entry) => entry != moduleName).toList(),
        harness: metadata.harness.copyWith(sdk: toolchain.contract),
        provenance: {
          ...metadata.provenance,
          'tool_version': MetadataProvenance.explicit,
          'modules': MetadataProvenance.explicit,
          'harness.sdk.manager': MetadataProvenance.inferred,
          'harness.sdk.channel':
              toolchain.detected.channel == null
                  ? MetadataProvenance.defaulted
                  : MetadataProvenance.inferred,
          'harness.sdk.version': MetadataProvenance.inferred,
        },
      ),
    );

    _logger.success('Module "$moduleName" removed successfully.');
    return 0;
  }
}
