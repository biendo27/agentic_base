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
}
