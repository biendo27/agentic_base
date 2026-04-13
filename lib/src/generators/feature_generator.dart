import 'dart:io';
import 'dart:isolate';

import 'package:agentic_base/src/config/scaffold_state_profile.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

/// Scaffolds a Clean Architecture feature from the agentic_feature brick.
class FeatureGenerator {
  const FeatureGenerator({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

  /// Generate feature files into [projectPath].
  ///
  /// - [featureName] must be snake_case.
  /// - [simple] generates a flat 2-file structure (no domain layer).
  /// - [stateManagement] is stored in the brick vars for future template use.
  /// - [projectName] is the Dart package name from pubspec.yaml.
  Future<void> generate({
    required String featureName,
    required String projectPath,
    required String projectName,
    required String stateManagement,
    bool simple = false,
  }) async {
    final progress = _logger.progress(
      'Generating ${simple ? 'simple' : 'full'} feature: $featureName',
    );

    try {
      final stateProfile = ScaffoldStateProfile.fromState(stateManagement);
      final bricksRoot = await _resolveBricksRoot();
      final brick = Brick.path(p.join(bricksRoot, 'agentic_feature'));
      final generator = await MasonGenerator.fromBrick(brick);

      final vars = <String, dynamic>{
        'feature_name': featureName,
        'simple': simple,
        'project_name': projectName,
        ...stateProfile.masonVars,
      };

      final target = DirectoryGeneratorTarget(Directory(projectPath));
      final files = await generator.generate(target, vars: vars);
      progress.complete('Feature scaffold generated (${files.length} files)');
    } catch (e) {
      progress.fail('Feature generation failed');
      rethrow;
    }
  }

  /// Resolve bricks root — mirrors ProjectGenerator._resolveBricksRoot().
  static Future<String> _resolveBricksRoot() async {
    final packageUri = Uri.parse('package:agentic_base/agentic_base.dart');
    final resolved = await Isolate.resolvePackageUri(packageUri);
    if (resolved != null) {
      final packageRoot = p.dirname(p.dirname(resolved.toFilePath()));
      final bricksDir = p.join(packageRoot, 'bricks');
      if (Directory(bricksDir).existsSync()) return bricksDir;
    }

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
