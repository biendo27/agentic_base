{{^is_riverpod}}
import 'package:injectable/injectable.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/core/commerce/entitlement_service.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';
import 'package:{{project_name.snakeCase()}}/core/privacy/consent_service.dart';
import 'package:{{project_name.snakeCase()}}/core/starter/starter_runtime_profile.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_entitlement.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_offer.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_paywall_snapshot.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/repositories/starter_monetization_repository.dart';

{{^is_riverpod}}
@LazySingleton(as: StarterMonetizationRepository)
{{/is_riverpod}}
class DemoStarterMonetizationRepository
    implements StarterMonetizationRepository {
  static const _entitlementService = StarterEntitlementService();
  static const _consentService = StarterConsentService();

  @override
  Future<StarterPaywallSnapshot> loadPaywall() async {
    final trace = ObservabilityService.instance.startSpan(
      'starter.paywall.load',
    );
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final entitlement = await _entitlementService.currentEntitlement();
    final consent = await _consentService.currentStatus();
    final snapshot = StarterPaywallSnapshot(
      currentEntitlement: entitlement,
      offers: <StarterOffer>[
        StarterOffer(
          id: 'starter_monthly',
          title: 'Starter Monthly',
          priceLabel: r'$9 / month',
          billingLabel: 'Cancel anytime',
          highlight: 'Fastest path to testing entitlement-aware UI.',
        ),
        StarterOffer(
          id: 'starter_annual',
          title: 'Starter Annual',
          priceLabel: r'$79 / year',
          billingLabel: 'Best value',
          highlight:
              'Use this lane when you wire a real entitlement backend later.',
        ),
      ],
      supportNote:
          '${StarterRuntimeProfile.paymentProviderLabel}. ${consent.summary} External checkout remains opt in only.',
    );
    ObservabilityService.instance.finishSpan(
      trace,
      fields: <String, Object?>{
        'offer_count': snapshot.offers.length,
        'entitlement_active': snapshot.currentEntitlement.isActive,
      },
    );
    return snapshot;
  }
}
