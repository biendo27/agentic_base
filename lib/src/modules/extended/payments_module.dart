import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs in_app_purchase with a store-native PaymentsService contract.
class PaymentsModule implements AgenticModule {
  const PaymentsModule();

  @override
  String get name => 'payments';

  @override
  String get description =>
      'in_app_purchase — store-native digital subscriptions and purchases.';

  @override
  List<String> get dependencies => ['in_app_purchase'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Create matching App Store Connect and Google Play products.',
    'Use platform sandbox accounts before wiring real catalog ids.',
    'Layer entitlement resolution on top of purchases instead of mixing it into PaymentsService.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/payments/payments_service.dart',
        _contractContent(),
      )
      ..writeFile(
        'lib/core/payments/in_app_purchase_payments_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/payments/payments_service.dart')
      ..deleteFile('lib/core/payments/in_app_purchase_payments_service.dart')
      ..markUninstalled(name);
  }

  String _contractContent() => '''
/// Represents one purchasable store product exposed to the app shell.
class AppOffering {
  const AppOffering({
    required this.identifier,
    required this.title,
    required this.priceLabel,
    required this.billingLabel,
  });

  final String identifier;
  final String title;
  final String priceLabel;
  final String billingLabel;
}

/// Payments service contract.
///
/// This seam owns store-native product discovery and purchase triggers only.
/// Keep entitlement resolution in a separate service so billing providers and
/// backend policy can evolve independently.
abstract class PaymentsService {
  /// Prepare the store purchase stream for the current app session.
  Future<void> initialize({String? applicationUserName});

  /// Returns true when the app has observed an owned purchase for [productId].
  Future<bool> hasActiveEntitlement(String productId);

  /// Fetch available offerings for the supplied [productIds].
  Future<List<AppOffering>> getOfferings(Set<String> productIds);

  /// Trigger a non-consumable or subscription purchase for [productId].
  Future<bool> purchase(String productId);

  /// Ask the store to restore previously completed purchases.
  Future<bool> restorePurchases();
}
''';

  String _implContent(String packageName) => '''
import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:$packageName/core/payments/payments_service.dart';

/// Store-native implementation of [PaymentsService] using in_app_purchase.
class InAppPurchasePaymentsService implements PaymentsService {
  InAppPurchasePaymentsService({
    InAppPurchase? inAppPurchase,
  }) : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;
  final Set<String> _ownedProductIds = <String>{};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  Future<void> initialize({String? applicationUserName}) async {
    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      _recordPurchases,
    );
  }

  @override
  Future<bool> hasActiveEntitlement(String productId) async {
    return _ownedProductIds.contains(productId);
  }

  @override
  Future<List<AppOffering>> getOfferings(Set<String> productIds) async {
    if (productIds.isEmpty) {
      return const <AppOffering>[];
    }

    final response = await _inAppPurchase.queryProductDetails(productIds);
    return response.productDetails
        .map(
          (product) => AppOffering(
            identifier: product.id,
            title: product.title,
            priceLabel: product.price,
            billingLabel: 'Store-managed purchase',
          ),
        )
        .toList();
  }

  @override
  Future<bool> purchase(String productId) async {
    final response = await _inAppPurchase.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      return false;
    }

    final product = response.productDetails.first;
    return _inAppPurchase.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<bool> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
    return true;
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }

  void _recordPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _ownedProductIds.add(purchase.productID);
        case PurchaseStatus.pending:
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        unawaited(_inAppPurchase.completePurchase(purchase));
      }
    }
  }
}
''';
}
