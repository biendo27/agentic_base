import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectMetadata', () {
    test('parses harness metadata from config maps', () {
      final metadata = ProjectMetadata.fromConfigMap(
        <String, dynamic>{
          'schema_version': 3,
          'tool_version': '0.1.0',
          'project_name': 'demo_app',
          'org': 'com.example',
          'ci_provider': 'github',
          'state_management': 'cubit',
          'platforms': ['android', 'ios'],
          'flavors': ['dev', 'staging', 'prod'],
          'modules': ['analytics', 'auth'],
          'harness': <String, dynamic>{
            'contract_version': 1,
            'app_profile': <String, dynamic>{
              'primary_profile': 'subscription-commerce-app',
              'secondary_traits': ['multi-locale'],
            },
            'capabilities': <String, dynamic>{
              'enabled': ['analytics', 'auth'],
            },
            'providers': <String, dynamic>{
              'analytics': 'firebase_analytics',
              'auth': 'firebase_auth',
            },
            'eval': <String, dynamic>{
              'evidence_dir': 'artifacts/evidence',
              'quality_dimensions': [
                'correctness',
                'release_readiness',
                'observability',
                'ux_confidence',
              ],
            },
            'approvals': <String, dynamic>{
              'pause_on': [
                'product-decisions',
                'credential-setup',
                'final-store-publish-approval',
              ],
            },
            'sdk': <String, dynamic>{
              'manager': 'fvm',
              'preferred_manager': 'puro',
              'channel': 'stable',
              'version': '3.29.0',
              'preferred_version': '3.28.0',
              'policy': 'newest_tested',
            },
          },
        },
      );

      expect(
        metadata.harness.appProfile,
        equals(HarnessAppProfile.subscriptionCommerceApp),
      );
      expect(metadata.harness.secondaryTraits, equals(['multi-locale']));
      expect(metadata.harness.capabilities, equals(['analytics', 'auth']));
      expect(
        metadata.harness.sdk.manager,
        equals(FlutterSdkManager.fvm),
      );
      expect(
        metadata.harness.sdk.preferredManager,
        equals(FlutterSdkManager.puro),
      );
      expect(metadata.harness.sdk.version, equals('3.29.0'));
      expect(metadata.harness.sdk.preferredVersion, equals('3.28.0'));
    });

    test('defaults harness metadata for legacy configs', () {
      final metadata = ProjectMetadata.fromConfigMap(
        <String, dynamic>{
          'tool_version': '0.1.0',
          'project_name': 'legacy_app',
          'org': 'com.example',
          'ci_provider': 'github',
          'state_management': 'cubit',
          'platforms': ['android'],
          'flavors': ['dev', 'staging', 'prod'],
          'modules': ['analytics'],
        },
      );

      expect(metadata.schemaVersion, equals(3));
      expect(
        metadata.harness.appProfile,
        equals(HarnessAppProfile.consumerApp),
      );
      expect(metadata.harness.capabilities, equals(['analytics']));
      expect(
        metadata.harness.providers['analytics'],
        equals('firebase_analytics'),
      );
    });

    test(
      'legacy sdk contracts keep resolved manager as the preferred fallback',
      () {
        final metadata = ProjectMetadata.fromConfigMap(
          <String, dynamic>{
            'tool_version': '0.1.0',
            'project_name': 'legacy_app',
            'org': 'com.example',
            'ci_provider': 'github',
            'state_management': 'cubit',
            'platforms': ['android'],
            'flavors': ['dev', 'staging', 'prod'],
            'modules': <String>[],
            'harness': <String, dynamic>{
              'sdk': <String, dynamic>{
                'manager': 'fvm',
                'channel': 'stable',
                'version': '3.29.0',
                'policy': 'newest_tested',
              },
            },
          },
        );

        expect(metadata.harness.sdk.manager, FlutterSdkManager.fvm);
        expect(
          metadata.harness.sdk.preferredManager,
          FlutterSdkManager.fvm,
        );
        expect(metadata.harness.sdk.preferredVersion, '3.29.0');
      },
    );
  });
}
