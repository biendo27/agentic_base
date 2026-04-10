import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
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

  /// Create initial config for a new project.
  static void createInitial({
    required String projectPath,
    required String projectName,
    required String org,
    required String stateManagement,
    required List<String> platforms,
    required List<String> flavors,
    required String toolVersion,
    CiProvider ciProvider = defaultCiProvider,
  }) {
    AgenticConfig(projectPath: projectPath).write({
      'tool_version': toolVersion,
      'project_name': projectName,
      'org': org,
      'ci_provider': ciProvider.name,
      'state_management': stateManagement,
      'platforms': platforms,
      'flavors': flavors,
      'modules': <String>[],
      'created_at': DateTime.now().toIso8601String(),
    });
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
