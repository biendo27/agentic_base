import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/project_metadata.dart';
import 'package:agentic_base/src/modules/module_registry.dart';

final class ProfileVerifyGate {
  const ProfileVerifyGate({
    required this.id,
    required this.label,
    required this.testPath,
    this.dimension = 'ux_confidence',
  });

  final String id;
  final String label;
  final String testPath;
  final String dimension;
}

final class ProfilePreset {
  const ProfilePreset({
    required this.appProfile,
    required this.defaultModules,
    required this.requiredGatePack,
    this.requiredVerifyGate,
    this.advisoryGateLabel,
  });

  final HarnessAppProfile appProfile;
  final List<String> defaultModules;
  final String requiredGatePack;
  final ProfileVerifyGate? requiredVerifyGate;
  final String? advisoryGateLabel;
}

final class ResolvedProfileRuntime {
  const ResolvedProfileRuntime({
    required this.appProfile,
    required this.effectiveModules,
    required this.providers,
    required this.requiredGatePack,
    required this.requiredVerifyGate,
    required this.advisoryGateLabel,
    required this.modulesProvenance,
    required this.providersProvenance,
  });

  final HarnessAppProfile appProfile;
  final List<String> effectiveModules;
  final Map<String, String> providers;
  final String requiredGatePack;
  final ProfileVerifyGate? requiredVerifyGate;
  final String? advisoryGateLabel;
  final MetadataProvenance modulesProvenance;
  final MetadataProvenance providersProvenance;

  bool get analyticsEnabled => effectiveModules.contains('analytics');
  bool get crashlyticsEnabled => effectiveModules.contains('crashlytics');
  bool get remoteConfigEnabled => effectiveModules.contains('remote_config');
  bool get featureFlagsEnabled => effectiveModules.contains('feature_flags');
  bool get paymentsEnabled => effectiveModules.contains('payments');
  bool get adsEnabled => effectiveModules.contains('ads');
  bool get notificationsEnabled => effectiveModules.contains('notifications');
  bool get deepLinksEnabled => effectiveModules.contains('deep_link');
  bool get inAppReviewEnabled => effectiveModules.contains('in_app_review');
  bool get appUpdateEnabled => effectiveModules.contains('app_update');

  bool get consentSeamEnabled => analyticsEnabled || adsEnabled;
  bool get entitlementSeamEnabled => paymentsEnabled;
  bool get commerceStarterEnabled =>
      paymentsEnabled ||
      entitlementSeamEnabled ||
      consentSeamEnabled ||
      adsEnabled;
  bool get configStarterEnabled => remoteConfigEnabled || featureFlagsEnabled;
  bool get lifecycleStarterEnabled =>
      notificationsEnabled ||
      deepLinksEnabled ||
      inAppReviewEnabled ||
      appUpdateEnabled;
}

ResolvedProfileRuntime resolveProfilePreset({
  required HarnessAppProfile appProfile,
  List<String>? explicitModules,
}) {
  final preset = _presetFor(appProfile);
  final moduleSource = explicitModules ?? preset.defaultModules;
  final effectiveModules = _expandModuleInstallOrder(moduleSource);
  final providers = buildHarnessProviderMap(effectiveModules);
  final runtime = resolveProfileRuntime(
    appProfile: appProfile,
    capabilities: effectiveModules,
  );

  return ResolvedProfileRuntime(
    appProfile: appProfile,
    effectiveModules: effectiveModules,
    providers: providers,
    requiredGatePack: runtime.requiredGatePack,
    requiredVerifyGate: runtime.requiredVerifyGate,
    advisoryGateLabel: runtime.advisoryGateLabel,
    modulesProvenance:
        explicitModules == null
            ? MetadataProvenance.defaulted
            : MetadataProvenance.explicit,
    providersProvenance:
        explicitModules == null
            ? MetadataProvenance.defaulted
            : MetadataProvenance.explicit,
  );
}

ResolvedProfileRuntime resolveProfileRuntime({
  required HarnessAppProfile appProfile,
  required Iterable<String> capabilities,
}) {
  final effectiveModules = _expandModuleInstallOrder(capabilities);
  final providers = buildHarnessProviderMap(effectiveModules);
  final preset = _presetFor(appProfile);
  final supportsCommercePack =
      appProfile == HarnessAppProfile.subscriptionCommerceApp &&
      effectiveModules.any(
        (module) => const {
          'payments',
          'remote_config',
          'feature_flags',
          'ads',
        }.contains(module),
      );
  final hasRequiredProfileGate =
      appProfile == HarnessAppProfile.consumerApp ||
      appProfile == HarnessAppProfile.internalBusinessApp ||
      supportsCommercePack;

  return ResolvedProfileRuntime(
    appProfile: appProfile,
    effectiveModules: effectiveModules,
    providers: providers,
    requiredGatePack: hasRequiredProfileGate ? preset.requiredGatePack : 'core',
    requiredVerifyGate:
        hasRequiredProfileGate ? preset.requiredVerifyGate : null,
    advisoryGateLabel:
        appProfile.supportTier == SupportTier.tier2
            ? preset.advisoryGateLabel
            : null,
    modulesProvenance: MetadataProvenance.migrated,
    providersProvenance: MetadataProvenance.defaulted,
  );
}

ProfilePreset _presetFor(HarnessAppProfile appProfile) {
  return switch (appProfile) {
    HarnessAppProfile.consumerApp => const ProfilePreset(
      appProfile: HarnessAppProfile.consumerApp,
      defaultModules: <String>[],
      requiredGatePack: 'core + consumer journey pack',
      requiredVerifyGate: ProfileVerifyGate(
        id: 'starter-journey',
        label: 'starter journey regression',
        testPath:
            'test/features/home/presentation/widgets/starter_journey_signal_card_test.dart',
      ),
    ),
    HarnessAppProfile.internalBusinessApp => const ProfilePreset(
      appProfile: HarnessAppProfile.internalBusinessApp,
      defaultModules: <String>[],
      requiredGatePack: 'core + internal workflow pack',
      requiredVerifyGate: ProfileVerifyGate(
        id: 'starter-settings',
        label: 'starter settings regression',
        testPath:
            'test/features/home/presentation/widgets/starter_settings_preview_card_test.dart',
      ),
    ),
    HarnessAppProfile.subscriptionCommerceApp => const ProfilePreset(
      appProfile: HarnessAppProfile.subscriptionCommerceApp,
      defaultModules: <String>[
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
      ],
      requiredGatePack: 'core + subscription commerce pack',
      requiredVerifyGate: ProfileVerifyGate(
        id: 'starter-commerce',
        label: 'starter commerce regression',
        testPath:
            'test/features/home/presentation/widgets/starter_monetization_overview_card_test.dart',
      ),
    ),
    HarnessAppProfile.contentCommunityApp => const ProfilePreset(
      appProfile: HarnessAppProfile.contentCommunityApp,
      defaultModules: <String>[],
      requiredGatePack: 'core',
      advisoryGateLabel:
          'community-specific starter checks stay advisory until deterministic.',
    ),
    HarnessAppProfile.offlineFirstFieldApp => const ProfilePreset(
      appProfile: HarnessAppProfile.offlineFirstFieldApp,
      defaultModules: <String>[],
      requiredGatePack: 'core',
      advisoryGateLabel:
          'offline-first starter checks stay advisory until sync surfaces are deterministic.',
    ),
  };
}

List<String> _expandModuleInstallOrder(Iterable<String> modules) {
  final requestedModules = <String>[];
  for (final name in modules) {
    ModuleRegistry.findOrThrow(name);
    final missing = ModuleRegistry.missingPrerequisites(
      name,
      installed: requestedModules,
    );
    for (final prerequisite in missing) {
      if (!requestedModules.contains(prerequisite)) {
        requestedModules.add(prerequisite);
      }
    }
    if (!requestedModules.contains(name)) {
      requestedModules.add(name);
    }
  }
  return requestedModules;
}
