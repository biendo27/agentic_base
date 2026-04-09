import 'dart:io';

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

    allGood &= await _check('Flutter SDK', 'flutter', ['--version']);
    allGood &= await _check('Dart SDK', 'dart', ['--version']);
    allGood &= await _checkOptional('FVM', 'fvm', ['--version']);
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
