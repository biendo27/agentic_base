import 'package:agentic_base/src/modules/base_module.dart';
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
  List<String> get dependencies => ['firebase_auth'];

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
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/auth/auth_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/auth/firebase_auth_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/auth/auth_service.dart')
      ..deleteFile('lib/core/auth/firebase_auth_service.dart')
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:$pkg/core/auth/auth_service.dart';

/// Firebase implementation of [AuthService].
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
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
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
''';
}
