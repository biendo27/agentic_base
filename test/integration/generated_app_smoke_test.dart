import 'dart:convert';
import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/generators/project_generator.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

bool _isFlutterAvailable() {
  try {
    return Process.runSync('flutter', ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

Future<String> _generateStarterApp({
  required String repoRoot,
  required Directory tempDir,
  required String appName,
  String stateManagement = 'cubit',
  CiProvider ciProvider = CiProvider.github,
  HarnessAppProfile appProfile = HarnessAppProfile.consumerApp,
  List<String>? modules,
}) async {
  final appDir = p.join(tempDir.path, appName);
  final previousCurrent = Directory.current.path;
  Directory.current = repoRoot;
  try {
    await ProjectGenerator(logger: AgenticLogger()).generate(
      projectName: appName,
      outputDirectory: appDir,
      org: 'com.example',
      platforms: const ['android', 'ios', 'web'],
      stateManagement: stateManagement,
      flavors: GeneratedProjectContract.generatedFlavors,
      ciProvider: ciProvider,
      appProfile: appProfile,
      flutterSdkManager: FlutterSdkManager.system,
      modules: modules,
      runVerify: false,
    );
  } finally {
    Directory.current = previousCurrent;
  }

  return appDir;
}

Future<void> _runGeneratedVerify(String appDir) async {
  final process = await Process.start(
    'bash',
    ['tools/verify.sh'],
    workingDirectory: appDir,
    environment: {
      ...Platform.environment,
      'AGENTIC_VERIFY_FAST': '1',
      'AGENTIC_SKIP_NATIVE_READINESS': '1',
    },
  );

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();
  final stdoutDone = process.stdout.transform(utf8.decoder).forEach((chunk) {
    stdoutBuffer.write(chunk);
    stdout.write(chunk);
  });
  final stderrDone = process.stderr.transform(utf8.decoder).forEach((chunk) {
    stderrBuffer.write(chunk);
    stderr.write(chunk);
  });
  final exitCode = await process.exitCode;
  await Future.wait([stdoutDone, stderrDone]);

  var failureDetails = '$stdoutBuffer\n$stderrBuffer'.trim();
  if (exitCode != 0) {
    final verifyRoot = Directory(
      p.join(appDir, 'artifacts', 'evidence', 'verify'),
    );
    if (verifyRoot.existsSync()) {
      final verifyRun = _latestEvidenceRunDirectory(appDir, 'verify');
      final verifyLog = File(p.join(verifyRun.path, 'logs', 'verify.log'));
      if (verifyLog.existsSync()) {
        failureDetails = '$failureDetails\n${verifyLog.readAsStringSync()}'
            .trim();
      }
    }
  }

  expect(
    exitCode,
    equals(0),
    reason: failureDetails,
  );
}

Directory _latestEvidenceRunDirectory(String appDir, String runKind) {
  final runRoot = Directory(p.join(appDir, 'artifacts', 'evidence', runKind));
  final children =
      runRoot.listSync().whereType<Directory>().toList()
        ..sort((left, right) => left.path.compareTo(right.path));
  return children.last;
}

void _expectIosPodfileContains(String appDir, List<String> snippets) {
  final podfile = File(p.join(appDir, 'ios', 'Podfile'));
  if (!podfile.existsSync()) {
    return;
  }

  final podfileContents = podfile.readAsStringSync();
  for (final snippet in snippets) {
    expect(podfileContents, contains(snippet));
  }
}

void _expectStarterRuntimeSurfaces(
  String appDir, {
  required String stateManagement,
}) {
  final errorInterceptor =
      File(
        p.join(
          appDir,
          'lib/core/network/interceptors/error_interceptor.dart',
        ),
      ).readAsStringSync();
  final errorHandler =
      File(
        p.join(appDir, 'lib/core/error/error_handler.dart'),
      ).readAsStringSync();
  final homeRepository =
      File(
        p.join(
          appDir,
          'lib/features/home/data/repositories/home_repository_impl.dart',
        ),
      ).readAsStringSync();
  final generatedPubspec =
      File(p.join(appDir, 'pubspec.yaml')).readAsStringSync();
  final generatedTheme =
      File(
        p.join(appDir, 'lib/core/theme/app_theme.dart'),
      ).readAsStringSync();
  final generatedTypography =
      File(
        p.join(appDir, 'lib/core/theme/typography.dart'),
      ).readAsStringSync();
  final generatedReadme = File(p.join(appDir, 'README.md')).readAsStringSync();
  final agentsAdapter = File(p.join(appDir, 'AGENTS.md')).readAsStringSync();
  final claudeAdapter = File(p.join(appDir, 'CLAUDE.md')).readAsStringSync();
  final contextExtensions =
      File(
        p.join(appDir, 'lib/core/extensions/context_extensions.dart'),
      ).readAsStringSync();
  final themingGuide =
      File(
        p.join(appDir, 'docs/05-theming-guide.md'),
      ).readAsStringSync();
  final starterRuntimeProfile =
      File(
        p.join(appDir, 'lib/core/starter/starter_runtime_profile.dart'),
      ).readAsStringSync();
  final consentService =
      File(
        p.join(appDir, 'lib/core/privacy/consent_service.dart'),
      ).readAsStringSync();
  final entitlementService =
      File(
        p.join(appDir, 'lib/core/commerce/entitlement_service.dart'),
      ).readAsStringSync();
  final testingGuide =
      File(
        p.join(appDir, 'docs/06-testing-guide.md'),
      ).readAsStringSync();
  final workflowGuide =
      File(
        p.join(appDir, 'docs/07-agentic-development-flow.md'),
      ).readAsStringSync();
  final appListResponseContract =
      File(
        p.join(appDir, 'lib/core/contracts/app_list_response.dart'),
      ).readAsStringSync();
  final localizedTextContract =
      File(
        p.join(appDir, 'lib/core/contracts/localized_text.dart'),
      ).readAsStringSync();

  expect(errorInterceptor, contains('ErrorHandler.handle(err)'));
  expect(errorInterceptor, contains('handler.next(mappedError);'));
  expect(
    errorHandler,
    contains('error is DioException && error.error is AppFailure'),
  );
  expect(
    homeRepository,
    contains('return failure(ErrorHandler.handle(error));'),
  );
  expect(generatedPubspec, isNot(contains('flutter_screenutil:')));
  expect(generatedPubspec, contains('google_fonts:'));
  expect(generatedTheme, contains('ThemeData.from('));
  expect(generatedTheme, isNot(contains('ColorScheme.fromSeed(')));
  expect(generatedTypography, contains('GoogleFonts.lexendTextTheme'));
  expect(generatedTypography, contains('GoogleFonts.sourceSans3TextTheme'));
  expect(generatedReadme, contains('./tools/test.sh'));
  expect(
    generatedReadme,
    contains('docs/07-agentic-development-flow.md'),
  );
  expect(generatedReadme, contains('Recommended default Gitflow'));
  expect(agentsAdapter, contains('docs/07-agentic-development-flow.md'));
  expect(agentsAdapter, contains('Recommended default Gitflow'));
  expect(claudeAdapter, contains('docs/07-agentic-development-flow.md'));
  expect(claudeAdapter, contains('Recommended default Gitflow'));
  expect(contextExtensions, contains('adaptivePagePadding'));
  expect(themingGuide, contains('BuildContextX'));
  expect(themingGuide, contains('trustworthy-commerce'));
  expect(starterRuntimeProfile, contains('requiredGatePack'));
  expect(consentService, contains('ConsentService'));
  expect(entitlementService, contains('EntitlementService'));
  expect(testingGuide, contains('./tools/test.sh'));
  expect(testingGuide, contains('make test'));
  expect(testingGuide, isNot(contains('flutter test')));
  expect(workflowGuide, contains('.info/agentic.yaml'));
  expect(workflowGuide, contains('Recommended default Gitflow'));
  expect(appListResponseContract, contains('abstract class AppListResponse'));
  expect(localizedTextContract, contains('abstract class LocalizedText'));
  expect(
    File(
      p.join(appDir, 'lib/core/theme/color_schemes.dart'),
    ).readAsStringSync(),
    allOf(
      contains('static const light = ColorScheme('),
      contains('static const dark = ColorScheme('),
      contains('primaryFixed:'),
    ),
  );
  expect(
    File(
      p.join(appDir, 'lib/core/responsive/app_screen_util_init.dart'),
    ).existsSync(),
    isFalse,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/core/contracts/app_list_response_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/core/contracts/app_response_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/core/contracts/localized_text_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/core/contracts/pagination_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/features/home/presentation/widgets/starter_journey_signal_card_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/features/home/presentation/widgets/starter_settings_preview_card_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/features/home/presentation/widgets/starter_monetization_overview_card_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/features/home/data/repositories/home_repository_impl_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/features/home/data/repositories/demo_starter_monetization_repository_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(
        appDir,
        'test/features/home/presentation/widgets/starter_action_card_test.dart',
      ),
    ).existsSync(),
    isTrue,
  );

  if (stateManagement == 'cubit') {
    expect(
      File(
        p.join(appDir, 'test/features/home/home_cubit_test.dart'),
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        p.join(appDir, 'test/features/home/home_controller_test.dart'),
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        p.join(appDir, 'test/features/home/home_store_test.dart'),
      ).existsSync(),
      isFalse,
    );
    return;
  }

  if (stateManagement == 'riverpod') {
    expect(
      File(
        p.join(appDir, 'test/features/home/home_controller_test.dart'),
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        p.join(appDir, 'test/features/home/home_cubit_test.dart'),
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        p.join(appDir, 'test/features/home/home_store_test.dart'),
      ).existsSync(),
      isFalse,
    );
    return;
  }

  expect(
    File(
      p.join(appDir, 'test/features/home/home_store_test.dart'),
    ).existsSync(),
    isTrue,
  );
  expect(
    File(
      p.join(appDir, 'test/features/home/home_cubit_test.dart'),
    ).existsSync(),
    isFalse,
  );
  expect(
    File(
      p.join(appDir, 'test/features/home/home_controller_test.dart'),
    ).existsSync(),
    isFalse,
  );
}

void main() {
  final flutterAvailable = _isFlutterAvailable();
  // Other test suites temporarily mutate Directory.current, so capture a
  // stable repo root once for all smoke subprocesses.
  final repoRoot = Directory.current.path;
  const smokeTimeout = Timeout(Duration(minutes: 6));
  // The default subscription-commerce lane now installs and verifies a larger
  // golden-path surface than the other starter smoke cases.
  const slowVerifyCanaryTimeout = Timeout(Duration(minutes: 15));
  test(
    'slow verify canary stays blocking for harness, verify, evidence, and profile-surface changes',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'agentic-base-smoke-github-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      const appName = 'smoke_github_app';
      final appDir = await _generateStarterApp(
        repoRoot: repoRoot,
        tempDir: tempDir,
        appName: appName,
        appProfile: HarnessAppProfile.subscriptionCommerceApp,
      );
      await _runGeneratedVerify(appDir);
      expect(Directory(appDir).existsSync(), isTrue);
      expect(
        () => GeneratedProjectContract.validate(
          appDir,
          ciProvider: CiProvider.github,
          stateManagement: 'cubit',
        ),
        returnsNormally,
      );
      final verifySummary =
          File(
            p.join(
              _latestEvidenceRunDirectory(appDir, 'verify').path,
              'summary.json',
            ),
          ).readAsStringSync();
      expect(verifySummary, contains('"run_kind": "verify"'));
      expect(verifySummary, contains('"derived_gate_expectation_id"'));
      expect(verifySummary, contains('"unit-widget"'));
      expect(verifySummary, contains('"app-shell-smoke"'));
      expect(verifySummary, contains('"starter-commerce"'));
      _expectStarterRuntimeSurfaces(appDir, stateManagement: 'cubit');
    },
    tags: const ['slow-canary'],
    skip:
        flutterAvailable
            ? false
            : 'Flutter SDK is required for smoke generation.',
    timeout: slowVerifyCanaryTimeout,
  );

  for (final stateManagement in ['riverpod', 'mobx']) {
    test(
      'create command generates a $stateManagement starter app with no foreign runtime leftovers',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'agentic-base-smoke-state-$stateManagement-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final appDir = await _generateStarterApp(
          repoRoot: repoRoot,
          tempDir: tempDir,
          appName: 'smoke_${stateManagement}_app',
          stateManagement: stateManagement,
        );

        expect(
          () => GeneratedProjectContract.validate(
            appDir,
            ciProvider: CiProvider.github,
            stateManagement: stateManagement,
          ),
          returnsNormally,
        );
        _expectStarterRuntimeSurfaces(
          appDir,
          stateManagement: stateManagement,
        );
      },
      skip:
          flutterAvailable
              ? false
              : 'Flutter SDK is required for smoke generation.',
      timeout: smokeTimeout,
    );
  }

  test(
    'create command wires analytics module into the generated DI graph',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'agentic-base-smoke-analytics-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      const appName = 'smoke_analytics_app';
      final appDir = await _generateStarterApp(
        repoRoot: repoRoot,
        tempDir: tempDir,
        appName: appName,
        modules: const ['analytics'],
      );
      final analyticsImpl =
          File(
            p.join(
              appDir,
              'lib/core/analytics/firebase_analytics_service.dart',
            ),
          ).readAsStringSync();
      final registrations =
          File(
            p.join(appDir, 'lib/app/modules/module_registrations.dart'),
          ).readAsStringSync();
      final injectionConfig =
          File(
            p.join(appDir, 'lib/core/di/injection.config.dart'),
          ).readAsStringSync();
      final firebaseOptions =
          File(
            p.join(appDir, 'lib/firebase_options.dart'),
          ).readAsStringSync();
      final firebaseRuntime =
          File(
            p.join(appDir, 'lib/core/firebase/firebase_runtime.dart'),
          ).readAsStringSync();

      expect(analyticsImpl, contains('@LazySingleton(as: AnalyticsService)'));
      expect(analyticsImpl, contains('FirebaseAnalytics.instance'));
      expect(
        analyticsImpl,
        isNot(
          contains('FirebaseAnalyticsService({FirebaseAnalytics? analytics})'),
        ),
      );
      expect(
        registrations,
        isNot(contains('await getIt<AnalyticsService>().init();')),
      );
      _expectIosPodfileContains(appDir, ["platform :ios, '15.0'"]);
      expect(injectionConfig, contains('FirebaseAnalyticsService'));
      expect(injectionConfig, contains('AnalyticsService'));
      expect(
        firebaseOptions,
        contains(
          'Run `flutterfire configure` to generate lib/firebase_options.dart.',
        ),
      );
      expect(
        firebaseRuntime,
        contains("import 'package:$appName/firebase_options.dart';"),
      );
      expect(
        firebaseRuntime,
        contains('DefaultFirebaseOptions.currentPlatform'),
      );
      expect(
        firebaseRuntime,
        contains('await Firebase.initializeApp();'),
      );
    },
    skip:
        flutterAvailable
            ? false
            : 'Flutter SDK is required for smoke generation.',
    timeout: smokeTimeout,
  );

  test(
    'create command wires notifications into the generated startup seam',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'agentic-base-smoke-notifications-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final appDir = await _generateStarterApp(
        repoRoot: repoRoot,
        tempDir: tempDir,
        appName: 'smoke_notifications_app',
        modules: const ['notifications'],
      );
      final registrations =
          File(
            p.join(appDir, 'lib/app/modules/module_registrations.dart'),
          ).readAsStringSync();
      final notificationsImpl =
          File(
            p.join(
              appDir,
              'lib/core/notifications/awesome_notifications_service.dart',
            ),
          ).readAsStringSync();

      expect(registrations, contains('NotificationsService'));
      expect(
        registrations,
        contains('await getIt<NotificationsService>().init();'),
      );
      expect(notificationsImpl, contains('_defaultNotificationChannels'));
      expect(
        notificationsImpl,
        contains("channelKey: 'general'"),
      );
      _expectIosPodfileContains(appDir, [
        "platform :ios, '15.0'",
        'use_modular_headers!',
        'update_awesome_pod_build_settings(installer)',
        "update_awesome_main_target_settings('Runner'",
      ]);
    },
    skip:
        flutterAvailable
            ? false
            : 'Flutter SDK is required for smoke generation.',
    timeout: smokeTimeout,
  );

  test(
    'release-preflight emits approval evidence for production uploads',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'agentic-base-smoke-release-preflight-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final appDir = await _generateStarterApp(
        repoRoot: repoRoot,
        tempDir: tempDir,
        appName: 'smoke_release_contract_app',
      );
      final fakeBinDir = Directory(p.join(tempDir.path, 'fake-bin'))
        ..createSync(recursive: true);
      final bundleScript = File(p.join(fakeBinDir.path, 'bundle'))
        ..writeAsStringSync('#!/bin/sh\nexit 0\n');
      await Process.run('chmod', ['755', bundleScript.path]);

      final preflightResult = await Process.run(
        'bash',
        ['./tools/release-preflight.sh', 'prod', 'play-production'],
        workingDirectory: appDir,
        environment: {
          'PATH':
              '${fakeBinDir.path}${Platform.isWindows ? ';' : ':'}${Platform.environment['PATH'] ?? ''}',
          'PLAY_STORE_JSON_KEY': 'fake-key',
        },
      );

      expect(
        preflightResult.exitCode,
        equals(0),
        reason: '${preflightResult.stdout}\n${preflightResult.stderr}',
      );

      final summary =
          File(
            p.join(
              _latestEvidenceRunDirectory(appDir, 'release-preflight').path,
              'summary.json',
            ),
          ).readAsStringSync();
      expect(summary, contains('"run_kind": "release-preflight"'));
      expect(summary, contains('"approval_state": "UploadReady"'));
    },
    skip:
        flutterAvailable
            ? false
            : 'Flutter SDK is required for smoke generation.',
    timeout: smokeTimeout,
  );
}
