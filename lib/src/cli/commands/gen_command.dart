import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Runs code-generation pipeline: build_runner + format.
class GenCommand extends Command<int> {
  GenCommand({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

  @override
  String get name => 'gen';

  @override
  String get description =>
      'Run code-generation pipeline (build_runner + format).';

  @override
  Future<int> run() async {
    final projectRoot = _findProjectRoot(Directory.current.path);
    if (projectRoot == null) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    _logger.header('Running code generation...');

    // Step 1: build_runner
    final buildProgress = _logger.progress('Running build_runner');
    final buildResult = await Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: projectRoot,
    );
    if (buildResult.exitCode != 0) {
      buildProgress.fail('build_runner failed');
      _logger.err(buildResult.stderr.toString());
      return 1;
    }
    buildProgress.complete('build_runner done');

    // Step 2: format
    final fmtProgress = _logger.progress('Formatting code');
    final fmtResult = await Process.run(
      'dart',
      ['format', 'lib', 'test'],
      workingDirectory: projectRoot,
    );
    if (fmtResult.exitCode != 0) {
      fmtProgress.fail('Format failed');
      _logger.err(fmtResult.stderr.toString());
      return 1;
    }
    fmtProgress.complete('Formatted');

    _logger.success('Code generation complete!');
    return 0;
  }

  /// Walk up from [start] to find the nearest directory with agentic.yaml.
  static String? _findProjectRoot(String start) {
    var dir = start;
    while (true) {
      if (AgenticConfig(projectPath: dir).exists) return dir;
      final parent = p.dirname(dir);
      if (parent == dir) return null; // reached filesystem root
      dir = parent;
    }
  }
}
