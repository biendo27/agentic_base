import 'package:agentic_base/src/modules/project_context.dart';

/// Contract every agentic module must fulfill.
///
/// Modules are state-management-agnostic — they read
/// [ProjectContext.stateManagement] and adapt their generated files
/// accordingly. Each module is independently installable and removable.
abstract class AgenticModule {
  /// Unique lowercase identifier (e.g. 'analytics', 'auth').
  String get name;

  /// Human-readable description shown in `agentic_base add --list`.
  String get description;

  /// Pub packages added to `dependencies` in pubspec.yaml.
  List<String> get dependencies;

  /// Pub packages added to `dev_dependencies` in pubspec.yaml.
  List<String> get devDependencies;

  /// Module names this module cannot coexist with.
  List<String> get conflictsWith;

  /// Module names that must be installed before this one.
  List<String> get requiresModules;

  /// Manual platform-level steps printed after install (e.g. GoogleService-Info.plist).
  List<String> get platformSteps;

  /// Install this module into the project described by [ctx].
  ///
  /// Responsibilities:
  /// - Add [dependencies]/[devDependencies] to pubspec.yaml via yaml_edit
  /// - Write service contract + implementation files
  /// - Register DI bindings
  /// - Update `.info/agentic.yaml` modules list
  Future<void> install(ProjectContext ctx);

  /// Undo the install: remove files, clean pubspec, update agentic.yaml.
  Future<void> uninstall(ProjectContext ctx);
}
