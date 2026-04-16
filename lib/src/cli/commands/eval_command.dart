import 'dart:io';

import 'package:agentic_base/src/cli/dry_run.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Runs Flutter tests for a specific feature or the entire project.
class EvalCommand extends Command<int> {
  EvalCommand({
    required AgenticLogger logger,
    ProcessRunner? processRunner,
    String Function()? projectPathProvider,
    FlutterToolchainDetector? toolchainDetector,
  }) : _logger = logger,
       _processRunner = processRunner ?? runProcess,
       _projectPathProvider = projectPathProvider,
       _toolchainDetector = toolchainDetector ?? detectFlutterToolchain {
    argParser.addFlag(
      'coverage',
      negatable: false,
      help: 'Collect and report test coverage.',
    );
    addDryRunFlag(argParser);
  }

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;
  final FlutterToolchainDetector _toolchainDetector;

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
    final args = argResults!;
    final dryRun = isDryRunEnabled(args);
    final projectPath = _projectPathProvider?.call() ?? Directory.current.path;
    final config = AgenticConfig(projectPath: projectPath);

    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    final metadata = config.readMetadata(
      fallbackProjectName: p.basename(projectPath),
    );
    final featureName = args.rest.isNotEmpty ? args.rest.first : null;
    final withCoverage = args['coverage'] as bool;

    if (featureName != null) {
      final testDir = Directory('$projectPath/test/features/$featureName');
      if (!testDir.existsSync()) {
        _logger.err(
          'No test directory found for feature "$featureName". '
          'Expected: test/features/$featureName/',
        );
        return 1;
      }
    }

    if (dryRun) {
      final reporter =
          DryRunReporter(
              logger: _logger,
              commandName: 'eval',
            )
            ..read('$projectPath/.info/agentic.yaml')
            ..toolchainContract(metadata.harness.sdk)
            ..command(
              flutterCommandForManager(
                metadata.harness.sdk.preferredManager,
                _buildFlutterTestArgs(
                  testPath:
                      featureName == null ? null : 'test/features/$featureName',
                  withCoverage: withCoverage,
                ),
              ),
              workingDirectory: projectPath,
            );
      return reporter.complete();
    }

    final toolchain = resolveProjectFlutterToolchain(
      projectPath: projectPath,
      contract: metadata.harness.sdk,
      detector: _toolchainDetector,
    );
    final command = toolchain.flutterCommand(
      _buildFlutterTestArgs(
        testPath: featureName == null ? null : 'test/features/$featureName',
        withCoverage: withCoverage,
      ),
    );

    _logger.header(
      featureName == null
          ? 'Eval: all tests${withCoverage ? " (coverage)" : ""}'
          : 'Eval: $featureName${withCoverage ? " (coverage)" : ""}',
    );

    return _executeTests(projectPath: projectPath, command: command);
  }

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
    required ToolCommandSpec command,
  }) async {
    final progress = _logger.progress('Running $command');

    try {
      final result = await _processRunner(
        command.executable,
        command.arguments,
        workingDirectory: projectPath,
      );
      final output = '${result.stdout}'.trim();
      final errOutput = '${result.stderr}'.trim();

      if (result.exitCode == 0) {
        progress.complete('Tests passed');
      } else {
        progress.fail('Tests failed');
      }

      if (output.isNotEmpty) {
        _logger
          ..info('')
          ..info(output);
      }
      if (errOutput.isNotEmpty) {
        _logger.err(errOutput);
      }

      _printSummary(output: output, exitCode: result.exitCode);
      return result.exitCode == 0 ? 0 : 1;
    } on ProcessException catch (error) {
      progress.fail('Could not launch ${command.executable}');
      _logger.err('${command.executable} not found or not runnable: $error');
      return 1;
    }
  }

  void _printSummary({required String output, required int exitCode}) {
    final summaryLine =
        output
            .split('\n')
            .lastWhere(
              (line) =>
                  line.contains('passed') ||
                  line.contains('failed') ||
                  line.contains('+'),
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
