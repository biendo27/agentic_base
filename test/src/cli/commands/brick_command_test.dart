import 'dart:io';

import 'package:agentic_base/src/cli/commands/brick_command.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('BrickCommand', () {
    late Directory tempDir;
    late String stableCwd;
    late CommandRunner<int> runner;

    setUpAll(() {
      stableCwd = Directory.current.path;
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('brick-command-test-');
      Directory(p.join(tempDir.path, '.info')).createSync(recursive: true);
      File(
        p.join(tempDir.path, '.info', 'agentic.yaml'),
      ).writeAsStringSync('project_name: demo_app\ncommunity_bricks: []\n');
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        BrickCommand(logger: AgenticLogger()),
      );
      Directory.current = tempDir.path;
    });

    tearDown(() {
      Directory.current = stableCwd;
      tempDir.deleteSync(recursive: true);
    });

    test(
      'supports dry-run add previews without touching agentic.yaml',
      () async {
        final before =
            File(
              p.join(tempDir.path, '.info', 'agentic.yaml'),
            ).readAsStringSync();

        final exitCode = await runner.run([
          'brick',
          'add',
          'demo_brick',
          '--dry-run',
        ]);

        expect(exitCode, equals(0));
        expect(
          File(
            p.join(tempDir.path, '.info', 'agentic.yaml'),
          ).readAsStringSync(),
          equals(before),
        );
      },
    );

    test(
      'supports dry-run remove previews without touching agentic.yaml',
      () async {
        final before =
            File(
              p.join(tempDir.path, '.info', 'agentic.yaml'),
            ).readAsStringSync();

        final exitCode = await runner.run([
          'brick',
          'remove',
          'demo_brick',
          '--dry-run',
        ]);

        expect(exitCode, equals(0));
        expect(
          File(
            p.join(tempDir.path, '.info', 'agentic.yaml'),
          ).readAsStringSync(),
          equals(before),
        );
      },
    );

    test('supports dry-run list previews', () async {
      final exitCode = await runner.run(['brick', 'list', '--dry-run']);

      expect(exitCode, equals(0));
    });
  });
}
