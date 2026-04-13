import 'dart:io';

import 'package:agentic_base/src/config/agent_ready_repo_contract.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Reads/writes `.info/agentic.yaml` for project state tracking.
class AgenticConfig {
  AgenticConfig({required this.projectPath});

  final String projectPath;

  String get _configPath => p.join(projectPath, '.info', 'agentic.yaml');

  /// Whether an agentic.yaml config exists at [projectPath].
  bool get exists => File(_configPath).existsSync();

  /// Read current config. Returns empty map if file doesn't exist.
  Map<String, dynamic> read() {
    final file = File(_configPath);
    if (!file.existsSync()) return {};
    final content = file.readAsStringSync();
    if (content.trim().isEmpty) return {};
    final yaml = loadYaml(content);
    if (yaml is! YamlMap) return {};
    return _yamlMapToMap(yaml);
  }

  ProjectMetadata readMetadata({
    String fallbackProjectName = 'app',
    String fallbackToolVersion = 'unknown',
  }) {
    return ProjectMetadata.fromConfigMap(
      read(),
      fallbackProjectName: fallbackProjectName,
      fallbackToolVersion: fallbackToolVersion,
    );
  }

  /// Write [data] to agentic.yaml, preserving comments if file exists.
  void write(Map<String, dynamic> data) {
    final file = File(_configPath);
    file.parent.createSync(recursive: true);

    final existing = file.existsSync() ? file.readAsStringSync() : '';
    // YamlEditor.update fails on empty docs — seed with empty map
    final content = existing.trim().isEmpty ? '{}' : existing;
    final editor = YamlEditor(content);
    for (final entry in data.entries) {
      editor.update([entry.key], entry.value);
    }
    file.writeAsStringSync(editor.toString());
  }

  void writeMetadata(ProjectMetadata metadata) {
    write(<String, dynamic>{
      ...metadata.toConfigMap(),
      ...buildAgentReadyConfigMap(metadata),
    });
  }

  /// Create initial config for a new project.
  static ProjectMetadata createInitial({
    required String projectPath,
    required String projectName,
    required String org,
    required String stateManagement,
    required List<String> platforms,
    required List<String> flavors,
    required String toolVersion,
    CiProvider ciProvider = defaultCiProvider,
    Map<String, MetadataProvenance> provenance =
        const <String, MetadataProvenance>{},
    List<String> modules = const <String>[],
  }) {
    final metadata = ProjectMetadata(
      toolVersion: toolVersion,
      projectName: projectName,
      org: org,
      ciProvider: ciProvider,
      stateManagement: stateManagement,
      platforms: List<String>.from(platforms),
      flavors: List<String>.from(flavors),
      modules: List<String>.from(modules),
      createdAt: DateTime.now().toIso8601String(),
      provenance: {
        'schema_version': MetadataProvenance.defaulted,
        'project_kind': MetadataProvenance.defaulted,
        'tool_version':
            provenance['tool_version'] ?? MetadataProvenance.explicit,
        'project_name':
            provenance['project_name'] ?? MetadataProvenance.explicit,
        'org': provenance['org'] ?? MetadataProvenance.explicit,
        'ci_provider': provenance['ci_provider'] ?? MetadataProvenance.explicit,
        'state_management':
            provenance['state_management'] ?? MetadataProvenance.explicit,
        'platforms': provenance['platforms'] ?? MetadataProvenance.explicit,
        'flavors': provenance['flavors'] ?? MetadataProvenance.explicit,
        'modules': provenance['modules'] ?? MetadataProvenance.explicit,
        'created_at': MetadataProvenance.defaulted,
      },
    );
    AgenticConfig(projectPath: projectPath).writeMetadata(metadata);
    return metadata;
  }

  static Map<String, dynamic> _yamlMapToMap(YamlMap yaml) {
    return yaml.map((key, value) {
      return MapEntry(key.toString(), _convertValue(value));
    });
  }

  static dynamic _convertValue(dynamic value) {
    if (value is YamlMap) return _yamlMapToMap(value);
    if (value is YamlList) return value.map(_convertValue).toList();
    return value;
  }
}
