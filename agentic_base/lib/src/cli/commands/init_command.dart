import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Adds agentic_base scaffolding to an EXISTING Flutter project.
///
/// Non-destructive: never overwrites files that already exist.
///
/// Usage: `agentic_base init`
class InitCommand extends Command<int> {
  InitCommand({required AgenticLogger logger}) : _logger = logger;

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

    // Guard: already initialised.
    final config = AgenticConfig(projectPath: projectPath);
    if (config.exists) {
      _logger.warn(
        '.info/agentic.yaml already exists. '
        'Project is already initialised.',
      );
      return 0;
    }

    _logger.header('Initialising agentic_base...');

    // Detect existing state management from pubspec.
    final pubspecContent = pubspecFile.readAsStringSync();
    final detectedState = _detectStateManagement(pubspecContent);
    final projectName = _readProjectName(pubspecContent, projectPath);

    _logger.info(
      'Detected state management: '
      '${detectedState ?? 'none (defaulting to cubit)'}',
    );

    final stateManagement = detectedState ?? 'cubit';
    final added = <String>[];

    // Write .info/agentic.yaml (non-destructive — guarded above).
    AgenticConfig.createInitial(
      projectPath: projectPath,
      projectName: projectName,
      org: 'com.example',
      stateManagement: stateManagement,
      platforms: const ['android', 'ios'],
      flavors: const ['dev', 'staging', 'prod'],
      toolVersion: AgenticBaseCliRunner.version,
    );
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
      content: _analysisOptionsContent,
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
      ..info('Files added:');
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
  // Detection helpers
  // ---------------------------------------------------------------------------

  /// Scan pubspec.yaml content for known state management packages.
  ///
  /// Returns `'cubit'`, `'riverpod'`, `'mobx'`, or `null` if none found.
  String? _detectStateManagement(String pubspecContent) {
    if (pubspecContent.contains('flutter_bloc') ||
        pubspecContent.contains('bloc:')) {
      return 'cubit';
    }
    if (pubspecContent.contains('flutter_riverpod') ||
        pubspecContent.contains('riverpod')) {
      return 'riverpod';
    }
    if (pubspecContent.contains('flutter_mobx') ||
        pubspecContent.contains('mobx:')) {
      return 'mobx';
    }
    if (pubspecContent.contains('get:') || pubspecContent.contains('get_x')) {
      // GetX is not natively supported — warn and default to cubit.
      _logger.warn(
        'GetX detected. agentic_base does not support GetX natively. '
        'Defaulting to cubit config.',
      );
    }
    return null;
  }

  /// Extract `name:` field from pubspec content; fallback to directory name.
  String _readProjectName(String pubspecContent, String projectPath) {
    try {
      final yaml = loadYaml(pubspecContent);
      if (yaml is YamlMap) {
        final name = yaml['name'];
        if (name is String && name.isNotEmpty) return name;
      }
    } on Exception {
      // Ignore parse errors — fall through to fallback.
    }
    return p.basename(projectPath);
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
See `docs/system-architecture.md` for full architecture details.
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

const _analysisOptionsContent = '''
include: package:very_good_analysis/analysis_options.yaml

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
