{{^is_riverpod}}
import 'package:injectable/injectable.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_paywall_snapshot.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/repositories/starter_monetization_repository.dart';

{{^is_riverpod}}
@injectable
{{/is_riverpod}}
class GetStarterPaywall {
  const GetStarterPaywall(this._repository);

  final StarterMonetizationRepository _repository;

  Future<StarterPaywallSnapshot> call() => _repository.loadPaywall();
}
