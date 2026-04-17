import 'package:{{project_name.snakeCase()}}/core/starter/starter_runtime_profile.dart';

class StarterConsentStatus {
  const StarterConsentStatus({
    required this.analyticsAllowed,
    required this.adsAllowed,
    required this.summary,
  });

  final bool analyticsAllowed;
  final bool adsAllowed;
  final String summary;
}

abstract class ConsentService {
  Future<StarterConsentStatus> currentStatus();
}

class StarterConsentService implements ConsentService {
  const StarterConsentService();

  @override
  Future<StarterConsentStatus> currentStatus() async {
    return StarterConsentStatus(
      analyticsAllowed: !StarterRuntimeProfile.consentEnabled,
      adsAllowed: false,
      summary:
          StarterRuntimeProfile.consentEnabled
              ? 'Consent stays explicit before richer analytics or any ads activation.'
              : 'Consent-sensitive surfaces stay opt in until product policy needs them.',
    );
  }
}
