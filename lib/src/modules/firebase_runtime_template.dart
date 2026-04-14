String firebaseOptionsStubFileContent() => '''
import 'package:firebase_core/firebase_core.dart';

/// Temporary stub replaced by `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw StateError(
      'Firebase has not been configured yet. '
      'Run `flutterfire configure` to generate lib/firebase_options.dart.',
    );
  }
}
''';

String firebaseRuntimeFileContent({required String packageName}) => '''
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:$packageName/firebase_options.dart';

Future<void> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    await _initializeFirebaseApp();
  } catch (error) {
    throw StateError(
      'Firebase is not configured for this app. '
      'Add the native config files and run `flutterfire configure` '
      'before using Firebase-backed modules. Original error: \$error',
    );
  }
}

Future<void> _initializeFirebaseApp() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return;
  }

  await Firebase.initializeApp();
}
''';
