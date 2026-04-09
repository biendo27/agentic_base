import 'dart:io';
import 'dart:isolate';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

/// Orchestrates Mason brick generation for new projects.
class ProjectGenerator {
  const ProjectGenerator({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

  /// Generate a new Flutter project from the bundled brick.
  Future<void> generate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
    required String stateManagement,
    required List<String> flavors,
    required String primaryColor,
  }) async {
    final progress = _logger.progress('Generating project structure');

    try {
      final bricksRoot = await _resolveBricksRoot();
      final brick = Brick.path(
        p.join(bricksRoot, 'agentic_app'),
      );
      final generator = await MasonGenerator.fromBrick(brick);

      final vars = <String, dynamic>{
        'project_name': projectName,
        'org': org,
        'platforms': platforms,
        'state_management': stateManagement,
        'flavors': flavors,
        'primary_color': primaryColor,
      };

      // Brick template creates {{project_name.snakeCase()}}/ as root dir,
      // so we generate into the parent to avoid double-nesting.
      final parentDir = p.dirname(outputDirectory);
      final target = DirectoryGeneratorTarget(Directory(parentDir));
      await generator.generate(target, vars: vars);
      progress.complete('Project structure generated');

      // Write agentic.yaml
      AgenticConfig.createInitial(
        projectPath: outputDirectory,
        projectName: projectName,
        org: org,
        stateManagement: stateManagement,
        platforms: platforms,
        flavors: flavors,
        toolVersion: AgenticBaseCliRunner.version,
      );
    } catch (e) {
      progress.fail('Generation failed');
      rethrow;
    }
  }

  /// Resolve bricks root — works for dev, pub global, and AOT.
  static Future<String> _resolveBricksRoot() async {
    // Try resolving via package URI (works for pub global + dev)
    final packageUri = Uri.parse('package:agentic_base/agentic_base.dart');
    final resolved = await Isolate.resolvePackageUri(packageUri);
    if (resolved != null) {
      // resolved = .../agentic_base/lib/agentic_base.dart
      final packageRoot = p.dirname(p.dirname(resolved.toFilePath()));
      final bricksDir = p.join(packageRoot, 'bricks');
      if (Directory(bricksDir).existsSync()) return bricksDir;
    }

    // Fallback: relative to script (dev mode)
    final script = Platform.script.toFilePath();
    final packageRoot = p.dirname(p.dirname(script));
    final bricksDir = p.join(packageRoot, 'bricks');
    if (Directory(bricksDir).existsSync()) return bricksDir;

    throw StateError(
      'Could not locate bricks directory. '
      'Ensure agentic_base is installed correctly.',
    );
  }
}
