import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs shared_preferences with a LocalStorageService contract.
class LocalStorageModule implements AgenticModule {
  const LocalStorageModule();

  @override
  String get name => 'local_storage';

  @override
  String get description =>
      'shared_preferences — simple key-value local storage.';

  @override
  List<String> get dependencies => ['shared_preferences'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/storage/local_storage_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/storage/shared_preferences_storage_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/storage/local_storage_service.dart')
      ..deleteFile('lib/core/storage/shared_preferences_storage_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Local key-value storage service contract.
abstract class LocalStorageService {
  /// Initialise the storage (call during app bootstrap).
  Future<void> init();

  /// Read a string value, or null if absent.
  Future<String?> getString(String key);

  /// Write a string value.
  Future<void> setString(String key, String value);

  /// Read a boolean value, or null if absent.
  Future<bool?> getBool(String key);

  /// Write a boolean value.
  Future<void> setBool(String key, {required bool value});

  /// Read an integer value, or null if absent.
  Future<int?> getInt(String key);

  /// Write an integer value.
  Future<void> setInt(String key, int value);

  /// Remove a value by key.
  Future<void> remove(String key);

  /// Clear all stored values.
  Future<void> clear();
}
''';

  String _implContent(String pkg) => '''
import 'package:shared_preferences/shared_preferences.dart';
import 'package:$pkg/core/storage/local_storage_service.dart';

/// [SharedPreferences] implementation of [LocalStorageService].
class SharedPreferencesStorageService implements LocalStorageService {
  SharedPreferences? _prefs;

  SharedPreferences get _instance {
    assert(_prefs != null, 'LocalStorageService.init() not called');
    return _prefs!;
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getString(String key) async => _instance.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _instance.setString(key, value);

  @override
  Future<bool?> getBool(String key) async => _instance.getBool(key);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _instance.setBool(key, value);

  @override
  Future<int?> getInt(String key) async => _instance.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _instance.setInt(key, value);

  @override
  Future<void> remove(String key) => _instance.remove(key);

  @override
  Future<void> clear() => _instance.clear();
}
''';
}
