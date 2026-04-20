import 'dart:io';

import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

String _readRepoFile(String relativePath) {
  return File(p.join(Directory.current.path, relativePath)).readAsStringSync();
}

List<String> _meaningfulIgnoreLines(String relativePath) {
  return _readRepoFile(relativePath)
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toList();
}

File _appBrickFile(String relativePath) {
  return File(
    p.join(
      Directory.current.path,
      'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}',
      relativePath,
    ),
  );
}

void main() {
  test('pubignore keeps generated brick docs in the package archive', () {
    final pubignoreLines = _meaningfulIgnoreLines('.pubignore');

    expect(pubignoreLines, contains('/docs/'));
    expect(pubignoreLines, isNot(contains('docs/')));

    for (final docPath in const <String>[
      'docs/01-architecture.md',
      'docs/02-coding-standards.md',
      'docs/03-state-management.md',
      'docs/04-network-layer.md',
      'docs/05-theming-guide.md',
      'docs/06-testing-guide.md',
      'docs/07-agentic-development-flow.md',
    ]) {
      expect(
        _appBrickFile(docPath).existsSync(),
        isTrue,
        reason: 'pub package must ship generated brick doc $docPath',
      );
    }
  });

  test('pubignore keeps hidden generated brick contract files in archive', () {
    final pubignoreLines = _meaningfulIgnoreLines('.pubignore');

    for (final allowPattern in const <String>[
      '!/bricks/agentic_app/__brick__/**/.gitignore',
      '!/bricks/agentic_app/__brick__/**/.gitlab-ci.yml',
      '!/bricks/agentic_app/__brick__/**/.github/**',
      '!/bricks/agentic_app/__brick__/**/.gitlab/**',
      '!/bricks/agentic_app/__brick__/**/.idea/**',
      '!/bricks/agentic_app/__brick__/**/.info/**',
      '!/bricks/agentic_app/__brick__/**/.vscode/**',
    ]) {
      expect(pubignoreLines, contains(allowPattern));
    }

    final hiddenContractPaths =
        GeneratedProjectContract.requiredPaths
            .where((path) => path.startsWith('.'))
            .toList();

    for (final relativePath in hiddenContractPaths) {
      expect(
        _appBrickFile(relativePath).existsSync(),
        isTrue,
        reason: 'pub package must ship generated hidden path $relativePath',
      );
    }
  });

  test('gitignore files keep generated IDE contract files trackable', () {
    final rootGitignore = _readRepoFile('.gitignore');
    final generatedGitignore = _readRepoFile(
      'bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitignore',
    );

    expect(
      rootGitignore,
      contains(
        '!bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.vscode/launch.json',
      ),
    );
    expect(
      rootGitignore,
      contains(
        '!bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.vscode/settings.json',
      ),
    );
    expect(
      rootGitignore,
      contains(
        '!bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.idea/runConfigurations/*.xml',
      ),
    );

    expect(generatedGitignore, contains('!.vscode/launch.json'));
    expect(generatedGitignore, contains('!.vscode/settings.json'));
    expect(generatedGitignore, contains('!.idea/runConfigurations/*.xml'));
    expect(generatedGitignore, contains('!env/*.env.example'));
  });
}
