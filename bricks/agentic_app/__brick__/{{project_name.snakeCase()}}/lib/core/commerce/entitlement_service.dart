import 'package:{{project_name.snakeCase()}}/core/starter/starter_runtime_profile.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_entitlement.dart';

abstract class EntitlementService {
  Future<StarterEntitlement> currentEntitlement();
}

class StarterEntitlementService implements EntitlementService {
  const StarterEntitlementService();

  @override
  Future<StarterEntitlement> currentEntitlement() async {
    return StarterEntitlement(
      id: 'starter_preview',
      name: 'Starter Preview',
      description:
          StarterRuntimeProfile.entitlementEnabled
              ? 'Entitlements stay separate from payments so backend policy can evolve safely.'
              : 'Entitlement wiring is still opt in for this profile override.',
      isActive: StarterRuntimeProfile.entitlementEnabled,
    );
  }
}
