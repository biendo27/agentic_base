import 'package:yaml/yaml.dart';

/// Parsed representation of a feature.spec.yaml file.
class FeatureSpec {
  const FeatureSpec({
    required this.feature,
    required this.description,
    required this.acceptanceCriteria,
    required this.edgeCases,
  });

  final String feature;
  final String description;
  final List<String> acceptanceCriteria;
  final List<String> edgeCases;
}

/// Parses a feature.spec.yaml file into a [FeatureSpec].
///
/// Expects the YAML structure:
/// ```yaml
/// feature: <name>
/// description: <text>
/// acceptance_criteria:
///   - <criterion>
/// edge_cases:
///   - <case>
/// ```
class SpecParser {
  const SpecParser._();

  /// Parse [yamlContent] into a [FeatureSpec].
  ///
  /// Throws [FormatException] if required fields are missing or malformed.
  static FeatureSpec parse(String yamlContent) {
    final dynamic raw = loadYaml(yamlContent);

    if (raw is! YamlMap) {
      throw const FormatException(
        'Invalid spec file: expected a YAML mapping at root.',
      );
    }

    final feature = _requireString(raw, 'feature');
    final description = _requireString(raw, 'description');
    final acceptanceCriteria = _readStringList(raw, 'acceptance_criteria');
    final edgeCases = _readStringList(raw, 'edge_cases');

    return FeatureSpec(
      feature: feature,
      description: description,
      acceptanceCriteria: acceptanceCriteria,
      edgeCases: edgeCases,
    );
  }

  static String _requireString(YamlMap map, String key) {
    final value = map[key];
    if (value == null) {
      throw FormatException('Missing required field "$key" in spec file.');
    }
    if (value is! String || value.isEmpty) {
      throw FormatException(
        'Field "$key" must be a non-empty string. Got: $value',
      );
    }
    return value;
  }

  static List<String> _readStringList(YamlMap map, String key) {
    final value = map[key];
    if (value == null) return [];
    if (value is! YamlList) {
      throw FormatException(
        'Field "$key" must be a YAML list. Got: ${value.runtimeType}',
      );
    }
    return value.map((e) => e.toString()).toList();
  }
}
