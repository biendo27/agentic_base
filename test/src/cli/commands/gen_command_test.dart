import 'dart:io';

import 'package:agentic_base/src/cli/commands/gen_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:test/test.dart';

void main() {
  group('GenCommand', () {
    late Directory tempDir;
    late List<String> processCalls;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('gen-command-test-');
      processCalls = <String>[];
      final metadata = AgenticConfig.createInitial(
        projectPath: tempDir.path,
        projectName: 'demo_app',
        org: 'com.example',
        stateManagement: 'cubit',
        platforms: const ['android', 'ios'],
        flavors: const ['dev', 'staging', 'prod'],
        toolVersion: 'test',
      );
      AgenticConfig(projectPath: tempDir.path).writeMetadata(
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
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        GenCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
          processRunner: _recordingProcessRunner(processCalls),
          toolchainDetector: _recordingToolchainDetector,
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('uses the resolved manager-aware toolchain commands', () async {
      final exitCode = await runner.run(['gen']);

      expect(exitCode, equals(0));
      expect(
        processCalls,
        equals([
          'fvm dart run build_runner build --delete-conflicting-outputs @ ${tempDir.path}',
          'fvm dart format lib test @ ${tempDir.path}',
        ]),
      );
      final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
        fallbackProjectName: 'demo_app',
        fallbackToolVersion: 'test',
      );
      expect(metadata.harness.sdk.manager, FlutterSdkManager.fvm);
      expect(metadata.harness.sdk.version, '3.41.6');
    });
  });
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
