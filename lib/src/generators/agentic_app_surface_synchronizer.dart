import 'dart:io';
import 'dart:isolate';

import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/config/scaffold_state_profile.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/modules/project_mutation_journal.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

final class AgenticAppSurfaceSynchronizer {
  const AgenticAppSurfaceSynchronizer();

  static const _upgradeOwnedPaths = <String>[
    'AGENTS.md',
    'CLAUDE.md',
    'README.md',
    'Makefile',
    'docs',
    'tools',
    '.github',
    '.gitlab-ci.yml',
    '.gitlab',
    'android/fastlane',
    'ios/fastlane',
  ];

  static const _initOwnedPaths = <String>[
    'AGENTS.md',
    'CLAUDE.md',
    'README.md',
    'docs',
    'tools',
    '.github',
    '.gitlab-ci.yml',
    '.gitlab',
    'android/fastlane',
    'ios/fastlane',
  ];

  Future<void> overlay({
    required String outputDirectory,
    required ProjectMetadata metadata,
  }) async {
    final stateProfile = ScaffoldStateProfile.fromState(
      metadata.stateManagement,
    );
    final appIdBase = GeneratedProjectContract.buildAppIdBase(
      org: metadata.org,
      projectName: metadata.projectName,
    );
    final generator = await _loadGenerator();
    final parentDir = p.dirname(outputDirectory);
    final target = DirectoryGeneratorTarget(Directory(parentDir));
    await generator.generate(
      target,
      vars: <String, dynamic>{
        'project_name': metadata.projectName,
        'org': metadata.org,
        'platforms': metadata.platforms,
        'flavors': metadata.flavors,
        'ci_provider': metadata.ciProvider.name,
        'app_id_base': appIdBase,
        'has_native_flavors': metadata.platforms.any(
          (platform) => const {'android', 'ios', 'macos'}.contains(platform),
        ),
        'has_android': metadata.platforms.contains('android'),
        'has_ios': metadata.platforms.contains('ios'),
        'has_macos': metadata.platforms.contains('macos'),
        'app_profile': metadata.harness.appProfile.wireName,
        'app_profile_label': metadata.harness.appProfile.label,
        'app_profile_summary': metadata.harness.appProfile.profileSummary,
        'support_tier_label': metadata.harness.supportTier.label,
        'support_tier_summary': metadata.harness.supportTier.contractSummary,
        'required_gate_pack': metadata.harness.supportTier.requiredGatePack,
        'secondary_traits_csv':
            metadata.harness.secondaryTraits.isEmpty
                ? 'none'
                : metadata.harness.secondaryTraits.join(', '),
        'evidence_dir': metadata.harness.eval.evidenceDir,
        'flutter_sdk_manager': metadata.harness.sdk.manager.wireName,
        'flutter_sdk_channel': metadata.harness.sdk.channel,
        'flutter_sdk_version': metadata.harness.sdk.version,
        'flutter_sdk_policy': metadata.harness.sdk.policy.wireName,
        ...stateProfile.masonVars,
      },
      fileConflictResolution: FileConflictResolution.overwrite,
    );
    _ensureExecutableToolScripts(outputDirectory);
  }

  Future<void> syncUpgradeOwnedSurfaces({
    required String projectPath,
    required ProjectMetadata metadata,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'agentic-base-upgrade-',
    );
    final renderedProjectPath = p.join(tempDir.path, metadata.projectName);

    try {
      await overlay(
        outputDirectory: renderedProjectPath,
        metadata: metadata,
      );
      GeneratedProjectContract.enforceCiProviderOutputs(
        renderedProjectPath,
        ciProvider: metadata.ciProvider,
      );

      for (final relativePath in _upgradeOwnedPaths) {
        _copyRenderedPath(
          fromRoot: renderedProjectPath,
          toRoot: projectPath,
          relativePath: relativePath,
        );
      }

      GeneratedProjectContract.enforceCiProviderOutputs(
        projectPath,
        ciProvider: metadata.ciProvider,
      );
      _ensureExecutableToolScripts(projectPath);
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  Future<InitSurfaceSyncResult> syncInitOwnedSurfaces({
    required String projectPath,
    required ProjectMetadata metadata,
    ProjectMutationJournal? journal,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'agentic-base-init-',
    );
    final renderedProjectPath = p.join(tempDir.path, metadata.projectName);
    final createdPaths = <String>[];

    try {
      await overlay(
        outputDirectory: renderedProjectPath,
        metadata: metadata,
      );
      GeneratedProjectContract.enforceCiProviderOutputs(
        renderedProjectPath,
        ciProvider: metadata.ciProvider,
      );

      for (final relativePath in _initOwnedPaths) {
        _copyRenderedPath(
          fromRoot: renderedProjectPath,
          toRoot: projectPath,
          relativePath: relativePath,
          overwriteExisting: false,
          createdPaths: createdPaths,
          journal: journal,
        );
      }

      _ensureExecutableToolScripts(projectPath, relativePaths: createdPaths);
      createdPaths.sort();
      return InitSurfaceSyncResult(createdPaths: createdPaths);
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  void _copyRenderedPath({
    required String fromRoot,
    required String toRoot,
    required String relativePath,
    bool overwriteExisting = true,
    List<String>? createdPaths,
    ProjectMutationJournal? journal,
  }) {
    final sourcePath = p.join(fromRoot, relativePath);
    final type = FileSystemEntity.typeSync(sourcePath);

    if (type == FileSystemEntityType.notFound) {
      return;
    }

    final destinationPath = p.join(toRoot, relativePath);

    switch (type) {
      case FileSystemEntityType.file:
        final file = File(destinationPath);
        if (!overwriteExisting && file.existsSync()) {
          return;
        }
        final content = File(sourcePath).readAsStringSync();
        if (journal != null) {
          journal.writeFile(destinationPath, content);
        } else {
          file.parent.createSync(recursive: true);
          file.writeAsStringSync(content);
        }
        createdPaths?.add(relativePath);
        return;
      case FileSystemEntityType.directory:
        final sourceDir = Directory(sourcePath);
        for (final entity in sourceDir.listSync(recursive: true)) {
          final relativeEntity = p.relative(entity.path, from: fromRoot);
          final targetEntity = p.join(toRoot, relativeEntity);
          if (entity is File) {
            final file = File(targetEntity);
            if (!overwriteExisting && file.existsSync()) {
              continue;
            }
            final content = entity.readAsStringSync();
            if (journal != null) {
              journal.writeFile(targetEntity, content);
            } else {
              file.parent.createSync(recursive: true);
              file.writeAsStringSync(content);
            }
            createdPaths?.add(relativeEntity);
          } else if (entity is Directory) {
            Directory(targetEntity).createSync(recursive: true);
          }
        }
        return;
      case FileSystemEntityType.link:
      case FileSystemEntityType.notFound:
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
        return;
    }
  }

  void _ensureExecutableToolScripts(
    String projectPath, {
    Iterable<String>? relativePaths,
  }) {
    if (Platform.isWindows) {
      return;
    }

    if (relativePaths != null) {
      for (final relativePath in relativePaths) {
        if (!relativePath.startsWith('tools/') ||
            !relativePath.endsWith('.sh')) {
          continue;
        }
        _markExecutable(File(p.join(projectPath, relativePath)));
      }
      return;
    }

    final toolsDir = Directory(p.join(projectPath, 'tools'));
    if (!toolsDir.existsSync()) {
      return;
    }

    for (final entity in toolsDir.listSync()) {
      if (entity is! File || !entity.path.endsWith('.sh')) {
        continue;
      }
      _markExecutable(entity);
    }
  }

  void _markExecutable(File file) {
    final result = Process.runSync('chmod', ['755', file.path]);
    if (result.exitCode != 0) {
      final stderr = '${result.stderr}'.trim();
      throw FileSystemException(
        stderr.isEmpty
            ? 'Failed to mark tool script executable'
            : 'Failed to mark tool script executable: $stderr',
        file.path,
      );
    }
  }

  Future<MasonGenerator> _loadGenerator() async {
    final bricksRoot = await _resolveBricksRoot();
    final brick = Brick.path(p.join(bricksRoot, 'agentic_app'));
    return MasonGenerator.fromBrick(brick);
  }

  static Future<String> _resolveBricksRoot() async {
    final packageUri = Uri.parse('package:agentic_base/agentic_base.dart');
    final resolved = await Isolate.resolvePackageUri(packageUri);
    if (resolved != null) {
      final root = p.dirname(p.dirname(resolved.toFilePath()));
      final dir = p.join(root, 'bricks');
      if (Directory(dir).existsSync()) {
        return dir;
      }
    }

    final script = Platform.script.toFilePath();
    final root = p.dirname(p.dirname(script));
    final dir = p.join(root, 'bricks');
    if (Directory(dir).existsSync()) {
      return dir;
    }

    throw StateError('Could not locate bricks directory.');
  }
}

final class InitSurfaceSyncResult {
  const InitSurfaceSyncResult({required this.createdPaths});

  final List<String> createdPaths;
}
