import 'dart:io';

import 'package:agentic_base/src/config/agent_ready_repo_contract.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Thrown when a generated project violates the starter-app contract.
class ProjectGenerationException implements Exception {
  const ProjectGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Generator-owned rules for generated Flutter starter apps.
final class GeneratedProjectContract {
  static const generatedFlavors = <String>['dev', 'staging', 'prod'];
  static const _darwinBuildModes = <String>['Debug', 'Profile', 'Release'];
  static const _nativeFlavorPlatforms = <String>{
    'android',
    'ios',
    'macos',
  };

  static const requiredPaths = <String>[
    '.info/agentic.yaml',
    'AGENTS.md',
    'CLAUDE.md',
    'README.md',
    'Makefile',
    'build.yaml',
    'flavorizr.yaml',
    'assets/i18n/app/app_en.i18n.yaml',
    'assets/i18n/app/app_vi.i18n.yaml',
    'assets/i18n/home/home_en.i18n.yaml',
    'assets/i18n/home/home_vi.i18n.yaml',
    'env/dev.env.example',
    'env/staging.env.example',
    'env/prod.env.example',
    'docs/01-architecture.md',
    'docs/02-coding-standards.md',
    'docs/03-state-management.md',
    'docs/04-network-layer.md',
    'docs/05-theming-guide.md',
    'docs/06-testing-guide.md',
    'lib/app/app.dart',
    'lib/app/bootstrap.dart',
    'lib/app/flavors.dart',
    'lib/app/i18n/translations.g.dart',
    'lib/main.dart',
    'lib/main_dev.dart',
    'lib/main_staging.dart',
    'lib/main_prod.dart',
    '.vscode/launch.json',
    '.vscode/settings.json',
    '.idea/runConfigurations/dev_dart.xml',
    '.idea/runConfigurations/dev_profile.xml',
    '.idea/runConfigurations/dev_release.xml',
    '.idea/runConfigurations/staging_dart.xml',
    '.idea/runConfigurations/staging_profile.xml',
    '.idea/runConfigurations/staging_release.xml',
    '.idea/runConfigurations/prod_dart.xml',
    '.idea/runConfigurations/prod_profile.xml',
    '.idea/runConfigurations/prod_release.xml',
    'tools/_common.sh',
    'tools/build.sh',
    'tools/ci-check.sh',
    'tools/clean.sh',
    'tools/format.sh',
    'tools/gen.sh',
    'tools/lint.sh',
    'tools/release-preflight.sh',
    'tools/release.sh',
    'tools/run-dev.sh',
    'tools/setup.sh',
    'tools/test.sh',
    'tools/verify.sh',
  ];

  static const forbiddenFiles = <String>[
    'lib/app.dart',
    'lib/flavors.dart',
    '.idea/modules.xml',
    '.idea/runConfigurations/main_dart.xml',
    '.idea/workspace.xml',
  ];

  static const generatedI18nFiles = <String>[
    'lib/app/i18n/translations.g.dart',
    'lib/app/i18n/translations_en.g.dart',
    'lib/app/i18n/translations_vi.g.dart',
  ];

  static const forbiddenDirectories = <String>[
    'lib/pages',
    '.idea/libraries',
  ];

  static const _githubCiPaths = <String>[
    '.github/workflows/ci.yml',
    '.github/workflows/cd-dev.yml',
    '.github/workflows/cd-staging.yml',
    '.github/workflows/cd-prod.yml',
    '.github/workflows/release.yml',
  ];

  static const _gitlabCiPaths = <String>[
    '.gitlab-ci.yml',
    '.gitlab/ci/verify.yml',
    '.gitlab/ci/deploy.yml',
  ];

  static String buildAppIdBase({
    required String org,
    required String projectName,
  }) {
    final normalizedName = projectName.replaceAll('_', '');
    if (normalizedName.isEmpty) {
      throw const ProjectGenerationException(
        'Project name does not produce a valid app id segment.',
      );
    }

    final appId = '$org.$normalizedName';
    final segments = appId.split('.');
    final segmentPattern = RegExp(r'^[a-z][a-z0-9]*$');
    final isValid = segments.every(segmentPattern.hasMatch);
    if (!isValid) {
      throw ProjectGenerationException('Invalid normalized app id: $appId');
    }

    return appId;
  }

  static bool requiresNativeFlavorization(List<String> platforms) {
    return platforms
        .map((platform) => platform.trim())
        .any(_nativeFlavorPlatforms.contains);
  }

  static void cleanupForbiddenOutputs(String projectDir) {
    for (final relativePath in forbiddenFiles) {
      final file = File(_resolveProjectPath(projectDir, relativePath));
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    for (final relativePath in forbiddenDirectories) {
      final directory = Directory(
        _resolveProjectPath(projectDir, relativePath),
      );
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    }
  }

  static void deleteGeneratedI18nOutputs(String projectDir) {
    for (final relativePath in generatedI18nFiles) {
      final file = File(_resolveProjectPath(projectDir, relativePath));
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    final directory = Directory(
      _resolveProjectPath(projectDir, 'lib/app/i18n'),
    );
    if (directory.existsSync() && directory.listSync().isEmpty) {
      directory.deleteSync();
    }
  }

  static void validate(
    String projectDir, {
    CiProvider? ciProvider,
    String? stateManagement,
  }) {
    for (final relativePath in requiredPaths) {
      final type = FileSystemEntity.typeSync(
        _resolveProjectPath(projectDir, relativePath),
      );
      if (type == FileSystemEntityType.notFound) {
        throw ProjectGenerationException(
          'Missing required generated file: $relativePath',
        );
      }
    }

    for (final relativePath in forbiddenFiles) {
      final file = File(_resolveProjectPath(projectDir, relativePath));
      if (file.existsSync()) {
        throw ProjectGenerationException(
          'Forbidden generated file still exists: $relativePath',
        );
      }
    }

    for (final relativePath in forbiddenDirectories) {
      final directory = Directory(
        _resolveProjectPath(projectDir, relativePath),
      );
      if (directory.existsSync()) {
        throw ProjectGenerationException(
          'Forbidden generated directory still exists: $relativePath',
        );
      }
    }

    final resolvedCiProvider =
        ciProvider ?? _resolveConfiguredCiProvider(projectDir);

    validateAgentReadyRepository(
      projectDir,
      ciProvider: resolvedCiProvider,
    );
    _validateGeneratedReadme(projectDir);
    validateNativeFlavorOutputs(projectDir);
    if (stateManagement != null) {
      validateStateOutput(projectDir, stateManagement: stateManagement);
    }
  }

  static void validateAgentReadyRepository(
    String projectDir, {
    CiProvider? ciProvider,
  }) {
    final resolvedCiProvider =
        ciProvider ?? _resolveConfiguredCiProvider(projectDir);

    _validateAgentReadyConfig(
      projectDir,
      ciProvider: resolvedCiProvider,
    );
    _validateThinAdapters(projectDir);
    _validateReleaseSurfaces(
      projectDir,
      ciProvider: resolvedCiProvider,
    );
    if (resolvedCiProvider != null) {
      validateCiProviderOutputs(projectDir, ciProvider: resolvedCiProvider);
    }
  }

  static void validateStateOutput(
    String projectDir, {
    required String stateManagement,
  }) {
    final pubspec =
        File(
          _resolveProjectPath(projectDir, 'pubspec.yaml'),
        ).readAsStringSync();
    final bootstrap =
        File(
          _resolveProjectPath(projectDir, 'lib/app/bootstrap.dart'),
        ).readAsStringSync();
    final injection =
        File(
          _resolveProjectPath(projectDir, 'lib/core/di/injection.dart'),
        ).readAsStringSync();

    switch (stateManagement) {
      case 'cubit':
        _requireContent(pubspec, 'flutter_bloc');
        _requireContent(pubspec, 'get_it');
        _requireContent(pubspec, 'injectable');
        _requireContent(bootstrap, 'Bloc.observer');
        _requirePath(
          projectDir,
          'lib/features/home/presentation/cubit/home_cubit.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/controller/home_controller.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/store/home_store.dart',
        );
      case 'riverpod':
        _requireContent(pubspec, 'flutter_riverpod');
        _forbidContent(pubspec, 'flutter_bloc');
        _forbidContent(pubspec, 'get_it');
        _forbidContent(pubspec, 'injectable');
        _requireContent(bootstrap, 'UncontrolledProviderScope');
        _forbidContent(bootstrap, 'Bloc.observer');
        _forbidContent(injection, 'GetIt');
        _requirePath(
          projectDir,
          'lib/features/home/presentation/controller/home_controller.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/cubit/home_cubit.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/store/home_store.dart',
        );
      case 'mobx':
        _requireContent(pubspec, 'flutter_mobx');
        _requireContent(pubspec, 'mobx');
        _requireContent(pubspec, 'get_it');
        _requireContent(pubspec, 'injectable');
        _forbidContent(bootstrap, 'Bloc.observer');
        _requirePath(
          projectDir,
          'lib/features/home/presentation/store/home_store.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/cubit/home_cubit.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/controller/home_controller.dart',
        );
      default:
        throw ProjectGenerationException(
          'Unsupported state management for contract validation: $stateManagement',
        );
    }
  }

  static void enforceCiProviderOutputs(
    String projectDir, {
    required CiProvider ciProvider,
  }) {
    final removedPaths =
        ciProvider == CiProvider.github ? _gitlabCiPaths : _githubCiPaths;

    for (final relativePath in removedPaths) {
      final targetPath = _resolveProjectPath(projectDir, relativePath);
      final file = File(targetPath);
      if (file.existsSync()) {
        file.deleteSync();
        continue;
      }

      final directory = Directory(targetPath);
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    }

    if (ciProvider == CiProvider.github) {
      final githubDirectory = Directory(
        _resolveProjectPath(projectDir, '.github'),
      );
      if (!githubDirectory.existsSync()) {
        githubDirectory.createSync(recursive: true);
      }
    } else {
      _deleteDirectoryIfEmpty(projectDir, '.github/workflows');
      _deleteDirectoryIfEmpty(projectDir, '.github');
      final gitlabDirectory = Directory(
        _resolveProjectPath(projectDir, '.gitlab/ci'),
      );
      if (!gitlabDirectory.existsSync()) {
        gitlabDirectory.createSync(recursive: true);
      }
    }
  }

  static void validateCiProviderOutputs(
    String projectDir, {
    required CiProvider ciProvider,
  }) {
    final requiredCiPaths =
        ciProvider == CiProvider.github ? _githubCiPaths : _gitlabCiPaths;
    final forbiddenCiPaths =
        ciProvider == CiProvider.github ? _gitlabCiPaths : _githubCiPaths;

    for (final relativePath in requiredCiPaths) {
      _requirePath(projectDir, relativePath);
    }

    for (final relativePath in forbiddenCiPaths) {
      final type = FileSystemEntity.typeSync(
        _resolveProjectPath(projectDir, relativePath),
      );
      if (type != FileSystemEntityType.notFound) {
        throw ProjectGenerationException(
          'Forbidden CI provider file still exists: $relativePath',
        );
      }
    }

    if (ciProvider == CiProvider.github) {
      _validateGitHubCiOutputs(projectDir);
    } else {
      _validateGitLabCiOutputs(projectDir);
    }
  }

  static void validateNativeFlavorOutputs(String projectDir) {
    if (Directory(
      _resolveProjectPath(projectDir, 'android/app'),
    ).existsSync()) {
      _validateAndroidFlavorOutputs(projectDir);
    }

    if (Directory(
      _resolveProjectPath(projectDir, 'ios/Flutter'),
    ).existsSync()) {
      _validateIosFlavorOutputs(projectDir);
    }

    if (Directory(
      _resolveProjectPath(projectDir, 'macos/Flutter'),
    ).existsSync()) {
      _validateMacosFlavorOutputs(projectDir);
    }
  }

  static void _validateAndroidFlavorOutputs(String projectDir) {
    _requirePath(projectDir, 'android/app/flavorizr.gradle.kts');

    final buildFiles = [
      'android/app/build.gradle.kts',
      'android/app/build.gradle',
    ];
    File? buildFile;
    for (final path in buildFiles) {
      final candidate = File(_resolveProjectPath(projectDir, path));
      if (candidate.existsSync()) {
        buildFile = candidate;
        break;
      }
    }

    if (buildFile == null) {
      throw const ProjectGenerationException(
        'Missing Android app build file after flavor generation.',
      );
    }

    final contents = buildFile.readAsStringSync();
    final importsFlavorizr =
        contents.contains('flavorizr.gradle.kts') ||
        contents.contains('flavorizr.gradle');
    if (!importsFlavorizr) {
      throw const ProjectGenerationException(
        'Android flavor output is incomplete: build.gradle does not import flavorizr output.',
      );
    }
  }

  static void _validateIosFlavorOutputs(String projectDir) {
    _validateDarwinFlavorOutputs(
      projectDir: projectDir,
      xcconfigDirectory: 'ios/Flutter',
      schemesDirectory: 'ios/Runner.xcodeproj/xcshareddata/xcschemes',
    );

    for (final flavor in generatedFlavors) {
      _requirePath(
        projectDir,
        'ios/Runner/Assets.xcassets/${flavor}AppIcon.appiconset',
      );
      _requirePath(
        projectDir,
        'ios/Runner/Assets.xcassets/${flavor}LaunchImage.imageset',
      );
    }
  }

  static void _validateMacosFlavorOutputs(String projectDir) {
    _validateDarwinFlavorOutputs(
      projectDir: projectDir,
      xcconfigDirectory: 'macos/Flutter',
      schemesDirectory: 'macos/Runner.xcodeproj/xcshareddata/xcschemes',
      extraXcconfigDirectory: 'macos/Runner/Configs',
    );

    for (final flavor in generatedFlavors) {
      _requirePath(
        projectDir,
        'macos/Runner/Assets.xcassets/${flavor}AppIcon.appiconset',
      );
    }
  }

  static void _validateDarwinFlavorOutputs({
    required String projectDir,
    required String xcconfigDirectory,
    required String schemesDirectory,
    String? extraXcconfigDirectory,
  }) {
    for (final flavor in generatedFlavors) {
      for (final mode in _darwinBuildModes) {
        _requirePath(projectDir, '$xcconfigDirectory/$flavor$mode.xcconfig');
        if (extraXcconfigDirectory != null) {
          _requirePath(
            projectDir,
            '$extraXcconfigDirectory/$flavor$mode.xcconfig',
          );
        }
      }

      _requirePath(projectDir, '$schemesDirectory/$flavor.xcscheme');
    }
  }

  static void _validateGitHubCiOutputs(String projectDir) {
    final ciContents = _readRequiredFile(
      projectDir,
      '.github/workflows/ci.yml',
    );
    if (!ciContents.contains('./tools/verify.sh') ||
        !ciContents.contains(r'${{ github.workflow }}-${{ github.ref }}') ||
        ciContents.contains(r'\${{ github.workflow }}-\${{ github.ref }}')) {
      throw const ProjectGenerationException(
        'GitHub CI workflow must preserve GitHub expressions and call ./tools/verify.sh.',
      );
    }

    if (!ciContents.contains(r'./tools/build.sh ${{ matrix.flavor }}') ||
        ciContents.contains(r'./tools/build.sh \${{ matrix.flavor }}')) {
      throw const ProjectGenerationException(
        'GitHub build matrix must preserve the matrix.flavor expression.',
      );
    }

    _requireContent(
      _readRequiredFile(projectDir, '.github/workflows/cd-dev.yml'),
      './tools/release.sh dev firebase',
    );

    final stagingContents = _readRequiredFile(
      projectDir,
      '.github/workflows/cd-staging.yml',
    );
    _requireContent(
      stagingContents,
      './tools/release.sh staging play-internal',
    );
    _requireContent(stagingContents, './tools/release.sh staging testflight');

    final prodContents = _readRequiredFile(
      projectDir,
      '.github/workflows/cd-prod.yml',
    );
    _requireContent(prodContents, './tools/release.sh prod play-production');
    _requireContent(prodContents, './tools/release.sh prod app-store');

    final releaseContents = _readRequiredFile(
      projectDir,
      '.github/workflows/release.yml',
    );
    _requireContent(
      releaseContents,
      './tools/release-preflight.sh prod play-production',
    );
    _requireContent(releaseContents, './tools/build.sh prod appbundle');
  }

  static void _validateGitLabCiOutputs(String projectDir) {
    final rootContents = _readRequiredFile(projectDir, '.gitlab-ci.yml');
    if (!rootContents.contains('include:') ||
        !rootContents.contains('.gitlab/ci/verify.yml') ||
        !rootContents.contains('.gitlab/ci/deploy.yml')) {
      throw const ProjectGenerationException(
        'GitLab root CI file must bootstrap local include files.',
      );
    }

    final verifyContents = _readRequiredFile(
      projectDir,
      '.gitlab/ci/verify.yml',
    );
    if (!verifyContents.contains('native_validate:') ||
        !verifyContents.contains('./tools/verify.sh') ||
        !verifyContents.contains('tags: [macos]') ||
        verifyContents.contains('allow_failure: true')) {
      throw const ProjectGenerationException(
        'GitLab verify contract must include a blocking macOS native validation job.',
      );
    }

    final deployContents = _readRequiredFile(
      projectDir,
      '.gitlab/ci/deploy.yml',
    );
    _requireContent(deployContents, 'deploy_dev:');
    _requireContent(deployContents, './tools/release.sh dev firebase');
    _requireContent(deployContents, 'deploy_staging_android_internal:');
    _requireContent(
      deployContents,
      './tools/release.sh staging play-internal',
    );
    _requireContent(deployContents, 'deploy_staging_testflight:');
    _requireContent(deployContents, './tools/release.sh staging testflight');
    _requireContent(deployContents, 'deploy_prod_play:');
    _requireContent(deployContents, './tools/release.sh prod play-production');
    _requireContent(deployContents, 'deploy_prod_app_store:');
    _requireContent(deployContents, './tools/release.sh prod app-store');

    if (!deployContents.contains('when: manual')) {
      throw const ProjectGenerationException(
        'GitLab deploy jobs must remain manual.',
      );
    }
  }

  static void _validateAgentReadyConfig(
    String projectDir, {
    CiProvider? ciProvider,
  }) {
    final config = _readRequiredYamlMap(projectDir, '.info/agentic.yaml');
    final context = _requireYamlMap(config, 'context');
    final execution = _requireYamlMap(config, 'execution');
    final checkpoints = _requireYamlMap(config, 'checkpoints');

    _requireYamlListValue(context, 'canonical_docs', 'docs/01-architecture.md');
    _requireYamlListValue(context, 'thin_adapters', 'AGENTS.md');
    _requireYamlListValue(context, 'thin_adapters', 'CLAUDE.md');

    final storedCiProvider = config['ci_provider'];
    if (storedCiProvider is! String) {
      throw const ProjectGenerationException(
        'Generated YAML contract is missing ci_provider.',
      );
    }

    final expectedCiProvider = ciProvider ?? parseCiProvider(storedCiProvider);
    if (context['ci_provider'] != expectedCiProvider.name ||
        storedCiProvider != expectedCiProvider.name) {
      throw ProjectGenerationException(
        'Generated YAML contract must keep ci_provider synchronized as ${expectedCiProvider.name}.',
      );
    }

    for (final entry in deterministicExecutionScripts.entries) {
      final value = execution[entry.key];
      if (value != entry.value) {
        throw ProjectGenerationException(
          'Generated execution contract is missing ${entry.key}: ${entry.value}',
        );
      }
      _requireDeclaredPath(
        projectDir,
        value.toString(),
        contractSection: 'execution',
      );
    }

    _requireDeclaredPathList(
      projectDir,
      context['canonical_docs'],
      contractSection: 'context.canonical_docs',
    );
    _requireDeclaredPathList(
      projectDir,
      context['thin_adapters'],
      contractSection: 'context.thin_adapters',
    );

    _requireYamlListValue(
      checkpoints,
      'requires_human',
      'final-store-publish-approval',
    );
    final boundary = checkpoints['release_human_boundary'];
    if (boundary is! String || !boundary.contains('human')) {
      throw const ProjectGenerationException(
        'Release human boundary must stay explicit in .info/agentic.yaml.',
      );
    }
  }

  static void _validateThinAdapters(String projectDir) {
    final agents = _readRequiredFile(projectDir, 'AGENTS.md');
    final claude = _readRequiredFile(projectDir, 'CLAUDE.md');

    _requireContent(agents, 'Thin adapter');
    _requireContent(agents, './tools/verify.sh');
    _forbidContent(agents, 'Feature Workflow');

    _requireContent(claude, 'Thin Claude adapter');
    _requireContent(claude, 'Machine contract: `.info/agentic.yaml`');
  }

  static void _validateGeneratedReadme(String projectDir) {
    final readme = _readRequiredFile(projectDir, 'README.md');

    _requireContent(readme, 'An agent-ready Flutter repository');
    _requireContent(readme, './tools/run-dev.sh');
    _requireContent(
      readme,
      'final production store publish remains a human approval step',
    );
  }

  static void _validateReleaseSurfaces(
    String projectDir, {
    CiProvider? ciProvider,
  }) {
    final effectiveCiProvider =
        ciProvider ?? _resolveConfiguredCiProvider(projectDir);
    final releaseSurfacePaths = <String>[
      'tools/release-preflight.sh',
      'tools/release.sh',
      if (effectiveCiProvider == CiProvider.github) ...[
        '.github/workflows/cd-dev.yml',
        '.github/workflows/cd-staging.yml',
        '.github/workflows/cd-prod.yml',
        '.github/workflows/release.yml',
      ] else ...[
        '.gitlab/ci/deploy.yml',
      ],
    ];

    for (final path in releaseSurfacePaths) {
      _forbidContent(_readRequiredFile(projectDir, path), 'TODO');
    }

    final config = _readRequiredYamlMap(projectDir, '.info/agentic.yaml');
    final expectedAppId = buildAppIdBase(
      org: config['org'] as String,
      projectName: config['project_name'] as String,
    );
    _requireContent(
      _readRequiredFile(projectDir, 'ios/fastlane/Appfile'),
      expectedAppId,
    );
    _requireContent(
      _readRequiredFile(projectDir, 'ios/fastlane/Matchfile'),
      expectedAppId,
    );
    _requireContent(
      _readRequiredFile(projectDir, 'android/fastlane/Appfile'),
      expectedAppId,
    );
    _requireContent(
      _readRequiredFile(projectDir, 'tools/release-preflight.sh'),
      'human approval step',
    );
  }

  static CiProvider? _resolveConfiguredCiProvider(String projectDir) {
    final config = _readRequiredYamlMap(projectDir, '.info/agentic.yaml');
    final storedCiProvider = config['ci_provider'];
    if (storedCiProvider is! String || storedCiProvider.trim().isEmpty) {
      return null;
    }

    try {
      return parseCiProvider(storedCiProvider);
    } on FormatException catch (error) {
      throw ProjectGenerationException(
        'Generated YAML contract has invalid ci_provider: $error',
      );
    }
  }

  static void _requirePath(String projectDir, String relativePath) {
    final type = FileSystemEntity.typeSync(
      _resolveProjectPath(projectDir, relativePath),
    );
    if (type == FileSystemEntityType.notFound) {
      throw ProjectGenerationException(
        'Missing native flavor output: $relativePath',
      );
    }
  }

  static void _requireDeclaredPathList(
    String projectDir,
    dynamic raw, {
    required String contractSection,
  }) {
    if (raw is! YamlList) {
      throw ProjectGenerationException(
        'Generated YAML contract is missing a path list for $contractSection.',
      );
    }
    for (final entry in raw) {
      _requireDeclaredPath(
        projectDir,
        entry?.toString() ?? '',
        contractSection: contractSection,
      );
    }
  }

  static void _requireDeclaredPath(
    String projectDir,
    String declaredPath, {
    required String contractSection,
  }) {
    final relativePath = declaredPath.replaceFirst('./', '');
    final type = FileSystemEntity.typeSync(
      _resolveProjectPath(projectDir, relativePath),
    );
    if (relativePath.isEmpty || type == FileSystemEntityType.notFound) {
      throw ProjectGenerationException(
        'Generated YAML contract declares a missing path in $contractSection: $declaredPath',
      );
    }
  }

  static void _forbidPath(String projectDir, String relativePath) {
    final type = FileSystemEntity.typeSync(
      _resolveProjectPath(projectDir, relativePath),
    );
    if (type != FileSystemEntityType.notFound) {
      throw ProjectGenerationException(
        'Forbidden generated path still exists: $relativePath',
      );
    }
  }

  static void _requireContent(String contents, String expected) {
    if (!contents.contains(expected)) {
      throw ProjectGenerationException(
        'Missing expected generated content: $expected',
      );
    }
  }

  static void _forbidContent(String contents, String expected) {
    if (contents.contains(expected)) {
      throw ProjectGenerationException(
        'Forbidden generated content still exists: $expected',
      );
    }
  }

  static String _readRequiredFile(String projectDir, String relativePath) {
    final file = File(_resolveProjectPath(projectDir, relativePath));
    if (!file.existsSync()) {
      throw ProjectGenerationException(
        'Missing required generated file: $relativePath',
      );
    }
    return file.readAsStringSync();
  }

  static YamlMap _readRequiredYamlMap(String projectDir, String relativePath) {
    final yaml = loadYaml(_readRequiredFile(projectDir, relativePath));
    if (yaml is! YamlMap) {
      throw ProjectGenerationException(
        'Generated YAML file is not a map: $relativePath',
      );
    }
    return yaml;
  }

  static YamlMap _requireYamlMap(YamlMap yaml, String key) {
    final value = yaml[key];
    if (value is! YamlMap) {
      throw ProjectGenerationException(
        'Generated YAML contract is missing map key: $key',
      );
    }
    return value;
  }

  static void _requireYamlListValue(YamlMap yaml, String key, String expected) {
    final value = yaml[key];
    if (value is! YamlList || !value.contains(expected)) {
      throw ProjectGenerationException(
        'Generated YAML contract is missing $expected in $key',
      );
    }
  }

  static void _deleteDirectoryIfEmpty(String projectDir, String relativePath) {
    final directory = Directory(_resolveProjectPath(projectDir, relativePath));
    if (directory.existsSync() && directory.listSync().isEmpty) {
      directory.deleteSync();
    }
  }

  static String _resolveProjectPath(String projectDir, String relativePath) {
    final root = p.normalize(p.absolute(projectDir));
    final resolved = p.normalize(p.join(root, relativePath));
    final insideRoot = resolved == root || p.isWithin(root, resolved);
    if (!insideRoot) {
      throw ProjectGenerationException(
        'Refusing to access path outside generated project: $relativePath',
      );
    }
    return resolved;
  }
}
