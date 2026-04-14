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
    'Run `flutterfire configure` to generate lib/firebase_options.dart before using Firebase-backed modules.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFileIfAbsent(
        'lib/firebase_options.dart',
        firebaseOptionsStubFileContent(),
      )
      ..writeFile(
        'lib/core/firebase/firebase_runtime.dart',
        firebaseRuntimeFileContent(packageName: ctx.projectName),
      )
      ..writeFile(
        'lib/core/crash_reporting/crash_reporting_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/crash_reporting/firebase_crash_reporting_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/crash_reporting/crash_reporting_service.dart')
      ..deleteFile(
        'lib/core/crash_reporting/firebase_crash_reporting_service.dart',
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
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:$pkg/core/crash_reporting/crash_reporting_service.dart';
import 'package:$pkg/core/firebase/firebase_runtime.dart';

/// Firebase implementation of [CrashReportingService].
class FirebaseCrashReportingService implements CrashReportingService {
  FirebaseCrashReportingService({FirebaseCrashlytics? crashlytics})
      : _overrideCrashlytics = crashlytics;

  final FirebaseCrashlytics? _overrideCrashlytics;

  FirebaseCrashlytics get _crashlytics =>
      _overrideCrashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> init() async {
    await ensureFirebaseInitialized();
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _crashlytics.recordError(error, stackTrace, fatal: true);
      return true;
    };
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) =>
      _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);

  @override
  Future<void> setUserId(String identifier) =>
      _crashlytics.setUserIdentifier(identifier);
}
''';
}
