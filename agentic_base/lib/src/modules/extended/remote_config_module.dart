import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs firebase_remote_config with a RemoteConfigService contract.
class RemoteConfigModule implements AgenticModule {
  const RemoteConfigModule();

  @override
  String get name => 'remote_config';

  @override
  String get description =>
      'firebase_remote_config — server-side app configuration without republishing.';

  @override
  List<String> get dependencies => ['firebase_remote_config'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
        'Add GoogleService-Info.plist (iOS) and google-services.json (Android).',
        'Define default parameter values in the Firebase console.',
        'Call RemoteConfigService.fetchAndActivate() on app start.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/remote_config/remote_config_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/remote_config/firebase_remote_config_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/remote_config/remote_config_service.dart')
      ..deleteFile('lib/core/remote_config/firebase_remote_config_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Remote configuration service contract.
abstract class RemoteConfigService {
  /// Fetch latest values from the server and activate them.
  Future<bool> fetchAndActivate();

  /// Returns a string value for [key], falling back to [defaultValue].
  String getString(String key, {String defaultValue = ''});

  /// Returns a boolean value for [key], falling back to [defaultValue].
  bool getBool(String key, {bool defaultValue = false});

  /// Returns an integer value for [key], falling back to [defaultValue].
  int getInt(String key, {int defaultValue = 0});

  /// Returns a double value for [key], falling back to [defaultValue].
  double getDouble(String key, {double defaultValue = 0.0});
}
''';

  String _implContent(String pkg) => '''
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:$pkg/core/remote_config/remote_config_service.dart';

/// Firebase implementation of [RemoteConfigService].
class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService()
      : _config = FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _config;

  @override
  Future<bool> fetchAndActivate() => _config.fetchAndActivate();

  @override
  String getString(String key, {String defaultValue = ''}) {
    final value = _config.getString(key);
    return value.isEmpty ? defaultValue : value;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _config.getBool(key);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _config.getInt(key);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _config.getDouble(key);
    } catch (_) {
      return defaultValue;
    }
  }
}
''';
}
