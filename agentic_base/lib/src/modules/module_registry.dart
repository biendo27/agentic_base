import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/core/analytics_module.dart';
import 'package:agentic_base/src/modules/core/auth_module.dart';
import 'package:agentic_base/src/modules/core/connectivity_module.dart';
import 'package:agentic_base/src/modules/core/crashlytics_module.dart';
import 'package:agentic_base/src/modules/core/local_storage_module.dart';
import 'package:agentic_base/src/modules/core/logging_module.dart';
import 'package:agentic_base/src/modules/core/permissions_module.dart';
import 'package:agentic_base/src/modules/core/secure_storage_module.dart';
import 'package:agentic_base/src/modules/extended/ads_module.dart';
import 'package:agentic_base/src/modules/extended/app_update_module.dart';
import 'package:agentic_base/src/modules/extended/biometric_module.dart';
import 'package:agentic_base/src/modules/extended/camera_module.dart';
import 'package:agentic_base/src/modules/extended/deep_link_module.dart';
import 'package:agentic_base/src/modules/extended/feature_flags_module.dart';
import 'package:agentic_base/src/modules/extended/file_manager_module.dart';
import 'package:agentic_base/src/modules/extended/image_picker_module.dart';
import 'package:agentic_base/src/modules/extended/in_app_review_module.dart';
import 'package:agentic_base/src/modules/extended/location_module.dart';
import 'package:agentic_base/src/modules/extended/maps_module.dart';
import 'package:agentic_base/src/modules/extended/notifications_module.dart';
import 'package:agentic_base/src/modules/extended/payments_module.dart';
import 'package:agentic_base/src/modules/extended/qr_scanner_module.dart';
import 'package:agentic_base/src/modules/extended/remote_config_module.dart';
import 'package:agentic_base/src/modules/extended/share_module.dart';
import 'package:agentic_base/src/modules/extended/social_login_module.dart';
import 'package:agentic_base/src/modules/extended/video_player_module.dart';
import 'package:agentic_base/src/modules/extended/webview_module.dart';

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
    // Core (8)
    AnalyticsModule(),
    CrashlyticsModule(),
    AuthModule(),
    LocalStorageModule(),
    ConnectivityModule(),
    PermissionsModule(),
    SecureStorageModule(),
    LoggingModule(),
    // Communication & Engagement (5)
    NotificationsModule(),
    DeepLinkModule(),
    InAppReviewModule(),
    ShareModule(),
    SocialLoginModule(),
    // Monetization (4)
    AdsModule(),
    PaymentsModule(),
    RemoteConfigModule(),
    FeatureFlagsModule(),
    // Media (4)
    ImagePickerModule(),
    CameraModule(),
    VideoPlayerModule(),
    QrScannerModule(),
    // Location & Maps (2)
    LocationModule(),
    MapsModule(),
    // Device & System (4)
    BiometricModule(),
    FileManagerModule(),
    AppUpdateModule(),
    WebViewModule(),
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
  ///
  /// Resolves transitively — if `maps` requires `location` which requires
  /// `permissions`, all missing prerequisites are returned in dependency order.
  static List<String> missingPrerequisites(
    String moduleName, {
    required List<String> installed,
  }) {
    final result = <String>[];
    final visited = <String>{};
    _collectMissing(moduleName, installed, result, visited);
    return result;
  }

  static void _collectMissing(
    String moduleName,
    List<String> installed,
    List<String> result,
    Set<String> visited,
  ) {
    if (visited.contains(moduleName)) return;
    visited.add(moduleName);
    final module = find(moduleName);
    if (module == null) return;
    for (final req in module.requiresModules) {
      if (!installed.contains(req)) {
        // Recurse to collect transitive deps first (depth-first pre-order).
        _collectMissing(req, installed, result, visited);
        if (!result.contains(req)) result.add(req);
      } else {
        // Still recurse in case transitive deps of an installed module are missing.
        _collectMissing(req, installed, result, visited);
      }
    }
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
