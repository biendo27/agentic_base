import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/firebase_runtime_template.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs Firebase Crashlytics with a CrashReportingService contract.
class CrashlyticsModule implements AgenticModule {
  const CrashlyticsModule();

  @override
  String get name => 'crashlytics';

  @override
  String get description => 'Firebase Crashlytics — crash and error reporting.';

  @override
  List<String> get dependencies => ['firebase_core', 'firebase_crashlytics'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Add GoogleService-Info.plist (iOS) and google-services.json (Android).',
    'Enable Crashlytics in the Firebase console.',
    'Run `agentic_base firebase setup` to generate per-flavor Firebase options before using Firebase-backed modules.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    final installer = ModuleInstaller(ctx)..addDependencies(dependencies);
    writeFirebaseRuntimeFiles(installer, ctx);
    installer
      ..writeFile(
        'lib/services/crash_reporting/crash_reporting_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/crash_reporting/firebase_crash_reporting_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/crash_reporting/crash_reporting_service.dart')
      ..deleteFile(
        'lib/services/crash_reporting/firebase_crash_reporting_service.dart',
      )
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Crash reporting service contract.
abstract class CrashReportingService {
  /// Initialise the crash reporter (call in bootstrap).
  Future<void> init();

  /// Record a non-fatal [error] with optional [stackTrace] and [reason].
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  /// Attach a key-value pair to all future crash reports.
  Future<void> setCustomKey(String key, Object value);

  /// Associate a user identifier with crash reports.
  Future<void> setUserId(String identifier);
}
''';

  String _implContent(String pkg) => '''
import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:$pkg/services/crash_reporting/crash_reporting_service.dart';
import 'package:$pkg/services/firebase/firebase_runtime.dart';
import 'package:$pkg/core/observability/observability_service.dart';

/// Firebase implementation of [CrashReportingService].
class FirebaseCrashReportingService implements CrashReportingService {
  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  @override
  Future<void> init() async {
    if (!await ensureFirebaseInitialized()) return;
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    ObservabilityService.instance.log('crash_reporting.initialized');
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      ObservabilityService.instance.log(
        'crash_reporting.platform_error',
        level: 'error',
        fields: {'error_type': error.runtimeType.toString()},
      );
      unawaited(_recordFatalPlatformError(error, stackTrace));
      return true;
    };
  }

  Future<void> _recordFatalPlatformError(
    Object error,
    StackTrace stackTrace,
  ) async {
    try {
      await _crashlytics.recordError(error, stackTrace, fatal: true);
    } catch (reportingError) {
      ObservabilityService.instance.log(
        'crash_reporting.platform_error_report_failed',
        level: 'error',
        fields: {
          'error_type': error.runtimeType.toString(),
          'reporting_error_type': reportingError.runtimeType.toString(),
        },
      );
    }
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    ObservabilityService.instance.log(
      'crash_reporting.record_error',
      level: fatal ? 'critical' : 'error',
      fields: {
        'error_type': error.runtimeType.toString(),
        'reason_present': reason != null,
        'fatal': fatal,
      },
    );
    if (!await ensureFirebaseInitialized()) return;
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    if (!await ensureFirebaseInitialized()) return;
    await _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> setUserId(String identifier) async {
    if (!await ensureFirebaseInitialized()) return;
    await _crashlytics.setUserIdentifier(identifier);
  }
}
''';
}
