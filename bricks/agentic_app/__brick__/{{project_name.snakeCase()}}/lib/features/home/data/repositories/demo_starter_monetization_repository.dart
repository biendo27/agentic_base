{{^is_riverpod}}
import 'package:injectable/injectable.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_entitlement.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_offer.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_paywall_snapshot.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/repositories/starter_monetization_repository.dart';

{{^is_riverpod}}
@LazySingleton(as: StarterMonetizationRepository)
{{/is_riverpod}}
class DemoStarterMonetizationRepository
    implements StarterMonetizationRepository {
  @override
  Future<StarterPaywallSnapshot> loadPaywall() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const StarterPaywallSnapshot(
      currentEntitlement: StarterEntitlement(
        id: 'starter_preview',
        name: 'Starter Preview',
        description: 'Provider-neutral demo entitlement for day-0 flows.',
        isActive: true,
      ),
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
          highlight: 'Use this lane when you wire a real billing provider later.',
        ),
      ],
      supportNote:
          'Swap this demo adapter for RevenueCat, Stripe, Paddle, or another billing backend when product requirements are real.',
    );
  }
}
