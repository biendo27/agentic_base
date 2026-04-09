import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs purchases_flutter (RevenueCat) with a PaymentsService contract.
class PaymentsModule implements AgenticModule {
  const PaymentsModule();

  @override
  String get name => 'payments';

  @override
  String get description =>
      'purchases_flutter — RevenueCat in-app purchases and subscriptions.';

  @override
  List<String> get dependencies => ['purchases_flutter'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
        'Create a RevenueCat project and obtain API keys for iOS and Android.',
        'Configure products / entitlements in the RevenueCat dashboard.',
        'Set up App Store Connect / Google Play products matching RevenueCat identifiers.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/payments/payments_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/payments/revenuecat_payments_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/payments/payments_service.dart')
      ..deleteFile('lib/core/payments/revenuecat_payments_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Represents a single purchasable offering.
class AppOffering {
  const AppOffering({
    required this.identifier,
    required this.monthlyPrice,
    required this.annualPrice,
  });

  final String identifier;
  final double monthlyPrice;
  final double annualPrice;
}

/// Payments service contract.
abstract class PaymentsService {
  /// Initialise the purchases SDK with platform [apiKey].
  Future<void> initialize(String apiKey, {String? userId});

  /// Returns true if the user has an active entitlement for [entitlementId].
  Future<bool> hasActiveEntitlement(String entitlementId);

  /// Fetch available offerings.
  Future<List<AppOffering>> getOfferings();

  /// Purchase a package by [packageIdentifier].
  Future<bool> purchase(String packageIdentifier);

  /// Restore previous purchases.
  Future<bool> restorePurchases();
}
''';

  String _implContent(String pkg) => '''
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:$pkg/core/payments/payments_service.dart';

/// RevenueCat implementation of [PaymentsService].
class RevenuecatPaymentsService implements PaymentsService {
  @override
  Future<void> initialize(String apiKey, {String? userId}) async {
    await Purchases.setLogLevel(LogLevel.debug);
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    if (userId != null) await Purchases.logIn(userId);
  }

  @override
  Future<bool> hasActiveEntitlement(String entitlementId) async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(entitlementId);
  }

  @override
  Future<List<AppOffering>> getOfferings() async {
    final offerings = await Purchases.getOfferings();
    return offerings.all.values.map((o) {
      final monthly = o.monthly?.storeProduct.price ?? 0;
      final annual = o.annual?.storeProduct.price ?? 0;
      return AppOffering(
        identifier: o.identifier,
        monthlyPrice: monthly,
        annualPrice: annual,
      );
    }).toList();
  }

  @override
  Future<bool> purchase(String packageIdentifier) async {
    final offerings = await Purchases.getOfferings();
    for (final offering in offerings.all.values) {
      for (final package in offering.availablePackages) {
        if (package.identifier == packageIdentifier) {
          final info = await Purchases.purchasePackage(package);
          return info.entitlements.active.isNotEmpty;
        }
      }
    }
    return false;
  }

  @override
  Future<bool> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.isNotEmpty;
  }
}
''';
}
