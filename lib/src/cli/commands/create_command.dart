import 'dart:io';

import 'package:agentic_base/src/generators/project_generator.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:agentic_base/src/tui/prompts.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Generates a new Flutter project optimized for AI-agent development.
class CreateCommand extends Command<int> {
  CreateCommand({required AgenticLogger logger}) : _logger = logger {
    argParser
      ..addOption('org', help: 'Organization (reverse domain)', abbr: 'o')
      ..addOption(
        'platforms',
        help: 'Target platforms (comma-separated)',
        abbr: 'p',
      )
      ..addOption(
        'state',
        help: 'State management: cubit, riverpod, mobx',
        abbr: 's',
        allowed: stateManagementOptions,
        defaultsTo: 'cubit',
      )
      ..addOption('flavors', help: 'Flavors (comma-separated)')
      ..addOption(
        'output-dir',
        help: 'Output directory (default: ./<app_name>)',
      )
      ..addOption(
        'primary-color',
        help: 'Primary color hex (e.g., 6750A4)',
      )
      ..addOption(
        'modules',
        help: 'Modules to install (comma-separated)',
        abbr: 'm',
      )
      ..addFlag(
        'no-interactive',
        help: 'Skip prompts, use defaults for missing values',
        negatable: false,
      );
  }

  final AgenticLogger _logger;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Flutter project.';

  @override
  String get invocation => 'agentic_base create <app_name>';

  @override
  Future<int> run() async {
    final args = argResults!;
    final rest = args.rest;
    if (rest.isEmpty) {
      throw UsageException('No project name provided.', usage);
    }

    final projectName = rest.first;

    // Validate project name before path construction
    if (!_validName.hasMatch(projectName)) {
      throw UsageException(
        'Project name must be snake_case (e.g. my_app). '
        'Got: "$projectName"',
        usage,
      );
    }

    final noInteractive = args['no-interactive'] as bool;
    final flagOutputDir = args['output-dir'] as String?;

    final String outputDir;
    if (flagOutputDir != null) {
      outputDir =
          p.isAbsolute(flagOutputDir)
              ? p.join(flagOutputDir, projectName)
              : p.join(Directory.current.path, flagOutputDir, projectName);
    } else if (noInteractive) {
      outputDir = p.join(Directory.current.path, projectName);
    } else {
      final defaultDir = p.join(Directory.current.path, projectName);
      final chosen = _logger.prompt(
        'Output directory',
        defaultValue: defaultDir,
      );
      outputDir =
          chosen.endsWith(projectName) ? chosen : p.join(chosen, projectName);
    }

    // Prevent overwriting pre-existing directories
    if (Directory(outputDir).existsSync()) {
      _logger.err('Directory already exists: $outputDir');
      return 1;
    }
    final prompts = CreatePrompts(_logger);

    final org =
        noInteractive
            ? (args['org'] as String? ?? 'com.example')
            : prompts.promptOrg(args['org'] as String?);

    // Validate org format
    if (!_validOrg.hasMatch(org)) {
      _logger.err(
        'Invalid org format. Expected reverse domain '
        '(e.g. com.example). Got: "$org"',
      );
      return 1;
    }

    final platforms =
        noInteractive
            ? (args['platforms'] as String?)?.split(',') ?? defaultPlatforms
            : prompts.promptPlatforms(args['platforms'] as String?);

    // Validate platforms
    for (final platform in platforms) {
      if (!allPlatforms.contains(platform.trim())) {
        _logger.err(
          'Invalid platform: "$platform". '
          'Allowed: ${allPlatforms.join(', ')}',
        );
        return 1;
      }
    }

    final state = args['state'] as String? ?? 'cubit';

    final flavors =
        noInteractive
            ? (args['flavors'] as String?)?.split(',') ?? defaultFlavors
            : prompts.promptFlavors(args['flavors'] as String?);

    final primaryColor =
        noInteractive
            ? (args['primary-color'] as String? ?? '6750A4')
            : prompts.promptPrimaryColor(args['primary-color'] as String?);

    // Validate hex color
    if (!_validHex.hasMatch(primaryColor)) {
      _logger.err(
        'Invalid hex color. Expected 6-char hex '
        '(e.g. 6750A4). Got: "$primaryColor"',
      );
      return 1;
    }

    final modules =
        noInteractive
            ? (args['modules'] as String?)
                    ?.split(',')
                    .map((m) => m.trim())
                    .toList() ??
                <String>[]
            : prompts.promptModules(args['modules'] as String?);

    _logger.header('Creating $projectName...');

    try {
      await ProjectGenerator(logger: _logger).generate(
        projectName: projectName,
        outputDirectory: outputDir,
        org: org,
        platforms: platforms,
        stateManagement: state,
        flavors: flavors,
        primaryColor: primaryColor,
        modules: modules,
      );

      _logger
        ..success('Created $projectName at $outputDir')
        ..info('')
        ..info('Next steps:')
        ..info('  cd $projectName')
        ..info('  flutter run');
      return 0;
    } on Exception catch (e) {
      _logger.err('Failed to create project: $e');
      final dir = Directory(outputDir);
      if (dir.existsSync()) {
        _logger.warn('Rolling back: deleting $outputDir');
        dir.deleteSync(recursive: true);
      }
      return 1;
    }
  }

  static final _validName = RegExp(r'^[a-z][a-z0-9_]*$');
  static final _validOrg = RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$');
  static final _validHex = RegExp(r'^[0-9a-fA-F]{6}$');
}
