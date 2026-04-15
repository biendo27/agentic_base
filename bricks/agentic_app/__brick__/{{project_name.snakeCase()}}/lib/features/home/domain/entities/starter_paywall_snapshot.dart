import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_entitlement.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_offer.dart';

class StarterPaywallSnapshot {
  const StarterPaywallSnapshot({
    required this.currentEntitlement,
    required this.offers,
    required this.supportNote,
  });

  final StarterEntitlement currentEntitlement;
  final List<StarterOffer> offers;
  final String supportNote;
}
