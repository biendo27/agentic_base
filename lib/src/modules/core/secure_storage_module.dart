import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs flutter_secure_storage with a SecureStorageService contract.
class SecureStorageModule implements AgenticModule {
  const SecureStorageModule();

  @override
  String get name => 'secure_storage';

  @override
  String get description =>
      'flutter_secure_storage — encrypted key-value storage.';

  @override
  List<String> get dependencies => ['flutter_secure_storage'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Android: set minSdkVersion to 18 in android/app/build.gradle.',
    'Web: add meta[name=flutter_secure_storage_web] to index.html if targeting web.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/services/secure_storage/secure_storage_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/secure_storage/flutter_secure_storage_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/secure_storage/secure_storage_service.dart')
      ..deleteFile(
        'lib/services/secure_storage/flutter_secure_storage_service.dart',
      )
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Encrypted key-value storage service contract.
///
/// Use for tokens, credentials, or other secrets.
abstract class SecureStorageService {
  /// Read an encrypted value by [key], or null if absent.
  Future<String?> read(String key);

  /// Write an encrypted [value] for [key].
  Future<void> write(String key, String value);

  /// Delete the value for [key].
  Future<void> delete(String key);

  /// Delete all stored values.
  Future<void> deleteAll();

  /// Returns true if [key] exists in the store.
  Future<bool> containsKey(String key);
}
''';

  String _implContent(String pkg) => '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:$pkg/services/secure_storage/secure_storage_service.dart';

/// [FlutterSecureStorage] implementation of [SecureStorageService].
class FlutterSecureStorageService implements SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<bool> containsKey(String key) => _storage.containsKey(key: key);
}
''';
}
