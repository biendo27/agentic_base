import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/generators/feature_generator.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Scaffolds a Clean Architecture feature inside an agentic_base project.
///
/// Usage: `agentic_base feature <name>` or `agentic_base feature <name> --simple`
class FeatureCommand extends Command<int> {
  FeatureCommand({
    required AgenticLogger logger,
    String Function()? projectPathProvider,
  }) : _logger = logger,
       _projectPathProvider = projectPathProvider {
    argParser.addFlag(
      'simple',
      abbr: 's',
      negatable: false,
      help: 'Generate a flat structure without domain layer.',
    );
  }

  final AgenticLogger _logger;
  final String Function()? _projectPathProvider;

  @override
  String get name => 'feature';

  @override
  String get description =>
      'Scaffold a Clean Architecture feature inside an agentic_base project.';

  @override
  String get invocation => 'agentic_base feature <feature_name> [--simple]';

  static final _validName = RegExp(r'^[a-z][a-z0-9_]*$');

  @override
  Future<int> run() async {
    final args = argResults!;
    final rest = args.rest;

    if (rest.isEmpty) {
      throw UsageException('No feature name provided.', usage);
    }

    final featureName = rest.first;

    if (!_validName.hasMatch(featureName)) {
      throw UsageException(
        'Feature name must be snake_case (e.g. user_profile). '
        'Got: "$featureName"',
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

    final metadata = config.readMetadata(
      fallbackProjectName: p.basename(projectPath),
      fallbackToolVersion: AgenticBaseCliRunner.version,
    );
    final projectName = metadata.projectName;
    final stateManagement = metadata.stateManagement;
    final simple = args['simple'] as bool;

    if (!simple) {
      try {
        GeneratedProjectContract.validateFeatureHost(projectPath);
      } on ProjectGenerationException catch (error) {
        _logger
          ..err('$error')
          ..info(
            'Run `agentic_base upgrade` to sync generator-owned surfaces, then retry `agentic_base feature $featureName`.',
          );
        return 1;
      }
    }

    _logger.header('Scaffolding feature: $featureName');

    try {
      await FeatureGenerator(logger: _logger).generate(
        featureName: featureName,
        projectPath: projectPath,
        projectName: projectName,
        stateManagement: stateManagement,
        simple: simple,
      );

      final structure =
          simple
              ? 'lib/features/$featureName/ (flat)'
              : 'lib/features/$featureName/{data,domain,presentation}';

      _logger
        ..success('Feature "$featureName" created at $structure')
        ..info('')
        ..info('Next steps:')
        ..info('  Register routes in lib/core/router/app_router.dart')
        ..info('  Run: agentic_base gen');
      return 0;
    } on Exception catch (e) {
      _logger.err('Failed to scaffold feature: $e');
      return 1;
    }
  }
}
