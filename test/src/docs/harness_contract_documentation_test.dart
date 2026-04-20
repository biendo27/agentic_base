import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

String _readRepoFile(String relativePath) {
  return File(p.join(Directory.current.path, relativePath)).readAsStringSync();
}

void main() {
  test('root harness docs stay in shipped-state language', () {
    const files = <String>[
      'docs/08-harness-contract-v1.md',
      'docs/09-support-tier-matrix.md',
      'docs/10-manifest-schema.md',
      'docs/11-eval-and-evidence-model.md',
      'docs/12-approval-state-machine.md',
      'docs/13-flutter-adapter-boundaries.md',
      'docs/17-observability-contract.md',
      'docs/18-local-operator-reporting.md',
    ];
    const stalePhrases = <String>[
      'design target for upcoming implementation waves',
      'design target for later implementation waves',
      'design target for future generator changes',
      'design target for future implementation waves',
      'until generator code lands',
      'not yet fully enforced by the current generator',
      'the state model below defines the approval contract to implement',
    ];

    for (final file in files) {
      final contents = _readRepoFile(file);
      for (final phrase in stalePhrases) {
        expect(
          contents,
          isNot(contains(phrase)),
          reason: '$file still contains stale phrase: $phrase',
        );
      }
    }
  });

  test('deployment docs and gitflow guard share the same protected routes', () {
    final deploymentGuide = _readRepoFile('docs/06-deployment-guide.md');
    final gitflowGuard = _readRepoFile('.github/workflows/gitflow-guard.yml');

    for (final route in const <String>[
      '`feature/*` -> `develop`',
      '`release/*` -> `main`',
      '`hotfix/*` -> `main`',
    ]) {
      expect(deploymentGuide, contains(route));
    }

    expect(
      gitflowGuard,
      contains(
        'PRs into develop must come from feature/*, release/*, or hotfix/*.',
      ),
    );
    expect(
      gitflowGuard,
      contains('PRs into main must come from release/* or hotfix/*.'),
    );
  });

  test(
    'root and generated coding standards agree on extension-safe contract helpers',
    () {
      const files = <String>[
        'docs/03-code-standards.md',
        'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/02-coding-standards.md',
      ];

      for (final file in files) {
        final contents = _readRepoFile(file);
        expect(
          contents,
          contains(
            'raw data shape, defaults, and invariants that define the transport contract stay on the contract class',
          ),
        );
        expect(
          contents,
          contains(
            'pure convenience, serialization, and formatting helpers may stay in extensions',
          ),
        );
        expect(
          contents,
          isNot(
            contains(
              'invariants and value behavior live on the contract class',
            ),
          ),
        );
      }
    },
  );

  test(
    'repo and generated verify surfaces declare their custom test tags',
    () {
      final rootDartTestConfig = _readRepoFile('dart_test.yaml');
      final generatedDartTestConfig = _readRepoFile(
        'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/dart_test.yaml',
      );
      final testingGuide = _readRepoFile(
        'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md',
      );
      final verifyScript = _readRepoFile(
        'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh',
      );
      final inspectScript = _readRepoFile(
        'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/inspect-evidence.sh',
      );
      final appSmokeTest = _readRepoFile(
        'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test/app_smoke_test.dart',
      );

      expect(rootDartTestConfig, contains('slow-canary'));
      expect(generatedDartTestConfig, contains('app-smoke'));
      expect(testingGuide, contains('app-shell-smoke'));
      expect(testingGuide, contains('./tools/inspect-evidence.sh'));
      expect(verifyScript, contains('--exclude-tags app-smoke'));
      expect(verifyScript, contains('runtime-telemetry'));
      expect(verifyScript, contains('AGENTIC_RUNTIME_TELEMETRY_CONTEXT_FILE'));
      expect(inspectScript, contains('agentic_base inspect'));
      expect(verifyScript, contains('test/app_smoke_test.dart'));
      expect(appSmokeTest, contains('app-smoke'));
    },
  );
}
