import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/deploy/deploy_coordinator.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:test/test.dart';

void main() {
  group('DeployCoordinator', () {
    test(
      'routes GitHub staging deploys through the generated workflow file',
      () async {
        final calls = <String>[];
        final coordinator = DeployCoordinator(
          logger: AgenticLogger(),
          projectPath: '/tmp/demo',
          processRunner: _runner(calls, {
            'git --version': _ok(),
            'git rev-parse --is-inside-work-tree': _ok(stdout: 'true'),
            'git status --porcelain': _ok(),
            'git status --branch --porcelain=v2': _ok(
              stdout: '# branch.ab +0 -0',
            ),
            'gh --version': _ok(stdout: 'gh version 1.0.0'),
            'gh auth status': _ok(stdout: 'logged in'),
            'gh workflow run cd-staging.yml': _ok(),
            'gh run list --workflow cd-staging.yml --limit 1 --json url --jq .[0].url':
                _ok(stdout: 'https://example.test/runs/1'),
          }),
          delay: (_) async {},
        );

        final exitCode = await coordinator.deploy(
          environment: 'staging',
          ciProvider: CiProvider.github,
        );

        expect(exitCode, equals(0));
        expect(calls, contains('gh workflow run cd-staging.yml'));
      },
    );

    test('routes GitLab staging deploys through both generated manual jobs', () async {
      final calls = <String>[];
      final coordinator = DeployCoordinator(
        logger: AgenticLogger(),
        projectPath: '/tmp/demo',
        processRunner: _runner(calls, {
          'git --version': _ok(),
          'git rev-parse --is-inside-work-tree': _ok(stdout: 'true'),
          'git status --porcelain': _ok(),
          'git status --branch --porcelain=v2': _ok(
            stdout: '# branch.ab +0 -0',
          ),
          'git branch --show-current': _ok(stdout: 'main'),
          'glab --version': _ok(stdout: 'glab version 1.0.0'),
          'glab auth status': _ok(stdout: 'logged in'),
          'glab ci run --branch main': _ok(),
          'glab ci get --branch main --output json': _ok(
            stdout: '{"id":17,"web_url":"https://gitlab.example/pipelines/17"}',
          ),
          'glab ci trigger deploy_staging_android_internal --branch main --pipeline-id 17':
              _ok(),
          'glab ci trigger deploy_staging_testflight --branch main --pipeline-id 17':
              _ok(),
        }),
        delay: (_) async {},
      );

      final exitCode = await coordinator.deploy(
        environment: 'staging',
        ciProvider: CiProvider.gitlab,
      );

      expect(exitCode, equals(0));
      expect(
        calls,
        contains(
          'glab ci trigger deploy_staging_android_internal --branch main --pipeline-id 17',
        ),
      );
      expect(
        calls,
        contains(
          'glab ci trigger deploy_staging_testflight --branch main --pipeline-id 17',
        ),
      );
    });
  });
}

ProcessRunner _runner(
  List<String> calls,
  Map<String, ProcessResult> responses,
) {
  return (
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    final key = '$executable ${arguments.join(' ')}';
    calls.add(key);
    final result = responses[key];
    if (result == null) {
      throw StateError('Missing mocked process response for: $key');
    }
    return result;
  };
}

ProcessResult _ok({
  String stdout = '',
  String stderr = '',
}) {
  return ProcessResult(1, 0, stdout, stderr);
}
