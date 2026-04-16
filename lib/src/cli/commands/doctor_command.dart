import 'dart:io';

import 'package:agentic_base/src/cli/dry_run.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Checks environment health for the current toolchain contract.
class DoctorCommand extends Command<int> {
  DoctorCommand({
    required AgenticLogger logger,
    ProcessRunner? processRunner,
    String Function()? projectPathProvider,
    FlutterToolchainDetector? toolchainDetector,
  }) : _logger = logger,
       _processRunner = processRunner ?? runProcess,
       _projectPathProvider = projectPathProvider,
       _toolchainDetector = toolchainDetector ?? detectFlutterToolchain {
    addDryRunFlag(argParser);
  }

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;
  final FlutterToolchainDetector _toolchainDetector;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check environment health for agentic_base.';

  @override
  Future<int> run() async {
    final dryRun = isDryRunEnabled(argResults!);
    final projectPath = _projectPathProvider?.call() ?? Directory.current.path;
    final config = AgenticConfig(projectPath: projectPath);

    if (dryRun) {
      return _preview(projectPath: projectPath, config: config);
    }

    _logger.header('agentic_base doctor');
    var allGood = true;

    if (config.exists) {
      final metadata = config.readMetadata(
        fallbackProjectName: p.basename(projectPath),
      );
      final declared = metadata.harness.sdk;

      _logger.info(
        '  Declared Flutter contract: '
        '${declared.preferredManager.wireName} '
        '${declared.preferredVersion} (${declared.channel})',
      );

      late final ResolvedFlutterToolchain resolved;
      try {
        resolved = resolveProjectFlutterToolchain(
          projectPath: projectPath,
          contract: declared,
          detector: _toolchainDetector,
        );
      } on FlutterToolchainResolutionException catch (error) {
        _logger.err('  ${error.message}');
        return _finish(allGood: false);
      }

      _logger.info(
        '  Resolved Flutter toolchain: '
        '${resolved.contract.manager.wireName} '
        '${resolved.contract.version} (${resolved.contract.channel})',
      );

      if (!resolved.detected.matches(declared)) {
        _logger.err(
          '  Flutter contract mismatch: expected '
          '${declared.preferredManager.wireName} '
          '${declared.preferredVersion}/${declared.channel}, found '
          '${resolved.detected.manager.wireName} '
          '${resolved.detected.version ?? 'unknown'}/'
          '${resolved.detected.channel ?? 'unknown'}',
        );
        allGood = false;
      } else {
        _logger.success('  Flutter contract matches the manifest.');
      }

      allGood &= await _checkCommand(
        label: 'Dart SDK',
        command: resolved.dartCommand(['--version']),
        workingDirectory: projectPath,
      );
      allGood &= await _checkOptional(
        label: 'FVM',
        command: const ToolCommandSpec(
          executable: 'fvm',
          arguments: ['--version'],
        ),
        workingDirectory: projectPath,
      );
      allGood &= await _checkOptional(
        label: 'Puro',
        command: const ToolCommandSpec(
          executable: 'puro',
          arguments: ['--version'],
        ),
        workingDirectory: projectPath,
      );
      allGood &= await _checkDartPackage(
        'build_runner',
        command: resolved.dartCommand(['pub', 'global', 'list']),
        workingDirectory: projectPath,
      );
      allGood &= await _checkDartPackage(
        'mason',
        command: resolved.dartCommand(['pub', 'global', 'list']),
        workingDirectory: projectPath,
      );
    } else {
      allGood &= await _checkCommand(
        label: 'Flutter SDK',
        command: const ToolCommandSpec(
          executable: 'flutter',
          arguments: ['--version'],
        ),
        workingDirectory: projectPath,
      );
      allGood &= await _checkCommand(
        label: 'Dart SDK',
        command: const ToolCommandSpec(
          executable: 'dart',
          arguments: ['--version'],
        ),
        workingDirectory: projectPath,
      );
      allGood &= await _checkOptional(
        label: 'FVM',
        command: const ToolCommandSpec(
          executable: 'fvm',
          arguments: ['--version'],
        ),
        workingDirectory: projectPath,
      );
      allGood &= await _checkOptional(
        label: 'Puro',
        command: const ToolCommandSpec(
          executable: 'puro',
          arguments: ['--version'],
        ),
        workingDirectory: projectPath,
      );
      allGood &= await _checkDartPackage(
        'build_runner',
        command: const ToolCommandSpec(
          executable: 'dart',
          arguments: ['pub', 'global', 'list'],
        ),
        workingDirectory: projectPath,
      );
      allGood &= await _checkDartPackage(
        'mason',
        command: const ToolCommandSpec(
          executable: 'dart',
          arguments: ['pub', 'global', 'list'],
        ),
        workingDirectory: projectPath,
      );
    }

    return _finish(allGood: allGood);
  }

  int _preview({
    required String projectPath,
    required AgenticConfig config,
  }) {
    final reporter = DryRunReporter(logger: _logger, commandName: 'doctor');
    if (config.exists) {
      final metadata = config.readMetadata(
        fallbackProjectName: p.basename(projectPath),
      );
      reporter
        ..read('$projectPath/.info/agentic.yaml')
        ..toolchainContract(metadata.harness.sdk)
        ..command(
          flutterCommandForManager(metadata.harness.sdk.preferredManager, [
            '--version',
          ]),
          workingDirectory: projectPath,
        )
        ..command(
          dartCommandForManager(metadata.harness.sdk.preferredManager, [
            '--version',
          ]),
          workingDirectory: projectPath,
        )
        ..command(
          dartCommandForManager(metadata.harness.sdk.preferredManager, [
            'pub',
            'global',
            'list',
          ]),
          workingDirectory: projectPath,
          label: 'inspect globally activated Dart packages',
        );
    } else {
      reporter
        ..command(
          const ToolCommandSpec(
            executable: 'flutter',
            arguments: ['--version'],
          ),
          workingDirectory: projectPath,
        )
        ..command(
          const ToolCommandSpec(executable: 'dart', arguments: ['--version']),
          workingDirectory: projectPath,
        );
    }
    reporter
      ..command(
        const ToolCommandSpec(executable: 'fvm', arguments: ['--version']),
        workingDirectory: projectPath,
        label: 'check optional FVM installation',
      )
      ..command(
        const ToolCommandSpec(executable: 'puro', arguments: ['--version']),
        workingDirectory: projectPath,
        label: 'check optional Puro installation',
      );
    return reporter.complete();
  }

  Future<bool> _checkCommand({
    required String label,
    required ToolCommandSpec command,
    required String workingDirectory,
  }) async {
    try {
      final result = await _processRunner(
        command.executable,
        command.arguments,
        workingDirectory: workingDirectory,
      );
      if (result.exitCode == 0) {
        final rawOutput =
            '${result.stdout}\n${result.stderr}'.trim().split('\n').firstOrNull;
        final version =
            rawOutput == null || rawOutput.isEmpty
                ? command.toString()
                : rawOutput;
        _logger.success('  $label: $version');
        return true;
      }
      _logger.err('  $label: not working (exit ${result.exitCode})');
      return false;
    } on ProcessException {
      _logger.err('  $label: not found');
      return false;
    }
  }

  Future<bool> _checkOptional({
    required String label,
    required ToolCommandSpec command,
    required String workingDirectory,
  }) async {
    try {
      final result = await _processRunner(
        command.executable,
        command.arguments,
        workingDirectory: workingDirectory,
      );
      if (result.exitCode == 0) {
        final rawOutput =
            '${result.stdout}\n${result.stderr}'.trim().split('\n').firstOrNull;
        final version =
            rawOutput == null || rawOutput.isEmpty
                ? command.toString()
                : rawOutput;
        _logger.success('  $label: $version');
        return true;
      }
      _logger.warn('  $label: not working (optional)');
      return true;
    } on ProcessException {
      _logger.warn('  $label: not installed (optional)');
      return true;
    }
  }

  Future<bool> _checkDartPackage(
    String package, {
    required ToolCommandSpec command,
    required String workingDirectory,
  }) async {
    try {
      final result = await _processRunner(
        command.executable,
        command.arguments,
        workingDirectory: workingDirectory,
      );
      final output = '${result.stdout}';
      if (RegExp('(?:^|\\n)$package ').hasMatch(output)) {
        _logger.success('  $package: installed (global)');
        return true;
      }
      _logger.warn('  $package: not globally activated (optional)');
      return true;
    } on ProcessException {
      _logger.warn('  $package: could not check');
      return true;
    }
  }

  int _finish({required bool allGood}) {
    _logger.info('');
    if (allGood) {
      _logger.success('All checks passed!');
    } else {
      _logger.warn('Some checks failed. See above for details.');
    }
    return allGood ? 0 : 1;
  }
}

extension on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
