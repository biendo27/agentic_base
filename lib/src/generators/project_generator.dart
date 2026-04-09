import 'dart:io';
import 'dart:isolate';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/modules/project_context.dart';
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
    List<String> modules = const [],
  }) async {
    // Step 1: flutter create for native platform scaffolding
    await _flutterCreate(
      projectName: projectName,
      outputDirectory: outputDirectory,
      org: org,
      platforms: platforms,
    );

    // Step 2: Overlay Mason brick templates
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

    // Step 4: Install dependencies
    await _runInProject(outputDirectory, 'Installing dependencies', 'flutter', [
      'pub',
      'get',
    ]);

    // Step 5: Run flavorizr to configure native flavor builds
    await _runInteractive(outputDirectory, 'Configuring flavors', 'dart', [
      'run',
      'flutter_flavorizr',
    ]);

    // Step 6: Install selected modules
    if (modules.isNotEmpty) {
      await _installModules(
        outputDirectory,
        projectName,
        stateManagement,
        modules,
      );
    }

    // Step 7: Code generation (freezed, injectable, auto_route)
    await _runInProject(outputDirectory, 'Running code generation', 'dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);

    // Step 8: Auto-fix lint (sort imports)
    await _runInProject(outputDirectory, 'Applying lint fixes', 'dart', [
      'fix',
      '--apply',
    ]);

    // Step 9: Verify — analyze + test
    await _verify(outputDirectory);
  }

  /// Install selected modules into the generated project.
  Future<void> _installModules(
    String projectDir,
    String projectName,
    String stateManagement,
    List<String> modules,
  ) async {
    final progress = _logger.progress(
      'Installing ${modules.length} module(s)',
    );
    final ctx = ProjectContext(
      projectPath: projectDir,
      projectName: projectName,
      stateManagement: stateManagement,
      installedModules: [],
    );
    for (final name in modules) {
      final module = ModuleRegistry.find(name);
      if (module == null) {
        _logger.warn('Module "$name" not found, skipping');
        continue;
      }
      try {
        await module.install(ctx);
        // Update config
        final config = AgenticConfig(projectPath: projectDir);
        final data = config.read();
        final installed = List<String>.from(
          (data['modules'] as List<dynamic>?) ?? [],
        )..add(name);
        config.write({'modules': installed});
      } on Exception catch (e) {
        _logger.warn('Failed to install $name: $e');
      }
    }
    // Re-run pub get after adding module deps
    await Process.run('flutter', ['pub', 'get'], workingDirectory: projectDir);
    progress.complete('Modules installed');
  }

  /// Run analyze + test to verify the generated project is clean.
  Future<void> _verify(String projectDir) async {
    final analyzeProgress = _logger.progress('Verifying (dart analyze)');
    final analyzeResult = await Process.run(
      'dart',
      ['analyze', 'lib/'],
      workingDirectory: projectDir,
    );
    if (analyzeResult.exitCode == 0) {
      analyzeProgress.complete('Analysis clean');
    } else {
      analyzeProgress.fail('Analysis has warnings');
      _logger.warn((analyzeResult.stdout as String).trim());
    }

    final testProgress = _logger.progress('Verifying (flutter test)');
    final testResult = await Process.run(
      'flutter',
      ['test'],
      workingDirectory: projectDir,
    );
    if (testResult.exitCode == 0) {
      testProgress.complete('Tests passed');
    } else {
      testProgress.fail('Some tests failed');
      _logger.warn((testResult.stdout as String).trim());
    }
  }

  /// Run a command with inherited stdio (for tools that need a terminal).
  Future<void> _runInteractive(
    String projectDir,
    String label,
    String cmd,
    List<String> args,
  ) async {
    _logger.info(label);
    final process = await Process.start(
      cmd,
      args,
      workingDirectory: projectDir,
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      _logger.warn('$label exited with $exitCode (non-fatal)');
    }
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
      return;
    }
    progress.complete(label);
  }

  /// Run `flutter create` for native platform directories.
  Future<void> _flutterCreate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
  }) async {
    final progress = _logger.progress('Creating Flutter project');
    final result = await Process.run('flutter', [
      'create',
      '--org',
      org,
      '--platforms',
      platforms.join(','),
      '-e',
      '--project-name',
      projectName,
      outputDirectory,
    ]);
    if (result.exitCode != 0) {
      progress.fail('flutter create failed');
      _logger.err((result.stderr as String).trim());
      throw Exception(
        'flutter create failed with exit ${result.exitCode}',
      );
    }
    progress.complete('Flutter project created');
  }

  /// Overlay Mason brick templates onto flutter create output.
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
      final parentDir = p.dirname(outputDirectory);
      final target = DirectoryGeneratorTarget(Directory(parentDir));
      await generator.generate(
        target,
        vars: <String, dynamic>{
          'project_name': projectName,
          'org': org,
          'platforms': platforms,
          'state_management': stateManagement,
          'flavors': flavors,
          'primary_color': primaryColor,
        },
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
      final root = p.dirname(p.dirname(resolved.toFilePath()));
      final dir = p.join(root, 'bricks');
      if (Directory(dir).existsSync()) return dir;
    }
    final script = Platform.script.toFilePath();
    final root = p.dirname(p.dirname(script));
    final dir = p.join(root, 'bricks');
    if (Directory(dir).existsSync()) return dir;
    throw StateError('Could not locate bricks directory.');
  }
}
