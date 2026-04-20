const supportedHarnessAppProfiles = <String>[
  'consumer-app',
  'internal-business-app',
  'subscription-commerce-app',
  'content-community-app',
  'offline-first-field-app',
];

const supportedHarnessSecondaryTraits = <String>[
  'offline-first',
  'real-time',
  'media-heavy',
  'geo-aware',
  'enterprise-auth',
  'multi-brand',
  'multi-locale',
];

const requiredHumanApprovalPauses = <String>[
  'product-decisions',
  'credential-setup',
  'final-store-publish-approval',
];

const defaultHarnessQualityDimensions = <String>[
  'correctness',
  'release_readiness',
  'evidence_quality',
  'ux_confidence',
];

const defaultHarnessEvidenceDir = 'artifacts/evidence';
const defaultHarnessObservabilityMode = 'local-first';
const defaultHarnessRuntimeObservability = <String>[
  'structured_logs',
  'traces',
  'metrics',
];
const defaultHarnessAgentLegibility = <String>['inspect', 'run_ledger'];
const defaultHarnessOperatorReports = <String>['markdown'];

enum SupportTier { tier1, tier2 }

extension SupportTierX on SupportTier {
  String get label => switch (this) {
    SupportTier.tier1 => 'Tier 1',
    SupportTier.tier2 => 'Tier 2',
  };

  String get contractSummary => switch (this) {
    SupportTier.tier1 => 'Core gates plus profile-specific required checks.',
    SupportTier.tier2 => 'Core gates required; profile extras stay advisory.',
  };

  String get requiredGatePack => switch (this) {
    SupportTier.tier1 => 'core + profile pack',
    SupportTier.tier2 => 'core',
  };
}

enum HarnessAppProfile {
  consumerApp,
  internalBusinessApp,
  subscriptionCommerceApp,
  contentCommunityApp,
  offlineFirstFieldApp,
}

extension HarnessAppProfileX on HarnessAppProfile {
  String get wireName => switch (this) {
    HarnessAppProfile.consumerApp => 'consumer-app',
    HarnessAppProfile.internalBusinessApp => 'internal-business-app',
    HarnessAppProfile.subscriptionCommerceApp => 'subscription-commerce-app',
    HarnessAppProfile.contentCommunityApp => 'content-community-app',
    HarnessAppProfile.offlineFirstFieldApp => 'offline-first-field-app',
  };

  String get label => switch (this) {
    HarnessAppProfile.consumerApp => 'Consumer App',
    HarnessAppProfile.internalBusinessApp => 'Internal Business App',
    HarnessAppProfile.subscriptionCommerceApp => 'Subscription Commerce App',
    HarnessAppProfile.contentCommunityApp => 'Content Community App',
    HarnessAppProfile.offlineFirstFieldApp => 'Offline-First Field App',
  };

  SupportTier get supportTier => switch (this) {
    HarnessAppProfile.consumerApp => SupportTier.tier1,
    HarnessAppProfile.internalBusinessApp => SupportTier.tier1,
    HarnessAppProfile.subscriptionCommerceApp => SupportTier.tier1,
    HarnessAppProfile.contentCommunityApp => SupportTier.tier2,
    HarnessAppProfile.offlineFirstFieldApp => SupportTier.tier2,
  };

  String get profileSummary => switch (this) {
    HarnessAppProfile.consumerApp =>
      'Thin-base user-facing app shell with first-class app-shell and navigation confidence.',
    HarnessAppProfile.internalBusinessApp =>
      'Operator workflows with stronger authenticated and configuration expectations.',
    HarnessAppProfile.subscriptionCommerceApp =>
      'Subscription-led app profile for the V1 golden path, with profile-owned commerce and evidence hardening beyond the thin base.',
    HarnessAppProfile.contentCommunityApp =>
      'Feed and engagement surfaces stay supported, but community-specific checks remain advisory.',
    HarnessAppProfile.offlineFirstFieldApp =>
      'Field and degraded-connectivity flows stay supported, but sync-specific checks remain advisory.',
  };

  static HarnessAppProfile fromWireName(String? value) => switch (value) {
    'consumer-app' => HarnessAppProfile.consumerApp,
    'internal-business-app' => HarnessAppProfile.internalBusinessApp,
    'subscription-commerce-app' => HarnessAppProfile.subscriptionCommerceApp,
    'content-community-app' => HarnessAppProfile.contentCommunityApp,
    'offline-first-field-app' => HarnessAppProfile.offlineFirstFieldApp,
    _ => HarnessAppProfile.consumerApp,
  };
}

Map<String, String> buildHarnessProviderMap(Iterable<String> capabilities) {
  const knownProviders = <String, String>{
    'ads': 'google_mobile_ads',
    'analytics': 'firebase_analytics',
    'app_update': 'upgrader',
    'auth': 'firebase_auth',
    'feature_flags': 'starter_in_memory',
    'connectivity': 'connectivity_plus',
    'crashlytics': 'firebase_crashlytics',
    'in_app_review': 'in_app_review',
    'local_storage': 'shared_preferences',
    'permissions': 'permission_handler',
    'payments': 'in_app_purchase',
    'secure_storage': 'flutter_secure_storage',
    'notifications': 'awesome_notifications',
    'deep_link': 'app_links',
    'remote_config': 'firebase_remote_config',
    'camera': 'camerawesome',
    'image_picker': 'image_picker',
    'maps': 'google_maps_flutter',
    'location': 'geolocator',
    'biometric': 'local_auth',
    'social_login': 'google_sign_in',
    'video_player': 'video_player',
    'webview': 'flutter_inappwebview',
    'qr_scanner': 'mobile_scanner',
    'share': 'share_plus',
  };

  final providers = <String, String>{};
  for (final capability in capabilities) {
    final provider = knownProviders[capability];
    if (provider != null) {
      providers[capability] = provider;
    }
  }
  return providers;
}

bool isSupportedHarnessSecondaryTrait(String value) {
  return supportedHarnessSecondaryTraits.contains(value);
}
