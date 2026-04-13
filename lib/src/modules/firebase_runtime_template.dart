String firebaseRuntimeFileContent() => r'''
import 'package:firebase_core/firebase_core.dart';

Future<void> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    await Firebase.initializeApp();
  } on Exception catch (error) {
    throw StateError(
      'Firebase is not configured for this app. '
      'Add the native config files or generated firebase_options.dart '
      'before using Firebase-backed modules. Original error: $error',
    );
  }
}
''';
