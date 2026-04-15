import 'dart:io';

import 'package:agentic_base/src/cli/commands/init_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
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
      final gitlabRoot =
          File(
            p.join(tempDir.path, '.gitlab-ci.yml'),
          ).readAsStringSync();
      expect(gitlabRoot, contains('.gitlab/ci/verify.yml'));
      expect(gitlabRoot, contains('.gitlab/ci/deploy.yml'));
    });

    test('accepts an explicit ci-provider override', () async {
      final exitCode = await runner.run(['init', '--ci-provider', 'github']);

      expect(exitCode, equals(0));
      final config = AgenticConfig(projectPath: tempDir.path).read();
      expect(config['ci_provider'], equals('github'));
    });

    test('materializes an honest agent-ready scaffold for init', () async {
      final exitCode = await runner.run(['init', '--ci-provider', 'github']);

      expect(exitCode, equals(0));
      expect(
        () => GeneratedProjectContract.validateAgentReadyRepository(
          tempDir.path,
          ciProvider: CiProvider.github,
        ),
        returnsNormally,
      );
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
        final makefile =
            File(p.join(tempDir.path, 'Makefile')).readAsStringSync();
        expect(analysisOptions, isNot(contains('very_good_analysis')));
        expect(analysisOptions, contains('public_member_api_docs: false'));
        expect(makefile, contains('./tools/lint.sh'));
        expect(makefile, contains('./tools/format.sh'));
        expect(makefile, contains('./tools/test.sh'));
        expect(makefile, contains('./tools/build.sh'));
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

    test(
      'fails rather than claiming thin adapters it did not create',
      () async {
        File(
          p.join(tempDir.path, 'AGENTS.md'),
        ).writeAsStringSync('custom repo instructions');
        File(
          p.join(tempDir.path, '.gitlab-ci.yml'),
        ).writeAsStringSync('include: []\n');

        final exitCode = await runner.run(['init']);

        expect(exitCode, equals(1));
        expect(
          File(
            p.join(tempDir.path, 'AGENTS.md'),
          ).readAsStringSync(),
          equals('custom repo instructions'),
        );
        expect(
          File(
            p.join(tempDir.path, '.info', 'agentic.yaml'),
          ).existsSync(),
          isFalse,
        );
        expect(File(p.join(tempDir.path, 'CLAUDE.md')).existsSync(), isFalse);
        expect(File(p.join(tempDir.path, 'README.md')).existsSync(), isFalse);
        expect(File(p.join(tempDir.path, 'Makefile')).existsSync(), isFalse);
        expect(
          File(
            p.join(tempDir.path, '.gitlab-ci.yml'),
          ).readAsStringSync(),
          equals('include: []\n'),
        );
        expect(Directory(p.join(tempDir.path, 'docs')).existsSync(), isFalse);
      },
    );

    test('persists preferred and resolved toolchain values honestly', () async {
      File(p.join(tempDir.path, '.fvmrc')).writeAsStringSync('stable\n');
      final localRunner = CommandRunner<int>('agentic_base', 'test runner')
        ..addCommand(
          InitCommand(
            logger: AgenticLogger(),
            toolchainDetector: _fallbackToolchainDetector,
          ),
        );

      final exitCode = await localRunner.run(['init']);

      expect(exitCode, equals(0));
      final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
        fallbackProjectName: 'fallback',
        fallbackToolVersion: 'test',
      );
      expect(metadata.harness.sdk.preferredManager, FlutterSdkManager.fvm);
      expect(metadata.harness.sdk.manager, FlutterSdkManager.system);
      expect(metadata.harness.sdk.version, '3.41.6');
    });
  });
}

DetectedFlutterToolchain _fallbackToolchainDetector({
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
