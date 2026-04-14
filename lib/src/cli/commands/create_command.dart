import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/generators/project_generator.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:agentic_base/src/tui/prompts.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

typedef ProjectGeneratorBuilder =
    ProjectGenerator Function(AgenticLogger logger);

/// Generates a new agent-ready Flutter repository.
class CreateCommand extends Command<int> {
  CreateCommand({
    required AgenticLogger logger,
    ProjectGeneratorBuilder? projectGeneratorBuilder,
  }) : _logger = logger,
       _projectGeneratorBuilder =
           projectGeneratorBuilder ?? _defaultProjectGeneratorBuilder {
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
      ..addOption(
        'flavors',
        help: 'Flavors (must remain the default contract: dev,staging,prod)',
      )
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
      ..addOption(
        'ci-provider',
        help: 'CI provider: github or gitlab',
        allowed: supportedCiProviders,
        defaultsTo: defaultCiProvider.name,
      )
      ..addOption(
        'app-profile',
        help: 'Harness app profile',
        allowed: supportedHarnessAppProfiles,
        defaultsTo: HarnessAppProfile.consumerApp.wireName,
      )
      ..addOption(
        'traits',
        help: 'Secondary harness traits (comma-separated)',
      )
      ..addOption(
        'flutter-sdk-manager',
        help: 'Flutter SDK manager: system, fvm, puro',
        allowed: FlutterSdkManager.values.map((value) => value.wireName),
        defaultsTo: FlutterSdkManager.system.wireName,
      )
      ..addOption(
        'flutter-version',
        help:
            'Explicit tested Flutter version to persist in the harness contract',
      )
      ..addFlag(
        'no-interactive',
        help: 'Skip prompts, use defaults for missing values',
        negatable: false,
      );
  }

  final AgenticLogger _logger;
  final ProjectGeneratorBuilder _projectGeneratorBuilder;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new agent-ready Flutter repository.';

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
    final requestedPlatforms = _normalizeCsvOption(
      args['platforms'] as String?,
    );
    final requestedFlavors = _resolveSupportedFlavors(
      args['flavors'] as String?,
    );
    final requestedModules = _normalizeCsvOption(args['modules'] as String?);
    final requestedTraits = _normalizeCsvOption(args['traits'] as String?);
    final ciProvider = parseCiProvider(
      args['ci-provider'] as String? ?? defaultCiProvider.name,
    );
    final appProfile = HarnessAppProfileX.fromWireName(
      args['app-profile'] as String?,
    );
    final flutterSdkManager = FlutterSdkManagerX.fromWireName(
      args['flutter-sdk-manager'] as String?,
    );
    final flutterVersion = args['flutter-version'] as String?;

    if (requestedTraits != null) {
      for (final trait in requestedTraits) {
        if (!isSupportedHarnessSecondaryTrait(trait)) {
          _logger.err(
            'Invalid harness trait: "$trait". Allowed: '
            '${supportedHarnessSecondaryTraits.join(', ')}',
          );
          return 1;
        }
      }
    }

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
            ? requestedPlatforms ?? defaultPlatforms
            : requestedPlatforms ?? prompts.promptPlatforms(null);

    if (platforms.isEmpty) {
      _logger.err('At least one target platform is required.');
      return 1;
    }

    // Validate platforms
    for (final platform in platforms) {
      if (!allPlatforms.contains(platform)) {
        _logger.err(
          'Invalid platform: "$platform". '
          'Allowed: ${allPlatforms.join(', ')}',
        );
        return 1;
      }
    }

    final state = args['state'] as String? ?? 'cubit';

    if (requestedFlavors == null) {
      _logger.err(
        'Only the default flavor contract is supported: '
        '${defaultFlavors.join(', ')}.',
      );
      return 1;
    }

    final flavors = requestedFlavors;

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
            ? requestedModules ?? <String>[]
            : requestedModules ?? prompts.promptModules(null);

    _logger.header('Creating $projectName...');

    try {
      await _projectGeneratorBuilder(_logger).generate(
        projectName: projectName,
        outputDirectory: outputDir,
        org: org,
        platforms: platforms,
        stateManagement: state,
        flavors: flavors,
        primaryColor: primaryColor,
        ciProvider: ciProvider,
        appProfile: appProfile,
        flutterSdkManager: flutterSdkManager,
        flutterSdkVersion: flutterVersion,
        secondaryTraits: requestedTraits ?? const <String>[],
        modules: modules,
      );

      _logger
        ..success('Created $projectName at $outputDir')
        ..info('')
        ..info('Next steps:')
        ..info('  cd $projectName')
        ..info(
          '  flutter run --flavor dev -t lib/main_dev.dart '
          '--dart-define-from-file=env/dev.env.example',
        );
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

  static ProjectGenerator _defaultProjectGeneratorBuilder(
    AgenticLogger logger,
  ) {
    return ProjectGenerator(logger: logger);
  }

  static List<String>? _normalizeCsvOption(String? rawValue) {
    if (rawValue == null) {
      return null;
    }

    final values = <String>[];
    final seen = <String>{};
    for (final value in rawValue.split(',')) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) {
        continue;
      }
      values.add(trimmed);
    }

    if (values.isEmpty) {
      return null;
    }

    return values;
  }

  static List<String>? _resolveSupportedFlavors(String? rawValue) {
    final requestedFlavors = _normalizeCsvOption(rawValue);
    if (requestedFlavors == null) {
      return List.of(defaultFlavors);
    }

    final requestedSet = requestedFlavors.toSet();
    final defaultSet = defaultFlavors.toSet();
    final matchesDefaultContract =
        requestedSet.length == defaultSet.length &&
        requestedSet.containsAll(defaultSet);

    if (!matchesDefaultContract) {
      return null;
    }

    return List.of(defaultFlavors);
  }
}
