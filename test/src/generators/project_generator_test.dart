import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/generators/feature_generator.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future<void> seedRequiredContractFiles(String projectDir) async {
  for (final path in GeneratedProjectContract.requiredPaths) {
    final file = File(p.join(projectDir, path));
    await file.parent.create(recursive: true);
    await file.writeAsString('ok');
  }
}

void main() {
  group('GeneratedProjectContract', () {
    test('buildAppIdBase normalizes project names into valid ids', () {
      final appId = GeneratedProjectContract.buildAppIdBase(
        org: 'com.example',
        projectName: 'starter_contract_app',
      );

      expect(appId, equals('com.example.startercontractapp'));
    });

    test('buildAppIdBase rejects invalid normalized ids', () {
      expect(
        () => GeneratedProjectContract.buildAppIdBase(
          org: 'com.Example',
          projectName: 'starter_contract_app',
        ),
        throwsA(isA<ProjectGenerationException>()),
      );
    });

    test(
      'cleanupForbiddenOutputs removes duplicate shell files and IDEA noise',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-cleanup-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final forbiddenFiles = [
          'lib/app.dart',
          'lib/flavors.dart',
          '.idea/modules.xml',
          '.idea/runConfigurations/main_dart.xml',
          '.idea/workspace.xml',
        ];
        for (final path in forbiddenFiles) {
          final file = File(p.join(tempDir.path, path));
          await file.parent.create(recursive: true);
          await file.writeAsString('stale');
        }

        final forbiddenDir = Directory(p.join(tempDir.path, 'lib/pages'));
        await forbiddenDir.create(recursive: true);
        await File(
          p.join(forbiddenDir.path, 'my_home_page.dart'),
        ).writeAsString(
          'stale',
        );

        GeneratedProjectContract.cleanupForbiddenOutputs(tempDir.path);

        for (final path in forbiddenFiles) {
          expect(File(p.join(tempDir.path, path)).existsSync(), isFalse);
        }
        expect(forbiddenDir.existsSync(), isFalse);
      },
    );

    test('deleteGeneratedI18nOutputs removes generated slang files', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'generated-project-contract-i18n-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      for (final path in GeneratedProjectContract.generatedI18nFiles) {
        final file = File(p.join(tempDir.path, path));
        await file.parent.create(recursive: true);
        await file.writeAsString('generated');
      }

      GeneratedProjectContract.deleteGeneratedI18nOutputs(tempDir.path);

      for (final path in GeneratedProjectContract.generatedI18nFiles) {
        expect(File(p.join(tempDir.path, path)).existsSync(), isFalse);
      }
      expect(
        Directory(p.join(tempDir.path, 'lib/app/i18n')).existsSync(),
        isFalse,
      );
    });

    test('validate enforces required files and forbidden leftovers', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'generated-project-contract-validate-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await seedRequiredContractFiles(tempDir.path);

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        returnsNormally,
      );

      await File(p.join(tempDir.path, 'lib/app.dart')).create(recursive: true);

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        throwsA(isA<ProjectGenerationException>()),
      );
    });

    test(
      'validate enforces Android flavor wiring when android output exists',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-android-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await seedRequiredContractFiles(tempDir.path);
        await Directory(p.join(tempDir.path, 'android/app')).create(
          recursive: true,
        );
        await File(
          p.join(tempDir.path, 'android/app/build.gradle.kts'),
        ).writeAsString('// missing flavorizr import');

        expect(
          () => GeneratedProjectContract.validate(tempDir.path),
          throwsA(isA<ProjectGenerationException>()),
        );

        await File(
          p.join(tempDir.path, 'android/app/flavorizr.gradle.kts'),
        ).writeAsString('flavors');
        await File(
          p.join(tempDir.path, 'android/app/build.gradle.kts'),
        ).writeAsString('apply { from("flavorizr.gradle.kts") }');

        expect(
          () => GeneratedProjectContract.validate(tempDir.path),
          returnsNormally,
        );
      },
    );

    test(
      'validate enforces iOS flavor schemes when ios output exists',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-ios-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await seedRequiredContractFiles(tempDir.path);
        await Directory(p.join(tempDir.path, 'ios/Flutter')).create(
          recursive: true,
        );
        await Directory(
          p.join(
            tempDir.path,
            'ios/Runner.xcodeproj/xcshareddata/xcschemes',
          ),
        ).create(recursive: true);

        for (final flavor in GeneratedProjectContract.generatedFlavors) {
          for (final mode in ['Debug', 'Profile', 'Release']) {
            await File(
              p.join(tempDir.path, 'ios/Flutter/$flavor$mode.xcconfig'),
            ).writeAsString('ok');
          }
        }

        expect(
          () => GeneratedProjectContract.validate(tempDir.path),
          throwsA(isA<ProjectGenerationException>()),
        );

        for (final flavor in GeneratedProjectContract.generatedFlavors) {
          await File(
            p.join(
              tempDir.path,
              'ios/Runner.xcodeproj/xcshareddata/xcschemes/$flavor.xcscheme',
            ),
          ).writeAsString('ok');
          await Directory(
            p.join(
              tempDir.path,
              'ios/Runner/Assets.xcassets/${flavor}AppIcon.appiconset',
            ),
          ).create(recursive: true);
          await Directory(
            p.join(
              tempDir.path,
              'ios/Runner/Assets.xcassets/${flavor}LaunchImage.imageset',
            ),
          ).create(recursive: true);
        }

        expect(
          () => GeneratedProjectContract.validate(tempDir.path),
          returnsNormally,
        );
      },
    );

    test(
      'enforceCiProviderOutputs removes the opposite provider files',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-provider-cleanup-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        for (final path in [
          '.github/workflows/ci.yml',
          '.github/workflows/cd-dev.yml',
          '.github/workflows/cd-staging.yml',
          '.github/workflows/cd-prod.yml',
          '.github/workflows/release.yml',
          '.gitlab-ci.yml',
          '.gitlab/ci/verify.yml',
          '.gitlab/ci/deploy.yml',
        ]) {
          final file = File(p.join(tempDir.path, path));
          await file.parent.create(recursive: true);
          await file.writeAsString('placeholder');
        }

        GeneratedProjectContract.enforceCiProviderOutputs(
          tempDir.path,
          ciProvider: CiProvider.gitlab,
        );

        expect(
          Directory(p.join(tempDir.path, '.github')).existsSync(),
          isFalse,
        );
        expect(
          File(p.join(tempDir.path, '.gitlab-ci.yml')).existsSync(),
          isTrue,
        );
      },
    );

    test('validate checks provider-exclusive CI contract', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'generated-project-contract-provider-validate-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await seedRequiredContractFiles(tempDir.path);

      for (final path in [
        '.gitlab-ci.yml',
        '.gitlab/ci/verify.yml',
        '.gitlab/ci/deploy.yml',
      ]) {
        final file = File(p.join(tempDir.path, path));
        await file.parent.create(recursive: true);
      }

      await File(
        p.join(tempDir.path, '.gitlab-ci.yml'),
      ).writeAsString(
        'include:\n  - local: .gitlab/ci/verify.yml\n  - local: .gitlab/ci/deploy.yml\n',
      );
      await File(
        p.join(tempDir.path, '.gitlab/ci/verify.yml'),
      ).writeAsString(
        'native_validate:\n  tags: [macos]\n  script:\n    - ./tools/ci-check.sh\n',
      );
      await File(
        p.join(tempDir.path, '.gitlab/ci/deploy.yml'),
      ).writeAsString(
        'deploy_dev:\n  when: manual\n  script:\n    - ./tools/build.sh dev\n'
        'deploy_staging:\n  when: manual\n  script:\n    - ./tools/build.sh staging\n'
        'deploy_prod:\n  when: manual\n  script:\n    - ./tools/build.sh prod\n',
      );

      expect(
        () => GeneratedProjectContract.validate(
          tempDir.path,
          ciProvider: CiProvider.gitlab,
        ),
        returnsNormally,
      );

      await File(
        p.join(tempDir.path, '.github/workflows/ci.yml'),
      ).create(recursive: true);

      expect(
        () => GeneratedProjectContract.validate(
          tempDir.path,
          ciProvider: CiProvider.gitlab,
        ),
        throwsA(isA<ProjectGenerationException>()),
      );
    });
  });

  group('FeatureGenerator', () {
    test('generates centralized i18n stubs for new features', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'feature-generator-i18n-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await FeatureGenerator(logger: AgenticLogger()).generate(
        featureName: 'user_profile',
        projectPath: tempDir.path,
        projectName: 'demo_app',
        stateManagement: 'cubit',
      );

      expect(
        File(
          p.join(
            tempDir.path,
            'assets/i18n/user_profile/userProfile_en.i18n.yaml',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(
            tempDir.path,
            'assets/i18n/user_profile/userProfile_vi.i18n.yaml',
          ),
        ).existsSync(),
        isTrue,
      );
    });

    test('generates riverpod presentation files without cubit output', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'feature-generator-riverpod-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await FeatureGenerator(logger: AgenticLogger()).generate(
        featureName: 'user_profile',
        projectPath: tempDir.path,
        projectName: 'demo_app',
        stateManagement: 'riverpod',
      );

      expect(
        File(
          p.join(
            tempDir.path,
            'lib/features/user_profile/presentation/controller/user_profile_controller.dart',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(
            tempDir.path,
            'lib/features/user_profile/presentation/cubit/user_profile_cubit.dart',
          ),
        ).existsSync(),
        isFalse,
      );
    });

    test('generates mobx presentation files without cubit output', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'feature-generator-mobx-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await FeatureGenerator(logger: AgenticLogger()).generate(
        featureName: 'user_profile',
        projectPath: tempDir.path,
        projectName: 'demo_app',
        stateManagement: 'mobx',
      );

      expect(
        File(
          p.join(
            tempDir.path,
            'lib/features/user_profile/presentation/store/user_profile_store.dart',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(
            tempDir.path,
            'lib/features/user_profile/presentation/cubit/user_profile_cubit.dart',
          ),
        ).existsSync(),
        isFalse,
      );
    });
  });
}
