import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_paywall_snapshot.dart';

// ignore: one_member_abstracts -- Clean Architecture contract pattern
abstract class StarterMonetizationRepository {
  Future<StarterPaywallSnapshot> loadPaywall();
}
