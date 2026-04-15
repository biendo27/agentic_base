import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_metadata.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void _createConfigFile(Directory tempDir, String content) {
  Directory(p.join(tempDir.path, '.info'))
    ..createSync(recursive: true)
    ..uri; // force eval
  File(
    p.join(tempDir.path, '.info', 'agentic.yaml'),
  ).writeAsStringSync(content);
}

void main() {
  group('AgenticConfig', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('agentic_config_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('exists returns false for non-existent file', () {
      final config = AgenticConfig(projectPath: tempDir.path);
      expect(config.exists, false);
    });

    test('read returns empty map for non-existent file', () {
      final config = AgenticConfig(projectPath: tempDir.path);
      expect(config.read(), isEmpty);
    });

    test('exists returns true when file exists', () {
      _createConfigFile(tempDir, 'test: data\n');
      expect(AgenticConfig(projectPath: tempDir.path).exists, true);
    });

    test('write can add fields to config', () {
      _createConfigFile(tempDir, 'project_name: my_app\n');
      final config = AgenticConfig(projectPath: tempDir.path)
        ..write({'new_field': 'new_value'});
      expect(config.read()['new_field'], equals('new_value'));
    });

    test('write creates .info directory if it does not exist', () {
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      expect(infoDir.existsSync(), false);

      AgenticConfig(projectPath: tempDir.path).write({'key': 'value'});
      expect(infoDir.existsSync(), true);
    });

    test('read parses modules list correctly', () {
      _createConfigFile(
        tempDir,
        'modules:\n  - analytics\n  - auth\n  - payments\n',
      );
      final data = AgenticConfig(projectPath: tempDir.path).read();
      expect(data['modules'], isA<List<dynamic>>());
      expect(data['modules'], contains('analytics'));
    });

    test('read returns empty map for empty YAML file', () {
      _createConfigFile(tempDir, '');
      expect(AgenticConfig(projectPath: tempDir.path).read(), isEmpty);
    });

    test('config path is correctly computed', () {
      final expectedPath = p.join(tempDir.path, '.info', 'agentic.yaml');
      _createConfigFile(tempDir, 'test: data\n');
      expect(File(expectedPath).existsSync(), true);
    });

    test('handles platforms list with multiple items', () {
      _createConfigFile(
        tempDir,
        'platforms:\n  - ios\n  - android\n  - web\n  - macos\n',
      );
      final data = AgenticConfig(projectPath: tempDir.path).read();
      expect(data['platforms'], isA<List<dynamic>>());
      expect((data['platforms'] as List<dynamic>).length, equals(4));
    });

    test('createInitial persists ci_provider from enum serialization', () {
      AgenticConfig.createInitial(
        projectPath: tempDir.path,
        projectName: 'demo_app',
        org: 'com.example',
        stateManagement: 'cubit',
        platforms: const ['android', 'ios'],
        flavors: const ['dev', 'staging', 'prod'],
        toolVersion: '0.1.0',
        ciProvider: CiProvider.gitlab,
      );

      final data = AgenticConfig(projectPath: tempDir.path).read();
      expect(data['ci_provider'], equals('gitlab'));
      expect(data['schema_version'], equals(3));
      expect(data['project_kind'], equals('agent_ready_flutter_repo'));
      expect(data['context'], isA<Map<String, dynamic>>());
      expect(data['execution'], isA<Map<String, dynamic>>());
      expect(data['checkpoints'], isA<Map<String, dynamic>>());
      expect(data['harness'], isA<Map<String, dynamic>>());
      expect(
        (data['execution'] as Map<String, dynamic>)['verify'],
        equals('./tools/verify.sh'),
      );
    });

    test('writeMetadata round-trips typed metadata and provenance', () {
      final metadata = ProjectMetadata(
        toolVersion: '0.1.0',
        projectName: 'demo_app',
        org: 'com.example',
        ciProvider: CiProvider.github,
        stateManagement: 'riverpod',
        platforms: const ['android', 'web'],
        flavors: const ['dev', 'prod'],
        modules: const ['analytics'],
        harness: HarnessMetadata.defaultFor(
          appProfile: HarnessAppProfile.internalBusinessApp,
          secondaryTraits: const ['enterprise-auth'],
          capabilities: const ['analytics'],
          sdk: const FlutterSdkContract(
            manager: FlutterSdkManager.system,
            channel: 'stable',
            version: '3.29.0',
            policy: FlutterVersionPolicy.newestTested,
            preferredManager: FlutterSdkManager.fvm,
            preferredVersion: '3.28.0',
          ),
        ),
        provenance: const {
          'schema_version': MetadataProvenance.defaulted,
          'project_kind': MetadataProvenance.defaulted,
          'tool_version': MetadataProvenance.explicit,
          'project_name': MetadataProvenance.explicit,
          'org': MetadataProvenance.inferred,
          'ci_provider': MetadataProvenance.explicit,
          'state_management': MetadataProvenance.inferred,
          'platforms': MetadataProvenance.inferred,
          'flavors': MetadataProvenance.inferred,
          'modules': MetadataProvenance.explicit,
          'created_at': MetadataProvenance.defaulted,
        },
        createdAt: '2026-04-13T00:00:00.000Z',
      );

      final config = AgenticConfig(projectPath: tempDir.path)
        ..writeMetadata(metadata);
      final restored = config.readMetadata(
        fallbackProjectName: 'fallback_app',
        fallbackToolVersion: 'fallback',
      );

      expect(restored.projectName, equals('demo_app'));
      expect(restored.stateManagement, equals('riverpod'));
      expect(restored.modules, equals(['analytics']));
      expect(
        restored.harness.appProfile,
        equals(HarnessAppProfile.internalBusinessApp),
      );
      expect(restored.harness.secondaryTraits, equals(['enterprise-auth']));
      expect(
        restored.provenance['state_management'],
        equals(MetadataProvenance.inferred),
      );
      expect(
        restored.provenance['modules'],
        equals(MetadataProvenance.explicit),
      );
      final raw = config.read();
      expect((raw['context'] as Map<String, dynamic>)['ci_provider'], 'github');
      expect(
        (raw['checkpoints'] as Map<String, dynamic>)['requires_human'],
        contains('final-store-publish-approval'),
      );
      expect(
        ((raw['harness'] as Map<String, dynamic>)['sdk']
            as Map<String, dynamic>)['version'],
        equals('3.29.0'),
      );
      expect(
        ((raw['harness'] as Map<String, dynamic>)['sdk']
            as Map<String, dynamic>)['preferred_manager'],
        equals('fvm'),
      );
    });

    test('readMetadata marks legacy stored fields as migrated provenance', () {
      _createConfigFile(
        tempDir,
        'project_name: legacy_app\nstate_management: mobx\norg: com.legacy\n',
      );

      final metadata = AgenticConfig(projectPath: tempDir.path).readMetadata(
        fallbackProjectName: 'fallback_app',
        fallbackToolVersion: '0.2.0',
      );

      expect(metadata.projectName, equals('legacy_app'));
      expect(metadata.stateManagement, equals('mobx'));
      expect(metadata.org, equals('com.legacy'));
      expect(
        metadata.provenance['project_name'],
        equals(MetadataProvenance.migrated),
      );
      expect(
        metadata.provenance['state_management'],
        equals(MetadataProvenance.migrated),
      );
      expect(
        metadata.provenance['platforms'],
        equals(MetadataProvenance.defaulted),
      );
      expect(metadata.harness.contractVersion, equals(1));
    });

    test(
      'resolveCiProviderFromConfig falls back to inferred provider files',
      () {
        Directory(p.join(tempDir.path, '.gitlab', 'ci')).createSync(
          recursive: true,
        );
        File(
          p.join(tempDir.path, '.gitlab-ci.yml'),
        ).writeAsStringSync('include: []');

        final resolved = resolveCiProviderFromConfig(
          config: const <String, dynamic>{},
          projectPath: tempDir.path,
        );

        expect(resolved, equals(CiProvider.gitlab));
      },
    );
  });
}
