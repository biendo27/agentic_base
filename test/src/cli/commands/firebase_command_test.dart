import 'dart:io';

import 'package:agentic_base/src/cli/commands/firebase_command.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../generators/project_generator_test.dart'
    show seedRequiredContractFiles;

void main() {
  group('FirebaseCommand', () {
    late Directory tempDir;
    late List<String> calls;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('firebase-command-test-');
      calls = <String>[];
      await seedRequiredContractFiles(tempDir.path);
      File(p.join(tempDir.path, 'flavorizr.yaml')).writeAsStringSync('''
flavors:
  dev:
    android:
      applicationId: com.example.demoapp.dev
    ios:
      bundleId: com.example.demoapp.dev
  staging:
    android:
      applicationId: com.example.demoapp.staging
    ios:
      bundleId: com.example.demoapp.staging
  prod:
    android:
      applicationId: com.example.demoapp
    ios:
      bundleId: com.example.demoapp
''');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test(
      'requires explicit Firebase project mapping before mutation',
      () async {
        final runner = _runner(
          projectDir: tempDir.path,
          calls: calls,
          processRunner: _recordingSuccessRunner(calls),
        );

        final exitCode = await runner.run(['firebase', 'setup']);

        expect(exitCode, equals(1));
        expect(calls, isEmpty);
      },
    );

    test(
      'constructs per-flavor FlutterFire commands and patches flavorizr',
      () async {
        final runner = _runner(
          projectDir: tempDir.path,
          calls: calls,
          processRunner: _recordingSuccessRunner(calls),
        );

        final exitCode = await runner.run([
          'firebase',
          'setup',
          '--project=demo-firebase',
          '--yes',
        ]);

        expect(exitCode, equals(0));
        expect(
          calls,
          contains(
            'flutterfire configure --project=demo-firebase --platforms=android,ios,web --out=lib/services/firebase/options/firebase_options_dev.dart --android-package-name=com.example.demoapp.dev --android-out=android/app/src/dev/google-services.json --ios-bundle-id=com.example.demoapp.dev --ios-out=ios/Runner/Firebase/dev/GoogleService-Info.plist --yes @ ${tempDir.path}',
          ),
        );
        expect(
          calls,
          contains(
            'dart run flutter_flavorizr -f @ ${tempDir.path}',
          ),
        );
        expect(
          File(p.join(tempDir.path, 'flavorizr.yaml')).readAsStringSync(),
          allOf(
            contains('android/app/src/dev/google-services.json'),
            contains('ios/Runner/Firebase/prod/GoogleService-Info.plist'),
          ),
        );
        expect(
          File(
            p.join(tempDir.path, 'lib/services/firebase/firebase_options.dart'),
          ).readAsStringSync(),
          contains('DefaultFirebaseOptionsForFlavor'),
        );
      },
    );

    test('rejects unsupported Firebase platforms before mutation', () async {
      final runner = _runner(
        projectDir: tempDir.path,
        calls: calls,
        processRunner: _recordingSuccessRunner(calls),
      );

      final exitCode = await runner.run([
        'firebase',
        'setup',
        '--project=demo-firebase',
        '--platforms=macos',
      ]);

      expect(exitCode, equals(1));
      expect(calls, isEmpty);
    });

    test('skips flavorizr for web-only Firebase setup', () async {
      final runner = _runner(
        projectDir: tempDir.path,
        calls: calls,
        processRunner: _recordingSuccessRunner(calls),
      );

      final exitCode = await runner.run([
        'firebase',
        'setup',
        '--project=demo-firebase',
        '--platforms=web',
      ]);

      expect(exitCode, equals(0));
      expect(
        calls,
        contains(
          'flutterfire configure --project=demo-firebase --platforms=web --out=lib/services/firebase/options/firebase_options_dev.dart @ ${tempDir.path}',
        ),
      );
      expect(
        calls.where((call) => call.contains('flutter_flavorizr')),
        isEmpty,
      );
      expect(
        calls.where((call) => call.contains('--android-package-name')),
        isEmpty,
      );
    });

    test(
      'rolls back tracked FlutterFire outputs after configure failure',
      () async {
        final outputPath = p.join(
          tempDir.path,
          'lib/services/firebase/options/firebase_options_dev.dart',
        );
        final runner = _runner(
          projectDir: tempDir.path,
          calls: calls,
          processRunner: (
            executable,
            arguments, {
            workingDirectory,
          }) async {
            calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
            if (executable == 'flutterfire' &&
                arguments.contains(
                  '--out=lib/services/firebase/options/firebase_options_dev.dart',
                )) {
              File(outputPath)
                ..createSync(recursive: true)
                ..writeAsStringSync('// partial output');
            }
            if (executable == 'flutterfire' &&
                arguments.contains(
                  '--out=lib/services/firebase/options/firebase_options_staging.dart',
                )) {
              return ProcessResult(1, 1, '', 'failed');
            }
            return ProcessResult(1, 0, '', '');
          },
        );

        final exitCode = await runner.run([
          'firebase',
          'setup',
          '--project=demo-firebase',
        ]);

        expect(exitCode, equals(1));
        expect(File(outputPath).existsSync(), isFalse);
      },
    );

    test('rolls back flavorizr outputs after flavorizr failure', () async {
      final flavorizrOutput =
          File(p.join(tempDir.path, 'android/app/flavorizr.gradle.kts'))
            ..createSync(recursive: true)
            ..writeAsStringSync('// before flavorizr');
      final androidGeneratedAsset = File(
        p.join(tempDir.path, 'android/app/src/dev/res/values/strings.xml'),
      );
      final iosPodfile =
          File(p.join(tempDir.path, 'ios/Podfile'))
            ..createSync(recursive: true)
            ..writeAsStringSync('# before podfile');
      final iosLaunchScreen = File(
        p.join(tempDir.path, 'ios/Runner/Base.lproj/LaunchScreen.storyboard'),
      );
      final iosGeneratedAsset = File(
        p.join(
          tempDir.path,
          'ios/Runner/Assets.xcassets/devAppIcon.appiconset/Contents.json',
        ),
      );
      final runner = _runner(
        projectDir: tempDir.path,
        calls: calls,
        processRunner: (
          executable,
          arguments, {
          workingDirectory,
        }) async {
          calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
          if (executable == 'dart' &&
              arguments.join(' ') == 'run flutter_flavorizr -f') {
            flavorizrOutput.writeAsStringSync('// after flavorizr');
            androidGeneratedAsset
              ..createSync(recursive: true)
              ..writeAsStringSync('<resources />');
            iosPodfile.writeAsStringSync('# after podfile');
            iosLaunchScreen
              ..createSync(recursive: true)
              ..writeAsStringSync('<document />');
            iosGeneratedAsset
              ..createSync(recursive: true)
              ..writeAsStringSync('{}');
            return ProcessResult(1, 1, '', 'flavorizr failed');
          }
          return ProcessResult(1, 0, '', '');
        },
      );

      final exitCode = await runner.run([
        'firebase',
        'setup',
        '--project=demo-firebase',
      ]);

      expect(exitCode, equals(1));
      expect(flavorizrOutput.readAsStringSync(), equals('// before flavorizr'));
      expect(androidGeneratedAsset.existsSync(), isFalse);
      expect(iosPodfile.readAsStringSync(), equals('# before podfile'));
      expect(iosLaunchScreen.existsSync(), isFalse);
      expect(iosGeneratedAsset.existsSync(), isFalse);
      expect(
        File(p.join(tempDir.path, 'flavorizr.yaml')).readAsStringSync(),
        isNot(contains('firebase:')),
      );
    });

    test('rolls back flavorizr outputs after build runner failure', () async {
      final flavorizrOutput =
          File(p.join(tempDir.path, 'android/app/flavorizr.gradle.kts'))
            ..createSync(recursive: true)
            ..writeAsStringSync('// before flavorizr');
      final injectionOutput =
          File(
              p.join(tempDir.path, 'lib/core/di/injection.config.dart'),
            )
            ..createSync(recursive: true)
            ..writeAsStringSync('// before injection config');
      final generatedDartOutput = File(
        p.join(tempDir.path, 'lib/services/firebase/firebase_options.g.dart'),
      );
      final runner = _runner(
        projectDir: tempDir.path,
        calls: calls,
        processRunner: (
          executable,
          arguments, {
          workingDirectory,
        }) async {
          calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
          if (executable == 'dart' &&
              arguments.join(' ') == 'run flutter_flavorizr -f') {
            flavorizrOutput.writeAsStringSync('// after flavorizr');
          }
          if (executable == 'dart' &&
              arguments.join(' ') ==
                  'run build_runner build --delete-conflicting-outputs') {
            injectionOutput.writeAsStringSync('// after injection config');
            generatedDartOutput
              ..createSync(recursive: true)
              ..writeAsStringSync('// generated');
            return ProcessResult(1, 1, '', 'build_runner failed');
          }
          return ProcessResult(1, 0, '', '');
        },
      );

      final exitCode = await runner.run([
        'firebase',
        'setup',
        '--project=demo-firebase',
      ]);

      expect(exitCode, equals(1));
      expect(flavorizrOutput.readAsStringSync(), equals('// before flavorizr'));
      expect(
        injectionOutput.readAsStringSync(),
        equals('// before injection config'),
      );
      expect(generatedDartOutput.existsSync(), isFalse);
      expect(
        File(p.join(tempDir.path, 'flavorizr.yaml')).readAsStringSync(),
        isNot(contains('firebase:')),
      );
    });
  });
}

CommandRunner<int> _runner({
  required String projectDir,
  required List<String> calls,
  required ProcessRunner processRunner,
}) {
  return CommandRunner<int>('agentic_base', 'test runner')..addCommand(
    FirebaseCommand(
      logger: AgenticLogger(),
      projectPathProvider: () => projectDir,
      processRunner: processRunner,
      toolchainDetector: _systemToolchainDetector,
    ),
  );
}

ProcessRunner _recordingSuccessRunner(List<String> calls) {
  return (
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
    return ProcessResult(1, 0, '', '');
  };
}

DetectedFlutterToolchain _systemToolchainDetector({
  required FlutterSdkManager manager,
  required String projectPath,
}) {
  return DetectedFlutterToolchain(
    manager: manager,
    version: manager == FlutterSdkManager.system ? '3.41.6' : null,
    channel: 'stable',
    available: manager == FlutterSdkManager.system,
    command: manager.wireName,
    problem: manager == FlutterSdkManager.system ? null : 'missing',
  );
}
