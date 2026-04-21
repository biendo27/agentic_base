import 'dart:io';

import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;

void writeFirebaseRuntimeFiles(ModuleInstaller installer, ProjectContext ctx) {
  final usesLegacyRootOptions =
      File(p.join(ctx.projectPath, 'lib/firebase_options.dart')).existsSync();

  for (final flavor in const ['dev', 'staging', 'prod']) {
    installer.writeFileIfAbsent(
      'lib/services/firebase/options/firebase_options_$flavor.dart',
      firebaseOptionsStubFileContent(flavor: flavor),
    );
  }

  installer
    ..writeFile(
      'lib/services/firebase/firebase_options.dart',
      firebaseOptionsSelectorFileContent(
        packageName: ctx.projectName,
        usesLegacyRootOptions: usesLegacyRootOptions,
      ),
    )
    ..writeFile(
      'lib/services/firebase/firebase_runtime.dart',
      firebaseRuntimeFileContent(packageName: ctx.projectName),
    );
}

String firebaseOptionsStubFileContent({required String flavor}) => '''
import 'package:firebase_core/firebase_core.dart';

/// Temporary $flavor stub replaced by `agentic_base firebase setup`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw StateError(
      'Firebase has not been configured for the $flavor flavor. '
      'Run `agentic_base firebase setup` to generate Firebase options.',
    );
  }
}
''';

String firebaseOptionsSelectorFileContent({
  required String packageName,
  required bool usesLegacyRootOptions,
}) {
  if (usesLegacyRootOptions) {
    return '''
import 'package:firebase_core/firebase_core.dart';
import 'package:$packageName/firebase_options.dart' as legacy;

/// Compatibility facade for projects that already had root Firebase options.
class DefaultFirebaseOptionsForFlavor {
  static FirebaseOptions get currentPlatform =>
      legacy.DefaultFirebaseOptions.currentPlatform;
}
''';
  }

  return '''
import 'package:firebase_core/firebase_core.dart';
import 'package:$packageName/app/flavors.dart';
import 'package:$packageName/services/firebase/options/firebase_options_dev.dart'
    as dev;
import 'package:$packageName/services/firebase/options/firebase_options_prod.dart'
    as prod;
import 'package:$packageName/services/firebase/options/firebase_options_staging.dart'
    as staging;

/// Selects Firebase options for the active generated app flavor.
class DefaultFirebaseOptionsForFlavor {
  static FirebaseOptions get currentPlatform {
    return switch (FlavorConfig.instance.flavor) {
      Flavor.dev => dev.DefaultFirebaseOptions.currentPlatform,
      Flavor.staging => staging.DefaultFirebaseOptions.currentPlatform,
      Flavor.prod => prod.DefaultFirebaseOptions.currentPlatform,
    };
  }
}
''';
}

String firebaseRuntimeFileContent({required String packageName}) => '''
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:$packageName/core/observability/observability_service.dart';
import 'package:$packageName/services/firebase/firebase_options.dart';

final class FirebaseRuntimeState {
  const FirebaseRuntimeState({
    required this.ready,
    required this.reason,
    this.errorType,
  });

  final bool ready;
  final String reason;
  final String? errorType;
}

FirebaseRuntimeState? _cachedFirebaseState;
Future<FirebaseRuntimeState>? _pendingFirebaseState;
bool _loggedFirebaseNotConfigured = false;

Future<FirebaseRuntimeState> firebaseRuntimeState() async {
  final cached = _cachedFirebaseState;
  if (cached != null) {
    return cached;
  }

  final pending = _pendingFirebaseState;
  if (pending != null) {
    return pending;
  }

  return _pendingFirebaseState = _resolveFirebaseRuntimeState().whenComplete(
    () => _pendingFirebaseState = null,
  );
}

Future<FirebaseRuntimeState> _resolveFirebaseRuntimeState() async {
  if (Firebase.apps.isNotEmpty) {
    return _cachedFirebaseState = const FirebaseRuntimeState(
      ready: true,
      reason: 'initialized',
    );
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptionsForFlavor.currentPlatform,
    );
    return _cachedFirebaseState = const FirebaseRuntimeState(
      ready: true,
      reason: 'initialized',
    );
  } on Object catch (error) {
    final state = FirebaseRuntimeState(
      ready: false,
      reason: 'not_configured',
      errorType: error.runtimeType.toString(),
    );
    _logFirebaseNotConfigured(error);
    return _cachedFirebaseState = state;
  }
}

Future<bool> ensureFirebaseInitialized() async {
  final state = await firebaseRuntimeState();
  return state.ready;
}

@visibleForTesting
void resetFirebaseRuntimeStateForTest() {
  _cachedFirebaseState = null;
  _pendingFirebaseState = null;
  _loggedFirebaseNotConfigured = false;
}

void _logFirebaseNotConfigured(Object error) {
  if (_loggedFirebaseNotConfigured) {
    return;
  }
  _loggedFirebaseNotConfigured = true;
  ObservabilityService.instance.log(
    'firebase.not_configured',
    level: 'warning',
    fields: <String, Object?>{
      'error_type': error.runtimeType.toString(),
    },
  );
  if (kDebugMode) {
    debugPrint(
      'Firebase is not configured for this flavor. '
      'Run `agentic_base firebase setup` when credentials are available.',
    );
  }
}
''';
