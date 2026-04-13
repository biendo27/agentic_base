import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/deploy/process_runner.dart';
import 'package:agentic_base/src/generators/agentic_app_surface_synchronizer.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Upgrades Flutter dependencies and syncs generator-owned repo surfaces.
///
/// Usage: `agentic_base upgrade`
///
/// Steps:
///   1. Run `flutter pub upgrade`
///   2. Detect major-version bumps in pubspec.lock and warn about each
///   3. Update `.info/agentic.yaml` → `tool_version`
class UpgradeCommand extends Command<int> {
  UpgradeCommand({
    required AgenticLogger logger,
    ProcessRunner? processRunner,
    String Function()? projectPathProvider,
    Future<void> Function({
      required String projectPath,
      required ProjectMetadata metadata,
    })?
    surfaceSync,
  }) : _logger = logger,
       _processRunner = processRunner ?? runProcess,
       _projectPathProvider = projectPathProvider,
       _surfaceSync = surfaceSync;

  final AgenticLogger _logger;
  final ProcessRunner _processRunner;
  final String Function()? _projectPathProvider;
  final Future<void> Function({
    required String projectPath,
    required ProjectMetadata metadata,
  })?
  _surfaceSync;

  @override
  String get name => 'upgrade';

  @override
  String get description =>
      'Upgrade dependencies and sync generator-owned repo surfaces.';

  @override
  String get invocation => 'agentic_base upgrade';

  @override
  Future<int> run() async {
    final projectPath = _projectPathProvider?.call() ?? Directory.current.path;

    // Must be inside an agentic_base project.
    final config = AgenticConfig(projectPath: projectPath);
    if (!config.exists) {
      _logger.err(
        'No .info/agentic.yaml found. '
        'Run this command inside an agentic_base project.',
      );
      return 1;
    }

    // Snapshot pubspec.lock BEFORE upgrade for diff.
    final lockFile = File(p.join(projectPath, 'pubspec.lock'));
    final snapshotBefore = _readLockVersions(lockFile);

    _logger.header('Upgrading dependencies...');

    final metadata = config.readMetadata(
      fallbackProjectName: p.basename(projectPath),
      fallbackToolVersion: AgenticBaseCliRunner.version,
    );

    // Run flutter pub upgrade.
    final upgradeResult = await _runFlutterPubUpgrade(projectPath);
    if (upgradeResult != 0) return upgradeResult;

    // Diff pubspec.lock for major-version bumps.
    final snapshotAfter = _readLockVersions(lockFile);
    _reportMajorBumps(snapshotBefore, snapshotAfter);

    final syncProgress = _logger.progress(
      'Syncing generator-owned repo assets',
    );
    try {
      final sync =
          _surfaceSync ??
          ({
            required String projectPath,
            required ProjectMetadata metadata,
          }) {
            return const AgenticAppSurfaceSynchronizer()
                .syncUpgradeOwnedSurfaces(
                  projectPath: projectPath,
                  metadata: metadata,
                );
          };
      await sync(projectPath: projectPath, metadata: metadata);
      syncProgress.complete('Generator-owned repo assets synced');
    } on Exception catch (error) {
      syncProgress.fail('Generator-owned repo asset sync failed');
      _logger.err('$error');
      return 1;
    }

    // Stamp current tool version into agentic.yaml.
    _stampToolVersion(config, metadata: metadata);

    _logger
      ..info('')
      ..success('Upgrade complete.')
      ..info('Run `agentic_base doctor` to verify project health.');

    return 0;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Run `flutter pub upgrade` and stream output to the user.
  Future<int> _runFlutterPubUpgrade(String projectPath) async {
    final progress = _logger.progress('Running flutter pub upgrade');

    final result = await _processRunner(
      'flutter',
      ['pub', 'upgrade'],
      workingDirectory: projectPath,
    );

    if (result.exitCode != 0) {
      progress.fail('flutter pub upgrade failed');
      final stderr = (result.stderr as String).trim();
      if (stderr.isNotEmpty) _logger.err(stderr);
      final stdout = (result.stdout as String).trim();
      if (stdout.isNotEmpty) _logger.info(stdout);
      return 1;
    }

    progress.complete('Dependencies upgraded');
    return 0;
  }

  /// Read package → major version number from pubspec.lock.
  ///
  /// Returns an empty map if the file doesn't exist or cannot be parsed.
  Map<String, int> _readLockVersions(File lockFile) {
    if (!lockFile.existsSync()) return {};
    try {
      final content = lockFile.readAsStringSync();
      final yaml = loadYaml(content);
      if (yaml is! YamlMap) return {};
      final packages = yaml['packages'];
      if (packages is! YamlMap) return {};

      final result = <String, int>{};
      for (final entry in packages.entries) {
        final name = entry.key as String;
        final info = entry.value;
        if (info is YamlMap) {
          final version = info['version'];
          if (version is String) {
            final major = _parseMajor(version);
            if (major != null) result[name] = major;
          }
        }
      }
      return result;
    } on Exception {
      return {};
    }
  }

  /// Parse the major segment from a semver string like `'2.3.1'`.
  int? _parseMajor(String version) {
    final parts = version.split('.');
    if (parts.isEmpty) return null;
    return int.tryParse(parts.first);
  }

  /// Log a warning for every package whose major version increased.
  void _reportMajorBumps(
    Map<String, int> before,
    Map<String, int> after,
  ) {
    final bumps = <String>[];
    for (final entry in after.entries) {
      final prevMajor = before[entry.key];
      if (prevMajor != null && entry.value > prevMajor) {
        bumps.add('${entry.key}: $prevMajor → ${entry.value}');
      }
    }

    if (bumps.isEmpty) return;

    _logger
      ..info('')
      ..warn('Major version bumps detected — review breaking changes:');
    for (final bump in bumps) {
      _logger.warn('  * $bump');
    }
  }

  /// Write the current CLI version into `.info/agentic.yaml`.
  void _stampToolVersion(
    AgenticConfig config, {
    required ProjectMetadata metadata,
  }) {
    config
      ..writeMetadata(
        metadata.copyWith(
          toolVersion: AgenticBaseCliRunner.version,
          provenance: {
            ...metadata.provenance,
            'tool_version': MetadataProvenance.explicit,
          },
        ),
      )
      ..write({'last_upgraded': DateTime.now().toIso8601String()});
  }
}
