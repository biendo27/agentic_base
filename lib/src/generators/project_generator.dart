import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/generators/agentic_app_surface_synchronizer.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/modules/module_integration_generator.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';

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
    required CiProvider ciProvider,
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
    await const AgenticAppSurfaceSynchronizer().overlay(
      projectName: projectName,
      outputDirectory: outputDirectory,
      org: org,
      platforms: platforms,
      stateManagement: stateManagement,
      flavors: flavors,
      primaryColor: primaryColor,
      ciProvider: ciProvider,
    );

    GeneratedProjectContract.enforceCiProviderOutputs(
      outputDirectory,
      ciProvider: ciProvider,
    );

    // Step 3: Write agentic.yaml config
    AgenticConfig.createInitial(
      projectPath: outputDirectory,
      projectName: projectName,
      org: org,
      ciProvider: ciProvider,
      stateManagement: stateManagement,
      platforms: platforms,
      flavors: flavors,
      toolVersion: AgenticBaseCliRunner.version,
      provenance: const {
        'tool_version': MetadataProvenance.explicit,
        'project_name': MetadataProvenance.explicit,
        'org': MetadataProvenance.explicit,
        'ci_provider': MetadataProvenance.explicit,
        'state_management': MetadataProvenance.explicit,
        'platforms': MetadataProvenance.explicit,
        'flavors': MetadataProvenance.explicit,
        'modules': MetadataProvenance.defaulted,
      },
    );

    // Step 4: Install dependencies
    await _runInProject(outputDirectory, 'Installing dependencies', 'flutter', [
      'pub',
      'get',
    ]);

    // Step 5: Run flavorizr to configure native flavor builds
    if (GeneratedProjectContract.requiresNativeFlavorization(platforms)) {
      await _runInteractive(outputDirectory, 'Configuring flavors', 'dart', [
        'run',
        'flutter_flavorizr',
        '-f',
      ]);
      GeneratedProjectContract.validateNativeFlavorOutputs(outputDirectory);
    } else {
      _logger.detail(
        'Skipping flutter_flavorizr: no native platforms selected',
      );
    }

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
    GeneratedProjectContract.deleteGeneratedI18nOutputs(outputDirectory);
    await _runInProject(outputDirectory, 'Running code generation', 'dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);

    // Step 8: Remove tool-owned Flutter-layer outputs.
    GeneratedProjectContract.cleanupForbiddenOutputs(outputDirectory);

    // Step 9: Auto-fix lint (sort imports)
    await _runInProject(outputDirectory, 'Applying lint fixes', 'dart', [
      'fix',
      '--apply',
    ]);

    // Step 10: Materialize Slang outputs from build.yaml.
    await _runInProject(
      outputDirectory,
      'Generating typed translations',
      'dart',
      ['run', 'slang'],
    );

    // Step 11: Normalize starter formatting after all generators finish.
    await _runInProject(
      outputDirectory,
      'Formatting generated sources',
      'dart',
      [
        'format',
        'lib',
        'test',
      ],
    );

    GeneratedProjectContract.validate(
      outputDirectory,
      ciProvider: ciProvider,
      stateManagement: stateManagement,
    );

    // Step 12: Verify — analyze + test
    await _verify(outputDirectory);
  }

  /// Install selected modules into the generated project.
  Future<void> _installModules(
    String projectDir,
    String projectName,
    String stateManagement,
    List<String> modules,
  ) async {
    final progress = _logger.progress('Installing ${modules.length} module(s)');
    final installed = <String>[];
    final requestedModules = <String>[];
    for (final name in modules) {
      final missing = ModuleRegistry.missingPrerequisites(
        name,
        installed: requestedModules,
      );
      for (final prereq in missing) {
        if (!requestedModules.contains(prereq)) {
          requestedModules.add(prereq);
        }
      }
      if (!requestedModules.contains(name)) {
        requestedModules.add(name);
      }
    }

    for (final name in requestedModules) {
      final module = ModuleRegistry.find(name);
      if (module == null) {
        progress.fail('Module install failed');
        throw ProjectGenerationException('Module "$name" not found.');
      }
      final ctx = ProjectContext(
        projectPath: projectDir,
        projectName: projectName,
        stateManagement: stateManagement,
        installedModules: List.unmodifiable(installed),
      );
      await module.install(ctx);
      if (!installed.contains(name)) {
        installed.add(name);
      }
    }
    const ModuleIntegrationGenerator().sync(
      ProjectContext(
        projectPath: projectDir,
        projectName: projectName,
        stateManagement: stateManagement,
        installedModules: List.unmodifiable(installed),
      ),
    );
    // Re-run pub get after adding module deps
    await _runInProject(
      projectDir,
      'Refreshing dependencies after module install',
      'flutter',
      ['pub', 'get'],
    );
    final config = AgenticConfig(projectPath: projectDir);
    final metadata = config.readMetadata(
      fallbackProjectName: projectName,
      fallbackToolVersion: AgenticBaseCliRunner.version,
    );
    config.writeMetadata(
      metadata.copyWith(
        toolVersion: AgenticBaseCliRunner.version,
        modules: installed,
        provenance: {
          ...metadata.provenance,
          'tool_version': MetadataProvenance.explicit,
          'modules': MetadataProvenance.explicit,
        },
      ),
    );
    progress.complete('Modules installed');
  }

  /// Run analyze + test to verify the generated project is clean.
  Future<void> _verify(String projectDir) async {
    await _runInProject(
      projectDir,
      'Verifying generated app with flutter analyze',
      'flutter',
      ['analyze'],
    );
    await _runInProject(
      projectDir,
      'Verifying generated app with flutter test',
      'flutter',
      ['test'],
    );
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
      throw ProjectGenerationException(
        '$label failed with exit code $exitCode',
      );
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
      final stderr = (result.stderr as String).trim();
      final stdout = (result.stdout as String).trim();
      if (stderr.isNotEmpty) {
        _logger.err(stderr);
      }
      if (stdout.isNotEmpty) {
        _logger.err(stdout);
      }
      throw ProjectGenerationException('$label failed');
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
}
