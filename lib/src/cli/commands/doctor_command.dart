import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';

/// Checks environment health: Flutter SDK, Dart SDK, FVM, build_runner.
class DoctorCommand extends Command<int> {
  DoctorCommand({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check environment health for agentic_base.';

  @override
  Future<int> run() async {
    _logger.header('agentic_base doctor');

    var allGood = true;

    final config = AgenticConfig(projectPath: Directory.current.path);
    if (config.exists) {
      final metadata = config.readMetadata();
      final declared = metadata.harness.sdk;
      final detected = detectFlutterToolchain(
        manager: declared.manager,
        projectPath: Directory.current.path,
      );
      _logger.info(
        '  Declared Flutter contract: '
        '${declared.manager.wireName} ${declared.version} (${declared.channel})',
      );
      if (!detected.available) {
        _logger.err(
          '  Local Flutter toolchain: unavailable via ${detected.command}'
          '${detected.problem == null ? '' : ' (${detected.problem})'}',
        );
        allGood = false;
      } else {
        _logger.info(
          '  Local Flutter toolchain: '
          '${detected.version ?? 'unknown'} (${detected.channel ?? 'unknown'})',
        );
        if (!detected.matches(declared)) {
          _logger.err(
            '  Flutter contract mismatch: expected '
            '${declared.version}/${declared.channel}, found '
            '${detected.version ?? 'unknown'}/${detected.channel ?? 'unknown'}',
          );
          allGood = false;
        } else {
          _logger.success('  Flutter contract matches the manifest.');
        }
      }
    } else {
      allGood &= await _check('Flutter SDK', 'flutter', ['--version']);
    }

    allGood &= await _check('Dart SDK', 'dart', ['--version']);
    allGood &= await _checkOptional('FVM', 'fvm', ['--version']);
    allGood &= await _checkOptional('Puro', 'puro', ['--version']);
    allGood &= await _checkDartPackage('build_runner');
    allGood &= await _checkDartPackage('mason');

    _logger.info('');
    if (allGood) {
      _logger.success('All checks passed!');
    } else {
      _logger.warn('Some checks failed. See above for details.');
    }

    return allGood ? 0 : 1;
  }

  Future<bool> _check(String label, String cmd, List<String> args) async {
    try {
      final result = await Process.run(cmd, args);
      if (result.exitCode == 0) {
        final version = (result.stdout as String).split('\n').first.trim();
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

  Future<bool> _checkOptional(
    String label,
    String cmd,
    List<String> args,
  ) async {
    try {
      final result = await Process.run(cmd, args);
      if (result.exitCode == 0) {
        final version = (result.stdout as String).split('\n').first.trim();
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

  Future<bool> _checkDartPackage(String package) async {
    try {
      final result = await Process.run(
        'dart',
        ['pub', 'global', 'list'],
      );
      final output = result.stdout as String;
      // Word-boundary match to avoid e.g. "mason" matching "mason_logger"
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
}
