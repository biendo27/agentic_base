import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';

/// Runs Flutter/Dart tests for a specific feature or the entire project.
///
/// Usage:
///   `agentic_base eval`                  — run all tests
///   `agentic_base eval <feature>`        — run tests for a single feature
///   `agentic_base eval --coverage`       — run all tests with coverage
///   `agentic_base eval <feature> --coverage`
///
/// Must be executed inside an agentic_base project (checks .info/agentic.yaml).
class EvalCommand extends Command<int> {
  EvalCommand({required AgenticLogger logger}) : _logger = logger {
    argParser.addFlag(
      'coverage',
      negatable: false,
      help: 'Collect and report test coverage.',
    );
  }

  final AgenticLogger _logger;

  @override
  String get name => 'eval';

  @override
  String get description =>
      'Run tests for a feature or the entire project. '
      'Use --coverage to collect coverage data.';

  @override
  String get invocation => 'agentic_base eval [feature] [--coverage]';

  @override
  Future<int> run() async {
    final projectPath = Directory.current.path;
    final config = AgenticConfig(projectPath: projectPath);

    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    final args = argResults!;
    final rest = args.rest;
    final withCoverage = args['coverage'] as bool;
    final featureName = rest.isNotEmpty ? rest.first : null;

    if (featureName != null) {
      return _runFeatureTests(
        projectPath: projectPath,
        featureName: featureName,
        withCoverage: withCoverage,
      );
    }

    return _runAllTests(projectPath: projectPath, withCoverage: withCoverage);
  }

  // ---------------------------------------------------------------------------
  // Internal runners
  // ---------------------------------------------------------------------------

  Future<int> _runFeatureTests({
    required String projectPath,
    required String featureName,
    required bool withCoverage,
  }) async {
    final testDir = Directory('$projectPath/test/features/$featureName');

    if (!testDir.existsSync()) {
      _logger.err(
        'No test directory found for feature "$featureName". '
        'Expected: test/features/$featureName/',
      );
      return 1;
    }

    _logger.header('Eval: $featureName${withCoverage ? " (coverage)" : ""}');

    return _executeTests(
      projectPath: projectPath,
      flutterArgs: _buildFlutterTestArgs(
        testPath: 'test/features/$featureName',
        withCoverage: withCoverage,
      ),
    );
  }

  Future<int> _runAllTests({
    required String projectPath,
    required bool withCoverage,
  }) async {
    _logger.header('Eval: all tests${withCoverage ? " (coverage)" : ""}');

    return _executeTests(
      projectPath: projectPath,
      flutterArgs: _buildFlutterTestArgs(
        testPath: null,
        withCoverage: withCoverage,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<String> _buildFlutterTestArgs({
    required String? testPath,
    required bool withCoverage,
  }) => [
    'test',
    if (withCoverage) '--coverage',
    if (testPath != null) testPath,
  ];

  Future<int> _executeTests({
    required String projectPath,
    required List<String> flutterArgs,
  }) async {
    final progress = _logger.progress(
      'Running flutter ${flutterArgs.join(' ')}',
    );

    try {
      final process = await Process.start(
        'flutter',
        flutterArgs,
        workingDirectory: projectPath,
      );

      // Buffer stdout/stderr; flutter test writes test results to stdout.
      final stdoutBuffer = StringBuffer();
      process.stdout
          .transform(const SystemEncoding().decoder)
          .listen(stdoutBuffer.write);

      final stderrBuffer = StringBuffer();
      process.stderr
          .transform(const SystemEncoding().decoder)
          .listen(stderrBuffer.write);

      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        progress.complete('Tests passed');
      } else {
        progress.fail('Tests failed');
      }

      final output = stdoutBuffer.toString().trim();
      if (output.isNotEmpty) {
        _logger
          ..info('')
          ..info(output);
      }

      final errOutput = stderrBuffer.toString().trim();
      if (errOutput.isNotEmpty) {
        _logger.err(errOutput);
      }

      _printSummary(output: output, exitCode: exitCode);

      return exitCode == 0 ? 0 : 1;
    } on ProcessException catch (e) {
      progress.fail('Could not launch flutter');
      _logger.err('flutter not found or not runnable: $e');
      return 1;
    }
  }

  /// Parse and re-print a compact pass/fail summary line.
  void _printSummary({required String output, required int exitCode}) {
    // flutter test emits: "00:01 +3: All tests passed!" or "00:01 +2 -1: ..."
    final summaryLine =
        output
            .split('\n')
            .lastWhere(
              (l) =>
                  l.contains('passed') ||
                  l.contains('failed') ||
                  l.contains('+'),
              orElse: () => '',
            )
            .trim();

    _logger.info('');
    if (exitCode == 0) {
      _logger.success(
        summaryLine.isNotEmpty ? summaryLine : 'All tests passed.',
      );
    } else {
      _logger.err(
        summaryLine.isNotEmpty ? summaryLine : 'Some tests failed.',
      );
    }
  }
}
