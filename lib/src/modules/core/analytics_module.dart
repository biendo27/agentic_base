import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/firebase_runtime_template.dart';
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
  List<String> get dependencies => ['firebase_core', 'firebase_analytics'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Add GoogleService-Info.plist (iOS) and google-services.json (Android).',
    'Run `agentic_base firebase setup` to generate per-flavor Firebase options before using Firebase-backed modules.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    final installer = ModuleInstaller(ctx)..addDependencies(dependencies);
    writeFirebaseRuntimeFiles(installer, ctx);
    installer
      ..writeFile(
        'lib/services/analytics/analytics_service.dart',
        _analyticsServiceContract(ctx.projectName),
      )
      ..writeFile(
        'lib/services/analytics/firebase_analytics_service.dart',
        _firebaseAnalyticsImpl(ctx.projectName),
      )
      ..mutateTextFile('ios/Podfile', _ensureIos15PodfilePlatform)
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/analytics/analytics_service.dart')
      ..deleteFile('lib/services/analytics/firebase_analytics_service.dart')
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
import 'package:$pkg/services/analytics/analytics_service.dart';
import 'package:$pkg/services/firebase/firebase_runtime.dart';

/// Firebase implementation of [AnalyticsService].
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, {Map<String, String>? parameters}) async {
    if (!await _ensureReady()) return;
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!await _ensureReady()) return;
    await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> setUserId(String? id) async {
    if (!await _ensureReady()) return;
    await _analytics.setUserId(id: id);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!await _ensureReady()) return;
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  Future<bool> _ensureReady() => ensureFirebaseInitialized();
}
''';
}

String _ensureIos15PodfilePlatform(String current) {
  var next = current;
  next = next.replaceFirst(
    "# platform :ios, '13.0'",
    "platform :ios, '15.0'",
  );
  next = next.replaceFirst(
    "platform :ios, '13.0'",
    "platform :ios, '15.0'",
  );
  return next;
}
