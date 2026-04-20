import 'dart:convert';
import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/observability/run_event_reporter.dart';
import 'package:agentic_base/src/observability/telemetry_bundle.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

class InspectCommand extends Command<int> {
  InspectCommand({
    required AgenticLogger logger,
    String Function()? projectPathProvider,
    void Function(String)? emit,
  }) : _logger = logger,
       _projectPathProvider = projectPathProvider,
       _emit = emit {
    argParser
      ..addOption(
        'kind',
        defaultsTo: 'verify',
        allowed: const ['verify', 'release-preflight', 'release'],
        help:
            'Evidence run kind to inspect when no explicit run directory is provided.',
      )
      ..addOption(
        'format',
        defaultsTo: 'markdown',
        allowed: const ['markdown', 'json'],
        help: 'Render the derived run ledger as markdown or json.',
      );
  }

  final AgenticLogger _logger;
  final String Function()? _projectPathProvider;
  final void Function(String)? _emit;

  @override
  String get name => 'inspect';

  @override
  String get description =>
      'Inspect the latest local evidence bundle and derive a run ledger.';

  @override
  String get invocation =>
      'agentic_base inspect [run-dir] [--kind verify] [--format markdown|json]';

  @override
  Future<int> run() async {
    final args = argResults!;
    final projectPath = _projectPathProvider?.call() ?? Directory.current.path;
    final explicitRunDirectory = args.rest.isNotEmpty ? args.rest.first : null;
    final format = args['format'] as String;

    try {
      final runDirectoryPath =
          explicitRunDirectory != null
              ? p.normalize(
                p.isAbsolute(explicitRunDirectory)
                    ? explicitRunDirectory
                    : p.join(projectPath, explicitRunDirectory),
              )
              : _resolveLatestRunDirectory(
                projectPath: projectPath,
                runKind: args['kind'] as String,
              );
      final inspection = const RunEventReporter().inspect(runDirectoryPath);
      final output =
          format == 'json'
              ? const JsonEncoder.withIndent(
                '  ',
              ).convert(inspection.ledger.toJson())
              : inspection.markdown;
      (_emit ?? _logger.info)(output);
      return 0;
    } on FormatException catch (error) {
      _logger.err(error.message);
      return 1;
    } on Exception catch (error) {
      _logger.err('$error');
      return 1;
    }
  }

  String _resolveLatestRunDirectory({
    required String projectPath,
    required String runKind,
  }) {
    final config = AgenticConfig(projectPath: projectPath);
    if (!config.exists) {
      throw const FormatException(
        'No .info/agentic.yaml found. Provide an explicit evidence run directory or run this inside an agentic_base project.',
      );
    }

    final metadata = config.readMetadata(
      fallbackProjectName: p.basename(projectPath),
    );
    return TelemetryBundle.resolveRunDirectory(
      projectPath: projectPath,
      evidenceDir: metadata.harness.eval.evidenceDir,
      runKind: runKind,
    );
  }
}
