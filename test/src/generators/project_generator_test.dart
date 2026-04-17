import 'dart:io';

import 'package:agentic_base/src/config/agent_ready_repo_contract.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/generators/feature_generator.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future<void> seedRequiredContractFiles(
  String projectDir, {
  String stateManagement = 'cubit',
}) async {
  const appId = 'com.example.demoapp';
  final stateSurface = switch (stateManagement) {
    'cubit' => (
      testPath: 'test/features/home/home_cubit_test.dart',
      presentationPath: 'lib/features/home/presentation/cubit/home_cubit.dart',
      pubspec:
          'name: demo_app\n'
          'dependencies:\n'
          '  flutter:\n'
          '    sdk: flutter\n'
          '  flutter_bloc: ^9.1.1\n'
          '  fpdart: ^1.1.1\n'
          '  get_it: ^9.2.1\n'
          '  injectable: ^2.7.1\n',
      bootstrap: 'Bloc.observer\n',
      injection: 'GetIt\n',
    ),
    'riverpod' => (
      testPath: 'test/features/home/home_controller_test.dart',
      presentationPath:
          'lib/features/home/presentation/controller/home_controller.dart',
      pubspec:
          'name: demo_app\n'
          'dependencies:\n'
          '  flutter:\n'
          '    sdk: flutter\n'
          '  fpdart: ^1.1.1\n'
          '  flutter_riverpod: ^3.3.1\n',
      bootstrap: 'UncontrolledProviderScope\n',
      injection: '// riverpod does not use GetIt\n',
    ),
    'mobx' => (
      testPath: 'test/features/home/home_store_test.dart',
      presentationPath: 'lib/features/home/presentation/store/home_store.dart',
      pubspec:
          'name: demo_app\n'
          'dependencies:\n'
          '  flutter:\n'
          '    sdk: flutter\n'
          '  flutter_mobx: ^2.2.1\n'
          '  fpdart: ^1.1.1\n'
          '  get_it: ^9.2.1\n'
          '  injectable: ^2.7.1\n'
          '  mobx: ^2.4.0\n',
      bootstrap: '// mobx bootstrap\n',
      injection: 'GetIt\n',
    ),
    _ =>
      throw ArgumentError.value(
        stateManagement,
        'stateManagement',
        'Unsupported state management',
      ),
  };
  final seededContent = <String, String>{
    '.info/agentic.yaml': '''
schema_version: 3
project_kind: agent_ready_flutter_repo
tool_version: 0.1.0
project_name: demo_app
org: com.example
ci_provider: github
state_management: $stateManagement
platforms:
  - android
  - ios
  - web
flavors:
  - dev
  - staging
  - prod
modules: []
context:
  canonical_docs:
${canonicalContextDocs.map((doc) => '    - $doc').join('\n')}
  thin_adapters:
${thinAdapterFiles.map((doc) => '    - $doc').join('\n')}
  state_runtime: $stateManagement
  ci_provider: github
execution:
  setup: ./tools/setup.sh
  run: ./tools/run-dev.sh
  test: ./tools/test.sh
  verify: ./tools/verify.sh
  build: ./tools/build.sh
  release_preflight: ./tools/release-preflight.sh
  release: ./tools/release.sh
  default_run_flavor: dev
checkpoints:
  requires_human:
    - product-decisions
    - credential-setup
    - final-store-publish-approval
  release_human_boundary: Agents prepare and upload; humans approve the final store publish.
ownership:
  generator_owned:
    - AGENTS.md
  human_owned:
    - lib/features/
harness:
  contract_version: 1
  app_profile:
    primary_profile: consumer-app
    secondary_traits: []
  capabilities:
    enabled: []
  providers: {}
  eval:
    evidence_dir: artifacts/evidence
    quality_dimensions:
      - correctness
      - release_readiness
      - observability
      - ux_confidence
  approvals:
    pause_on:
      - product-decisions
      - credential-setup
      - final-store-publish-approval
  sdk:
    manager: system
    channel: stable
    version: 3.29.0
    policy: newest_tested
''',
    'AGENTS.md':
        'Thin adapter\n./tools/verify.sh\ndocs/07-agentic-development-flow.md\nHarness Contract: `v1`\nEvidence directory: `artifacts/evidence`\nRecommended default Gitflow\n',
    'CLAUDE.md':
        'Thin Claude adapter\nMachine contract: `.info/agentic.yaml`\nHarness Contract: `v1`\nSupport tier:\ndocs/07-agentic-development-flow.md\nRecommended default Gitflow\n',
    'README.md':
        'An agent-ready Flutter repository\nPrimary profile: `consumer-app`\nSupport tier: `Tier 1`\nEvidence directory: `artifacts/evidence`\n./tools/test.sh\n./tools/run-dev.sh\ndocs/07-agentic-development-flow.md\nRecommended default Gitflow\nfinal production store publish remains a human approval step\n',
    'docs/02-coding-standards.md':
        'raw data shape, defaults, and invariants that define the transport contract stay on the contract class\n'
        'pure convenience, serialization, and formatting helpers may stay in extensions when they depend only on the contract value and keep the Freezed model smaller\n'
        'locale-, DI-, or app-runtime-aware convenience belongs in extensions or services outside raw contracts\n',
    'docs/06-testing-guide.md':
        './tools/test.sh\n./tools/verify.sh\nmake test\napp-shell-smoke\n',
    'docs/07-agentic-development-flow.md':
        '.info/agentic.yaml\n./tools/verify.sh\nRecommended default Gitflow\nfeature/*\nrelease/*\nhotfix/*\n',
    'tools/_common.sh': 'summary.json\n',
    'lib/core/contracts/app_response.dart':
        'abstract class AppResponse<T>\nextension AppResponseX<T> on AppResponse<T> {}\n',
    'lib/core/contracts/app_list_response.dart':
        'abstract class AppListResponse<T>\nextension AppListResponseX<T> on AppListResponse<T> {}\n',
    'lib/core/contracts/localized_text.dart':
        'abstract class LocalizedText\nextension LocalizedTextX on LocalizedText {}\n',
    'lib/core/contracts/pagination.dart':
        'extension PaginationRequestX<T extends JsonRequestFilter> on PaginationRequest<T> {}\n'
        'extension PaginatedResponseX<T> on PaginatedResponse<T> {}\n',
    'lib/app/bootstrap.dart': stateSurface.bootstrap,
    'lib/core/di/injection.dart': stateSurface.injection,
    stateSurface.presentationPath: 'ok',
    'tools/release-preflight.sh': 'credential-setup\nUploadReady\n',
    'tools/release.sh': 'AwaitingFinalPublishApproval\n',
    'tools/verify.sh':
        '--exclude-tags app-smoke\napp-shell-smoke\ntest/app_smoke_test.dart\n',
    'test/app_smoke_test.dart':
        "group('app shell smoke', tags: const ['app-smoke'], () {})\n",
    'pubspec.yaml': stateSurface.pubspec,
    stateSurface.testPath: 'ok',
    'lib/core/theme/app_theme.dart': 'ThemeData.from(\n',
    'lib/core/theme/color_schemes.dart':
        'static const light = ColorScheme(\n'
        'static const dark = ColorScheme(\n'
        'primaryFixed:\n',
    'lib/core/extensions/context_extensions.dart': 'adaptivePagePadding\n',
    'docs/05-theming-guide.md': 'BuildContextX\n',
    '.github/workflows/ci.yml':
        r'./tools/verify.sh ${{ github.workflow }}-${{ github.ref }} ./tools/build.sh ${{ matrix.flavor }} actions/upload-artifact@v4 flutter-version:',
    '.github/workflows/cd-dev.yml': './tools/release.sh dev firebase\n',
    '.github/workflows/cd-staging.yml':
        './tools/release.sh staging play-internal\n./tools/release.sh staging testflight\n',
    '.github/workflows/cd-prod.yml':
        './tools/release.sh prod play-production\n./tools/release.sh prod app-store\n',
    '.github/workflows/release.yml':
        './tools/release-preflight.sh prod play-production\n./tools/build.sh prod appbundle\n',
    'ios/fastlane/Appfile': appId,
    'ios/fastlane/Matchfile': appId,
    'android/fastlane/Appfile': appId,
  };

  for (final path in GeneratedProjectContract.requiredPaths) {
    final file = File(p.join(projectDir, path));
    await file.parent.create(recursive: true);
    await file.writeAsString(seededContent[path] ?? 'ok');
  }

  for (final entry in seededContent.entries) {
    final file = File(p.join(projectDir, entry.key));
    await file.parent.create(recursive: true);
    await file.writeAsString(entry.value);
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

    test('validate rejects seed-derived theme surfaces', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'generated-project-contract-seed-theme-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await seedRequiredContractFiles(tempDir.path);
      await File(
        p.join(tempDir.path, 'lib/core/theme/color_schemes.dart'),
      ).writeAsString('ColorScheme.fromSeed(\n');

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        throwsA(isA<ProjectGenerationException>()),
      );
    });

    test('validate rejects legacy screenutil theme leftovers', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'generated-project-contract-theme-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await seedRequiredContractFiles(tempDir.path);

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        returnsNormally,
      );

      await File(p.join(tempDir.path, 'pubspec.yaml')).writeAsString(
        'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n  flutter_screenutil: ^5.9.3\n',
      );

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        throwsA(isA<ProjectGenerationException>()),
      );
    });

    test('validate requires starter verification test surfaces', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'generated-project-contract-test-matrix-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await seedRequiredContractFiles(tempDir.path);

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        returnsNormally,
      );

      await File(
        p.join(
          tempDir.path,
          'test/features/home/data/repositories/home_repository_impl_test.dart',
        ),
      ).delete();

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        throwsA(isA<ProjectGenerationException>()),
      );
    });

    test('validate rejects stale generated contract helper guidance', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'generated-project-contract-helper-policy-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await seedRequiredContractFiles(tempDir.path);
      await File(
        p.join(tempDir.path, 'docs/02-coding-standards.md'),
      ).writeAsString(
        'invariants and value behavior live on the contract class\n',
      );

      expect(
        () => GeneratedProjectContract.validate(tempDir.path),
        throwsA(isA<ProjectGenerationException>()),
      );
    });

    test(
      'validate rejects testing guides that reintroduce bare flutter test',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-testing-guide-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await seedRequiredContractFiles(tempDir.path);
        await File(
          p.join(tempDir.path, 'docs/06-testing-guide.md'),
        ).writeAsString('./tools/test.sh\nflutter test\n');

        expect(
          () => GeneratedProjectContract.validate(tempDir.path),
          throwsA(isA<ProjectGenerationException>()),
        );
      },
    );

    test(
      'validate rejects verify surfaces that double-run app smoke without tag separation',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-verify-surface-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await seedRequiredContractFiles(tempDir.path);
        await File(
          p.join(tempDir.path, 'tools/verify.sh'),
        ).writeAsString('app-shell-smoke\ntest/app_smoke_test.dart\n');

        expect(
          () => GeneratedProjectContract.validate(tempDir.path),
          throwsA(isA<ProjectGenerationException>()),
        );
      },
    );

    test(
      'validateStateOutput requires only the active state test surface',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-state-cubit-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await seedRequiredContractFiles(tempDir.path);

        expect(
          () => GeneratedProjectContract.validate(
            tempDir.path,
            stateManagement: 'cubit',
          ),
          returnsNormally,
        );

        await File(
          p.join(tempDir.path, 'test/features/home/home_cubit_test.dart'),
        ).delete();

        expect(
          () => GeneratedProjectContract.validate(
            tempDir.path,
            stateManagement: 'cubit',
          ),
          throwsA(isA<ProjectGenerationException>()),
        );
      },
    );

    test(
      'validateFeatureHost requires shared full-feature contracts but skips simple mode',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'generated-project-contract-feature-host-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        AgenticConfig.createInitial(
          projectPath: tempDir.path,
          projectName: 'demo_app',
          org: 'com.example',
          stateManagement: 'cubit',
          platforms: const ['android', 'ios'],
          flavors: const ['dev', 'staging', 'prod'],
          toolVersion: 'test',
        );
        await File(
          p.join(tempDir.path, 'pubspec.yaml'),
        ).writeAsString(
          'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
        );
        await File(
          p.join(tempDir.path, 'lib/core/error/failures.dart'),
        ).create(recursive: true);

        expect(
          () => GeneratedProjectContract.validateFeatureHost(tempDir.path),
          throwsA(isA<ProjectGenerationException>()),
        );
        expect(
          () => GeneratedProjectContract.validateFeatureHost(
            tempDir.path,
            simple: true,
          ),
          returnsNormally,
        );

        await File(
          p.join(tempDir.path, 'lib/core/contracts/app_result.dart'),
        ).create(recursive: true);
        await File(
          p.join(tempDir.path, 'lib/core/error/error_handler.dart'),
        ).create(recursive: true);
        await File(
          p.join(tempDir.path, 'lib/core/router/app_router.dart'),
        ).create(recursive: true);
        await File(
          p.join(tempDir.path, 'pubspec.yaml'),
        ).writeAsString(
          'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n  fpdart: ^1.1.1\n',
        );

        expect(
          () => GeneratedProjectContract.validateFeatureHost(tempDir.path),
          returnsNormally,
        );
      },
    );

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
      await File(
        p.join(tempDir.path, '.info/agentic.yaml'),
      ).writeAsString(
        File(
              p.join(tempDir.path, '.info/agentic.yaml'),
            )
            .readAsStringSync()
            .replaceAll('ci_provider: github', 'ci_provider: gitlab')
            .replaceAll(
              '  ci_provider: github',
              '  ci_provider: gitlab',
            ),
      );

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
        'native_validate:\n  tags: [macos]\n  script:\n    - ./tools/verify.sh\n  artifacts:\n    when: always\n    paths:\n      - artifacts/evidence\n',
      );
      await File(
        p.join(tempDir.path, '.gitlab/ci/deploy.yml'),
      ).writeAsString(
        '.deploy_template:\n  when: manual\n  artifacts:\n    when: always\n    paths:\n      - artifacts/evidence\n'
        'deploy_dev:\n  script:\n    - ./tools/release.sh dev firebase\n'
        'deploy_staging_android_internal:\n  script:\n    - ./tools/release.sh staging play-internal\n'
        'deploy_staging_testflight:\n  script:\n    - ./tools/release.sh staging testflight\n'
        'deploy_prod_play:\n  script:\n    - ./tools/release.sh prod play-production\n'
        'deploy_prod_app_store:\n  script:\n    - ./tools/release.sh prod app-store\n',
      );
      await Directory(p.join(tempDir.path, '.github')).delete(recursive: true);

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
      final repository =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/data/repositories/user_profile_repository_impl.dart',
            ),
          ).readAsStringSync();
      final controller =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/presentation/controller/user_profile_controller.dart',
            ),
          ).readAsStringSync();

      expect(repository, contains('core/contracts/app_result.dart'));
      expect(repository, contains('ErrorHandler.handle(error)'));
      expect(controller, contains('result.match('));
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
      final repository =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/data/repositories/user_profile_repository_impl.dart',
            ),
          ).readAsStringSync();
      final store =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/presentation/store/user_profile_store.dart',
            ),
          ).readAsStringSync();

      expect(repository, contains('core/contracts/app_result.dart'));
      expect(repository, contains('ErrorHandler.handle(error)'));
      expect(store, contains('result.match('));
    });

    test('generates shared app-result boundaries for full features', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'feature-generator-contracts-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await FeatureGenerator(logger: AgenticLogger()).generate(
        featureName: 'user_profile',
        projectPath: tempDir.path,
        projectName: 'demo_app',
        stateManagement: 'cubit',
      );

      final repository =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/domain/repositories/user_profile_repository.dart',
            ),
          ).readAsStringSync();
      final useCase =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/domain/usecases/get_user_profile.dart',
            ),
          ).readAsStringSync();
      final cubit =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/presentation/cubit/user_profile_cubit.dart',
            ),
          ).readAsStringSync();
      final repositoryImpl =
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/data/repositories/user_profile_repository_impl.dart',
            ),
          ).readAsStringSync();

      expect(repository, contains('core/contracts/app_result.dart'));
      expect(
        repository,
        contains(
          'Future<AppResult<List<UserProfileEntity>>> getAll();',
        ),
      );
      expect(
        useCase,
        contains(
          'Future<AppResult<List<UserProfileEntity>>> call() =>',
        ),
      );
      expect(repositoryImpl, contains('ErrorHandler.handle(error)'));
      expect(cubit, contains('result.match('));
    });

    test(
      'writes spec-driven route and contract surfaces when a router exists',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'feature-generator-router-sync-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final routerFile = File(
          p.join(tempDir.path, 'lib/core/router/app_router.dart'),
        );
        await routerFile.create(recursive: true);
        await routerFile.writeAsString('''
import 'package:auto_route/auto_route.dart';
import 'package:demo_app/core/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
      ];
}
''');

        await FeatureGenerator(logger: AgenticLogger()).generate(
          featureName: 'user_profile',
          projectPath: tempDir.path,
          projectName: 'demo_app',
          stateManagement: 'cubit',
        );

        expect(
          routerFile.readAsStringSync(),
          contains('AutoRoute(page: UserProfileRoute.page),'),
        );
        expect(
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/user_profile_spec.dart',
            ),
          ).readAsStringSync(),
          contains('UserProfileFeatureSpec'),
        );
        expect(
          File(
            p.join(
              tempDir.path,
              'test/features/user_profile/user_profile_spec_contract_test.dart',
            ),
          ).existsSync(),
          isTrue,
        );
        final generatedPage =
            File(
              p.join(
                tempDir.path,
                'lib/features/user_profile/presentation/pages/user_profile_page.dart',
              ),
            ).readAsStringSync();
        expect(generatedPage, contains('UserProfileFeatureSpec.description'));
        expect(
          generatedPage,
          contains('UserProfileFeatureSpec.acceptanceCriteria'),
        );
        expect(generatedPage, contains('UserProfileFeatureSpec.edgeCases'));
        expect(generatedPage, contains('Acceptance criteria'));
      },
    );
  });
}
