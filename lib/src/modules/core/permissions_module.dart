import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs permission_handler with a PermissionsService contract.
class PermissionsModule implements AgenticModule {
  const PermissionsModule();

  @override
  String get name => 'permissions';

  @override
  String get description =>
      'permission_handler — runtime permission management.';

  @override
  List<String> get dependencies => ['permission_handler'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
        'iOS: add required NSUsage* keys to Info.plist for each permission.',
        'Android: add uses-permission entries to AndroidManifest.xml.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/permissions/permissions_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/permissions/permission_handler_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/permissions/permissions_service.dart')
      ..deleteFile('lib/core/permissions/permission_handler_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Enum representing common runtime permissions.
enum AppPermission {
  camera,
  microphone,
  location,
  locationAlways,
  photos,
  notification,
  contacts,
  storage,
}

/// Permission status returned by the service.
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

/// Runtime permissions service contract.
abstract class PermissionsService {
  /// Check the current status of [permission].
  Future<AppPermissionStatus> check(AppPermission permission);

  /// Request [permission] from the user.
  Future<AppPermissionStatus> request(AppPermission permission);

  /// Open the device app-settings screen.
  Future<bool> openSettings();
}
''';

  String _implContent(String pkg) => '''
import 'package:permission_handler/permission_handler.dart';
import 'package:$pkg/core/permissions/permissions_service.dart';

/// [Permission] implementation of [PermissionsService].
class PermissionHandlerService implements PermissionsService {
  @override
  Future<AppPermissionStatus> check(AppPermission permission) async {
    final status = await _toHandler(permission).status;
    return _fromHandler(status);
  }

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async {
    final status = await _toHandler(permission).request();
    return _fromHandler(status);
  }

  @override
  Future<bool> openSettings() => openAppSettings();

  Permission _toHandler(AppPermission p) => switch (p) {
        AppPermission.camera => Permission.camera,
        AppPermission.microphone => Permission.microphone,
        AppPermission.location => Permission.location,
        AppPermission.locationAlways => Permission.locationAlways,
        AppPermission.photos => Permission.photos,
        AppPermission.notification => Permission.notification,
        AppPermission.contacts => Permission.contacts,
        AppPermission.storage => Permission.storage,
      };

  AppPermissionStatus _fromHandler(PermissionStatus s) => switch (s) {
        PermissionStatus.granted => AppPermissionStatus.granted,
        PermissionStatus.denied => AppPermissionStatus.denied,
        PermissionStatus.permanentlyDenied =>
          AppPermissionStatus.permanentlyDenied,
        PermissionStatus.restricted => AppPermissionStatus.restricted,
        PermissionStatus.limited => AppPermissionStatus.limited,
        _ => AppPermissionStatus.denied,
      };
}
''';
}
