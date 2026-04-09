import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs in_app_review with an InAppReviewService contract.
class InAppReviewModule implements AgenticModule {
  const InAppReviewModule();

  @override
  String get name => 'in_app_review';

  @override
  String get description =>
      'in_app_review — native App Store / Play Store review prompts.';

  @override
  List<String> get dependencies => ['in_app_review'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
        'iOS: review prompts are throttled by Apple — test on a real device.',
        'Android: app must be published on Play Store for the dialog to appear.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/in_app_review/in_app_review_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/in_app_review/native_in_app_review_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/in_app_review/in_app_review_service.dart')
      ..deleteFile('lib/core/in_app_review/native_in_app_review_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// In-app review service contract.
abstract class InAppReviewService {
  /// Returns true if the in-app review flow is available on this device.
  Future<bool> isAvailable();

  /// Trigger the native review dialog (platform may ignore repeated calls).
  Future<void> requestReview();

  /// Open the store listing as a fallback when [requestReview] is unavailable.
  Future<void> openStoreListing({String? appStoreId});
}
''';

  String _implContent(String pkg) => '''
import 'package:in_app_review/in_app_review.dart';
import 'package:$pkg/core/in_app_review/in_app_review_service.dart';

/// Native implementation of [InAppReviewService] using in_app_review package.
class NativeInAppReviewService implements InAppReviewService {
  NativeInAppReviewService() : _review = InAppReview.instance;

  final InAppReview _review;

  @override
  Future<bool> isAvailable() => _review.isAvailable();

  @override
  Future<void> requestReview() => _review.requestReview();

  @override
  Future<void> openStoreListing({String? appStoreId}) =>
      _review.openStoreListing(appStoreId: appStoreId);
}
''';
}
