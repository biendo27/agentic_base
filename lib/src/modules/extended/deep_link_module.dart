import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs app_links + uni_links with a DeepLinkService contract.
class DeepLinkModule implements AgenticModule {
  const DeepLinkModule();

  @override
  String get name => 'deep_link';

  @override
  String get description =>
      'app_links + uni_links — deep link and universal link handling.';

  @override
  List<String> get dependencies => ['app_links', 'uni_links'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'iOS: add Associated Domains entitlement for universal links.',
    'Android: add intent-filter with ACTION_VIEW in AndroidManifest.xml.',
    'Register your scheme / domain in the Firebase console if using Dynamic Links.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/deep_link/deep_link_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/deep_link/app_links_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/deep_link/deep_link_service.dart')
      ..deleteFile('lib/core/deep_link/app_links_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Deep link service contract.
///
/// Handles both cold-start initial links and runtime incoming links.
abstract class DeepLinkService {
  /// Stream of incoming deep link URIs after the app is running.
  Stream<Uri> get linkStream;

  /// Returns the URI that launched the app, or null if none.
  Future<Uri?> getInitialLink();
}
''';

  String _implContent(String pkg) => '''
import 'package:app_links/app_links.dart';
import 'package:$pkg/core/deep_link/deep_link_service.dart';

/// app_links implementation of [DeepLinkService].
class AppLinksService implements DeepLinkService {
  AppLinksService() : _appLinks = AppLinks();

  final AppLinks _appLinks;

  @override
  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  @override
  Future<Uri?> getInitialLink() => _appLinks.getInitialLink();
}
''';
}
