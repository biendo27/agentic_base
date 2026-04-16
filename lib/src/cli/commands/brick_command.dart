import 'dart:io';

import 'package:agentic_base/src/cli/dry_run.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';

/// Top-level `brick` command — delegates to add / remove / list subcommands.
///
/// Usage:
///   agentic_base brick add `<name>`
///   agentic_base brick remove `<name>`
///   agentic_base brick list
class BrickCommand extends Command<int> {
  BrickCommand({required AgenticLogger logger}) : _logger = logger {
    addSubcommand(_BrickAddSubcommand(logger: _logger));
    addSubcommand(_BrickRemoveSubcommand(logger: _logger));
    addSubcommand(_BrickListSubcommand(logger: _logger));
  }

  final AgenticLogger _logger;

  @override
  String get name => 'brick';

  @override
  String get description => 'Manage community Mason bricks.';
}

// ---------------------------------------------------------------------------
// Subcommand: brick add
// ---------------------------------------------------------------------------

class _BrickAddSubcommand extends Command<int> {
  _BrickAddSubcommand({required AgenticLogger logger}) : _logger = logger {
    addDryRunFlag(argParser);
  }

  final AgenticLogger _logger;

  @override
  String get name => 'add';

  @override
  String get description => 'Fetch and install a brick from BrickHub.';

  @override
  String get invocation => 'agentic_base brick add <name>';

  @override
  Future<int> run() async {
    final dryRun = isDryRunEnabled(argResults!);
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      throw UsageException('No brick name provided.', usage);
    }

    final brickName = rest.first.trim();
    if (!_validBrickName.hasMatch(brickName)) {
      _logger.err(
        'Invalid brick name "$brickName". '
        'Use lowercase letters, digits, and underscores only.',
      );
      return 1;
    }

    // Require agentic project context.
    final config = AgenticConfig(projectPath: Directory.current.path);
    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    _logger.header('Adding brick: $brickName');
    if (dryRun) {
      final reporter =
          DryRunReporter(
              logger: _logger,
              commandName: 'brick add',
            )
            ..read('${Directory.current.path}/.info/agentic.yaml')
            ..command(
              ToolCommandSpec(
                executable: 'mason',
                arguments: ['add', brickName, '--global'],
              ),
              workingDirectory: Directory.current.path,
              label: 'fetch brick from BrickHub',
            )
            ..write('${Directory.current.path}/.info/agentic.yaml');
      return reporter.complete();
    }

    // Check mason is available.
    if (!await _masonAvailable()) return 1;

    final progress = _logger.progress('Fetching $brickName from BrickHub');
    final result = await Process.run(
      'mason',
      ['add', brickName, '--global'],
      workingDirectory: Directory.current.path,
    );

    if (result.exitCode != 0) {
      progress.fail('Failed to add brick');
      _logger.err((result.stderr as String).trim());
      return 1;
    }
    progress.complete('Brick "$brickName" added');

    // Record in agentic.yaml community_bricks list.
    _registerBrick(config, brickName, added: true);

    _logger.success('Done. Use: mason make $brickName');
    return 0;
  }

  static final _validBrickName = RegExp(r'^[a-z][a-z0-9_]*$');
}

// ---------------------------------------------------------------------------
// Subcommand: brick remove
// ---------------------------------------------------------------------------

class _BrickRemoveSubcommand extends Command<int> {
  _BrickRemoveSubcommand({required AgenticLogger logger}) : _logger = logger {
    addDryRunFlag(argParser);
  }

  final AgenticLogger _logger;

  @override
  String get name => 'remove';

  @override
  String get description => 'Remove an installed brick.';

  @override
  String get invocation => 'agentic_base brick remove <name>';

  @override
  Future<int> run() async {
    final dryRun = isDryRunEnabled(argResults!);
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      throw UsageException('No brick name provided.', usage);
    }

    final brickName = rest.first.trim();

    final config = AgenticConfig(projectPath: Directory.current.path);
    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    _logger.header('Removing brick: $brickName');
    if (dryRun) {
      final reporter =
          DryRunReporter(
              logger: _logger,
              commandName: 'brick remove',
            )
            ..read('${Directory.current.path}/.info/agentic.yaml')
            ..command(
              ToolCommandSpec(
                executable: 'mason',
                arguments: ['remove', brickName, '--global'],
              ),
              workingDirectory: Directory.current.path,
            )
            ..write('${Directory.current.path}/.info/agentic.yaml');
      return reporter.complete();
    }

    if (!await _masonAvailable()) return 1;

    final progress = _logger.progress('Removing $brickName');
    final result = await Process.run(
      'mason',
      ['remove', brickName, '--global'],
      workingDirectory: Directory.current.path,
    );

    if (result.exitCode != 0) {
      progress.fail('Failed to remove brick');
      _logger.err((result.stderr as String).trim());
      return 1;
    }
    progress.complete('Brick "$brickName" removed');

    // Remove from agentic.yaml community_bricks list.
    _registerBrick(config, brickName, added: false);

    _logger.success('Brick "$brickName" removed successfully.');
    return 0;
  }
}

// ---------------------------------------------------------------------------
// Subcommand: brick list
// ---------------------------------------------------------------------------

class _BrickListSubcommand extends Command<int> {
  _BrickListSubcommand({required AgenticLogger logger}) : _logger = logger {
    addDryRunFlag(argParser);
  }

  final AgenticLogger _logger;

  @override
  String get name => 'list';

  @override
  String get description => 'List community bricks recorded in agentic.yaml.';

  @override
  String get invocation => 'agentic_base brick list';

  @override
  Future<int> run() async {
    final dryRun = isDryRunEnabled(argResults!);
    final config = AgenticConfig(projectPath: Directory.current.path);
    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    if (dryRun) {
      final reporter =
          DryRunReporter(
              logger: _logger,
              commandName: 'brick list',
            )
            ..read('${Directory.current.path}/.info/agentic.yaml')
            ..note('would print recorded community bricks only');
      return reporter.complete();
    }

    final data = config.read();
    final bricks = List<String>.from(
      (data['community_bricks'] as List?)?.cast<String>() ?? [],
    );

    if (bricks.isEmpty) {
      _logger.info(
        'No community bricks installed. '
        'Use: agentic_base brick add <name>',
      );
      return 0;
    }

    _logger.header('Installed community bricks');
    for (final b in bricks) {
      _logger.info('  * $b');
    }
    return 0;
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/// Returns `true` if `mason` CLI is accessible on PATH.
Future<bool> _masonAvailable() async {
  try {
    final result = await Process.run('mason', ['--version']);
    return result.exitCode == 0;
  } on ProcessException {
    return false;
  }
}

/// Add or remove [brickName] from the `community_bricks` list in agentic.yaml.
void _registerBrick(
  AgenticConfig config,
  String brickName, {
  required bool added,
}) {
  final data = config.read();
  final bricks = List<String>.from(
    (data['community_bricks'] as List?)?.cast<String>() ?? [],
  );

  if (added) {
    if (!bricks.contains(brickName)) bricks.add(brickName);
  } else {
    bricks.remove(brickName);
  }

  config.write({'community_bricks': bricks});
}
