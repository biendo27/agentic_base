import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';

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
    final config = AgenticConfig(projectPath: Directory.current.path);
    if (!config.exists) {
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
      workingDirectory: Directory.current.path,
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
      workingDirectory: Directory.current.path,
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
}
