import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs connectivity_plus with a ConnectivityService contract.
class ConnectivityModule implements AgenticModule {
  const ConnectivityModule();

  @override
  String get name => 'connectivity';

  @override
  String get description =>
      'connectivity_plus — network connectivity monitoring.';

  @override
  List<String> get dependencies => ['connectivity_plus'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
        'iOS: add NSLocalNetworkUsageDescription to Info.plist if needed.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/connectivity/connectivity_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/connectivity/connectivity_plus_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/connectivity/connectivity_service.dart')
      ..deleteFile('lib/core/connectivity/connectivity_plus_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Network connectivity service contract.
abstract class ConnectivityService {
  /// Stream of connectivity status changes.
  Stream<bool> get onConnectivityChanged;

  /// True if the device currently has a network connection.
  Future<bool> get isConnected;
}
''';

  String _implContent(String pkg) => '''
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:$pkg/core/connectivity/connectivity_service.dart';

/// [Connectivity] implementation of [ConnectivityService].
class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
''';
}
