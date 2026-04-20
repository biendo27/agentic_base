import 'dart:io';

import 'package:agentic_base/src/cli/commands/upgrade_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('UpgradeCommand', () {
    late Directory tempDir;
    late AgenticLogger logger;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('upgrade-command-test-');
      logger = AgenticLogger();

      final infoDir = Directory(p.join(tempDir.path, '.info'))
        ..createSync(recursive: true);
      File(
        p.join(infoDir.path, 'agentic.yaml'),
      ).writeAsStringSync('''
tool_version: 0.0.9
project_name: demo_app
org: com.example
ci_provider: github
state_management: cubit
platforms:
  - android
  - ios
  - web
flavors:
  - dev
  - staging
  - prod
modules: []
''');

      File(
        p.join(tempDir.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: demo_app\n');
      File(
        p.join(tempDir.path, 'AGENTS.md'),
      ).writeAsStringSync('legacy adapter');
      File(
        p.join(tempDir.path, 'README.md'),
      ).writeAsStringSync('legacy readme');
      final bootstrapFile = File(
        p.join(tempDir.path, 'lib/app/bootstrap.dart'),
      );
      bootstrapFile.parent.createSync(recursive: true);
      bootstrapFile.writeAsStringSync('// keep user-owned bootstrap');

      final command = UpgradeCommand(
        logger: logger,
        processRunner: (executable, arguments, {workingDirectory}) async {
          return ProcessResult(0, 0, 'ok', '');
        },
        projectPathProvider: () => tempDir.path,
        toolchainDetector: _systemToolchainDetector,
      );

      runner = CommandRunner<int>('agentic_base', 'test runner')
        ..addCommand(command);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('syncs generator-owned surfaces without rewriting app code', () async {
      final exitCode = await runner.run(['upgrade']);

      expect(exitCode, equals(0));

      final config = AgenticConfig(projectPath: tempDir.path).read();
      expect(config['tool_version'], equals('0.2.1'));
      expect(config['context'], isA<Map<String, dynamic>>());
      expect(config['execution'], isA<Map<String, dynamic>>());

      expect(
        File(p.join(tempDir.path, 'AGENTS.md')).readAsStringSync(),
        contains('Thin adapter'),
      );
      expect(
        File(p.join(tempDir.path, 'README.md')).readAsStringSync(),
        contains('agent-ready Flutter repository'),
      );
      expect(
        File(p.join(tempDir.path, 'tools/verify.sh')).existsSync(),
        isTrue,
      );
      if (!Platform.isWindows) {
        expect(
          File(p.join(tempDir.path, 'tools/verify.sh')).statSync().mode & 0x49,
          isNot(equals(0)),
        );
      }
      expect(
        File(p.join(tempDir.path, 'lib/app/bootstrap.dart')).readAsStringSync(),
        equals('// keep user-owned bootstrap'),
      );
    });

    test('uses the resolved manager-aware flutter command', () async {
      final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
        fallbackProjectName: 'demo_app',
        fallbackToolVersion: 'test',
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
      final processCalls = <String>[];
      final command = UpgradeCommand(
        logger: logger,
        processRunner: (executable, arguments, {workingDirectory}) async {
          processCalls.add(
            '$executable ${arguments.join(' ')} @ $workingDirectory',
          );
          return ProcessResult(0, 0, 'ok', '');
        },
        projectPathProvider: () => tempDir.path,
        toolchainDetector: _recordingToolchainDetector,
      );
      final localRunner = CommandRunner<int>('agentic_base', 'test runner')
        ..addCommand(command);

      final exitCode = await localRunner.run(['upgrade']);

      expect(exitCode, equals(0));
      expect(
        processCalls,
        equals([
          'fvm flutter pub upgrade @ ${tempDir.path}',
        ]),
      );
      final restored = AgenticConfig(projectPath: tempDir.path).readMetadata(
        fallbackProjectName: 'demo_app',
        fallbackToolVersion: 'test',
      );
      expect(restored.harness.sdk.manager, FlutterSdkManager.fvm);
      expect(restored.harness.sdk.version, '3.41.6');
    });

    test('supports dry-run previews without running upgrades', () async {
      final metadataBefore = AgenticConfig(projectPath: tempDir.path).read();

      final exitCode = await runner.run(['upgrade', '--dry-run']);

      expect(exitCode, equals(0));
      expect(
        AgenticConfig(projectPath: tempDir.path).read(),
        equals(metadataBefore),
      );
    });
  });
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
