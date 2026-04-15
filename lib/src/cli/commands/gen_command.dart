import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

Future<int> runProjectCodeGeneration({
  required AgenticLogger logger,
  required String projectRoot,
  required ResolvedFlutterToolchain toolchain,
  ProcessRunner processRunner = runProcess,
  bool announceHeader = false,
}) async {
  if (announceHeader) {
    logger.header('Running code generation...');
  }

  final buildProgress = logger.progress('Running build_runner');
  final buildCommand = toolchain.dartCommand([
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  final buildResult = await processRunner(
    buildCommand.executable,
    buildCommand.arguments,
    workingDirectory: projectRoot,
  );
  if (buildResult.exitCode != 0) {
    buildProgress.fail('build_runner failed');
    logger.err(buildResult.stderr.toString());
    return 1;
  }
  buildProgress.complete('build_runner done');

  final fmtProgress = logger.progress('Formatting code');
  final formatCommand = toolchain.dartCommand([
    'format',
    'lib',
    'test',
  ]);
  final fmtResult = await processRunner(
    formatCommand.executable,
    formatCommand.arguments,
    workingDirectory: projectRoot,
  );
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
    FlutterToolchainDetector? toolchainDetector,
  }) : _logger = logger,
       _processRunner = processRunner ?? runProcess,
       _projectPathProvider = projectPathProvider,
       _toolchainDetector = toolchainDetector ?? detectFlutterToolchain;

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;
  final FlutterToolchainDetector _toolchainDetector;

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

    final config = AgenticConfig(projectPath: projectRoot);
    final metadata = config.readMetadata(
      fallbackProjectName: p.basename(projectRoot),
    );
    final toolchain = resolveProjectFlutterToolchain(
      projectPath: projectRoot,
      contract: metadata.harness.sdk,
      detector: _toolchainDetector,
    );
    final exitCode = await runProjectCodeGeneration(
      logger: _logger,
      projectRoot: projectRoot,
      toolchain: toolchain,
      processRunner: _processRunner,
      announceHeader: true,
    );
    if (exitCode != 0) return exitCode;
    _persistResolvedToolchain(config, metadata, toolchain);
    _logger.success('Code generation complete!');
    return 0;
  }

  void _persistResolvedToolchain(
    AgenticConfig config,
    ProjectMetadata metadata,
    ResolvedFlutterToolchain toolchain,
  ) {
    final existing = metadata.harness.sdk;
    if (existing.manager == toolchain.contract.manager &&
        existing.channel == toolchain.contract.channel &&
        existing.version == toolchain.contract.version &&
        existing.preferredManager == toolchain.contract.preferredManager &&
        existing.preferredVersion == toolchain.contract.preferredVersion) {
      return;
    }

    config.writeMetadata(
      metadata.copyWith(
        harness: metadata.harness.copyWith(sdk: toolchain.contract),
        provenance: {
          ...metadata.provenance,
          'harness.sdk.manager': MetadataProvenance.inferred,
          'harness.sdk.channel':
              toolchain.detected.channel == null
                  ? MetadataProvenance.defaulted
                  : MetadataProvenance.inferred,
          'harness.sdk.version': MetadataProvenance.inferred,
        },
      ),
    );
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
