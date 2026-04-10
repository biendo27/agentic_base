import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/deploy/deploy_coordinator.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';

/// Valid deployment environments.
const _validEnvironments = ['dev', 'staging', 'prod'];

typedef DeployAction =
    Future<int> Function({
      required String projectPath,
      required String environment,
      required CiProvider ciProvider,
    });

class DeployCommand extends Command<int> {
  DeployCommand({
    required AgenticLogger logger,
    DeployAction? deployAction,
    String Function()? projectPathProvider,
    ProcessRunner? processRunner,
    Future<void> Function(Duration)? delay,
  }) : _logger = logger,
       _deployAction = deployAction,
       _projectPathProvider = projectPathProvider,
       _processRunner = processRunner,
       _delay = delay;

  final AgenticLogger _logger;
  final DeployAction? _deployAction;
  final String Function()? _projectPathProvider;
  final ProcessRunner? _processRunner;
  final Future<void> Function(Duration)? _delay;

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

    final projectPath = _projectPathProvider?.call() ?? Directory.current.path;
    final config = AgenticConfig(projectPath: projectPath);
    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    final configData = config.read();
    final ciProvider = resolveCiProviderFromConfig(
      config: configData,
      projectPath: projectPath,
    );
    final storedProvider = configData['ci_provider'];
    if (storedProvider is! String ||
        !supportedCiProviders.contains(storedProvider.trim().toLowerCase())) {
      _logger.warn(
        'Missing or invalid ci_provider in .info/agentic.yaml. '
        'Falling back to ${ciProvider.name}.',
      );
    }

    _logger.header('Deploy → $env');
    final deployAction =
        _deployAction ??
        ({
          required String projectPath,
          required String environment,
          required CiProvider ciProvider,
        }) {
          return DeployCoordinator(
            logger: _logger,
            projectPath: projectPath,
            processRunner: _processRunner,
            delay: _delay,
          ).deploy(environment: environment, ciProvider: ciProvider);
        };

    return deployAction(
      projectPath: projectPath,
      environment: env,
      ciProvider: ciProvider,
    );
  }
}
