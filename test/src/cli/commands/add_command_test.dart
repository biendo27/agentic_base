import 'dart:io';

import 'package:agentic_base/src/cli/commands/add_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('AddCommand', () {
    late Directory tempDir;
    late List<String> processCalls;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('add-command-test-');
      processCalls = <String>[];
      _seedAgenticProject(tempDir.path);
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        AddCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
          processRunner: _recordingProcessRunner(processCalls),
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('installs analytics and refreshes generated code', () async {
      final exitCode = await runner.run(['add', 'analytics']);

      expect(exitCode, equals(0));
      expect(
        AgenticConfig(projectPath: tempDir.path).read()['modules'],
        equals(['analytics']),
      );
      expect(
        File(
          p.join(
            tempDir.path,
            'lib/core/analytics/firebase_analytics_service.dart',
          ),
        ).readAsStringSync(),
        contains('@LazySingleton(as: AnalyticsService)'),
      );
      expect(
        File(p.join(tempDir.path, 'pubspec.yaml')).readAsStringSync(),
        contains('firebase_analytics: ^12.2.0'),
      );
      expect(
        processCalls,
        equals([
          'flutter pub get @ ${tempDir.path}',
          'dart run build_runner build --delete-conflicting-outputs @ ${tempDir.path}',
          'dart format lib test @ ${tempDir.path}',
        ]),
      );
    });

    test(
      'preserves an existing firebase_options file and generates runtime import',
      () async {
        File(p.join(tempDir.path, 'lib', 'firebase_options.dart'))
          ..createSync(recursive: true)
          ..writeAsStringSync('// existing firebase options\n');

        final exitCode = await runner.run(['add', 'analytics']);

        expect(exitCode, equals(0));
        expect(
          File(
            p.join(tempDir.path, 'lib', 'firebase_options.dart'),
          ).readAsStringSync(),
          equals('// existing firebase options\n'),
        );
        expect(
          File(
            p.join(tempDir.path, 'lib/core/firebase/firebase_runtime.dart'),
          ).readAsStringSync(),
          contains('DefaultFirebaseOptions.currentPlatform'),
        );
      },
    );

    test('installs remote_config without fetching during init', () async {
      final exitCode = await runner.run(['add', 'remote_config']);

      expect(exitCode, equals(0));
      final implementation =
          File(
            p.join(
              tempDir.path,
              'lib/core/remote_config/firebase_remote_config_service.dart',
            ),
          ).readAsStringSync();

      final initBlock = implementation.substring(
        implementation.indexOf('Future<void> init() async {'),
        implementation.indexOf('@override\n  Future<bool> fetchAndActivate()'),
      );

      expect(initBlock, isNot(contains('_config.fetchAndActivate()')));
      expect(
        implementation,
        contains('return _config.fetchAndActivate();'),
      );
    });

    test(
      'returns cleanly for already-installed modules without toolchain resolution',
      () async {
        final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
          fallbackProjectName: 'demo_app',
          fallbackToolVersion: 'test',
        );
        AgenticConfig(projectPath: tempDir.path).writeMetadata(
          metadata.copyWith(modules: const ['analytics']),
        );

        final localRunner = CommandRunner<int>(
          'agentic_base',
          'test runner',
        )..addCommand(
          AddCommand(
            logger: AgenticLogger(),
            projectPathProvider: () => tempDir.path,
            processRunner: _recordingProcessRunner(processCalls),
            toolchainDetector: ({
              required manager,
              required projectPath,
            }) {
              fail(
                'toolchain resolution should not run for already-installed modules',
              );
            },
          ),
        );

        final exitCode = await localRunner.run(['add', 'analytics']);

        expect(exitCode, equals(0));
        expect(processCalls, isEmpty);
      },
    );

    test('uses the resolved manager-aware toolchain commands', () async {
      final config = AgenticConfig(projectPath: tempDir.path);
      final metadata = config.readMetadata(
        fallbackProjectName: 'demo_app',
        fallbackToolVersion: 'test',
      );
      config.writeMetadata(
        metadata.copyWith(
          harness: metadata.harness.copyWith(
            sdk: const FlutterSdkContract(
              manager: FlutterSdkManager.system,
              channel: 'stable',
              version: '3.29.0',
              policy: FlutterVersionPolicy.newestTested,
              preferredManager: FlutterSdkManager.fvm,
              preferredVersion: '3.29.0',
            ),
          ),
        ),
      );
      processCalls = <String>[];
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        AddCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
          processRunner: _recordingProcessRunner(processCalls),
          toolchainDetector: _recordingToolchainDetector,
        ),
      );

      final exitCode = await runner.run(['add', 'analytics']);

      expect(exitCode, equals(0));
      expect(
        processCalls,
        equals([
          'fvm flutter pub get @ ${tempDir.path}',
          'fvm dart run build_runner build --delete-conflicting-outputs @ ${tempDir.path}',
          'fvm dart format lib test @ ${tempDir.path}',
        ]),
      );
      final restored = AgenticConfig(projectPath: tempDir.path).readMetadata(
        fallbackProjectName: 'demo_app',
        fallbackToolVersion: 'test',
      );
      expect(restored.harness.sdk.manager, FlutterSdkManager.fvm);
      expect(
        restored.harness.sdk.preferredManager,
        FlutterSdkManager.fvm,
      );
    });
  });
}

void _seedAgenticProject(String projectPath) {
  AgenticConfig.createInitial(
    projectPath: projectPath,
    projectName: 'demo_app',
    org: 'com.example',
    stateManagement: 'cubit',
    platforms: ['android', 'ios'],
    flavors: ['dev', 'staging', 'prod'],
    toolVersion: 'test',
  );
  File(p.join(projectPath, 'pubspec.yaml'))
    ..createSync(recursive: true)
    ..writeAsStringSync(
      'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
}

ProcessRunner _recordingProcessRunner(List<String> calls) {
  return (
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
    return ProcessResult(1, 0, '', '');
  };
}

DetectedFlutterToolchain _recordingToolchainDetector({
  required FlutterSdkManager manager,
  required String projectPath,
}) {
  return DetectedFlutterToolchain(
    manager: manager,
    version: manager == FlutterSdkManager.fvm ? '3.41.6' : null,
    channel: 'stable',
    available: manager == FlutterSdkManager.fvm,
    command: manager.wireName,
    problem: manager == FlutterSdkManager.fvm ? null : 'missing',
  );
}
