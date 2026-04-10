import 'dart:io';

import 'package:agentic_base/src/cli/commands/init_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('InitCommand', () {
    late Directory tempDir;
    late String stableCwd;
    late CommandRunner<int> runner;

    setUpAll(() {
      stableCwd = Directory.current.path;
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('init-command-test-');
      Directory.current = tempDir.path;
      File(
        p.join(tempDir.path, 'pubspec.yaml'),
      ).writeAsStringSync(
        'name: demo_app\ndependencies:\n  flutter_bloc: any\n',
      );
      runner = CommandRunner<int>('agentic_base', 'test runner')
        ..addCommand(InitCommand(logger: AgenticLogger()));
    });

    tearDown(() {
      Directory.current = stableCwd;
      tempDir.deleteSync(recursive: true);
    });

    test('infers gitlab provider from existing CI files', () async {
      File(
        p.join(tempDir.path, '.gitlab-ci.yml'),
      ).writeAsStringSync('include: []');

      final exitCode = await runner.run(['init']);

      expect(exitCode, equals(0));
      final config = AgenticConfig(projectPath: tempDir.path).read();
      expect(config['ci_provider'], equals('gitlab'));
    });

    test('accepts an explicit ci-provider override', () async {
      final exitCode = await runner.run(['init', '--ci-provider', 'github']);

      expect(exitCode, equals(0));
      final config = AgenticConfig(projectPath: tempDir.path).read();
      expect(config['ci_provider'], equals('github'));
    });
  });
}
