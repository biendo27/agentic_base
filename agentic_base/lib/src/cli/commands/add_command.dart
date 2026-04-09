import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/modules/project_context.dart';
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
  AddCommand({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

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
    final projectPath = Directory.current.path;
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

    final data = config.read();
    final projectName =
        data['project_name'] as String? ?? p.basename(projectPath);
    final stateManagement = data['state_management'] as String? ?? 'cubit';
    final installed = List<String>.from(
      (data['modules'] as List?)?.cast<String>() ?? [],
    );

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
    for (final prereq in missing) {
      _logger.info('Auto-installing prerequisite: $prereq');
      final prereqResult = await _installOne(
        name: prereq,
        projectPath: projectPath,
        projectName: projectName,
        stateManagement: stateManagement,
        installed: installed,
      );
      if (prereqResult != 0) return prereqResult;
      installed.add(prereq);
    }

    final result = await _installOne(
      name: moduleName,
      projectPath: projectPath,
      projectName: projectName,
      stateManagement: stateManagement,
      installed: installed,
    );
    if (result != 0) return result;

    // Run flutter pub get.
    final pubProgress = _logger.progress('Running flutter pub get');
    final pubResult = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: projectPath,
    );
    if (pubResult.exitCode != 0) {
      pubProgress.fail('flutter pub get failed');
      _logger.err(pubResult.stderr.toString());
      return 1;
    }
    pubProgress.complete('Dependencies installed');

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
  }) async {
    final mod = ModuleRegistry.findOrThrow(name);
    final ctx = ProjectContext(
      projectPath: projectPath,
      projectName: projectName,
      stateManagement: stateManagement,
      installedModules: List.unmodifiable(installed),
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
