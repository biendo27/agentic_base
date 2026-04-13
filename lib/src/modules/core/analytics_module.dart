import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs Firebase Analytics with an AnalyticsService contract.
class AnalyticsModule implements AgenticModule {
  const AnalyticsModule();

  @override
  String get name => 'analytics';

  @override
  String get description => 'Firebase Analytics — event tracking service.';

  @override
  List<String> get dependencies => ['firebase_analytics'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Add GoogleService-Info.plist (iOS) and google-services.json (Android).',
    'Ensure Firebase is initialised in bootstrap.dart before runApp().',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/analytics/analytics_service.dart',
        _analyticsServiceContract(ctx.projectName),
      )
      ..writeFile(
        'lib/core/analytics/firebase_analytics_service.dart',
        _firebaseAnalyticsImpl(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/analytics/analytics_service.dart')
      ..deleteFile('lib/core/analytics/firebase_analytics_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _analyticsServiceContract(String pkg) => '''
/// Analytics service contract.
///
/// Swap the implementation in the DI module to use any analytics provider.
abstract class AnalyticsService {
  /// Log a named event with optional string parameters.
  Future<void> logEvent(String name, {Map<String, String>? parameters});

  /// Set a user property (e.g. subscription tier).
  Future<void> setUserProperty({required String name, required String value});

  /// Set the analytics user identifier.
  Future<void> setUserId(String? id);

  /// Log a screen view.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });
}
''';

  String _firebaseAnalyticsImpl(String pkg) => '''
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:$pkg/core/analytics/analytics_service.dart';

/// Firebase implementation of [AnalyticsService].
@LazySingleton(as: AnalyticsService)
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, String>? parameters,
  }) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) =>
      _analytics.setUserProperty(name: name, value: value);

  @override
  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) =>
      _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
}
''';
}
