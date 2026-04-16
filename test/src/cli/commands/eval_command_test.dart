import 'dart:io';

import 'package:agentic_base/src/cli/commands/eval_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('EvalCommand', () {
    late Directory tempDir;
    late List<String> processCalls;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('eval-command-test-');
      processCalls = <String>[];
      _seedProject(tempDir.path);
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        EvalCommand(
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

    test('supports dry-run previews without executing flutter test', () async {
      final exitCode = await runner.run(['eval', '--coverage', '--dry-run']);

      expect(exitCode, equals(0));
      expect(processCalls, isEmpty);
    });

    test(
      'dry-run still fails when a requested feature test directory is missing',
      () async {
        final exitCode = await runner.run([
          'eval',
          'missing_feature',
          '--dry-run',
        ]);

        expect(exitCode, equals(1));
        expect(processCalls, isEmpty);
      },
    );

    test('uses the resolved manager-aware flutter test command', () async {
      final exitCode = await runner.run(['eval', '--coverage']);

      expect(exitCode, equals(0));
      expect(
        processCalls,
        equals([
          'fvm flutter test --coverage @ ${tempDir.path}',
        ]),
      );
    });
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
          version: '3.29.0',
          policy: FlutterVersionPolicy.newestTested,
          preferredManager: FlutterSdkManager.fvm,
          preferredVersion: '3.29.0',
        ),
      ),
    ),
  );
  File(p.join(projectPath, 'pubspec.yaml'))
    ..createSync(recursive: true)
    ..writeAsStringSync('name: demo_app\n');
  Directory(p.join(projectPath, 'test', 'features', 'payments')).createSync(
    recursive: true,
  );
}

ProcessRunner _recordingProcessRunner(List<String> calls) {
  return (
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    calls.add('$executable ${arguments.join(' ')} @ $workingDirectory');
    return ProcessResult(1, 0, '00:00 +3: All tests passed!', '');
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
