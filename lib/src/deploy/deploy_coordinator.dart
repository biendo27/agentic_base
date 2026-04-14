import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';

class DeployCoordinator {
  DeployCoordinator({
    required AgenticLogger logger,
    required String projectPath,
    ProcessRunner? processRunner,
    Future<void> Function(Duration)? delay,
  }) : _logger = logger,
       _projectPath = projectPath,
       _processRunner = processRunner ?? runProcess,
       _delay = delay ?? Future<void>.delayed;

  static const _githubWorkflowByEnvironment = <String, String>{
    'dev': 'cd-dev.yml',
    'staging': 'cd-staging.yml',
    'prod': 'cd-prod.yml',
  };

  static const _gitlabJobsByEnvironment = <String, List<String>>{
    'dev': ['deploy_dev'],
    'staging': [
      'deploy_staging_android_internal',
      'deploy_staging_testflight',
    ],
    'prod': ['deploy_prod_play', 'deploy_prod_app_store'],
  };

  final AgenticLogger _logger;
  final String _projectPath;
  final ProcessRunner _processRunner;
  final Future<void> Function(Duration) _delay;

  Future<int> deploy({
    required String environment,
    required CiProvider ciProvider,
  }) async {
    final gitCheck = await _validateGitState();
    if (gitCheck != 0) {
      return gitCheck;
    }

    if (ciProvider == CiProvider.gitlab) {
      return _deployViaGitLab(environment);
    }

    return _deployViaGitHub(environment);
  }

  Future<int> _validateGitState() async {
    final versionResult = await _runToolCheck(
      executable: 'git',
      arguments: const ['--version'],
      missingToolMessage: 'git not found. Install git and try again.',
    );
    if (versionResult != 0) {
      return versionResult;
    }

    final repoCheck = await _processRunner(
      'git',
      ['rev-parse', '--is-inside-work-tree'],
      workingDirectory: _projectPath,
    );
    if (repoCheck.exitCode != 0) {
      _logger.err('Current directory is not inside a git repository.');
      return 1;
    }

    final statusResult = await _processRunner(
      'git',
      ['status', '--porcelain'],
      workingDirectory: _projectPath,
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

    final aheadResult = await _processRunner(
      'git',
      ['status', '--branch', '--porcelain=v2'],
      workingDirectory: _projectPath,
    );
    if (aheadResult.exitCode != 0) {
      _logger.err('Failed to check branch tracking state.');
      return 1;
    }

    final branchOutput = aheadResult.stdout as String;
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

  Future<int> _deployViaGitHub(String environment) async {
    final cliCheck = await _validateProviderCli(
      executable: 'gh',
      authArguments: const ['auth', 'status'],
      missingToolMessage:
          'gh CLI not found. Install it from https://cli.github.com '
          'and authenticate with: gh auth login',
      authHelpMessage: 'gh CLI is not authenticated. Run: gh auth login',
      successLabel: 'gh',
    );
    if (cliCheck != 0) {
      return cliCheck;
    }

    final workflowFile = _githubWorkflowByEnvironment[environment];
    if (workflowFile == null) {
      _logger.err('Unsupported GitHub deploy environment: $environment');
      return 1;
    }
    final progress = _logger.progress('Triggering $workflowFile');
    final result = await _processRunner(
      'gh',
      ['workflow', 'run', workflowFile],
      workingDirectory: _projectPath,
    );

    if (result.exitCode != 0) {
      progress.fail('Failed to trigger workflow');
      final stderr = (result.stderr as String).trim();
      if (stderr.contains('Could not find any workflows') ||
          stderr.contains('workflow not found') ||
          stderr.contains(workflowFile)) {
        _logger.err(
          'Workflow "$workflowFile" not found in this repository. '
          'Ensure the file exists at .github/workflows/$workflowFile '
          'and has been pushed to the remote.',
        );
      } else {
        _logProcessFailure(result, fallbackMessage: 'Unknown gh error.');
      }
      return 1;
    }

    progress.complete('Workflow triggered');
    final runUrl = await _fetchGitHubRunUrl(workflowFile);
    _printUrl(
      runUrl,
      successMessage: 'Workflow URL:',
      fallbackMessage: 'View runs: gh run list --workflow $workflowFile',
    );
    return 0;
  }

  Future<int> _deployViaGitLab(String environment) async {
    final cliCheck = await _validateProviderCli(
      executable: 'glab',
      authArguments: const ['auth', 'status'],
      missingToolMessage:
          'glab CLI not found. Install it from https://gitlab.com/gitlab-org/cli '
          'and authenticate with: glab auth login',
      authHelpMessage: 'glab CLI is not authenticated. Run: glab auth login',
      successLabel: 'glab',
    );
    if (cliCheck != 0) {
      return cliCheck;
    }

    final branch = await _currentBranch();
    if (branch == null) {
      _logger.err(
        'Could not resolve the current git branch for GitLab deploy.',
      );
      return 1;
    }

    final pipelineProgress = _logger.progress('Creating GitLab pipeline');
    final pipelineRunResult = await _processRunner(
      'glab',
      ['ci', 'run', '--branch', branch],
      workingDirectory: _projectPath,
    );
    if (pipelineRunResult.exitCode != 0) {
      pipelineProgress.fail('Failed to create GitLab pipeline');
      _logProcessFailure(
        pipelineRunResult,
        fallbackMessage: 'Could not create a GitLab pipeline for this branch.',
      );
      return 1;
    }
    pipelineProgress.complete('GitLab pipeline created');

    await _delay(const Duration(seconds: 2));
    final pipeline = await _fetchGitLabPipeline(branch);
    if (pipeline == null) {
      _logger.err(
        'GitLab pipeline was created, but its metadata could not be resolved.',
      );
      return 1;
    }

    final deployJobs = _gitlabJobsByEnvironment[environment];
    if (deployJobs == null || deployJobs.isEmpty) {
      _logger.err('Unsupported GitLab deploy environment: $environment');
      return 1;
    }

    for (final deployJob in deployJobs) {
      final triggerProgress = _logger.progress('Triggering $deployJob');
      final triggerResult = await _processRunner(
        'glab',
        [
          'ci',
          'trigger',
          deployJob,
          '--branch',
          branch,
          '--pipeline-id',
          pipeline.id.toString(),
        ],
        workingDirectory: _projectPath,
      );

      if (triggerResult.exitCode != 0) {
        triggerProgress.fail('Failed to trigger $deployJob');
        _logProcessFailure(
          triggerResult,
          fallbackMessage:
              'The pipeline exists, but the manual deploy job could not be triggered.',
        );
        _printUrl(
          pipeline.webUrl,
          successMessage: 'Pipeline URL:',
          fallbackMessage: 'View pipelines: glab ci get --branch $branch',
        );
        return 1;
      }

      triggerProgress.complete('Manual deploy job triggered');
    }

    _printUrl(
      pipeline.webUrl,
      successMessage: 'Pipeline URL:',
      fallbackMessage: 'View pipelines: glab ci get --branch $branch',
    );
    return 0;
  }

  Future<int> _validateProviderCli({
    required String executable,
    required List<String> authArguments,
    required String missingToolMessage,
    required String authHelpMessage,
    required String successLabel,
  }) async {
    final versionResult = await _runToolCheck(
      executable: executable,
      arguments: const ['--version'],
      missingToolMessage: missingToolMessage,
    );
    if (versionResult != 0) {
      return versionResult;
    }

    final authResult = await _processRunner(
      executable,
      authArguments,
      workingDirectory: _projectPath,
    );
    if (authResult.exitCode != 0) {
      _logger.err(authHelpMessage);
      return 1;
    }

    _logger.success('  $successLabel: authenticated');
    return 0;
  }

  Future<int> _runToolCheck({
    required String executable,
    required List<String> arguments,
    required String missingToolMessage,
  }) async {
    try {
      final result = await _processRunner(
        executable,
        arguments,
        workingDirectory: _projectPath,
      );
      if (result.exitCode != 0) {
        _logger.err(missingToolMessage);
        return 1;
      }
      return 0;
    } on ProcessException {
      _logger.err(missingToolMessage);
      return 1;
    }
  }

  Future<String?> _currentBranch() async {
    final result = await _processRunner(
      'git',
      ['branch', '--show-current'],
      workingDirectory: _projectPath,
    );
    if (result.exitCode != 0) {
      return null;
    }

    final branch = (result.stdout as String).trim();
    if (branch.isEmpty || branch == 'HEAD') {
      return null;
    }

    return branch;
  }

  Future<String?> _fetchGitHubRunUrl(String workflowFile) async {
    await _delay(const Duration(seconds: 2));
    final listResult = await _processRunner(
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
      workingDirectory: _projectPath,
    );

    final url = (listResult.stdout as String).trim();
    return url.startsWith('https://') ? url : null;
  }

  Future<_GitLabPipeline?> _fetchGitLabPipeline(String branch) async {
    final result = await _processRunner(
      'glab',
      ['ci', 'get', '--branch', branch, '--output', 'json'],
      workingDirectory: _projectPath,
    );
    if (result.exitCode != 0) {
      return null;
    }

    final stdout = (result.stdout as String).trim();
    if (stdout.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(stdout);
      final payload =
          decoded is List && decoded.isNotEmpty ? decoded.first : decoded;
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      final idValue = payload['id'] ?? payload['pipeline_id'];
      final pipelineId =
          idValue is int ? idValue : int.tryParse(idValue?.toString() ?? '');
      if (pipelineId == null) {
        return null;
      }

      final webUrl =
          payload['web_url']?.toString() ??
          payload['webUrl']?.toString() ??
          payload['url']?.toString();
      return _GitLabPipeline(id: pipelineId, webUrl: webUrl);
    } on FormatException {
      return null;
    }
  }

  void _logProcessFailure(
    ProcessResult result, {
    required String fallbackMessage,
  }) {
    final stderr = (result.stderr as String).trim();
    final stdout = (result.stdout as String).trim();
    if (stderr.isNotEmpty) {
      _logger.err(stderr);
      return;
    }
    if (stdout.isNotEmpty) {
      _logger.err(stdout);
      return;
    }
    _logger.err(fallbackMessage);
  }

  void _printUrl(
    String? url, {
    required String successMessage,
    required String fallbackMessage,
  }) {
    _logger.info('');
    if (url != null && url.startsWith('https://')) {
      _logger
        ..success(successMessage)
        ..info('  $url');
      return;
    }

    _logger.info(fallbackMessage);
  }
}

final class _GitLabPipeline {
  const _GitLabPipeline({required this.id, this.webUrl});

  final int id;
  final String? webUrl;
}
