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

    test(
      'writes safe analysis options without very_good_analysis include',
      () async {
        final exitCode = await runner.run(['init']);

        expect(exitCode, equals(0));
        final analysisOptions =
            File(
              p.join(tempDir.path, 'analysis_options.yaml'),
            ).readAsStringSync();
        expect(analysisOptions, isNot(contains('very_good_analysis')));
        expect(analysisOptions, contains('public_member_api_docs: false'));
      },
    );

    test('infers runtime metadata from project files', () async {
      Directory(p.join(tempDir.path, 'android', 'app')).createSync(
        recursive: true,
      );
      File(
        p.join(tempDir.path, 'android', 'app', 'build.gradle'),
      ).writeAsStringSync('applicationId "com.acme.demo_app"');
      Directory(p.join(tempDir.path, 'web')).createSync(recursive: true);
      File(p.join(tempDir.path, 'lib', 'main_dev.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('void main() {}');
      File(p.join(tempDir.path, 'lib', 'main_prod.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('void main() {}');
      File(
        p.join(tempDir.path, 'pubspec.yaml'),
      ).writeAsStringSync(
        'name: demo_app\ndependencies:\n  flutter_riverpod: any\n',
      );

      final exitCode = await runner.run(['init']);

      expect(exitCode, equals(0));
      final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
        fallbackProjectName: 'fallback',
        fallbackToolVersion: 'test',
      );
      expect(metadata.org, equals('com.acme'));
      expect(metadata.stateManagement, equals('riverpod'));
      expect(metadata.platforms, equals(['android', 'web']));
      expect(metadata.flavors, equals(['dev', 'prod']));
    });

    test(
      'repairs existing fabricated metadata using inferred project state',
      () async {
        Directory(p.join(tempDir.path, '.info')).createSync(recursive: true);
        File(
          p.join(tempDir.path, '.info', 'agentic.yaml'),
        ).writeAsStringSync(
          'project_name: demo_app\n'
          'org: com.example\n'
          'ci_provider: github\n'
          'state_management: cubit\n'
          'platforms:\n'
          '  - android\n'
          '  - ios\n'
          'flavors:\n'
          '  - dev\n'
          '  - staging\n'
          '  - prod\n',
        );
        Directory(p.join(tempDir.path, 'android', 'app')).createSync(
          recursive: true,
        );
        File(
          p.join(tempDir.path, 'android', 'app', 'build.gradle'),
        ).writeAsStringSync('applicationId "com.acme.demo_app"');
        Directory(p.join(tempDir.path, 'web')).createSync(recursive: true);
        File(p.join(tempDir.path, 'lib', 'main_prod.dart'))
          ..createSync(recursive: true)
          ..writeAsStringSync('void main() {}');
        File(
          p.join(tempDir.path, 'pubspec.yaml'),
        ).writeAsStringSync(
          'name: demo_app\ndependencies:\n  flutter_riverpod: any\n',
        );

        final exitCode = await runner.run(['init']);

        expect(exitCode, equals(0));
        final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
          fallbackProjectName: 'fallback',
          fallbackToolVersion: 'test',
        );
        expect(metadata.org, equals('com.acme'));
        expect(metadata.stateManagement, equals('riverpod'));
        expect(metadata.platforms, equals(['android', 'web']));
        expect(metadata.flavors, equals(['prod']));
      },
    );
  });
}
