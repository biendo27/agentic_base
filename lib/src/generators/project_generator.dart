import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/config/harness_metadata.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/generators/agentic_app_surface_synchronizer.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/modules/module_integration_generator.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';

/// Orchestrates Flutter project creation + Mason brick overlay.
class ProjectGenerator {
  const ProjectGenerator({
    required AgenticLogger logger,
    FlutterToolchainDetector toolchainDetector = detectFlutterToolchain,
  }) : _logger = logger,
       _toolchainDetector = toolchainDetector;

  final AgenticLogger _logger;
  final FlutterToolchainDetector _toolchainDetector;

  /// Generate a new Flutter project with native scaffolding + templates.
  Future<void> generate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
    required String stateManagement,
    required List<String> flavors,
    required CiProvider ciProvider,
    required HarnessAppProfile appProfile,
    required FlutterSdkManager flutterSdkManager,
    String? flutterSdkVersion,
    List<String> secondaryTraits = const [],
    List<String> modules = const [],
  }) async {
    final toolchain = resolveFlutterToolchain(
      projectPath: Directory.current.path,
      preferredManager: flutterSdkManager,
      preferredVersion: flutterSdkVersion,
      detector: _toolchainDetector,
    );
    _logResolvedToolchain(toolchain);
    final harness = HarnessMetadata.defaultFor(
      appProfile: appProfile,
      secondaryTraits: secondaryTraits,
      capabilities: modules,
      sdk: toolchain.contract,
    );
    final metadata = AgenticConfig.buildInitialMetadata(
      projectName: projectName,
      org: org,
      ciProvider: ciProvider,
      stateManagement: stateManagement,
      platforms: platforms,
      flavors: flavors,
      toolVersion: AgenticBaseCliRunner.version,
      provenance: {
        'tool_version': MetadataProvenance.explicit,
        'project_name': MetadataProvenance.explicit,
        'org': MetadataProvenance.explicit,
        'ci_provider': MetadataProvenance.explicit,
        'state_management': MetadataProvenance.explicit,
        'platforms': MetadataProvenance.explicit,
        'flavors': MetadataProvenance.explicit,
        'modules': MetadataProvenance.defaulted,
        'harness.contract_version': MetadataProvenance.defaulted,
        'harness.app_profile.primary_profile': MetadataProvenance.explicit,
        'harness.app_profile.secondary_traits': MetadataProvenance.explicit,
        'harness.capabilities.enabled': MetadataProvenance.explicit,
        'harness.providers': MetadataProvenance.defaulted,
        'harness.eval.evidence_dir': MetadataProvenance.defaulted,
        'harness.eval.quality_dimensions': MetadataProvenance.defaulted,
        'harness.approvals.pause_on': MetadataProvenance.defaulted,
        'harness.sdk.manager': MetadataProvenance.inferred,
        'harness.sdk.preferred_manager': MetadataProvenance.explicit,
        'harness.sdk.channel':
            toolchain.detected.channel == null
                ? MetadataProvenance.defaulted
                : MetadataProvenance.inferred,
        'harness.sdk.version': MetadataProvenance.inferred,
        'harness.sdk.preferred_version':
            flutterSdkVersion == null
                ? MetadataProvenance.inferred
                : MetadataProvenance.explicit,
        'harness.sdk.policy': MetadataProvenance.defaulted,
      },
      modules: modules,
      harness: harness,
    );

    // Step 1: flutter create for native platform scaffolding
    await _flutterCreate(
      projectName: projectName,
      outputDirectory: outputDirectory,
      org: org,
      platforms: platforms,
      toolchain: toolchain,
    );

    // Step 2: Overlay Mason brick templates
    await const AgenticAppSurfaceSynchronizer().overlay(
      outputDirectory: outputDirectory,
      metadata: metadata,
    );

    GeneratedProjectContract.enforceCiProviderOutputs(
      outputDirectory,
      ciProvider: ciProvider,
    );

    // Step 3: Write agentic.yaml config
    AgenticConfig(projectPath: outputDirectory).writeMetadata(metadata);

    // Step 4: Install dependencies
    await _runInProject(
      outputDirectory,
      'Installing dependencies',
      toolchain.flutterCommand(['pub', 'get']),
    );

    // Step 5: Run flavorizr to configure native flavor builds
    if (GeneratedProjectContract.requiresNativeFlavorization(platforms)) {
      await _runInteractive(
        outputDirectory,
        'Configuring flavors',
        toolchain.dartCommand(['run', 'flutter_flavorizr', '-f']),
      );
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
        toolchain,
      );
    }

    // Step 7: Code generation (freezed, injectable, auto_route)
    GeneratedProjectContract.deleteGeneratedI18nOutputs(outputDirectory);
    await _runInProject(
      outputDirectory,
      'Running code generation',
      toolchain.dartCommand([
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]),
    );

    // Step 8: Remove tool-owned Flutter-layer outputs.
    GeneratedProjectContract.cleanupForbiddenOutputs(outputDirectory);

    // Step 9: Auto-fix lint (sort imports)
    await _runInProject(
      outputDirectory,
      'Applying lint fixes',
      toolchain.dartCommand(['fix', '--apply']),
    );

    // Step 10: Materialize Slang outputs from build.yaml.
    await _runInProject(
      outputDirectory,
      'Generating typed translations',
      toolchain.dartCommand(['run', 'slang']),
    );

    // Step 11: Normalize starter formatting after all generators finish.
    await _runInProject(
      outputDirectory,
      'Formatting generated sources',
      toolchain.dartCommand(['format', 'lib', 'test']),
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
    ResolvedFlutterToolchain toolchain,
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
      toolchain.flutterCommand(['pub', 'get']),
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
      'Verifying generated app with harness contract',
      const ToolCommandSpec(
        executable: 'bash',
        arguments: ['tools/verify.sh'],
      ),
    );
  }

  /// Run a command with inherited stdio (for tools that need a terminal).
  Future<void> _runInteractive(
    String projectDir,
    String label,
    ToolCommandSpec command,
  ) async {
    _logger.info(label);
    final process = await Process.start(
      command.executable,
      command.arguments,
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
    ToolCommandSpec command,
  ) async {
    final progress = _logger.progress(label);
    final result = await Process.run(
      command.executable,
      command.arguments,
      workingDirectory: projectDir,
    );
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
    required ResolvedFlutterToolchain toolchain,
  }) async {
    final progress = _logger.progress('Creating Flutter project');
    final command = toolchain.flutterCommand([
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
    final result = await Process.run(
      command.executable,
      command.arguments,
    );
    if (result.exitCode != 0) {
      progress.fail('flutter create failed');
      _logger.err((result.stderr as String).trim());
      throw Exception(
        'flutter create failed with exit ${result.exitCode}',
      );
    }
    progress.complete('Flutter project created');
  }

  void _logResolvedToolchain(ResolvedFlutterToolchain toolchain) {
    if (toolchain.source != FlutterToolchainResolutionSource.preferred) {
      _logger.warn(
        'Preferred Flutter manager '
        '"${toolchain.contract.preferredManager.wireName}" is unavailable. '
        'Using "${toolchain.contract.manager.wireName}" instead.',
      );
    }
    if (toolchain.contract.preferredVersion != toolchain.contract.version) {
      _logger.warn(
        'Preferred Flutter version ${toolchain.contract.preferredVersion} '
        'is not active. Resolved ${toolchain.contract.version} instead.',
      );
    }
  }
}
