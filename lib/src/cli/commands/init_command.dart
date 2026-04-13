import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/init_project_metadata_resolver.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Adds agentic_base scaffolding to an EXISTING Flutter project.
///
/// Non-destructive: never overwrites files that already exist.
///
/// Usage: `agentic_base init`
class InitCommand extends Command<int> {
  InitCommand({required AgenticLogger logger}) : _logger = logger {
    argParser.addOption(
      'ci-provider',
      help: 'CI provider: github or gitlab',
      allowed: supportedCiProviders,
    );
  }

  final AgenticLogger _logger;

  @override
  String get name => 'init';

  @override
  String get description =>
      'Add agentic_base scaffolding to an existing Flutter project.';

  @override
  String get invocation => 'agentic_base init';

  @override
  Future<int> run() async {
    final projectPath = Directory.current.path;

    // Must be inside a Flutter project (pubspec.yaml must exist).
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command inside a Flutter project root.',
      );
      return 1;
    }

    final config = AgenticConfig(projectPath: projectPath);
    final pubspecContent = pubspecFile.readAsStringSync();
    final resolver = InitProjectMetadataResolver();
    final metadata = resolver.resolve(
      projectPath: projectPath,
      pubspecContent: pubspecContent,
      projectNameFallback: p.basename(projectPath),
      explicitCiProvider: argResults!['ci-provider'] as String?,
    );
    final projectName = metadata.projectName;
    final modeLabel = config.exists ? 'Repairing' : 'Initialising';

    _logger
      ..header('$modeLabel agentic_base...')
      ..info(
        'Resolved state management: ${metadata.stateManagement} '
        '(${metadata.provenance['state_management']!.wireName})',
      );
    final added = <String>[];

    config.writeMetadata(metadata);
    added.add('.info/agentic.yaml');

    // Write optional scaffolding files — skip if already present.
    _writeIfAbsent(
      path: p.join(projectPath, 'AGENTS.md'),
      content: _agentsMdContent(projectName),
      added: added,
    );

    _writeIfAbsent(
      path: p.join(projectPath, 'CLAUDE.md'),
      content: _claudeMdContent(projectName),
      added: added,
    );

    _writeIfAbsent(
      path: p.join(projectPath, 'Makefile'),
      content: _makefileContent,
      added: added,
    );

    _writeIfAbsent(
      path: p.join(projectPath, 'analysis_options.yaml'),
      content: _safeAnalysisOptionsContent,
      added: added,
    );

    // tools/ scripts
    final toolsDir = Directory(p.join(projectPath, 'tools'));
    if (!toolsDir.existsSync()) {
      toolsDir.createSync(recursive: true);
    }

    _writeIfAbsent(
      path: p.join(projectPath, 'tools', 'format.sh'),
      content: _formatShContent,
      added: added,
    );

    _writeIfAbsent(
      path: p.join(projectPath, 'tools', 'analyze.sh'),
      content: _analyzeShContent,
      added: added,
    );

    // Report summary.
    _logger
      ..info('')
      ..success('Initialisation complete.')
      ..info('')
      ..info('Files created or updated:');
    for (final f in added) {
      _logger.info('  + $f');
    }
    _logger
      ..info('')
      ..info('Next steps:')
      ..info('  flutter pub get')
      ..info('  agentic_base doctor');

    return 0;
  }

  // ---------------------------------------------------------------------------
  // File writing helper
  // ---------------------------------------------------------------------------

  /// Write [content] to [path] only if the file does not already exist.
  void _writeIfAbsent({
    required String path,
    required String content,
    required List<String> added,
  }) {
    final file = File(path);
    if (file.existsSync()) return;
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    added.add(p.relative(path, from: Directory.current.path));
  }
}

// ---------------------------------------------------------------------------
// Scaffold content templates
// ---------------------------------------------------------------------------

String _agentsMdContent(String projectName) => '''
# AGENTS.md — $projectName

This file provides guidance to AI coding agents (GPT, Claude, Gemini, etc.)
working in this repository.

## Project Overview
Flutter application managed with agentic_base.

## Code Conventions
- State management: see `.info/agentic.yaml`
- Linting: `dart analyze`
- Formatting: `dart format .`

## Key Commands
```
make analyze   # lint
make format    # format
make test      # run tests
```

## Architecture
See the repo `docs/` directory for architecture details when that doc set is present.
''';

String _claudeMdContent(String projectName) => '''
# CLAUDE.md — $projectName

Instructions for Claude Code when working in this repository.

## Project
Flutter application. Run `agentic_base doctor` to verify tooling.

## Workflows
- Implement → Test → Review
- Keep files under 200 lines
- Follow existing module patterns

## Commands
- `flutter pub get` — install dependencies
- `dart analyze` — lint
- `dart format .` — format
- `flutter test` — run tests
''';

const _makefileContent = '''
.PHONY: analyze format test build

analyze:
\tdart analyze

format:
\tdart format .

test:
\tflutter test

build:
\tflutter build apk
''';

const _safeAnalysisOptionsContent = '''
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    public_member_api_docs: false
''';

const _formatShContent = '''
#!/bin/bash
set -e
dart format .
''';

const _analyzeShContent = '''
#!/bin/bash
set -e
dart analyze --fatal-infos
''';
