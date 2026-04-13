import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

Future<int> runProjectCodeGeneration({
  required AgenticLogger logger,
  required String projectRoot,
  ProcessRunner processRunner = runProcess,
  bool announceHeader = false,
}) async {
  if (announceHeader) {
    logger.header('Running code generation...');
  }

  final buildProgress = logger.progress('Running build_runner');
  final buildResult = await processRunner('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ], workingDirectory: projectRoot);
  if (buildResult.exitCode != 0) {
    buildProgress.fail('build_runner failed');
    logger.err(buildResult.stderr.toString());
    return 1;
  }
  buildProgress.complete('build_runner done');

  final fmtProgress = logger.progress('Formatting code');
  final fmtResult = await processRunner('dart', [
    'format',
    'lib',
    'test',
  ], workingDirectory: projectRoot);
  if (fmtResult.exitCode != 0) {
    fmtProgress.fail('Format failed');
    logger.err(fmtResult.stderr.toString());
    return 1;
  }
  fmtProgress.complete('Formatted');
  return 0;
}

/// Runs code-generation pipeline: build_runner + format.
class GenCommand extends Command<int> {
  GenCommand({
    required AgenticLogger logger,
    ProcessRunner? processRunner,
    String Function()? projectPathProvider,
  }) : _logger = logger,
       _processRunner = processRunner ?? runProcess,
       _projectPathProvider = projectPathProvider;

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;

  @override
  String get name => 'gen';

  @override
  String get description =>
      'Run code-generation pipeline (build_runner + format).';

  @override
  Future<int> run() async {
    final projectRoot = _findProjectRoot(
      _projectPathProvider?.call() ?? Directory.current.path,
    );
    if (projectRoot == null) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    final exitCode = await runProjectCodeGeneration(
      logger: _logger,
      projectRoot: projectRoot,
      processRunner: _processRunner,
      announceHeader: true,
    );
    if (exitCode != 0) return exitCode;
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
