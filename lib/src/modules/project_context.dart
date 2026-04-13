import 'package:agentic_base/src/config/scaffold_state_profile.dart';
import 'package:agentic_base/src/modules/project_mutation_journal.dart';

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
    this.mutationJournal,
  });

  /// Absolute path to the project root (contains pubspec.yaml).
  final String projectPath;

  /// Dart package name (snake_case).
  final String projectName;

  /// State management strategy: 'cubit', 'riverpod', or 'mobx'.
  final String stateManagement;

  /// Names of modules already installed in this project.
  final List<String> installedModules;

  /// Optional journal used to make file mutations rollback-safe.
  final ProjectMutationJournal? mutationJournal;

  ScaffoldStateProfile get stateProfile =>
      ScaffoldStateProfile.fromState(stateManagement);

  @override
  String toString() =>
      'ProjectContext('
      'project=$projectName, '
      'state=$stateManagement, '
      'modules=$installedModules, '
      'journal=${mutationJournal != null})';
}
