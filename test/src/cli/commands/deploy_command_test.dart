import 'dart:io';

import 'package:agentic_base/src/cli/commands/deploy_command.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DeployCommand', () {
    late Directory tempDir;
    late CommandRunner<int> runner;
    late String? recordedProjectPath;
    late String? recordedEnvironment;
    late CiProvider? recordedCiProvider;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('deploy-command-test-');
      Directory(p.join(tempDir.path, '.info')).createSync(recursive: true);
      File(
        p.join(tempDir.path, '.info', 'agentic.yaml'),
      ).writeAsStringSync(
        'project_name: demo_app\nci_provider: gitlab\n',
      );

      recordedProjectPath = null;
      recordedEnvironment = null;
      recordedCiProvider = null;

      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        DeployCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
          deployAction: ({
            required projectPath,
            required environment,
            required ciProvider,
          }) async {
            recordedProjectPath = projectPath;
            recordedEnvironment = environment;
            recordedCiProvider = ciProvider;
            return 0;
          },
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('routes deploy through the stored ci provider', () async {
      final exitCode = await runner.run(['deploy', 'staging']);

      expect(exitCode, equals(0));
      expect(
        p.canonicalize(recordedProjectPath!),
        equals(p.canonicalize(tempDir.path)),
      );
      expect(recordedEnvironment, equals('staging'));
      expect(recordedCiProvider, equals(CiProvider.gitlab));
    });

    test(
      'falls back to inferred provider when ci_provider is missing',
      () async {
        File(
          p.join(tempDir.path, '.info', 'agentic.yaml'),
        ).writeAsStringSync('project_name: demo_app\n');
        Directory(p.join(tempDir.path, '.github', 'workflows')).createSync(
          recursive: true,
        );

        final exitCode = await runner.run(['deploy', 'prod']);

        expect(exitCode, equals(0));
        expect(recordedCiProvider, equals(CiProvider.github));
      },
    );
  });
}
