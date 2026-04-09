import 'dart:io';
import 'dart:isolate';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

/// Orchestrates Flutter project creation + Mason brick overlay.
class ProjectGenerator {
  const ProjectGenerator({required AgenticLogger logger}) : _logger = logger;

  final AgenticLogger _logger;

  /// Generate a new Flutter project with native scaffolding + templates.
  Future<void> generate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
    required String stateManagement,
    required List<String> flavors,
    required String primaryColor,
  }) async {
    // Step 1: Run flutter create for native platform scaffolding
    await _flutterCreate(
      projectName: projectName,
      outputDirectory: outputDirectory,
      org: org,
      platforms: platforms,
    );

    // Step 2: Overlay Mason brick templates on top
    await _overlayBrickTemplates(
      projectName: projectName,
      outputDirectory: outputDirectory,
      org: org,
      platforms: platforms,
      stateManagement: stateManagement,
      flavors: flavors,
      primaryColor: primaryColor,
    );

    // Step 3: Write agentic.yaml config
    AgenticConfig.createInitial(
      projectPath: outputDirectory,
      projectName: projectName,
      org: org,
      stateManagement: stateManagement,
      platforms: platforms,
      flavors: flavors,
      toolVersion: AgenticBaseCliRunner.version,
    );

    // Step 4: Install dependencies (overwrite the empty flutter create pubspec)
    await _runInProject(outputDirectory, 'Installing dependencies',
        'flutter', ['pub', 'get']);

    // Step 5: Run code generation (freezed, injectable, auto_route, etc.)
    await _runInProject(outputDirectory, 'Running code generation',
        'dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);

    // Step 6: Auto-fix lint (sort imports, apply dart fixes)
    await _runInProject(outputDirectory, 'Applying lint fixes',
        'dart', ['fix', '--apply']);
  }

  /// Run a command inside the generated project directory.
  Future<void> _runInProject(
    String projectDir,
    String label,
    String cmd,
    List<String> args,
  ) async {
    final progress = _logger.progress(label);
    final result = await Process.run(cmd, args, workingDirectory: projectDir);
    if (result.exitCode != 0) {
      progress.fail('$label failed');
      _logger.err((result.stderr as String).trim());
      return; // Non-fatal — user can run manually
    }
    progress.complete(label);
  }

  /// Run `flutter create` to generate native platform directories.
  Future<void> _flutterCreate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
  }) async {
    final progress = _logger.progress('Creating Flutter project');

    final result = await Process.run(
      'flutter',
      [
        'create',
        '--org', org,
        '--platforms', platforms.join(','),
        '-e', // empty app (we'll overlay our own code)
        '--project-name', projectName,
        outputDirectory,
      ],
    );

    if (result.exitCode != 0) {
      progress.fail('flutter create failed');
      _logger.err((result.stderr as String).trim());
      throw Exception('flutter create failed with exit ${result.exitCode}');
    }
    progress.complete('Flutter project created');
  }

  /// Overlay Mason brick templates onto the flutter create output.
  Future<void> _overlayBrickTemplates({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
    required String stateManagement,
    required List<String> flavors,
    required String primaryColor,
  }) async {
    final progress = _logger.progress('Applying agentic templates');

    try {
      final bricksRoot = await _resolveBricksRoot();
      final brick = Brick.path(p.join(bricksRoot, 'agentic_app'));
      final generator = await MasonGenerator.fromBrick(brick);

      final vars = <String, dynamic>{
        'project_name': projectName,
        'org': org,
        'platforms': platforms,
        'state_management': stateManagement,
        'flavors': flavors,
        'primary_color': primaryColor,
      };

      // Brick creates {{project_name.snakeCase()}}/ dir, so target parent.
      final parentDir = p.dirname(outputDirectory);
      final target = DirectoryGeneratorTarget(Directory(parentDir));
      await generator.generate(
        target,
        vars: vars,
        fileConflictResolution: FileConflictResolution.overwrite,
      );
      progress.complete('Agentic templates applied');
    } on Exception {
      progress.fail('Template overlay failed');
      rethrow;
    }
  }

  /// Resolve bricks root — works for dev, pub global, and AOT.
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
