import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

bool _isFlutterAvailable() {
  try {
    return Process.runSync('flutter', ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

String get _dartExecutable => Platform.resolvedExecutable;

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

void main() {
  final flutterAvailable = _isFlutterAvailable();
  // Other test suites temporarily mutate Directory.current, so capture a
  // stable repo root once for all smoke subprocesses.
  final repoRoot = Directory.current.path;
  const smokeTimeout = Timeout(Duration(minutes: 6));
  for (final ciProvider in ['github', 'gitlab']) {
    test(
      'create command generates a cubit $ciProvider starter app that matches the ownership contract',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'agentic-base-smoke-$ciProvider-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final appName = 'smoke_${ciProvider}_app';
        final result = await Process.run(_dartExecutable, [
          'run',
          'bin/agentic_base.dart',
          'create',
          appName,
          '--no-interactive',
          '--output-dir',
          tempDir.path,
          '--ci-provider',
          ciProvider,
          '--state',
          'cubit',
        ], workingDirectory: repoRoot);

        expect(
          result.exitCode,
          equals(0),
          reason: '${result.stdout}\n${result.stderr}',
        );

        final appDir = p.join(tempDir.path, appName);
        expect(Directory(appDir).existsSync(), isTrue);
        expect(
          () => GeneratedProjectContract.validate(
            appDir,
            ciProvider: parseCiProvider(ciProvider),
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
        expect(verifySummary, contains('"app-shell-smoke"'));
      },
      skip:
          flutterAvailable
              ? false
              : 'Flutter SDK is required for smoke generation.',
      timeout: smokeTimeout,
    );
  }

  for (final stateManagement in ['cubit', 'riverpod', 'mobx']) {
    test(
      'create command generates a $stateManagement starter app with no foreign runtime leftovers',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'agentic-base-smoke-state-$stateManagement-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final appName = 'smoke_${stateManagement}_app';
        final result = await Process.run(_dartExecutable, [
          'run',
          'bin/agentic_base.dart',
          'create',
          appName,
          '--no-interactive',
          '--output-dir',
          tempDir.path,
          '--ci-provider',
          'github',
          '--state',
          stateManagement,
        ], workingDirectory: repoRoot);

        expect(
          result.exitCode,
          equals(0),
          reason: '${result.stdout}\n${result.stderr}',
        );

        final appDir = p.join(tempDir.path, appName);
        expect(
          () => GeneratedProjectContract.validate(
            appDir,
            ciProvider: CiProvider.github,
            stateManagement: stateManagement,
          ),
          returnsNormally,
        );

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
        final contextExtensions =
            File(
              p.join(appDir, 'lib/core/extensions/context_extensions.dart'),
            ).readAsStringSync();
        final themingGuide =
            File(
              p.join(appDir, 'docs/05-theming-guide.md'),
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
        expect(generatedTheme, contains('ThemeData.from('));
        expect(contextExtensions, contains('adaptivePagePadding'));
        expect(themingGuide, contains('BuildContextX'));
        expect(
          File(
            p.join(appDir, 'lib/core/responsive/app_screen_util_init.dart'),
          ).existsSync(),
          isFalse,
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
      final result = await Process.run(_dartExecutable, [
        'run',
        'bin/agentic_base.dart',
        'create',
        appName,
        '--no-interactive',
        '--output-dir',
        tempDir.path,
        '--modules',
        'analytics',
      ], workingDirectory: repoRoot);

      expect(
        result.exitCode,
        equals(0),
        reason: '${result.stdout}\n${result.stderr}',
      );

      final appDir = p.join(tempDir.path, appName);
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

      const appName = 'smoke_notifications_app';
      final result = await Process.run(_dartExecutable, [
        'run',
        'bin/agentic_base.dart',
        'create',
        appName,
        '--no-interactive',
        '--output-dir',
        tempDir.path,
        '--modules',
        'notifications',
      ], workingDirectory: repoRoot);

      expect(
        result.exitCode,
        equals(0),
        reason: '${result.stdout}\n${result.stderr}',
      );

      final appDir = p.join(tempDir.path, appName);
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

      const appName = 'smoke_release_contract_app';
      final createResult = await Process.run(_dartExecutable, [
        'run',
        'bin/agentic_base.dart',
        'create',
        appName,
        '--no-interactive',
        '--output-dir',
        tempDir.path,
      ], workingDirectory: repoRoot);

      expect(
        createResult.exitCode,
        equals(0),
        reason: '${createResult.stdout}\n${createResult.stderr}',
      );

      final appDir = p.join(tempDir.path, appName);
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
