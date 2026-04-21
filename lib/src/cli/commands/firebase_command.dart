import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/modules/firebase_runtime_template.dart';
import 'package:agentic_base/src/modules/project_mutation_journal.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

final class FirebaseCommand extends Command<int> {
  FirebaseCommand({
    required AgenticLogger logger,
    ProcessRunner? processRunner,
    String Function()? projectPathProvider,
    FlutterToolchainDetector? toolchainDetector,
  }) {
    addSubcommand(
      _FirebaseSetupCommand(
        logger: logger,
        processRunner: processRunner ?? runProcess,
        projectPathProvider: projectPathProvider,
        toolchainDetector: toolchainDetector ?? detectFlutterToolchain,
      ),
    );
  }

  @override
  String get name => 'firebase';

  @override
  String get description => 'Configure Firebase for generated app flavors.';
}

final class _FirebaseSetupCommand extends Command<int> {
  _FirebaseSetupCommand({
    required AgenticLogger logger,
    required ProcessRunner processRunner,
    required FlutterToolchainDetector toolchainDetector,
    String Function()? projectPathProvider,
  }) : _logger = logger,
       _processRunner = processRunner,
       _projectPathProvider = projectPathProvider,
       _toolchainDetector = toolchainDetector {
    argParser
      ..addOption('project-dir', help: 'Generated project root.')
      ..addOption('project', help: 'Firebase project ID for all flavors.')
      ..addOption('project-dev', help: 'Firebase project ID for dev.')
      ..addOption('project-staging', help: 'Firebase project ID for staging.')
      ..addOption('project-prod', help: 'Firebase project ID for prod.')
      ..addOption(
        'platforms',
        help: 'Firebase platforms to configure: android,ios,web',
      )
      ..addFlag(
        'yes',
        negatable: false,
        help: 'Pass --yes to flutterfire configure.',
      );
  }

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;
  final FlutterToolchainDetector _toolchainDetector;

  @override
  String get name => 'setup';

  @override
  String get description => 'Run FlutterFire setup for dev/staging/prod.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final projectDir = _resolveProjectDir(args['project-dir'] as String?);
    final config = AgenticConfig(projectPath: projectDir);
    if (!config.exists) {
      _logger.err('No .info/agentic.yaml found at $projectDir.');
      return 1;
    }

    try {
      GeneratedProjectContract.validateAgentReadyRepository(projectDir);
    } on Exception catch (error) {
      _logger.err('Generated project contract is invalid: $error');
      return 1;
    }

    final metadata = config.readMetadata(
      fallbackProjectName: p.basename(projectDir),
    );
    final platforms = _resolvePlatforms(
      args['platforms'] as String?,
      metadata.platforms,
    );
    final unsupported = platforms.where(
      (platform) => !_supportedPlatforms.contains(platform),
    );
    if (unsupported.isNotEmpty) {
      _logger.err(
        'Unsupported Firebase platform(s): ${unsupported.join(', ')}. '
        'Supported: ${_supportedPlatforms.join(', ')}',
      );
      return 1;
    }

    final projectIds = _resolveProjectIds(args);
    if (projectIds == null) {
      _logger.err(
        'Provide --project for all flavors or all of '
        '--project-dev, --project-staging, and --project-prod.',
      );
      return 1;
    }

    final toolchain = resolveProjectFlutterToolchain(
      projectPath: projectDir,
      contract: metadata.harness.sdk,
      detector: _toolchainDetector,
    );

    if (!await _checkCommand('firebase', const ['--version'], projectDir)) {
      _logger.err(
        'Firebase CLI is required. Install from '
        'https://firebase.google.com/docs/cli before setup.',
      );
      return 1;
    }
    if (!await _checkCommand('flutterfire', const ['--help'], projectDir)) {
      _logger.err(
        'FlutterFire CLI is required. Run '
        '`dart pub global activate flutterfire_cli` before setup.',
      );
      return 1;
    }
    if (!await _checkCommand(
      'firebase',
      const ['projects:list', '--json'],
      projectDir,
    )) {
      _logger.err('Firebase login/project access check failed.');
      return 1;
    }

    final journal = ProjectMutationJournal();
    final needsNativeFlavorization =
        GeneratedProjectContract.requiresNativeFlavorization(platforms);
    try {
      for (final flavor in GeneratedProjectContract.generatedFlavors) {
        _trackFlutterFireOutputs(
          journal: journal,
          projectDir: projectDir,
          flavor: flavor,
          platforms: platforms,
        );
        final result = await _processRunner(
          'flutterfire',
          _flutterFireArgs(
            projectId: projectIds[flavor]!,
            projectName: metadata.projectName,
            org: metadata.org,
            flavor: flavor,
            platforms: platforms,
            yes: args['yes'] as bool,
          ),
          workingDirectory: projectDir,
        );
        if (result.exitCode != 0) {
          throw _FirebaseSetupException(
            'flutterfire configure failed for $flavor: ${result.stderr}',
          );
        }
      }

      journal
        ..writeFile(
          p.join(projectDir, 'lib/services/firebase/firebase_options.dart'),
          firebaseOptionsSelectorFileContent(
            packageName: metadata.projectName,
            usesLegacyRootOptions: false,
          ),
        )
        ..writeFile(
          p.join(projectDir, 'lib/services/firebase/firebase_runtime.dart'),
          firebaseRuntimeFileContent(packageName: metadata.projectName),
        );

      if (needsNativeFlavorization) {
        _trackFlavorizrOutputs(
          journal: journal,
          projectDir: projectDir,
          platforms: platforms,
        );
        journal.mutateTextFile(
          p.join(projectDir, 'flavorizr.yaml'),
          (current) => _patchFlavorizrFirebaseConfig(
            current,
            platforms: platforms,
          ),
        );

        await _runToolchainCommand(
          projectDir,
          toolchain.dartCommand(['run', 'flutter_flavorizr', '-f']),
        );
      }
      _trackBuildRunnerOutputs(journal: journal, projectDir: projectDir);
      await _runToolchainCommand(
        projectDir,
        toolchain.dartCommand([
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs',
        ]),
      );
    } on Exception catch (error) {
      journal.rollback();
      _logger.err('$error');
      return 1;
    }

    _logger.success('Firebase setup complete for dev, staging, and prod.');
    return 0;
  }

  String _resolveProjectDir(String? flagValue) {
    final raw =
        flagValue ?? _projectPathProvider?.call() ?? Directory.current.path;
    return p.normalize(p.absolute(raw));
  }

  List<String> _resolvePlatforms(String? raw, List<String> fallback) {
    final values = raw == null ? fallback : raw.split(',');
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  Map<String, String>? _resolveProjectIds(ArgResults args) {
    final shared = args['project'] as String?;
    if (shared != null && shared.trim().isNotEmpty) {
      return {
        for (final flavor in GeneratedProjectContract.generatedFlavors)
          flavor: shared.trim(),
      };
    }

    final dev = args['project-dev'] as String?;
    final staging = args['project-staging'] as String?;
    final prod = args['project-prod'] as String?;
    if ([
      dev,
      staging,
      prod,
    ].any((value) => value == null || value.trim().isEmpty)) {
      return null;
    }
    return {
      'dev': dev!.trim(),
      'staging': staging!.trim(),
      'prod': prod!.trim(),
    };
  }

  Future<bool> _checkCommand(
    String executable,
    List<String> arguments,
    String projectDir,
  ) async {
    final result = await _processRunner(
      executable,
      arguments,
      workingDirectory: projectDir,
    );
    return result.exitCode == 0;
  }

  void _trackFlutterFireOutputs({
    required ProjectMutationJournal journal,
    required String projectDir,
    required String flavor,
    required List<String> platforms,
  }) {
    journal.trackFile(
      p.join(
        projectDir,
        'lib/services/firebase/options/firebase_options_$flavor.dart',
      ),
    );
    if (platforms.contains('android')) {
      journal.trackFile(
        p.join(projectDir, 'android/app/src/$flavor/google-services.json'),
      );
    }
    if (platforms.contains('ios')) {
      journal.trackFile(
        p.join(
          projectDir,
          'ios/Runner/Firebase/$flavor/GoogleService-Info.plist',
        ),
      );
    }
  }

  void _trackFlavorizrOutputs({
    required ProjectMutationJournal journal,
    required String projectDir,
    required List<String> platforms,
  }) {
    if (platforms.contains('android')) {
      journal.trackDirectory(p.join(projectDir, 'android/app/src'));
      for (final relativePath in [
        'android/app/build.gradle',
        'android/app/build.gradle.kts',
        'android/app/flavorizr.gradle',
        'android/app/flavorizr.gradle.kts',
      ]) {
        journal.trackFile(p.join(projectDir, relativePath));
      }
    }

    if (platforms.contains('ios')) {
      for (final relativePath in [
        'ios/Flutter',
        'ios/Runner',
        'ios/Runner.xcodeproj/xcshareddata/xcschemes',
      ]) {
        journal.trackDirectory(p.join(projectDir, relativePath));
      }
      for (final relativePath in [
        'ios/Podfile',
        'ios/Runner.xcodeproj/project.pbxproj',
      ]) {
        journal.trackFile(p.join(projectDir, relativePath));
      }
    }
  }

  void _trackBuildRunnerOutputs({
    required ProjectMutationJournal journal,
    required String projectDir,
  }) {
    journal.trackDirectory(p.join(projectDir, 'lib'));
  }

  List<String> _flutterFireArgs({
    required String projectId,
    required String projectName,
    required String org,
    required String flavor,
    required List<String> platforms,
    required bool yes,
  }) {
    final appId = _appIdForFlavor(
      org: org,
      projectName: projectName,
      flavor: flavor,
    );
    return [
      'configure',
      '--project=$projectId',
      '--platforms=${platforms.join(',')}',
      '--out=lib/services/firebase/options/firebase_options_$flavor.dart',
      if (platforms.contains('android')) ...[
        '--android-package-name=$appId',
        '--android-out=android/app/src/$flavor/google-services.json',
      ],
      if (platforms.contains('ios')) ...[
        '--ios-bundle-id=$appId',
        '--ios-out=ios/Runner/Firebase/$flavor/GoogleService-Info.plist',
      ],
      if (yes) '--yes',
    ];
  }

  String _appIdForFlavor({
    required String org,
    required String projectName,
    required String flavor,
  }) {
    final base = GeneratedProjectContract.buildAppIdBase(
      org: org,
      projectName: projectName,
    );
    return switch (flavor) {
      'dev' => '$base.dev',
      'staging' => '$base.staging',
      _ => base,
    };
  }

  String _patchFlavorizrFirebaseConfig(
    String current, {
    required List<String> platforms,
  }) {
    final parsed = loadYaml(current);
    if (parsed is! YamlMap) {
      throw const _FirebaseSetupException('flavorizr.yaml is not valid YAML.');
    }
    final editor = YamlEditor(current);
    final flavors = parsed['flavors'];
    if (flavors is! YamlMap) {
      throw const _FirebaseSetupException('flavorizr.yaml is missing flavors.');
    }
    for (final flavor in GeneratedProjectContract.generatedFlavors) {
      final flavorNode = flavors[flavor];
      if (flavorNode is! YamlMap) {
        throw _FirebaseSetupException(
          'flavorizr.yaml is missing flavor $flavor.',
        );
      }
      if (platforms.contains('android')) {
        editor.update(
          ['flavors', flavor, 'android'],
          _withFirebaseConfig(
            flavorNode['android'],
            'android/app/src/$flavor/google-services.json',
          ),
        );
      }
      if (platforms.contains('ios')) {
        editor.update(
          ['flavors', flavor, 'ios'],
          _withFirebaseConfig(
            flavorNode['ios'],
            'ios/Runner/Firebase/$flavor/GoogleService-Info.plist',
          ),
        );
      }
    }
    return editor.toString();
  }

  Map<String, dynamic> _withFirebaseConfig(dynamic raw, String configPath) {
    final next = <String, dynamic>{};
    if (raw is YamlMap) {
      for (final entry in raw.entries) {
        next[entry.key.toString()] = entry.value;
      }
    }
    next['firebase'] = <String, dynamic>{'config': configPath};
    return next;
  }

  Future<void> _runToolchainCommand(
    String projectDir,
    ToolCommandSpec command,
  ) async {
    final result = await _processRunner(
      command.executable,
      command.arguments,
      workingDirectory: projectDir,
    );
    if (result.exitCode != 0) {
      throw _FirebaseSetupException('$command failed: ${result.stderr}');
    }
  }
}

const _supportedPlatforms = <String>{'android', 'ios', 'web'};

final class _FirebaseSetupException implements Exception {
  const _FirebaseSetupException(this.message);

  final String message;

  @override
  String toString() => message;
}
