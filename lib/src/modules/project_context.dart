/// Contextual information about the target Flutter project.
///
/// Passed to `AgenticModule.install` and `AgenticModule.uninstall`
/// so modules can locate project files and respect configuration.
class ProjectContext {
  const ProjectContext({
    required this.projectPath,
    required this.projectName,
    required this.stateManagement,
    required this.installedModules,
  });

  /// Absolute path to the project root (contains pubspec.yaml).
  final String projectPath;

  /// Dart package name (snake_case).
  final String projectName;

  /// State management strategy: 'cubit', 'riverpod', or 'mobx'.
  final String stateManagement;

  /// Names of modules already installed in this project.
  final List<String> installedModules;

  @override
  String toString() =>
      'ProjectContext('
      'project=$projectName, '
      'state=$stateManagement, '
      'modules=$installedModules)';
}
