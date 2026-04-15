import 'dart:io';

import 'package:agentic_base/src/cli/commands/remove_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/modules/core/analytics_module.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('RemoveCommand', () {
    late Directory tempDir;
    late List<String> processCalls;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('remove-command-test-');
      processCalls = <String>[];
      _seedAgenticProject(tempDir.path);
      await const AnalyticsModule().install(
        ProjectContext(
          projectPath: tempDir.path,
          projectName: 'demo_app',
          stateManagement: 'cubit',
          installedModules: const [],
        ),
      );
      AgenticConfig(projectPath: tempDir.path).write({
        'modules': ['analytics'],
      });
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        RemoveCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
          processRunner: _recordingProcessRunner(processCalls),
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('removes analytics and refreshes generated code', () async {
      final exitCode = await runner.run(['remove', 'analytics']);

      expect(exitCode, equals(0));
      expect(
        AgenticConfig(projectPath: tempDir.path).read()['modules'],
        equals(<String>[]),
      );
      expect(
        File(
          p.join(
            tempDir.path,
            'lib/core/analytics/firebase_analytics_service.dart',
          ),
        ).existsSync(),
        isFalse,
      );
      expect(
        File(p.join(tempDir.path, 'pubspec.yaml')).readAsStringSync(),
        isNot(contains('firebase_analytics: any')),
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
      'returns cleanly for absent modules without toolchain resolution',
      () async {
        final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
          fallbackProjectName: 'demo_app',
          fallbackToolVersion: 'test',
        );
        AgenticConfig(projectPath: tempDir.path).writeMetadata(
          metadata.copyWith(modules: const <String>[]),
        );

        final localRunner = CommandRunner<int>('agentic_base', 'test runner')
          ..addCommand(
            RemoveCommand(
              logger: AgenticLogger(),
              projectPathProvider: () => tempDir.path,
              processRunner: _recordingProcessRunner(processCalls),
              toolchainDetector: ({
                required manager,
                required projectPath,
              }) {
                fail('toolchain resolution should not run for absent modules');
              },
            ),
          );

        final exitCode = await localRunner.run(['remove', 'analytics']);

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
        RemoveCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
          processRunner: _recordingProcessRunner(processCalls),
          toolchainDetector: _recordingToolchainDetector,
        ),
      );

      final exitCode = await runner.run(['remove', 'analytics']);

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
