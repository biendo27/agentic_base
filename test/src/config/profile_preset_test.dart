import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/profile_preset.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('resolveProfilePreset', () {
    test(
      'subscription-commerce-app resolves the golden-path default modules',
      () {
        final preset = resolveProfilePreset(
          appProfile: HarnessAppProfile.subscriptionCommerceApp,
        );

        expect(
          preset.effectiveModules,
          containsAll(const [
            'analytics',
            'crashlytics',
            'remote_config',
            'feature_flags',
            'payments',
            'ads',
            'notifications',
            'deep_link',
            'in_app_review',
            'app_update',
          ]),
        );
        expect(
          preset.providers['payments'],
          equals('in_app_purchase'),
        );
        expect(
          preset.modulesProvenance,
          MetadataProvenance.defaulted,
        );
      },
    );

    test('explicit module overrides stay authoritative', () {
      final preset = resolveProfilePreset(
        appProfile: HarnessAppProfile.subscriptionCommerceApp,
        explicitModules: const ['analytics'],
      );

      expect(preset.effectiveModules, equals(const ['analytics']));
      expect(
        preset.modulesProvenance,
        MetadataProvenance.explicit,
      );
      expect(preset.requiredGatePack, equals('core'));
      expect(preset.requiredVerifyGate, isNull);
    });
  });

  group('resolveProfileRuntime', () {
    test('tier1 consumer apps keep a required starter gate', () {
      final runtime = resolveProfileRuntime(
        appProfile: HarnessAppProfile.consumerApp,
        capabilities: const <String>[],
      );

      expect(runtime.requiredVerifyGate?.id, equals('starter-journey'));
      expect(runtime.requiredGatePack, equals('core + consumer journey pack'));
    });

    test('tier2 profiles keep advisory gates only', () {
      final runtime = resolveProfileRuntime(
        appProfile: HarnessAppProfile.contentCommunityApp,
        capabilities: const <String>[],
      );

      expect(runtime.requiredVerifyGate, isNull);
      expect(runtime.advisoryGateLabel, isNotNull);
      expect(runtime.requiredGatePack, equals('core'));
    });
  });
}
