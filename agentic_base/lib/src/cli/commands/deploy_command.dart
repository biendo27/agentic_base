import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';

/// Valid deployment environments.
const _validEnvironments = ['dev', 'staging', 'prod'];

/// Triggers GitHub Actions CD workflows for the specified environment.
///
/// Validates git state (clean + pushed) before triggering the workflow,
/// then runs `gh workflow run cd-<env>.yml` and prints the workflow URL.
class DeployCommand extends Command<int> {
  DeployCommand({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

  @override
  String get name => 'deploy';

  @override
  String get description =>
      'Trigger CI/CD deployment workflow for an environment.';

  @override
  String get invocation => 'agentic_base deploy <dev|staging|prod>';

  @override
  Future<int> run() async {
    final args = argResults!;
    final rest = args.rest;

    if (rest.isEmpty) {
      throw UsageException(
        'No environment provided. Use: dev, staging, or prod.',
        usage,
      );
    }

    final env = rest.first.toLowerCase();
    if (!_validEnvironments.contains(env)) {
      throw UsageException(
        'Invalid environment "$env". Must be one of: '
        '${_validEnvironments.join(', ')}.',
        usage,
      );
    }

    // Must be inside an agentic_base project.
    final config = AgenticConfig(projectPath: Directory.current.path);
    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    _logger.header('Deploy → $env');

    // Validate git tooling and state.
    final gitCheck = await _validateGitState();
    if (gitCheck != 0) return gitCheck;

    // Validate gh CLI availability and authentication.
    final ghCheck = await _validateGhCli();
    if (ghCheck != 0) return ghCheck;

    // Trigger the workflow.
    return _triggerWorkflow(env);
  }

  /// Ensures git is installed, working tree is clean, and branch is pushed.
  Future<int> _validateGitState() async {
    // Check git is installed.
    try {
      await Process.run('git', ['--version']);
    } on ProcessException {
      _logger.err('git not found. Install git and try again.');
      return 1;
    }

    // Confirm we are inside a git repository.
    final repoCheck = await Process.run(
      'git',
      ['rev-parse', '--is-inside-work-tree'],
      workingDirectory: Directory.current.path,
    );
    if (repoCheck.exitCode != 0) {
      _logger.err('Current directory is not inside a git repository.');
      return 1;
    }

    // Require clean working tree (no uncommitted changes).
    final statusResult = await Process.run(
      'git',
      ['status', '--porcelain'],
      workingDirectory: Directory.current.path,
    );
    if (statusResult.exitCode != 0) {
      _logger.err('Failed to check git status.');
      return 1;
    }
    final dirtyFiles = (statusResult.stdout as String).trim();
    if (dirtyFiles.isNotEmpty) {
      _logger
        ..err(
          'Working tree is not clean. Commit or stash changes before deploying.',
        )
        ..info('')
        ..info('Dirty files:');
      for (final line in dirtyFiles.split('\n')) {
        _logger.info('  $line');
      }
      return 1;
    }

    // Confirm local branch is not ahead of remote (i.e. changes are pushed).
    final aheadResult = await Process.run(
      'git',
      ['status', '--branch', '--porcelain=v2'],
      workingDirectory: Directory.current.path,
    );
    if (aheadResult.exitCode != 0) {
      _logger.err('Failed to check branch tracking state.');
      return 1;
    }

    final branchOutput = aheadResult.stdout as String;

    // branch.ab line looks like: # branch.ab +0 -0
    final abMatch = RegExp(r'# branch\.ab \+(\d+)').firstMatch(branchOutput);
    if (abMatch != null) {
      final ahead = int.tryParse(abMatch.group(1) ?? '0') ?? 0;
      if (ahead > 0) {
        _logger.err(
          'Local branch is $ahead commit(s) ahead of remote. '
          'Push your changes before deploying.',
        );
        return 1;
      }
    }

    _logger.success('  git: working tree clean and up-to-date');
    return 0;
  }

  /// Ensures gh CLI is installed and the user is authenticated.
  Future<int> _validateGhCli() async {
    // Check gh is installed.
    try {
      final versionResult = await Process.run('gh', ['--version']);
      if (versionResult.exitCode != 0) {
        _logger.err('gh CLI is installed but returned an error.');
        return 1;
      }
    } on ProcessException {
      _logger.err(
        'gh CLI not found. Install it from https://cli.github.com '
        'and authenticate with: gh auth login',
      );
      return 1;
    }

    // Check authentication status.
    final authResult = await Process.run('gh', ['auth', 'status']);
    if (authResult.exitCode != 0) {
      _logger.err(
        'gh CLI is not authenticated. Run: gh auth login',
      );
      return 1;
    }

    _logger.success('  gh: authenticated');
    return 0;
  }

  /// Triggers `cd-<env>.yml` via `gh workflow run` and prints the run URL.
  Future<int> _triggerWorkflow(String env) async {
    final workflowFile = 'cd-$env.yml';
    _logger.info('');

    final progress = _logger.progress('Triggering $workflowFile');

    final result = await Process.run(
      'gh',
      ['workflow', 'run', workflowFile],
      workingDirectory: Directory.current.path,
    );

    if (result.exitCode != 0) {
      progress.fail('Failed to trigger workflow');
      final stderr = (result.stderr as String).trim();

      // Distinguish "workflow not found" from other errors.
      if (stderr.contains('Could not find any workflows') ||
          stderr.contains('workflow not found') ||
          stderr.contains(workflowFile)) {
        _logger.err(
          'Workflow "$workflowFile" not found in this repository. '
          'Ensure the file exists at .github/workflows/$workflowFile '
          'and has been pushed to the remote.',
        );
      } else {
        _logger.err(stderr.isNotEmpty ? stderr : 'Unknown gh error.');
      }
      return 1;
    }

    progress.complete('Workflow triggered');

    // Retrieve and display the URL of the latest run.
    await _printWorkflowUrl(workflowFile);

    return 0;
  }

  /// Fetches the most-recent run URL for [workflowFile] and logs it.
  Future<void> _printWorkflowUrl(String workflowFile) async {
    // Small delay to let GitHub register the new run.
    await Future<void>.delayed(const Duration(seconds: 2));

    final listResult = await Process.run(
      'gh',
      [
        'run',
        'list',
        '--workflow',
        workflowFile,
        '--limit',
        '1',
        '--json',
        'url',
        '--jq',
        '.[0].url',
      ],
      workingDirectory: Directory.current.path,
    );

    final url = (listResult.stdout as String).trim();
    _logger.info('');
    if (url.isNotEmpty && url.startsWith('https://')) {
      _logger
        ..success('Workflow URL:')
        ..info('  $url');
    } else {
      _logger.info('View runs: gh run list --workflow $workflowFile');
    }
  }
}
