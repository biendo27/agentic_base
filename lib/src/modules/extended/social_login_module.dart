import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs google_sign_in + sign_in_with_apple with a SocialLoginService contract.
class SocialLoginModule implements AgenticModule {
  const SocialLoginModule();

  @override
  String get name => 'social_login';

  @override
  String get description =>
      'google_sign_in + sign_in_with_apple — OAuth social login providers.';

  @override
  List<String> get dependencies => ['google_sign_in', 'sign_in_with_apple'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => ['auth'];

  @override
  List<String> get platformSteps => [
    'iOS: add Sign In with Apple capability in Xcode.',
    'iOS: add REVERSED_CLIENT_ID to Info.plist CFBundleURLSchemes for Google.',
    'Android: configure SHA-1 fingerprint in Firebase console for Google Sign-In.',
    'Web: configure OAuth client IDs in Google Cloud Console.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/services/social_login/social_login_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/social_login/social_login_service_impl.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/social_login/social_login_service.dart')
      ..deleteFile('lib/services/social_login/social_login_service_impl.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Credential returned after a successful social sign-in.
class SocialCredential {
  const SocialCredential({
    required this.provider,
    required this.idToken,
    this.accessToken,
  });

  final String provider;
  final String idToken;
  final String? accessToken;
}

/// Social login service contract.
///
/// Returns [SocialCredential] — pass the tokens to [AuthService] to complete
/// Firebase sign-in via signInWithCredential.
abstract class SocialLoginService {
  /// Sign in with Google. Returns null if the user cancels.
  Future<SocialCredential?> signInWithGoogle();

  /// Sign in with Apple. Returns null if the user cancels.
  Future<SocialCredential?> signInWithApple();

  /// Sign out from all social providers.
  Future<void> signOut();
}
''';

  String _implContent(String pkg) => '''
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:$pkg/services/social_login/social_login_service.dart';

/// Implementation of [SocialLoginService] using Google and Apple SDKs.
class SocialLoginServiceImpl implements SocialLoginService {
  SocialLoginServiceImpl() : _googleSignIn = GoogleSignIn();

  final GoogleSignIn _googleSignIn;

  @override
  Future<SocialCredential?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) return null;
    return SocialCredential(
      provider: 'google',
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  @override
  Future<SocialCredential?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final idToken = appleCredential.identityToken;
    if (idToken == null) return null;
    return SocialCredential(
      provider: 'apple',
      idToken: idToken,
      accessToken: appleCredential.authorizationCode,
    );
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();
}
''';
}
