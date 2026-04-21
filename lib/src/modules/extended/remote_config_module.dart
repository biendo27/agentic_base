import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/firebase_runtime_template.dart';
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
  List<String> get dependencies => ['firebase_core', 'firebase_remote_config'];

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
    'Run `agentic_base firebase setup` to generate per-flavor Firebase options before using Firebase-backed modules.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    final installer = ModuleInstaller(ctx)..addDependencies(dependencies);
    writeFirebaseRuntimeFiles(installer, ctx);
    installer
      ..writeFile(
        'lib/services/remote_config/remote_config_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/remote_config/firebase_remote_config_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/remote_config/remote_config_service.dart')
      ..deleteFile(
        'lib/services/remote_config/firebase_remote_config_service.dart',
      )
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Remote configuration service contract.
abstract class RemoteConfigService {
  /// Ensure the Firebase runtime is ready before the first fetch.
  Future<void> init();

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
import 'package:$pkg/services/remote_config/remote_config_service.dart';
import 'package:$pkg/services/firebase/firebase_runtime.dart';

/// Firebase implementation of [RemoteConfigService].
class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfig? _config;

  FirebaseRemoteConfig get _readyConfig =>
      _config ??= FirebaseRemoteConfig.instance;

  @override
  Future<void> init() async {
    if (!await ensureFirebaseInitialized()) return;
    await _readyConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
  }

  @override
  Future<bool> fetchAndActivate() async {
    await init();
    final config = _config;
    if (config == null) return false;
    return config.fetchAndActivate();
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final config = _config;
    if (config == null) return defaultValue;
    final value = config.getString(key);
    return value.isEmpty ? defaultValue : value;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _config?.getBool(key) ?? defaultValue;
    } on Exception catch (_) {
      return defaultValue;
    }
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _config?.getInt(key) ?? defaultValue;
    } on Exception catch (_) {
      return defaultValue;
    }
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _config?.getDouble(key) ?? defaultValue;
    } on Exception catch (_) {
      return defaultValue;
    }
  }
}
''';
}
