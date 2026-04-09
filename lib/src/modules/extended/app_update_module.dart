import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs upgrader with an AppUpdateService contract.
class AppUpdateModule implements AgenticModule {
  const AppUpdateModule();

  @override
  String get name => 'app_update';

  @override
  String get description =>
      'upgrader — prompt users to update when a newer app version is available.';

  @override
  List<String> get dependencies => ['upgrader'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
        'Wrap your MaterialApp with UpgradeAlert or UpgradeCupertino widget.',
        'Ensure app is published on App Store / Play Store for version checks to work.',
        'Test with debugDisplayAlways: true during development.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/app_update/app_update_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/app_update/upgrader_app_update_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/app_update/app_update_service.dart')
      ..deleteFile('lib/core/app_update/upgrader_app_update_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Update availability status.
enum UpdateStatus { upToDate, updateAvailable, unknown }

/// App update service contract.
abstract class AppUpdateService {
  /// Check whether an update is available on the store.
  Future<UpdateStatus> checkForUpdate();

  /// Open the store listing so the user can update manually.
  Future<void> openStoreListing();
}
''';

  String _implContent(String pkg) => '''
import 'package:upgrader/upgrader.dart';
import 'package:$pkg/core/app_update/app_update_service.dart';

/// upgrader implementation of [AppUpdateService].
///
/// For automatic in-app prompts, wrap MaterialApp with [UpgradeAlert]:
///
/// ```dart
/// UpgradeAlert(child: MaterialApp(...))
/// ```
class UpgraderAppUpdateService implements AppUpdateService {
  UpgraderAppUpdateService() : _upgrader = Upgrader();

  final Upgrader _upgrader;

  @override
  Future<UpdateStatus> checkForUpdate() async {
    await _upgrader.initialize();
    if (_upgrader.isUpdateAvailable()) return UpdateStatus.updateAvailable;
    return UpdateStatus.upToDate;
  }

  @override
  Future<void> openStoreListing() => _upgrader.sendUserToAppStore();
}
''';
}
