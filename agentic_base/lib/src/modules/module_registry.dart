import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/core/analytics_module.dart';
import 'package:agentic_base/src/modules/core/auth_module.dart';
import 'package:agentic_base/src/modules/core/connectivity_module.dart';
import 'package:agentic_base/src/modules/core/crashlytics_module.dart';
import 'package:agentic_base/src/modules/core/local_storage_module.dart';
import 'package:agentic_base/src/modules/core/logging_module.dart';
import 'package:agentic_base/src/modules/core/permissions_module.dart';
import 'package:agentic_base/src/modules/core/secure_storage_module.dart';

/// Central registry mapping module names to their implementations.
///
/// Usage:
/// ```dart
/// final module = ModuleRegistry.find('analytics');
/// ModuleRegistry.checkConflicts('analytics', installed: ['crashlytics']);
/// ```
class ModuleRegistry {
  ModuleRegistry._();

  static final Map<String, AgenticModule> _modules = {
    for (final m in _allModules) m.name: m,
  };

  static const List<AgenticModule> _allModules = [
    AnalyticsModule(),
    CrashlyticsModule(),
    AuthModule(),
    LocalStorageModule(),
    ConnectivityModule(),
    PermissionsModule(),
    SecureStorageModule(),
    LoggingModule(),
  ];

  /// All registered module names.
  static List<String> get allNames => _modules.keys.toList()..sort();

  /// All registered modules.
  static List<AgenticModule> get all => List.unmodifiable(_allModules);

  /// Returns the module for [name], or null if not found.
  static AgenticModule? find(String name) => _modules[name];

  /// Throws [ArgumentError] if [name] is not registered.
  static AgenticModule findOrThrow(String name) {
    final module = _modules[name];
    if (module == null) {
      throw ArgumentError(
        'Unknown module "$name". '
        'Available: ${allNames.join(', ')}',
      );
    }
    return module;
  }

  /// Returns conflicting module names from [installed] for a given [moduleName].
  static List<String> findConflicts(
    String moduleName, {
    required List<String> installed,
  }) {
    final module = find(moduleName);
    if (module == null) return [];
    return module.conflictsWith
        .where((c) => installed.contains(c))
        .toList();
  }

  /// Returns prerequisite modules not yet in [installed].
  static List<String> missingPrerequisites(
    String moduleName, {
    required List<String> installed,
  }) {
    final module = find(moduleName);
    if (module == null) return [];
    return module.requiresModules
        .where((r) => !installed.contains(r))
        .toList();
  }

  /// Returns installed modules that declare a dependency on [moduleName].
  ///
  /// Used by the remove command to prevent breaking dependents.
  static List<String> dependentsOf(
    String moduleName, {
    required List<String> installed,
  }) {
    return installed.where((installedName) {
      final m = find(installedName);
      return m != null && m.requiresModules.contains(moduleName);
    }).toList();
  }
}
