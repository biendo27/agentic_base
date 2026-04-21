import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/firebase_runtime_template.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs Firebase Auth with an AuthService contract.
class AuthModule implements AgenticModule {
  const AuthModule();

  @override
  String get name => 'auth';

  @override
  String get description => 'Firebase Auth — authentication service.';

  @override
  List<String> get dependencies => ['firebase_core', 'firebase_auth'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Add GoogleService-Info.plist (iOS) and google-services.json (Android).',
    'Enable desired sign-in providers in the Firebase console.',
    'Run `agentic_base firebase setup` to generate per-flavor Firebase options before using Firebase-backed modules.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    final installer = ModuleInstaller(ctx)..addDependencies(dependencies);
    writeFirebaseRuntimeFiles(installer, ctx);
    installer
      ..writeFile(
        'lib/services/auth/auth_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/auth/firebase_auth_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/auth/auth_service.dart')
      ..deleteFile('lib/services/auth/firebase_auth_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Authentication service contract.
///
/// Implementations can use Firebase, Supabase, or a custom backend.
abstract class AuthService {
  /// Ensure the Firebase runtime is ready before the first call.
  Future<void> init();

  /// Stream of authenticated user IDs; emits null when signed out.
  Stream<String?> get authStateChanges;

  /// Currently signed-in user ID, or null.
  String? get currentUserId;

  /// Sign in with email and password.
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create a new account with email and password.
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email);
}
''';

  String _implContent(String pkg) => '''
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:$pkg/services/auth/auth_service.dart';
import 'package:$pkg/services/firebase/firebase_runtime.dart';

/// Firebase implementation of [AuthService].
class FirebaseAuthService implements AuthService {
  @override
  Future<void> init() async {
    await ensureFirebaseInitialized();
  }

  @override
  Stream<String?> get authStateChanges async* {
    final auth = await _optionalAuth();
    if (auth == null) {
      yield null;
      return;
    }
    yield* auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  String? get currentUserId {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = await _requireAuth();
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = await _requireAuth();
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  @override
  Future<void> signOut() async {
    final auth = await _optionalAuth();
    await auth?.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = await _requireAuth();
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<FirebaseAuth?> _optionalAuth() async {
    if (!await ensureFirebaseInitialized()) return null;
    return FirebaseAuth.instance;
  }

  Future<FirebaseAuth> _requireAuth() async {
    final auth = await _optionalAuth();
    if (auth == null) {
      throw StateError(
        'Firebase Auth is not configured for this flavor. '
        'Run `agentic_base firebase setup` before using auth operations.',
      );
    }
    return auth;
  }
}
''';
}
