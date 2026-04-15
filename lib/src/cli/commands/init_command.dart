import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/config/init_project_metadata_resolver.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/generators/agentic_app_surface_synchronizer.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:agentic_base/src/modules/project_mutation_journal.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Adds agentic_base scaffolding to an EXISTING Flutter project.
///
/// Non-destructive: never overwrites files that already exist.
///
/// Usage: `agentic_base init`
class InitCommand extends Command<int> {
  InitCommand({
    required AgenticLogger logger,
    FlutterToolchainDetector? toolchainDetector,
  }) : _logger = logger,
       _toolchainDetector = toolchainDetector ?? detectFlutterToolchain {
    argParser.addOption(
      'ci-provider',
      help: 'CI provider: github or gitlab',
      allowed: supportedCiProviders,
    );
  }

  final AgenticLogger _logger;
  final FlutterToolchainDetector _toolchainDetector;

  @override
  String get name => 'init';

  @override
  String get description =>
      'Add agentic_base scaffolding to an existing Flutter project.';

  @override
  String get invocation => 'agentic_base init';

  @override
  Future<int> run() async {
    final projectPath = Directory.current.path;

    // Must be inside a Flutter project (pubspec.yaml must exist).
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      _logger.err(
        'No pubspec.yaml found. '
        'Run this command inside a Flutter project root.',
      );
      return 1;
    }

    final config = AgenticConfig(projectPath: projectPath);
    final pubspecContent = pubspecFile.readAsStringSync();
    final resolver = InitProjectMetadataResolver(
      toolchainDetector: _toolchainDetector,
    );
    final metadata =
        (() {
          try {
            return resolver.resolve(
              projectPath: projectPath,
              pubspecContent: pubspecContent,
              projectNameFallback: p.basename(projectPath),
              explicitCiProvider: argResults!['ci-provider'] as String?,
            );
          } on FlutterToolchainResolutionException catch (error) {
            _logger.err(error.message);
            return null;
          }
        })();
    if (metadata == null) {
      return 1;
    }
    final projectName = metadata.projectName;
    final modeLabel = config.exists ? 'Repairing' : 'Initialising';

    _logger
      ..header('$modeLabel agentic_base...')
      ..info(
        'Resolved state management: ${metadata.stateManagement} '
        '(${metadata.provenance['state_management']!.wireName})',
      );
    final added = <String>[];
    final journal = ProjectMutationJournal();
    const synchronizer = AgenticAppSurfaceSynchronizer();
    final syncResult = await synchronizer.syncInitOwnedSurfaces(
      projectPath: projectPath,
      metadata: metadata,
      journal: journal,
    );
    added.addAll(syncResult.createdPaths);
    _repairGitLabRootCiIfNeeded(
      projectPath: projectPath,
      ciProvider: metadata.ciProvider.name,
      added: added,
      journal: journal,
    );

    _writeIfAbsent(
      path: p.join(projectPath, 'Makefile'),
      content: _makefileContent,
      added: added,
      journal: journal,
    );

    _writeIfAbsent(
      path: p.join(projectPath, 'analysis_options.yaml'),
      content: _safeAnalysisOptionsContent,
      added: added,
      journal: journal,
    );

    final configFile = File(p.join(projectPath, '.info', 'agentic.yaml'));
    final previousConfig =
        configFile.existsSync() ? configFile.readAsStringSync() : null;

    try {
      config.writeMetadata(metadata);
      added.add('.info/agentic.yaml');
      GeneratedProjectContract.validateAgentReadyRepository(
        projectPath,
        ciProvider: metadata.ciProvider,
      );
    } on Exception catch (error) {
      journal.rollback();
      if (previousConfig != null) {
        configFile.parent.createSync(recursive: true);
        configFile.writeAsStringSync(previousConfig);
      } else if (configFile.existsSync()) {
        configFile.deleteSync();
      }
      _logger.err(
        'Init could not produce an honest agent-ready contract: $error',
      );
      return 1;
    }

    // Report summary.
    _logger
      ..info('')
      ..success('$projectName is now synced to the agent-ready scaffold.')
      ..info('')
      ..info('Files created or updated:');
    for (final f in added) {
      _logger.info('  + $f');
    }
    _logger
      ..info('')
      ..info('Next steps:')
      ..info('  ./tools/setup.sh')
      ..info('  agentic_base doctor');

    return 0;
  }

  /// Write [content] to [path] only if the file does not already exist.
  void _writeIfAbsent({
    required String path,
    required String content,
    required List<String> added,
    ProjectMutationJournal? journal,
  }) {
    final file = File(path);
    if (file.existsSync()) return;
    if (journal != null) {
      journal.writeFile(path, content);
    } else {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(content);
    }
    added.add(p.relative(path, from: Directory.current.path));
  }

  void _repairGitLabRootCiIfNeeded({
    required String projectPath,
    required String ciProvider,
    required List<String> added,
    ProjectMutationJournal? journal,
  }) {
    if (ciProvider != 'gitlab') {
      return;
    }

    final file = File(p.join(projectPath, '.gitlab-ci.yml'));
    if (!file.existsSync()) {
      return;
    }

    final content = file.readAsStringSync();
    final parsed = loadYaml(content);
    if (parsed is! YamlMap) {
      return;
    }

    final mergedIncludes = _mergeGitLabIncludes(parsed['include']);
    if (_sameGitLabIncludes(parsed['include'], mergedIncludes)) {
      return;
    }

    final editor = YamlEditor(content)..update(['include'], mergedIncludes);
    if (journal != null) {
      journal.writeFile(file.path, editor.toString());
    } else {
      file.writeAsStringSync(editor.toString());
    }
    if (!added.contains('.gitlab-ci.yml')) {
      added.add('.gitlab-ci.yml');
    }
  }

  List<Object> _mergeGitLabIncludes(dynamic rawInclude) {
    final merged = <Object>[];
    if (rawInclude is YamlList) {
      merged.addAll(rawInclude.map(_normalizeGitLabInclude));
    } else if (rawInclude != null) {
      merged.add(_normalizeGitLabInclude(rawInclude));
    }

    for (final requiredInclude in const [
      {'local': '.gitlab/ci/verify.yml'},
      {'local': '.gitlab/ci/deploy.yml'},
    ]) {
      final exists = merged.any(
        (entry) => entry is Map && entry['local'] == requiredInclude['local'],
      );
      if (!exists) {
        merged.add(requiredInclude);
      }
    }
    return merged;
  }

  Object _normalizeGitLabInclude(dynamic entry) {
    if (entry is YamlMap) {
      return entry.map((key, value) => MapEntry('$key', value));
    }
    return entry?.toString() ?? '';
  }

  bool _sameGitLabIncludes(dynamic rawInclude, List<Object> mergedIncludes) {
    if (rawInclude is! YamlList || rawInclude.length != mergedIncludes.length) {
      return false;
    }

    for (var index = 0; index < rawInclude.length; index++) {
      final left = _normalizeGitLabInclude(rawInclude[index]);
      final right = mergedIncludes[index];
      if ('$left' != '$right') {
        return false;
      }
    }
    return true;
  }
}

const _makefileContent = '''
.PHONY: analyze format test build

analyze:
\t./tools/lint.sh

format:
\t./tools/format.sh

test:
\t./tools/test.sh

build:
\t./tools/build.sh
''';

const _safeAnalysisOptionsContent = '''
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    public_member_api_docs: false
''';
