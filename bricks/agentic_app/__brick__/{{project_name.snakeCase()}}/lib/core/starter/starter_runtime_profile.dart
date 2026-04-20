abstract final class StarterRuntimeProfile {
  static const primaryProfile = '{{app_profile}}';
  static const primaryProfileLabel = '{{app_profile_label}}';
  static const supportTierLabel = '{{support_tier_label}}';
  static const requiredGatePack = '{{required_gate_pack}}';

  static const analyticsEnabled = {{starter_analytics_enabled}};
  static const crashlyticsEnabled = {{starter_crashlytics_enabled}};
  static const remoteConfigEnabled = {{starter_remote_config_enabled}};
  static const featureFlagsEnabled = {{starter_feature_flags_enabled}};
  static const paymentsEnabled = {{starter_payments_enabled}};
  static const entitlementEnabled = {{starter_entitlement_enabled}};
  static const consentEnabled = {{starter_consent_enabled}};
  static const adsEnabled = {{starter_ads_enabled}};
  static const notificationsEnabled = {{starter_notifications_enabled}};
  static const deepLinksEnabled = {{starter_deep_links_enabled}};
  static const inAppReviewEnabled = {{starter_in_app_review_enabled}};
  static const appUpdateEnabled = {{starter_app_update_enabled}};
  static const commerceEnabled = {{starter_commerce_enabled}};
  static const configEnabled = {{starter_config_enabled}};
  static const lifecycleEnabled = {{starter_lifecycle_enabled}};

  static const bool externalCheckoutOptInOnly = true;
  static const bool adsInactiveByDefault = true;

  static String get paymentProviderLabel =>
      paymentsEnabled ? 'Store-native via in_app_purchase' : 'Opt in later';

  static String get entitlementProviderLabel =>
      entitlementEnabled ? 'Starter entitlement seam' : 'Opt in later';

  static String get consentLabel =>
      consentEnabled
          ? 'Explicit before richer analytics or ads'
          : 'Profile keeps consent-sensitive lanes opt in';

  static String get adsLabel =>
      adsEnabled ? 'Generated but inactive by default' : 'Not generated';

  static String get configLabel =>
      configEnabled
          ? 'Generated starter seam for rollout control'
          : 'Add remote config or flags when product policy needs them';
}
