import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs talker + talker_dio_logger with a LoggingService contract.
class LoggingModule implements AgenticModule {
  const LoggingModule();

  @override
  String get name => 'logging';

  @override
  String get description =>
      'talker + talker_dio_logger — structured app and network logging.';

  @override
  List<String> get dependencies => ['talker', 'talker_dio_logger'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
        'Add TalkerDioLogger to your Dio instance interceptors in api_client.dart.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/logging/logging_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/logging/talker_logging_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/logging/logging_service.dart')
      ..deleteFile('lib/core/logging/talker_logging_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Structured logging service contract.
abstract class LoggingService {
  /// Log a debug-level message.
  void debug(Object message, [Object? error, StackTrace? stackTrace]);

  /// Log an info-level message.
  void info(Object message, [Object? error, StackTrace? stackTrace]);

  /// Log a warning-level message.
  void warning(Object message, [Object? error, StackTrace? stackTrace]);

  /// Log an error-level message.
  void error(Object message, [Object? error, StackTrace? stackTrace]);

  /// Log a critical/fatal message.
  void critical(Object message, [Object? error, StackTrace? stackTrace]);
}
''';

  String _implContent(String pkg) => '''
import 'package:talker/talker.dart';
import 'package:$pkg/core/logging/logging_service.dart';

/// [Talker] implementation of [LoggingService].
class TalkerLoggingService implements LoggingService {
  TalkerLoggingService({Talker? talker}) : _talker = talker ?? Talker();

  final Talker _talker;

  /// Expose the underlying [Talker] instance (e.g. for TalkerDioLogger).
  Talker get talker => _talker;

  @override
  void debug(Object message, [Object? error, StackTrace? stackTrace]) =>
      _talker.debug(message, error, stackTrace);

  @override
  void info(Object message, [Object? error, StackTrace? stackTrace]) =>
      _talker.info(message, error, stackTrace);

  @override
  void warning(Object message, [Object? error, StackTrace? stackTrace]) =>
      _talker.warning(message, error, stackTrace);

  @override
  void error(Object message, [Object? error, StackTrace? stackTrace]) =>
      _talker.error(message, error, stackTrace);

  @override
  void critical(Object message, [Object? error, StackTrace? stackTrace]) =>
      _talker.critical(message, error, stackTrace);
}
''';
}
