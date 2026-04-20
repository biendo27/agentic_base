import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_profile.dart';

final class HarnessEvalConfig {
  const HarnessEvalConfig({
    required this.evidenceDir,
    required this.qualityDimensions,
  });

  factory HarnessEvalConfig.fromConfigMap(dynamic raw) {
    if (raw is! Map) {
      return const HarnessEvalConfig(
        evidenceDir: defaultHarnessEvidenceDir,
        qualityDimensions: defaultHarnessQualityDimensions,
      );
    }

    return HarnessEvalConfig(
      evidenceDir:
          _readString(raw['evidence_dir']) ?? defaultHarnessEvidenceDir,
      qualityDimensions:
          _readCanonicalQualityDimensions(raw['quality_dimensions']) ??
          defaultHarnessQualityDimensions,
    );
  }

  final String evidenceDir;
  final List<String> qualityDimensions;

  Map<String, dynamic> toConfigMap() {
    return <String, dynamic>{
      'evidence_dir': evidenceDir,
      'quality_dimensions': qualityDimensions,
    };
  }
}

final class HarnessApprovalsConfig {
  const HarnessApprovalsConfig({required this.pauseOn});

  factory HarnessApprovalsConfig.fromConfigMap(dynamic raw) {
    if (raw is! Map) {
      return const HarnessApprovalsConfig(
        pauseOn: requiredHumanApprovalPauses,
      );
    }

    return HarnessApprovalsConfig(
      pauseOn: _readStringList(raw['pause_on']) ?? requiredHumanApprovalPauses,
    );
  }

  final List<String> pauseOn;

  Map<String, dynamic> toConfigMap() {
    return <String, dynamic>{'pause_on': pauseOn};
  }
}

final class HarnessObservabilityConfig {
  const HarnessObservabilityConfig({
    required this.mode,
    required this.runtimeObservability,
    required this.agentLegibility,
    required this.operatorReports,
  });

  factory HarnessObservabilityConfig.fromConfigMap(dynamic raw) {
    if (raw is! Map) {
      return const HarnessObservabilityConfig(
        mode: defaultHarnessObservabilityMode,
        runtimeObservability: defaultHarnessRuntimeObservability,
        agentLegibility: defaultHarnessAgentLegibility,
        operatorReports: defaultHarnessOperatorReports,
      );
    }

    return HarnessObservabilityConfig(
      mode: _readString(raw['mode']) ?? defaultHarnessObservabilityMode,
      runtimeObservability:
          _readStringList(raw['runtime_observability']) ??
          defaultHarnessRuntimeObservability,
      agentLegibility:
          _readStringList(raw['agent_legibility']) ??
          defaultHarnessAgentLegibility,
      operatorReports:
          _readStringList(raw['operator_reports']) ??
          defaultHarnessOperatorReports,
    );
  }

  final String mode;
  final List<String> runtimeObservability;
  final List<String> agentLegibility;
  final List<String> operatorReports;

  Map<String, dynamic> toConfigMap() {
    return <String, dynamic>{
      'mode': mode,
      'runtime_observability': runtimeObservability,
      'agent_legibility': agentLegibility,
      'operator_reports': operatorReports,
    };
  }
}

final class HarnessMetadata {
  const HarnessMetadata({
    required this.contractVersion,
    required this.appProfile,
    required this.secondaryTraits,
    required this.capabilities,
    required this.providers,
    required this.eval,
    required this.approvals,
    required this.observability,
    required this.sdk,
  });

  factory HarnessMetadata.fromConfigMap(
    Map<String, dynamic> data, {
    List<String> fallbackCapabilities = const <String>[],
    FlutterSdkContract? fallbackSdk,
  }) {
    final rawHarness = data['harness'];
    if (rawHarness is! Map) {
      final capabilities = List<String>.from(fallbackCapabilities);
      return HarnessMetadata.defaultFor(
        capabilities: capabilities,
        providers: buildHarnessProviderMap(capabilities),
        sdk: fallbackSdk,
      );
    }

    final rawAppProfile = rawHarness['app_profile'];
    final capabilities =
        _readStringList(
          rawHarness['capabilities'] is Map
              ? (rawHarness['capabilities'] as Map)['enabled']
              : null,
        ) ??
        List<String>.from(fallbackCapabilities);
    final providers =
        _readStringMap(rawHarness['providers']) ??
        buildHarnessProviderMap(capabilities);
    final resolvedSdk = FlutterSdkContract.fromConfigMap(rawHarness['sdk']);

    return HarnessMetadata(
      contractVersion: _readInt(rawHarness['contract_version']) ?? 1,
      appProfile: HarnessAppProfileX.fromWireName(
        rawAppProfile is Map
            ? rawAppProfile['primary_profile']?.toString()
            : null,
      ),
      secondaryTraits:
          _readStringList(
            rawAppProfile is Map ? rawAppProfile['secondary_traits'] : null,
          ) ??
          const <String>[],
      capabilities: capabilities,
      providers: providers,
      eval: HarnessEvalConfig.fromConfigMap(rawHarness['eval']),
      approvals: HarnessApprovalsConfig.fromConfigMap(
        rawHarness['approvals'],
      ),
      observability: HarnessObservabilityConfig.fromConfigMap(
        rawHarness['observability'],
      ),
      sdk:
          fallbackSdk != null
              ? fallbackSdk.copyWith(
                manager: resolvedSdk.manager,
                channel: resolvedSdk.channel,
                version: resolvedSdk.version,
                policy: resolvedSdk.policy,
                preferredManager: resolvedSdk.preferredManager,
                preferredVersion: resolvedSdk.preferredVersion,
              )
              : resolvedSdk,
    );
  }

  factory HarnessMetadata.defaultFor({
    HarnessAppProfile appProfile = HarnessAppProfile.consumerApp,
    List<String> secondaryTraits = const <String>[],
    List<String> capabilities = const <String>[],
    Map<String, String>? providers,
    FlutterSdkContract? sdk,
  }) {
    final resolvedCapabilities = List<String>.from(capabilities);
    return HarnessMetadata(
      contractVersion: 1,
      appProfile: appProfile,
      secondaryTraits: List<String>.from(secondaryTraits),
      capabilities: resolvedCapabilities,
      providers: providers ?? buildHarnessProviderMap(resolvedCapabilities),
      eval: const HarnessEvalConfig(
        evidenceDir: defaultHarnessEvidenceDir,
        qualityDimensions: defaultHarnessQualityDimensions,
      ),
      approvals: const HarnessApprovalsConfig(
        pauseOn: requiredHumanApprovalPauses,
      ),
      observability: const HarnessObservabilityConfig(
        mode: defaultHarnessObservabilityMode,
        runtimeObservability: defaultHarnessRuntimeObservability,
        agentLegibility: defaultHarnessAgentLegibility,
        operatorReports: defaultHarnessOperatorReports,
      ),
      sdk:
          sdk ??
          const FlutterSdkContract(
            manager: FlutterSdkManager.system,
            channel: defaultFlutterChannel,
            version: newestTestedFlutterVersion,
            policy: FlutterVersionPolicy.newestTested,
          ),
    );
  }

  final int contractVersion;
  final HarnessAppProfile appProfile;
  final List<String> secondaryTraits;
  final List<String> capabilities;
  final Map<String, String> providers;
  final HarnessEvalConfig eval;
  final HarnessApprovalsConfig approvals;
  final HarnessObservabilityConfig observability;
  final FlutterSdkContract sdk;

  SupportTier get supportTier => appProfile.supportTier;

  HarnessMetadata copyWith({
    int? contractVersion,
    HarnessAppProfile? appProfile,
    List<String>? secondaryTraits,
    List<String>? capabilities,
    Map<String, String>? providers,
    HarnessEvalConfig? eval,
    HarnessApprovalsConfig? approvals,
    HarnessObservabilityConfig? observability,
    FlutterSdkContract? sdk,
  }) {
    return HarnessMetadata(
      contractVersion: contractVersion ?? this.contractVersion,
      appProfile: appProfile ?? this.appProfile,
      secondaryTraits: secondaryTraits ?? this.secondaryTraits,
      capabilities: capabilities ?? this.capabilities,
      providers: providers ?? this.providers,
      eval: eval ?? this.eval,
      approvals: approvals ?? this.approvals,
      observability: observability ?? this.observability,
      sdk: sdk ?? this.sdk,
    );
  }

  Map<String, dynamic> toConfigMap() {
    return <String, dynamic>{
      'contract_version': contractVersion,
      'app_profile': <String, dynamic>{
        'primary_profile': appProfile.wireName,
        'secondary_traits': secondaryTraits,
      },
      'capabilities': <String, dynamic>{'enabled': capabilities},
      'providers': providers,
      'eval': eval.toConfigMap(),
      'approvals': approvals.toConfigMap(),
      'observability': observability.toConfigMap(),
      'sdk': sdk.toConfigMap(),
    };
  }
}

String? _readString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

List<String>? _readStringList(dynamic value) {
  if (value is! List) return null;
  return value
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .toList();
}

List<String>? _readCanonicalQualityDimensions(dynamic value) {
  final dimensions = _readStringList(value);
  if (dimensions == null ||
      dimensions.length != defaultHarnessQualityDimensions.length) {
    return null;
  }

  for (var index = 0; index < dimensions.length; index++) {
    if (dimensions[index] != defaultHarnessQualityDimensions[index]) {
      return null;
    }
  }

  return dimensions;
}

Map<String, String>? _readStringMap(dynamic value) {
  if (value is! Map) return null;
  return value.map((key, entry) {
    return MapEntry(
      key.toString(),
      entry?.toString().trim() ?? '',
    );
  })..removeWhere((key, entry) => entry.isEmpty);
}
