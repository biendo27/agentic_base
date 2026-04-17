import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_entitlement.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_offer.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_paywall_snapshot.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_monetization_overview_card.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the store-native commerce seam summary', (
    tester,
  ) async {
    await tester.pumpApp(
      const StarterMonetizationOverviewCard(
        subtitle: 'Demonstrates a provider-safe commerce seam.',
        snapshot: StarterPaywallSnapshot(
          currentEntitlement: StarterEntitlement(
            id: 'starter_preview',
            name: 'Starter Preview',
            description: 'Entitlements stay separate from payments.',
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
          ],
          supportNote: 'Store-native via in_app_purchase.',
        ),
      ),
    );

    expect(find.text('Starter commerce seams'), findsOneWidget);
    expect(find.textContaining('Store-native via in_app_purchase'), findsAtLeastNWidgets(1));
    expect(find.text('Ads status'), findsOneWidget);
  });
}
