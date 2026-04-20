import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_metadata.dart';

const defaultProjectFlavors = <String>['dev', 'staging', 'prod'];
const defaultProjectPlatforms = <String>['android', 'ios', 'web'];

enum MetadataProvenance { explicit, inferred, defaulted, migrated }

extension MetadataProvenanceX on MetadataProvenance {
  String get wireName => switch (this) {
    MetadataProvenance.explicit => 'explicit',
    MetadataProvenance.inferred => 'inferred',
    MetadataProvenance.defaulted => 'defaulted',
    MetadataProvenance.migrated => 'migrated',
  };

  static MetadataProvenance fromWireName(String? value) => switch (value) {
    'explicit' => MetadataProvenance.explicit,
    'inferred' => MetadataProvenance.inferred,
    'defaulted' => MetadataProvenance.defaulted,
    'migrated' => MetadataProvenance.migrated,
    _ => MetadataProvenance.defaulted,
  };
}

final class ProjectMetadata {
  ProjectMetadata({
    required this.toolVersion,
    required this.projectName,
    required this.org,
    required this.ciProvider,
    required this.stateManagement,
    required this.platforms,
    required this.flavors,
    required this.modules,
    required this.harness,
    required this.provenance,
    this.schemaVersion = 3,
    this.projectKind = 'agent_ready_flutter_repo',
    this.createdAt,
  });

  factory ProjectMetadata.fromConfigMap(
    Map<String, dynamic> data, {
    String fallbackProjectName = 'app',
    String fallbackToolVersion = 'unknown',
  }) {
    final provenance = _parseProvenanceMap(data['metadata_provenance']);
    final capabilities = _readStringList(data['modules']) ?? const <String>[];
    const fallbackSdk = FlutterSdkContract(
      manager: FlutterSdkManager.system,
      channel: defaultFlutterChannel,
      version: newestTestedFlutterVersion,
      policy: FlutterVersionPolicy.newestTested,
    );
    return ProjectMetadata(
      schemaVersion: _readInt(data['schema_version']) ?? 3,
      projectKind:
          _readString(data['project_kind']) ?? 'agent_ready_flutter_repo',
      toolVersion: _readString(data['tool_version']) ?? fallbackToolVersion,
      projectName: _readString(data['project_name']) ?? fallbackProjectName,
      org: _readString(data['org']) ?? 'com.example',
      ciProvider: _readCiProvider(data['ci_provider']) ?? defaultCiProvider,
      stateManagement: _readString(data['state_management']) ?? 'cubit',
      platforms: _readStringList(data['platforms']) ?? defaultProjectPlatforms,
      flavors: _readStringList(data['flavors']) ?? defaultProjectFlavors,
      modules: capabilities,
      harness: HarnessMetadata.fromConfigMap(
        data,
        fallbackCapabilities: capabilities,
        fallbackSdk: fallbackSdk,
      ),
      provenance: _resolveFieldProvenance(
        data,
        provenance,
        fallbackProjectName: fallbackProjectName,
        fallbackToolVersion: fallbackToolVersion,
      ),
      createdAt: _readString(data['created_at']),
    );
  }

  final int schemaVersion;
  final String projectKind;
  final String toolVersion;
  final String projectName;
  final String org;
  final CiProvider ciProvider;
  final String stateManagement;
  final List<String> platforms;
  final List<String> flavors;
  final List<String> modules;
  final HarnessMetadata harness;
  final Map<String, MetadataProvenance> provenance;
  final String? createdAt;

  ProjectMetadata copyWith({
    int? schemaVersion,
    String? projectKind,
    String? toolVersion,
    String? projectName,
    String? org,
    CiProvider? ciProvider,
    String? stateManagement,
    List<String>? platforms,
    List<String>? flavors,
    List<String>? modules,
    HarnessMetadata? harness,
    Map<String, MetadataProvenance>? provenance,
    String? createdAt,
  }) {
    return ProjectMetadata(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      projectKind: projectKind ?? this.projectKind,
      toolVersion: toolVersion ?? this.toolVersion,
      projectName: projectName ?? this.projectName,
      org: org ?? this.org,
      ciProvider: ciProvider ?? this.ciProvider,
      stateManagement: stateManagement ?? this.stateManagement,
      platforms: platforms ?? this.platforms,
      flavors: flavors ?? this.flavors,
      modules: modules ?? this.modules,
      harness: harness ?? this.harness,
      provenance: provenance ?? this.provenance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toConfigMap() {
    return <String, dynamic>{
      'schema_version': schemaVersion,
      'project_kind': projectKind,
      'tool_version': toolVersion,
      'project_name': projectName,
      'org': org,
      'ci_provider': ciProvider.name,
      'state_management': stateManagement,
      'platforms': platforms,
      'flavors': flavors,
      'modules': modules,
      'harness': harness.toConfigMap(),
      'metadata_provenance': provenance.map(
        (key, value) => MapEntry(key, value.wireName),
      ),
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  static Map<String, MetadataProvenance> _resolveFieldProvenance(
    Map<String, dynamic> data,
    Map<String, MetadataProvenance> parsed, {
    required String fallbackProjectName,
    required String fallbackToolVersion,
  }) {
    MetadataProvenance resolve(String key, {required bool hasDefault}) {
      final parsedValue = parsed[key];
      if (parsedValue != null) return parsedValue;
      if (data.containsKey(key)) {
        return MetadataProvenance.migrated;
      }
      return hasDefault
          ? MetadataProvenance.defaulted
          : MetadataProvenance.defaulted;
    }

    return <String, MetadataProvenance>{
      'schema_version': resolve('schema_version', hasDefault: true),
      'project_kind': resolve('project_kind', hasDefault: true),
      'tool_version':
          data.containsKey('tool_version') || fallbackToolVersion != 'unknown'
              ? resolve('tool_version', hasDefault: true)
              : MetadataProvenance.defaulted,
      'project_name':
          data.containsKey('project_name') || fallbackProjectName != 'app'
              ? resolve('project_name', hasDefault: true)
              : MetadataProvenance.defaulted,
      'org': resolve('org', hasDefault: true),
      'ci_provider': resolve('ci_provider', hasDefault: true),
      'state_management': resolve('state_management', hasDefault: true),
      'platforms': resolve('platforms', hasDefault: true),
      'flavors': resolve('flavors', hasDefault: true),
      'modules': resolve('modules', hasDefault: true),
      'harness.contract_version': resolve(
        'harness.contract_version',
        hasDefault: true,
      ),
      'harness.app_profile.primary_profile': resolve(
        'harness.app_profile.primary_profile',
        hasDefault: true,
      ),
      'harness.app_profile.secondary_traits': resolve(
        'harness.app_profile.secondary_traits',
        hasDefault: true,
      ),
      'harness.capabilities.enabled': resolve(
        'harness.capabilities.enabled',
        hasDefault: true,
      ),
      'harness.providers': resolve('harness.providers', hasDefault: true),
      'harness.eval.evidence_dir': resolve(
        'harness.eval.evidence_dir',
        hasDefault: true,
      ),
      'harness.eval.quality_dimensions': resolve(
        'harness.eval.quality_dimensions',
        hasDefault: true,
      ),
      'harness.approvals.pause_on': resolve(
        'harness.approvals.pause_on',
        hasDefault: true,
      ),
      'harness.observability.mode': resolve(
        'harness.observability.mode',
        hasDefault: true,
      ),
      'harness.observability.runtime_observability': resolve(
        'harness.observability.runtime_observability',
        hasDefault: true,
      ),
      'harness.observability.agent_legibility': resolve(
        'harness.observability.agent_legibility',
        hasDefault: true,
      ),
      'harness.observability.operator_reports': resolve(
        'harness.observability.operator_reports',
        hasDefault: true,
      ),
      'harness.sdk.manager': resolve(
        'harness.sdk.manager',
        hasDefault: true,
      ),
      'harness.sdk.preferred_manager': resolve(
        'harness.sdk.preferred_manager',
        hasDefault: true,
      ),
      'harness.sdk.channel': resolve(
        'harness.sdk.channel',
        hasDefault: true,
      ),
      'harness.sdk.version': resolve(
        'harness.sdk.version',
        hasDefault: true,
      ),
      'harness.sdk.preferred_version': resolve(
        'harness.sdk.preferred_version',
        hasDefault: true,
      ),
      'harness.sdk.policy': resolve(
        'harness.sdk.policy',
        hasDefault: true,
      ),
      'created_at': resolve('created_at', hasDefault: true),
    };
  }

  static Map<String, MetadataProvenance> _parseProvenanceMap(dynamic raw) {
    if (raw is! Map) return const <String, MetadataProvenance>{};
    return raw.map((key, value) {
      return MapEntry(
        key.toString(),
        MetadataProvenanceX.fromWireName(value?.toString()),
      );
    });
  }

  static String? _readString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static CiProvider? _readCiProvider(dynamic value) {
    final wireValue = _readString(value);
    if (wireValue == null) return null;
    try {
      return parseCiProvider(wireValue);
    } on Exception {
      return null;
    }
  }

  static List<String>? _readStringList(dynamic value) {
    if (value is! List) return null;
    return value
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }
}
