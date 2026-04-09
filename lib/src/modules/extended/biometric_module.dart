import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs local_auth with a BiometricService contract.
class BiometricModule implements AgenticModule {
  const BiometricModule();

  @override
  String get name => 'biometric';

  @override
  String get description =>
      'local_auth — Face ID, Touch ID, and fingerprint authentication.';

  @override
  List<String> get dependencies => ['local_auth'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'iOS: add NSFaceIDUsageDescription to Info.plist.',
    'Android: add USE_BIOMETRIC and USE_FINGERPRINT permissions to AndroidManifest.xml.',
    'Android: ensure FlutterFragmentActivity (not FlutterActivity) in MainActivity.kt.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/biometric/biometric_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/biometric/local_auth_biometric_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/biometric/biometric_service.dart')
      ..deleteFile('lib/core/biometric/local_auth_biometric_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Available biometric types.
enum BiometricType { fingerprint, face, iris, unknown }

/// Biometric authentication service contract.
abstract class BiometricService {
  /// Returns true if the device supports biometric authentication.
  Future<bool> isAvailable();

  /// Returns the list of enrolled biometric types.
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Prompt the user to authenticate.
  ///
  /// [reason] is shown in the system authentication dialog.
  /// Returns true if authentication succeeded.
  Future<bool> authenticate({required String reason});
}
''';

  String _implContent(String pkg) => '''
import 'package:local_auth/local_auth.dart';
import 'package:$pkg/core/biometric/biometric_service.dart';

/// local_auth implementation of [BiometricService].
class LocalAuthBiometricService implements BiometricService {
  LocalAuthBiometricService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() => _auth.canCheckBiometrics;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    final types = await _auth.getAvailableBiometrics();
    return types.map(_mapType).toList();
  }

  @override
  Future<bool> authenticate({required String reason}) =>
      _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true),
      );

  BiometricType _mapType(BiometricType t) => switch (t) {
        BiometricType.fingerprint => BiometricType.fingerprint,
        BiometricType.face => BiometricType.face,
        BiometricType.iris => BiometricType.iris,
        _ => BiometricType.unknown,
      };
}
''';
}
