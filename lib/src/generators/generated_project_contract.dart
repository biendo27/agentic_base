import 'dart:io';

import 'package:agentic_base/src/config/agent_ready_repo_contract.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
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
    'dart_test.yaml',
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
    'docs/07-agentic-development-flow.md',
    'lib/app/app.dart',
    'lib/app/bootstrap.dart',
    'lib/app/flavors.dart',
    'lib/app/locale/app_locale_contract.dart',
    'lib/app/i18n/translations.g.dart',
    'lib/core/commerce/entitlement_service.dart',
    'lib/core/contracts/app_list_response.dart',
    'lib/core/contracts/localized_text.dart',
    'lib/core/contracts/app_response.dart',
    'lib/core/contracts/app_result.dart',
    'lib/core/network/interceptors/observability_interceptor.dart',
    'lib/core/observability/observability_service.dart',
    'lib/core/observability/redaction_policy.dart',
    'lib/core/observability/trace_context.dart',
    'lib/core/contracts/pagination.dart',
    'lib/core/privacy/consent_service.dart',
    'lib/core/starter/starter_runtime_profile.dart',
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
    'tools/inspect-evidence.sh',
    'tools/lint.sh',
    'tools/release-preflight.sh',
    'tools/release.sh',
    'tools/run-dev.sh',
    'tools/setup.sh',
    'tools/test.sh',
    'tools/verify.sh',
    'test/app_smoke_test.dart',
    'test/core/contracts/app_list_response_test.dart',
    'test/core/contracts/app_response_test.dart',
    'test/core/contracts/localized_text_test.dart',
    'test/core/contracts/pagination_test.dart',
    'test/features/home/data/repositories/demo_starter_monetization_repository_test.dart',
    'test/features/home/data/repositories/home_repository_impl_test.dart',
    'test/features/home/presentation/widgets/starter_action_card_test.dart',
    'test/features/home/presentation/widgets/starter_journey_signal_card_test.dart',
    'test/features/home/presentation/widgets/starter_monetization_overview_card_test.dart',
    'test/features/home/presentation/widgets/starter_settings_preview_card_test.dart',
  ];

  static const requiredFeatureHostPaths = <String>[
    'lib/core/contracts/app_result.dart',
    'lib/core/error/error_handler.dart',
    'lib/core/error/failures.dart',
    'lib/core/router/app_router.dart',
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
    _validateGeneratedDocs(projectDir);
    _validateGeneratedContractModelSurface(projectDir);
    _validateGeneratedVerifySurface(projectDir);
    _validateThemeSurface(projectDir);
    validateNativeFlavorOutputs(projectDir);
    if (stateManagement != null) {
      validateStateOutput(projectDir, stateManagement: stateManagement);
    }
  }

  static void validateFeatureHost(String projectDir, {bool simple = false}) {
    if (simple) {
      return;
    }

    for (final relativePath in requiredFeatureHostPaths) {
      final type = FileSystemEntity.typeSync(
        _resolveProjectPath(projectDir, relativePath),
      );
      if (type == FileSystemEntityType.notFound) {
        throw ProjectGenerationException(
          'Full feature scaffolds require the shared host file `$relativePath`.',
        );
      }
    }

    final pubspecFile = File(_resolveProjectPath(projectDir, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw const ProjectGenerationException(
        'Full feature scaffolds require `pubspec.yaml` in the host project.',
      );
    }

    final pubspecContents = pubspecFile.readAsStringSync();
    if (!pubspecContents.contains('fpdart:')) {
      throw const ProjectGenerationException(
        'Full feature scaffolds require the `fpdart` dependency in `pubspec.yaml`.',
      );
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
        _requirePath(projectDir, 'test/features/home/home_cubit_test.dart');
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/controller/home_controller.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/store/home_store.dart',
        );
        _forbidPath(projectDir, 'test/features/home/home_controller_test.dart');
        _forbidPath(projectDir, 'test/features/home/home_store_test.dart');
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
        _requirePath(
          projectDir,
          'test/features/home/home_controller_test.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/cubit/home_cubit.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/store/home_store.dart',
        );
        _forbidPath(projectDir, 'test/features/home/home_cubit_test.dart');
        _forbidPath(projectDir, 'test/features/home/home_store_test.dart');
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
        _requirePath(projectDir, 'test/features/home/home_store_test.dart');
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/cubit/home_cubit.dart',
        );
        _forbidPath(
          projectDir,
          'lib/features/home/presentation/controller/home_controller.dart',
        );
        _forbidPath(projectDir, 'test/features/home/home_cubit_test.dart');
        _forbidPath(projectDir, 'test/features/home/home_controller_test.dart');
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
        ciContents.contains(r'\${{ github.workflow }}-\${{ github.ref }}') ||
        !ciContents.contains('actions/upload-artifact@v4') ||
        !ciContents.contains('flutter-version:')) {
      throw const ProjectGenerationException(
        'GitHub CI workflow must preserve expressions, call ./tools/verify.sh, and upload evidence artifacts.',
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
        verifyContents.contains('allow_failure: true') ||
        !verifyContents.contains('artifacts:')) {
      throw const ProjectGenerationException(
        'GitLab verify contract must include a blocking macOS native validation job and preserve evidence artifacts.',
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
    final schemaVersion = config['schema_version'];
    if (schemaVersion is! int || schemaVersion < 3) {
      throw const ProjectGenerationException(
        'Generated YAML contract must use schema_version 3 or later.',
      );
    }
    final context = _requireYamlMap(config, 'context');
    final execution = _requireYamlMap(config, 'execution');
    final checkpoints = _requireYamlMap(config, 'checkpoints');
    final harness = _requireYamlMap(config, 'harness');

    for (final doc in canonicalContextDocs) {
      _requireYamlListValue(context, 'canonical_docs', doc);
    }
    for (final adapter in thinAdapterFiles) {
      _requireYamlListValue(context, 'thin_adapters', adapter);
    }

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

    final contractVersion = harness['contract_version'];
    if (contractVersion != 1) {
      throw const ProjectGenerationException(
        'Harness Contract V1 requires harness.contract_version: 1.',
      );
    }

    final appProfile = _requireYamlMap(harness, 'app_profile');
    final primaryProfile = appProfile['primary_profile'];
    if (primaryProfile is! String ||
        !supportedHarnessAppProfiles.contains(primaryProfile)) {
      throw const ProjectGenerationException(
        'Generated YAML contract has an unsupported harness app profile.',
      );
    }

    final secondaryTraits = appProfile['secondary_traits'];
    if (secondaryTraits is! YamlList) {
      throw const ProjectGenerationException(
        'Generated YAML contract must expose harness.app_profile.secondary_traits.',
      );
    }
    for (final trait in secondaryTraits) {
      if (!isSupportedHarnessSecondaryTrait(trait.toString())) {
        throw ProjectGenerationException(
          'Unsupported harness secondary trait: $trait',
        );
      }
    }

    final capabilities = _requireYamlMap(harness, 'capabilities');
    final enabledCapabilities = capabilities['enabled'];
    if (enabledCapabilities is! YamlList) {
      throw const ProjectGenerationException(
        'Generated YAML contract must expose harness.capabilities.enabled.',
      );
    }

    final providers = harness['providers'];
    if (providers is YamlMap) {
      for (final entry in providers.entries) {
        final capability = entry.key.toString();
        final provider = entry.value?.toString() ?? '';
        if (!enabledCapabilities.contains(capability)) {
          throw ProjectGenerationException(
            'Generated YAML contract declares a provider for a disabled capability: $capability',
          );
        }
        if (_looksLikeSecret(provider)) {
          throw ProjectGenerationException(
            'Harness providers must stay declarative and secret-free: $capability',
          );
        }
      }
    }

    final eval = _requireYamlMap(harness, 'eval');
    if (eval['evidence_dir'] != defaultHarnessEvidenceDir) {
      throw const ProjectGenerationException(
        'Harness eval contract must use the canonical evidence directory.',
      );
    }
    final qualityDimensions = eval['quality_dimensions'];
    if (qualityDimensions is! YamlList) {
      throw const ProjectGenerationException(
        'Harness eval quality dimensions are missing or incomplete.',
      );
    }
    final resolvedQualityDimensions =
        qualityDimensions.map((value) => value.toString()).toList();
    if (resolvedQualityDimensions.length !=
            defaultHarnessQualityDimensions.length ||
        !_listsEqual(
          resolvedQualityDimensions,
          defaultHarnessQualityDimensions,
        )) {
      throw const ProjectGenerationException(
        'Harness eval quality dimensions drifted from the canonical contract.',
      );
    }

    final approvals = _requireYamlMap(harness, 'approvals');
    for (final pause in requiredHumanApprovalPauses) {
      _requireYamlListValue(approvals, 'pause_on', pause);
    }
    if (_containsSecretLikeValue(approvals)) {
      throw const ProjectGenerationException(
        'Harness approvals must stay declarative and secret-free.',
      );
    }

    final observability = _requireYamlMap(harness, 'observability');
    if (observability['mode'] != defaultHarnessObservabilityMode) {
      throw const ProjectGenerationException(
        'Harness observability mode must stay local-first.',
      );
    }
    _requireYamlStringList(
      observability,
      key: 'runtime_observability',
      expectedValues: defaultHarnessRuntimeObservability,
      message:
          'Harness runtime observability signals drifted from the canonical contract.',
    );
    _requireYamlStringList(
      observability,
      key: 'agent_legibility',
      expectedValues: defaultHarnessAgentLegibility,
      message:
          'Harness agent legibility signals drifted from the canonical contract.',
    );
    _requireYamlStringList(
      observability,
      key: 'operator_reports',
      expectedValues: defaultHarnessOperatorReports,
      message:
          'Harness operator report signals drifted from the canonical contract.',
    );

    final sdk = _requireYamlMap(harness, 'sdk');
    if (_containsSecretLikeValue(sdk)) {
      throw const ProjectGenerationException(
        'Harness SDK metadata must stay declarative and secret-free.',
      );
    }
    final manager = sdk['manager']?.toString();
    if (!FlutterSdkManager.values
        .map((value) => value.wireName)
        .contains(manager)) {
      throw const ProjectGenerationException(
        'Harness SDK manager must be one of system, fvm, or puro.',
      );
    }
    final version = sdk['version']?.toString() ?? '';
    if (!RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+$').hasMatch(version)) {
      throw const ProjectGenerationException(
        'Harness SDK version must be a semantic version.',
      );
    }
    if (sdk['policy'] != FlutterVersionPolicy.newestTested.wireName) {
      throw const ProjectGenerationException(
        'Harness SDK policy must stay on newest_tested.',
      );
    }
  }

  static void _validateThinAdapters(String projectDir) {
    final agents = _readRequiredFile(projectDir, 'AGENTS.md');
    final claude = _readRequiredFile(projectDir, 'CLAUDE.md');

    _requireContent(agents, 'Thin adapter');
    _requireContent(agents, './tools/verify.sh');
    _requireContent(agents, 'Harness Contract: `v1`');
    _requireContent(agents, 'Evidence directory: `artifacts/evidence`');
    _requireContent(agents, 'docs/07-agentic-development-flow.md');
    _requireContent(agents, 'Recommended default Gitflow');

    _requireContent(claude, 'Thin Claude adapter');
    _requireContent(claude, 'Machine contract: `.info/agentic.yaml`');
    _requireContent(claude, 'Harness Contract: `v1`');
    _requireContent(claude, 'Support tier:');
    _requireContent(claude, 'docs/07-agentic-development-flow.md');
    _requireContent(claude, 'Recommended default Gitflow');
  }

  static bool _listsEqual(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  static void _requireYamlStringList(
    YamlMap map, {
    required String key,
    required List<String> expectedValues,
    required String message,
  }) {
    final raw = map[key];
    if (raw is! YamlList) {
      throw ProjectGenerationException(message);
    }

    final resolved = raw.map((value) => value.toString()).toList();
    if (!_listsEqual(resolved, expectedValues)) {
      throw ProjectGenerationException(message);
    }
  }

  static void _validateGeneratedReadme(String projectDir) {
    final readme = _readRequiredFile(projectDir, 'README.md');

    _requireContent(readme, 'An agent-ready Flutter repository');
    _requireContent(readme, 'Primary profile: `');
    _requireContent(readme, 'Support tier: `');
    _requireContent(readme, 'Evidence directory: `artifacts/evidence`');
    _requireContent(readme, './tools/test.sh');
    _requireContent(readme, './tools/run-dev.sh');
    _requireContent(readme, 'docs/07-agentic-development-flow.md');
    _requireContent(readme, 'Recommended default Gitflow');
    _requireContent(
      readme,
      'final production store publish remains a human approval step',
    );
  }

  static void _validateGeneratedDocs(String projectDir) {
    final testingGuide = _readRequiredFile(
      projectDir,
      'docs/06-testing-guide.md',
    );
    final workflowGuide = _readRequiredFile(
      projectDir,
      'docs/07-agentic-development-flow.md',
    );

    _requireContent(testingGuide, './tools/test.sh');
    _requireContent(testingGuide, './tools/verify.sh');
    _requireContent(testingGuide, './tools/inspect-evidence.sh');
    _requireContent(testingGuide, 'make test');
    _requireContent(testingGuide, 'app-shell-smoke');
    _forbidContent(testingGuide, 'flutter test');

    _requireContent(workflowGuide, '.info/agentic.yaml');
    _requireContent(workflowGuide, './tools/verify.sh');
    _requireContent(workflowGuide, './tools/inspect-evidence.sh');
    _requireContent(workflowGuide, 'Recommended default Gitflow');
    _requireContent(workflowGuide, 'feature/*');
    _requireContent(workflowGuide, 'release/*');
    _requireContent(workflowGuide, 'hotfix/*');
  }

  static void _validateGeneratedContractModelSurface(String projectDir) {
    final codingStandards = _readRequiredFile(
      projectDir,
      'docs/02-coding-standards.md',
    );

    _requireContent(
      codingStandards,
      'raw data shape, defaults, and invariants that define the transport contract stay on the contract class',
    );
    _requireContent(
      codingStandards,
      'pure convenience, serialization, and formatting helpers may stay in extensions',
    );
    _forbidContent(
      codingStandards,
      'invariants and value behavior live on the contract class',
    );

    _requireContent(
      _readRequiredFile(projectDir, 'lib/core/contracts/app_response.dart'),
      'extension AppResponseX',
    );
    _requireContent(
      _readRequiredFile(
        projectDir,
        'lib/core/contracts/app_list_response.dart',
      ),
      'extension AppListResponseX',
    );
    _requireContent(
      _readRequiredFile(projectDir, 'lib/core/contracts/localized_text.dart'),
      'extension LocalizedTextX',
    );
    final pagination = _readRequiredFile(
      projectDir,
      'lib/core/contracts/pagination.dart',
    );
    _requireContent(pagination, 'extension PaginationRequestX');
    _requireContent(pagination, 'extension PaginatedResponseX');
  }

  static void _validateGeneratedVerifySurface(String projectDir) {
    final config = _readRequiredYamlMap(projectDir, '.info/agentic.yaml');
    final dartTestConfig = _readRequiredFile(projectDir, 'dart_test.yaml');
    final verifyScript = _readRequiredFile(projectDir, 'tools/verify.sh');
    final appSmokeTest = _readRequiredFile(
      projectDir,
      'test/app_smoke_test.dart',
    );

    _requireContent(dartTestConfig, 'app-smoke');
    _requireContent(verifyScript, '--exclude-tags app-smoke');
    _requireContent(verifyScript, 'runtime-telemetry');
    _requireContent(verifyScript, 'AGENTIC_RUNTIME_TELEMETRY_CONTEXT_FILE');
    _requireContent(verifyScript, 'test/app_smoke_test.dart');
    _requireContent(appSmokeTest, 'app-smoke');

    final harness = _requireYamlMap(config, 'harness');
    final appProfile = _requireYamlMap(harness, 'app_profile');
    final primaryProfile = appProfile['primary_profile']?.toString();
    final capabilities =
        (_requireYamlMap(harness, 'capabilities')['enabled'] as YamlList)
            .map((value) => value.toString())
            .toSet();

    switch (primaryProfile) {
      case 'consumer-app':
        _requireContent(verifyScript, 'starter-journey');
        _requireContent(
          verifyScript,
          'test/features/home/presentation/widgets/starter_journey_signal_card_test.dart',
        );
      case 'internal-business-app':
        _requireContent(verifyScript, 'starter-settings');
        _requireContent(
          verifyScript,
          'test/features/home/presentation/widgets/starter_settings_preview_card_test.dart',
        );
      case 'subscription-commerce-app':
        if (capabilities.any(
          (capability) => const {
            'payments',
            'remote_config',
            'feature_flags',
            'ads',
          }.contains(capability),
        )) {
          _requireContent(verifyScript, 'starter-commerce');
          _requireContent(
            verifyScript,
            'test/features/home/presentation/widgets/starter_monetization_overview_card_test.dart',
          );
        }
      case 'content-community-app':
      case 'offline-first-field-app':
        _requireContent(verifyScript, 'profile-advisory');
      case null:
        break;
    }
  }

  static void _validateThemeSurface(String projectDir) {
    final pubspec = _readRequiredFile(projectDir, 'pubspec.yaml');
    final appTheme = _readRequiredFile(
      projectDir,
      'lib/core/theme/app_theme.dart',
    );
    final colorSchemes = _readRequiredFile(
      projectDir,
      'lib/core/theme/color_schemes.dart',
    );
    final typography = _readRequiredFile(
      projectDir,
      'lib/core/theme/typography.dart',
    );
    final contextExtensions = _readRequiredFile(
      projectDir,
      'lib/core/extensions/context_extensions.dart',
    );
    final themingGuide = _readRequiredFile(
      projectDir,
      'docs/05-theming-guide.md',
    );

    _forbidContent(pubspec, 'flutter_screenutil:');
    _requireContent(pubspec, 'google_fonts:');
    _requireContent(appTheme, 'ThemeData.from(');
    _requireContent(colorSchemes, 'static const light = ColorScheme(');
    _requireContent(colorSchemes, 'static const dark = ColorScheme(');
    _requireContent(colorSchemes, 'primaryFixed:');
    _forbidContent(colorSchemes, 'ColorScheme.fromSeed(');
    _requireContent(typography, 'GoogleFonts.lexendTextTheme');
    _requireContent(typography, 'GoogleFonts.sourceSans3TextTheme');
    _requireContent(contextExtensions, 'adaptivePagePadding');
    _requireContent(themingGuide, 'BuildContextX');
    _forbidPath(projectDir, 'lib/core/responsive/app_screen_util_init.dart');
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
      'credential-setup',
    );
    _requireContent(
      _readRequiredFile(projectDir, 'tools/release-preflight.sh'),
      'UploadReady',
    );
    _requireContent(
      _readRequiredFile(projectDir, 'tools/release.sh'),
      'AwaitingFinalPublishApproval',
    );
    _requireContent(
      _readRequiredFile(projectDir, 'tools/verify.sh'),
      'app-shell-smoke',
    );
    _requireContent(
      _readRequiredFile(projectDir, 'tools/_common.sh'),
      'summary.json',
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

  static bool _looksLikeSecret(String value) {
    return RegExp(
      '(secret|token|apikey|api_key|-----BEGIN|AIza|AKIA|sk_live|sk_test)',
      caseSensitive: false,
    ).hasMatch(value);
  }

  static bool _containsSecretLikeValue(dynamic value) {
    if (value is String) {
      return _looksLikeSecret(value);
    }
    if (value is YamlMap) {
      for (final entry in value.entries) {
        if (_containsSecretLikeValue(entry.value)) {
          return true;
        }
      }
      return false;
    }
    if (value is YamlList) {
      for (final entry in value) {
        if (_containsSecretLikeValue(entry)) {
          return true;
        }
      }
      return false;
    }
    return false;
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
