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
    },
    skip:
        flutterAvailable
            ? false
            : 'Flutter SDK is required for smoke generation.',
    timeout: smokeTimeout,
  );
}
