import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs open_filex + path_provider with a FileManagerService contract.
class FileManagerModule implements AgenticModule {
  const FileManagerModule();

  @override
  String get name => 'file_manager';

  @override
  String get description =>
      'open_filex + path_provider — file saving, reading, and native open.';

  @override
  List<String> get dependencies => ['open_filex', 'path_provider'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => ['permissions'];

  @override
  List<String> get platformSteps => [
    'Android: add READ_EXTERNAL_STORAGE / WRITE_EXTERNAL_STORAGE or MANAGE_EXTERNAL_STORAGE to AndroidManifest.xml.',
    'Android: add FileProvider authority to AndroidManifest.xml for open_filex.',
    'iOS: add UIFileSharingEnabled and LSSupportsOpeningDocumentsInPlace to Info.plist if sharing files.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/file_manager/file_manager_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/file_manager/file_manager_service_impl.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/file_manager/file_manager_service.dart')
      ..deleteFile('lib/core/file_manager/file_manager_service_impl.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Result of an open-file operation.
enum OpenFileResult { done, noAppToOpen, permissionDenied, error }

/// File manager service contract.
abstract class FileManagerService {
  /// Returns the app documents directory path.
  Future<String> getDocumentsPath();

  /// Returns the app temporary cache directory path.
  Future<String> getCachePath();

  /// Write [bytes] to [fileName] in the documents directory.
  /// Returns the absolute file path.
  Future<String> saveBytes(String fileName, List<int> bytes);

  /// Write [text] to [fileName] in the documents directory.
  Future<String> saveText(String fileName, String text);

  /// Read bytes from [filePath].
  Future<List<int>> readBytes(String filePath);

  /// Open [filePath] with the native app associated with its MIME type.
  Future<OpenFileResult> openFile(String filePath);

  /// Delete the file at [filePath]. Returns true if deleted.
  Future<bool> deleteFile(String filePath);
}
''';

  String _implContent(String pkg) => '''
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:$pkg/core/file_manager/file_manager_service.dart';

/// open_filex + path_provider implementation of [FileManagerService].
class FileManagerServiceImpl implements FileManagerService {
  @override
  Future<String> getDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  @override
  Future<String> getCachePath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  @override
  Future<String> saveBytes(String fileName, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Future<String> saveText(String fileName, String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(text);
    return file.path;
  }

  @override
  Future<List<int>> readBytes(String filePath) =>
      File(filePath).readAsBytes();

  @override
  Future<OpenFileResult> openFile(String filePath) async {
    final result = await OpenFilex.open(filePath);
    return switch (result.type) {
      ResultType.done => OpenFileResult.done,
      ResultType.noAppToOpen => OpenFileResult.noAppToOpen,
      ResultType.permissionDenied => OpenFileResult.permissionDenied,
      _ => OpenFileResult.error,
    };
  }

  @override
  Future<bool> deleteFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return false;
    await file.delete();
    return true;
  }
}
''';
}
