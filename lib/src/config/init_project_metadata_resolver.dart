import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/config/harness_metadata.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/config/state_config.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final class InitProjectMetadataResolver {
  const InitProjectMetadataResolver({
    FlutterToolchainDetector toolchainDetector = detectFlutterToolchain,
  }) : _toolchainDetector = toolchainDetector;

  final FlutterToolchainDetector _toolchainDetector;

  ProjectMetadata resolve({
    required String projectPath,
    required String pubspecContent,
    required String projectNameFallback,
    required String? explicitCiProvider,
  }) {
    final config = AgenticConfig(projectPath: projectPath);
    final existingMetadata =
        config.exists
            ? config.readMetadata(
              fallbackProjectName: projectNameFallback,
              fallbackToolVersion: AgenticBaseCliRunner.version,
            )
            : null;
    final pubspecYaml = _tryLoadYaml(pubspecContent);
    final pubspecName = _readPubspecName(pubspecYaml);
    final stateFromPubspec = _detectStateManagement(pubspecYaml);
    final inferredCiProvider = inferCiProviderFromProjectFiles(projectPath);
    final inferredOrg = _detectOrg(projectPath);
    final inferredPlatforms = _detectPlatforms(projectPath);
    final inferredFlavors = _detectFlavors(projectPath);
    final inferredSdkManager = inferFlutterSdkManager(projectPath);

    MetadataResolution<String> resolveString({
      required String? explicitValue,
      required String? inferredValue,
      required String? existingValue,
      required String defaultValue,
    }) {
      if (explicitValue != null && explicitValue.trim().isNotEmpty) {
        return MetadataResolution(
          explicitValue.trim(),
          MetadataProvenance.explicit,
        );
      }
      if (inferredValue != null && inferredValue.trim().isNotEmpty) {
        return MetadataResolution(
          inferredValue.trim(),
          MetadataProvenance.inferred,
        );
      }
      if (existingValue != null && existingValue.trim().isNotEmpty) {
        return MetadataResolution(
          existingValue.trim(),
          MetadataProvenance.migrated,
        );
      }
      return MetadataResolution(defaultValue, MetadataProvenance.defaulted);
    }

    MetadataResolution<List<String>> resolveList({
      required List<String>? inferredValue,
      required List<String>? existingValue,
      required List<String> defaultValue,
    }) {
      if (inferredValue != null && inferredValue.isNotEmpty) {
        return MetadataResolution(
          List<String>.from(inferredValue),
          MetadataProvenance.inferred,
        );
      }
      if (existingValue != null && existingValue.isNotEmpty) {
        return MetadataResolution(
          List<String>.from(existingValue),
          MetadataProvenance.migrated,
        );
      }
      return MetadataResolution(
        List<String>.from(defaultValue),
        MetadataProvenance.defaulted,
      );
    }

    final projectName = resolveString(
      explicitValue: null,
      inferredValue: pubspecName,
      existingValue: existingMetadata?.projectName,
      defaultValue: projectNameFallback,
    );
    final stateManagement = resolveString(
      explicitValue: null,
      inferredValue: stateFromPubspec,
      existingValue: existingMetadata?.stateManagement,
      defaultValue: 'cubit',
    );
    final ciProvider =
        (() {
          if (explicitCiProvider != null) {
            return MetadataResolution(
              parseCiProvider(explicitCiProvider),
              MetadataProvenance.explicit,
            );
          }
          if (inferredCiProvider != null) {
            return MetadataResolution(
              inferredCiProvider,
              MetadataProvenance.inferred,
            );
          }
          if (existingMetadata != null) {
            return MetadataResolution(
              existingMetadata.ciProvider,
              MetadataProvenance.migrated,
            );
          }
          return const MetadataResolution(
            defaultCiProvider,
            MetadataProvenance.defaulted,
          );
        })();
    final org = resolveString(
      explicitValue: null,
      inferredValue: inferredOrg,
      existingValue: existingMetadata?.org,
      defaultValue: 'com.example',
    );
    final platforms = resolveList(
      inferredValue: inferredPlatforms,
      existingValue: existingMetadata?.platforms,
      defaultValue: defaultProjectPlatforms,
    );
    final flavors = resolveList(
      inferredValue: inferredFlavors,
      existingValue: existingMetadata?.flavors,
      defaultValue: defaultProjectFlavors,
    );
    final modules =
        existingMetadata?.modules.isNotEmpty == true
            ? MetadataResolution(
              List<String>.from(existingMetadata!.modules),
              MetadataProvenance.migrated,
            )
            : const MetadataResolution(
              <String>[],
              MetadataProvenance.defaulted,
            );
    final preferredManager =
        existingMetadata?.harness.sdk.preferredManager ??
        existingMetadata?.harness.sdk.manager ??
        inferredSdkManager;
    final preferredVersion =
        existingMetadata?.harness.sdk.preferredVersion ??
        existingMetadata?.harness.sdk.version;
    final resolvedToolchain = resolveFlutterToolchain(
      projectPath: projectPath,
      preferredManager: preferredManager,
      preferredVersion: preferredVersion,
      preferredChannel:
          existingMetadata?.harness.sdk.channel ?? defaultFlutterChannel,
      policy:
          existingMetadata?.harness.sdk.policy ??
          FlutterVersionPolicy.newestTested,
      detector: _toolchainDetector,
    );
    final resolvedSdkContract = resolvedToolchain.contract;
    final preferredManagerProvenance =
        existingMetadata?.provenance['harness.sdk.preferred_manager'] ??
        existingMetadata?.provenance['harness.sdk.manager'] ??
        (preferredManager == FlutterSdkManager.system
            ? MetadataProvenance.defaulted
            : MetadataProvenance.inferred);
    final preferredVersionProvenance =
        existingMetadata?.provenance['harness.sdk.preferred_version'] ??
        existingMetadata?.provenance['harness.sdk.version'] ??
        MetadataProvenance.inferred;
    final harness =
        existingMetadata?.harness.copyWith(
          capabilities: modules.value,
          providers: buildHarnessProviderMap(modules.value),
          sdk: resolvedSdkContract,
        ) ??
        HarnessMetadata.defaultFor(
          capabilities: modules.value,
          sdk: resolvedSdkContract,
        );

    return ProjectMetadata(
      toolVersion: AgenticBaseCliRunner.version,
      projectName: projectName.value,
      org: org.value,
      ciProvider: ciProvider.value,
      stateManagement: stateManagement.value,
      platforms: platforms.value,
      flavors: flavors.value,
      modules: modules.value,
      harness: harness,
      createdAt:
          existingMetadata?.createdAt ?? DateTime.now().toIso8601String(),
      provenance: {
        'schema_version': MetadataProvenance.defaulted,
        'project_kind': MetadataProvenance.defaulted,
        'tool_version': MetadataProvenance.explicit,
        'project_name': projectName.provenance,
        'org': org.provenance,
        'ci_provider': ciProvider.provenance,
        'state_management': stateManagement.provenance,
        'platforms': platforms.provenance,
        'flavors': flavors.provenance,
        'modules': modules.provenance,
        'harness.contract_version':
            existingMetadata?.harness.contractVersion == 1
                ? MetadataProvenance.migrated
                : MetadataProvenance.defaulted,
        'harness.app_profile.primary_profile':
            existingMetadata != null
                ? MetadataProvenance.migrated
                : MetadataProvenance.defaulted,
        'harness.app_profile.secondary_traits':
            existingMetadata != null
                ? MetadataProvenance.migrated
                : MetadataProvenance.defaulted,
        'harness.capabilities.enabled': modules.provenance,
        'harness.providers': MetadataProvenance.defaulted,
        'harness.eval.evidence_dir': MetadataProvenance.defaulted,
        'harness.eval.quality_dimensions': MetadataProvenance.defaulted,
        'harness.approvals.pause_on': MetadataProvenance.defaulted,
        'harness.sdk.manager': MetadataProvenance.inferred,
        'harness.sdk.preferred_manager': preferredManagerProvenance,
        'harness.sdk.channel':
            resolvedToolchain.detected.channel == null
                ? MetadataProvenance.defaulted
                : MetadataProvenance.inferred,
        'harness.sdk.version': MetadataProvenance.inferred,
        'harness.sdk.preferred_version': preferredVersionProvenance,
        'harness.sdk.policy':
            existingMetadata != null
                ? MetadataProvenance.migrated
                : MetadataProvenance.defaulted,
        'created_at':
            existingMetadata?.createdAt != null
                ? MetadataProvenance.migrated
                : MetadataProvenance.defaulted,
      },
    );
  }

  String? _readPubspecName(YamlMap? yaml) {
    final name = yaml?['name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }
    return null;
  }

  String? _detectStateManagement(YamlMap? yaml) {
    final dependencies = <String>{
      ..._dependencyKeys(yaml?['dependencies']),
      ..._dependencyKeys(yaml?['dev_dependencies']),
    };
    if (dependencies.contains('flutter_riverpod') ||
        dependencies.contains('riverpod_annotation')) {
      return StateConfig.riverpod.name;
    }
    if (dependencies.contains('flutter_mobx') ||
        dependencies.contains('mobx')) {
      return StateConfig.mobx.name;
    }
    if (dependencies.contains('flutter_bloc') ||
        dependencies.contains('bloc')) {
      return StateConfig.cubit.name;
    }
    return null;
  }

  Set<String> _dependencyKeys(dynamic raw) {
    if (raw is! YamlMap) return const <String>{};
    return raw.keys.map((key) => key.toString()).toSet();
  }

  YamlMap? _tryLoadYaml(String pubspecContent) {
    try {
      final parsed = loadYaml(pubspecContent);
      return parsed is YamlMap ? parsed : null;
    } on Exception {
      return null;
    }
  }

  String? _detectOrg(String projectPath) {
    final androidCandidates = [
      p.join(projectPath, 'android', 'app', 'build.gradle.kts'),
      p.join(projectPath, 'android', 'app', 'build.gradle'),
    ];
    for (final candidate in androidCandidates) {
      final file = File(candidate);
      if (!file.existsSync()) continue;
      final match = RegExp(
        r'applicationId\s*[= ]\s*"([a-zA-Z0-9_.]+)"',
      ).firstMatch(file.readAsStringSync());
      if (match != null) {
        return _packageOrg(match.group(1)!);
      }
    }

    final iosProject = File(
      p.join(projectPath, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
    );
    if (iosProject.existsSync()) {
      final match = RegExp(
        'PRODUCT_BUNDLE_IDENTIFIER = ([A-Za-z0-9_.]+);',
      ).firstMatch(iosProject.readAsStringSync());
      if (match != null) {
        return _packageOrg(match.group(1)!);
      }
    }
    return null;
  }

  String? _packageOrg(String bundleId) {
    final segments = bundleId.split('.');
    if (segments.length < 2) return null;
    return segments.take(segments.length - 1).join('.');
  }

  List<String>? _detectPlatforms(String projectPath) {
    final ordered = [
      'android',
      'ios',
      'web',
      'macos',
      'windows',
      'linux',
    ];
    final platforms =
        ordered
            .where(
              (platform) =>
                  Directory(p.join(projectPath, platform)).existsSync(),
            )
            .toList();
    return platforms.isEmpty ? null : platforms;
  }

  List<String>? _detectFlavors(String projectPath) {
    final libDir = Directory(p.join(projectPath, 'lib'));
    if (!libDir.existsSync()) return null;
    final flavors = <String>{};
    for (final entity in libDir.listSync()) {
      if (entity is! File) continue;
      final match = RegExp(r'^main_(\w+)\.dart$').firstMatch(
        p.basename(entity.path),
      );
      if (match != null) {
        flavors.add(match.group(1)!);
      }
    }
    if (flavors.isEmpty) {
      final envDir = Directory(p.join(projectPath, 'env'));
      if (envDir.existsSync()) {
        for (final entity in envDir.listSync()) {
          final match = RegExp(r'^(\w+)\.env').firstMatch(
            p.basename(entity.path),
          );
          if (match != null) {
            flavors.add(match.group(1)!);
          }
        }
      }
    }
    if (flavors.isEmpty) return null;
    final ordered = List<String>.from(flavors)..sort();
    if (ordered.contains('dev') &&
        ordered.contains('staging') &&
        ordered.contains('prod')) {
      return const ['dev', 'staging', 'prod'];
    }
    return ordered;
  }
}

final class MetadataResolution<T> {
  const MetadataResolution(this.value, this.provenance);

  final T value;
  final MetadataProvenance provenance;
}
