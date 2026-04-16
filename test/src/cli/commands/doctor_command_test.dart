import 'dart:io';

import 'package:agentic_base/src/cli/commands/doctor_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DoctorCommand', () {
    late Directory tempDir;
    late List<String> processCalls;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('doctor-command-test-');
      processCalls = <String>[];
      _seedProject(tempDir.path);
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        DoctorCommand(
          logger: AgenticLogger(),
          processRunner: _recordingProcessRunner(processCalls),
          projectPathProvider: () => tempDir.path,
          toolchainDetector: _recordingToolchainDetector,
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('supports dry-run previews without probing the environment', () async {
      final exitCode = await runner.run(['doctor', '--dry-run']);

      expect(exitCode, equals(0));
      expect(processCalls, isEmpty);
    });

    test('uses the resolved manager-aware dart commands', () async {
      final exitCode = await runner.run(['doctor']);

      expect(exitCode, equals(0));
      expect(
        processCalls,
        equals([
          'fvm dart --version @ ${tempDir.path}',
          'fvm --version @ ${tempDir.path}',
          'puro --version @ ${tempDir.path}',
          'fvm dart pub global list @ ${tempDir.path}',
          'fvm dart pub global list @ ${tempDir.path}',
        ]),
      );
    });

    test('fails cleanly when no toolchain can be resolved', () async {
      final localRunner = CommandRunner<int>('agentic_base', 'test runner')
        ..addCommand(
          DoctorCommand(
            logger: AgenticLogger(),
            processRunner: _recordingProcessRunner(processCalls),
            projectPathProvider: () => tempDir.path,
            toolchainDetector: _missingToolchainDetector,
          ),
        );

      final exitCode = await localRunner.run(['doctor']);

      expect(exitCode, equals(1));
      expect(processCalls, isEmpty);
    });

    test(
      'reports a mismatch when the declared manager falls back to system flutter',
      () async {
        processCalls = <String>[];
        final localRunner = CommandRunner<int>('agentic_base', 'test runner')
          ..addCommand(
            DoctorCommand(
              logger: AgenticLogger(),
              processRunner: _systemProcessRunner(processCalls),
              projectPathProvider: () => tempDir.path,
              toolchainDetector: _systemOnlyToolchainDetector,
            ),
          );

        final exitCode = await localRunner.run(['doctor']);

        expect(exitCode, equals(1));
        expect(processCalls, contains('dart --version @ ${tempDir.path}'));
      },
    );
  });
}

void _seedProject(String projectPath) {
  final metadata = AgenticConfig.createInitial(
    projectPath: projectPath,
    projectName: 'demo_app',
    org: 'com.example',
    stateManagement: 'cubit',
    platforms: ['android', 'ios'],
    flavors: ['dev', 'staging', 'prod'],
    toolVersion: 'test',
  );
  AgenticConfig(projectPath: projectPath).writeMetadata(
    metadata.copyWith(
      harness: metadata.harness.copyWith(
        sdk: const FlutterSdkContract(
          manager: FlutterSdkManager.system,
          channel: 'stable',
          version: '3.41.6',
          policy: FlutterVersionPolicy.newestTested,
          preferredManager: FlutterSdkManager.fvm,
          preferredVersion: '3.41.6',
        ),
      ),
    ),
  );
  File(p.join(projectPath, 'pubspec.yaml'))
    ..createSync(recursive: true)
    ..writeAsStringSync('name: demo_app\n');
}

ProcessRunner _recordingProcessRunner(List<String> calls) {
  return (
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
    final command = '$executable ${arguments.join(' ')}';
    if (command == 'fvm dart --version') {
      return ProcessResult(1, 0, 'Dart SDK version: 3.3.0', '');
    }
    if (command == 'fvm --version') {
      return ProcessResult(1, 0, 'FVM 3.1.0', '');
    }
    if (command == 'puro --version') {
      return ProcessResult(1, 0, 'Puro 1.5.0', '');
    }
    if (command == 'fvm dart pub global list') {
      return ProcessResult(1, 0, 'build_runner 2.4.0\nmason 0.1.0', '');
    }
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

ProcessRunner _systemProcessRunner(List<String> calls) {
  return (
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
    final command = '$executable ${arguments.join(' ')}';
    if (command == 'dart --version') {
      return ProcessResult(1, 0, 'Dart SDK version: 3.3.0', '');
    }
    if (command == 'fvm --version') {
      return ProcessResult(1, 0, 'FVM 3.1.0', '');
    }
    if (command == 'puro --version') {
      return ProcessResult(1, 0, 'Puro 1.5.0', '');
    }
    if (command == 'dart pub global list') {
      return ProcessResult(1, 0, 'build_runner 2.4.0\nmason 0.1.0', '');
    }
    return ProcessResult(1, 0, '', '');
  };
}

DetectedFlutterToolchain _missingToolchainDetector({
  required FlutterSdkManager manager,
  required String projectPath,
}) {
  return DetectedFlutterToolchain(
    manager: manager,
    version: null,
    channel: null,
    available: false,
    command: manager.wireName,
    problem: 'missing',
  );
}

DetectedFlutterToolchain _systemOnlyToolchainDetector({
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
