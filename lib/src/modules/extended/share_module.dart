import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs share_plus with a ShareService contract.
class ShareModule implements AgenticModule {
  const ShareModule();

  @override
  String get name => 'share';

  @override
  String get description =>
      'share_plus — native share sheet for text and files.';

  @override
  List<String> get dependencies => ['share_plus'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'No platform setup required — share_plus works out of the box.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/share/share_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/share/share_plus_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/share/share_service.dart')
      ..deleteFile('lib/core/share/share_plus_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Share service contract.
abstract class ShareService {
  /// Share plain [text] via the native share sheet.
  ///
  /// [subject] is used as the email subject when sharing to mail clients.
  Future<void> shareText(String text, {String? subject});

  /// Share one or more file [paths] via the native share sheet.
  Future<void> shareFiles(List<String> paths, {String? text, String? subject});
}
''';

  String _implContent(String pkg) => '''
import 'package:share_plus/share_plus.dart';
import 'package:$pkg/core/share/share_service.dart';

/// share_plus implementation of [ShareService].
class SharePlusService implements ShareService {
  @override
  Future<void> shareText(String text, {String? subject}) =>
      Share.share(text, subject: subject);

  @override
  Future<void> shareFiles(
    List<String> paths, {
    String? text,
    String? subject,
  }) =>
      Share.shareXFiles(
        paths.map(XFile.new).toList(),
        text: text,
        subject: subject,
      );
}
''';
}
