import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Removes a module from the current agentic_base project.
///
/// Usage: `agentic_base remove <module_name>`
class RemoveCommand extends Command<int> {
  RemoveCommand({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

  @override
  String get name => 'remove';

  @override
  String get description => 'Remove an installed module from the current project.';

  @override
  String get invocation => 'agentic_base remove <module_name>';

  @override
  Future<int> run() async {
    final args = argResults!;
    final rest = args.rest;

    if (rest.isEmpty) {
      _logger.err('No module name provided.');
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

    // Validate module exists in registry.
    if (ModuleRegistry.find(moduleName) == null) {
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

    final module = ModuleRegistry.findOrThrow(moduleName);
    final ctx = ProjectContext(
      projectPath: projectPath,
      projectName: projectName,
      stateManagement: stateManagement,
      installedModules: List.unmodifiable(installed),
    );

    final progress = _logger.progress('Removing $moduleName');
    try {
      await module.uninstall(ctx);
      progress.complete('$moduleName removed');
    } on Exception catch (e) {
      progress.fail('Failed to remove $moduleName');
      _logger.err('$e');
      return 1;
    }

    // Run flutter pub get to reflect removed dependencies.
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
    pubProgress.complete('Dependencies updated');

    _logger.success('Module "$moduleName" removed successfully.');
    return 0;
  }
}
