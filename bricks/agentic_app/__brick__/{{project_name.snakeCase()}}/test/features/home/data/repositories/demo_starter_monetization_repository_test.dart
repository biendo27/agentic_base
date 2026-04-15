import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/features/home/data/repositories/demo_starter_monetization_repository.dart';

void main() {
  test('returns the demo starter paywall snapshot', () async {
    final snapshot = await DemoStarterMonetizationRepository().loadPaywall();

    expect(snapshot.currentEntitlement.name, equals('Starter Preview'));
    expect(snapshot.currentEntitlement.isActive, isTrue);
    expect(snapshot.offers, hasLength(2));
    expect(snapshot.offers.first.priceLabel, equals(r'$9 / month'));
    expect(snapshot.supportNote, contains('RevenueCat'));
  });
}
