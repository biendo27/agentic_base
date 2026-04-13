import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:path/path.dart' as p;

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
    'build.yaml',
    'flavorizr.yaml',
    'assets/i18n/app/app_en.i18n.yaml',
    'assets/i18n/app/app_vi.i18n.yaml',
    'assets/i18n/home/home_en.i18n.yaml',
    'assets/i18n/home/home_vi.i18n.yaml',
    'env/dev.env.example',
    'env/staging.env.example',
    'env/prod.env.example',
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

    validateNativeFlavorOutputs(projectDir);
    if (ciProvider != null) {
      validateCiProviderOutputs(projectDir, ciProvider: ciProvider);
    }
    if (stateManagement != null) {
      validateStateOutput(projectDir, stateManagement: stateManagement);
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
    if (Directory(_resolveProjectPath(projectDir, 'android')).existsSync()) {
      _validateAndroidFlavorOutputs(projectDir);
    }

    if (Directory(_resolveProjectPath(projectDir, 'ios')).existsSync()) {
      _validateIosFlavorOutputs(projectDir);
    }

    if (Directory(_resolveProjectPath(projectDir, 'macos')).existsSync()) {
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
    if (!ciContents.contains('./tools/ci-check.sh')) {
      throw const ProjectGenerationException(
        'GitHub CI workflow must call ./tools/ci-check.sh.',
      );
    }

    for (final flavor in generatedFlavors) {
      final workflowContents = _readRequiredFile(
        projectDir,
        '.github/workflows/cd-$flavor.yml',
      );
      if (!workflowContents.contains('./tools/build.sh $flavor')) {
        throw ProjectGenerationException(
          'GitHub deploy workflow must call ./tools/build.sh $flavor.',
        );
      }
    }
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
        !verifyContents.contains('./tools/ci-check.sh') ||
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
    for (final flavor in generatedFlavors) {
      if (!deployContents.contains('deploy_$flavor:') ||
          !deployContents.contains('./tools/build.sh $flavor')) {
        throw ProjectGenerationException(
          'GitLab deploy contract must define deploy_$flavor.',
        );
      }
    }

    if (!deployContents.contains('when: manual')) {
      throw const ProjectGenerationException(
        'GitLab deploy jobs must remain manual.',
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
