import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Shared helpers for module install/uninstall operations.
///
/// Handles pubspec.yaml manipulation (via yaml_edit to preserve comments)
/// and agentic.yaml module list updates.
class ModuleInstaller {
  const ModuleInstaller(this.ctx);

  final ProjectContext ctx;

  // ---------------------------------------------------------------------------
  // Pubspec manipulation
  // ---------------------------------------------------------------------------

  /// Add [packages] to pubspec.yaml `dependencies` block.
  ///
  /// Each entry in [packages] is a package name; version is set to `any`
  /// unless [versions] provides an override keyed by package name.
  void addDependencies(
    List<String> packages, {
    Map<String, String>? versions,
  }) {
    _editPubspec((editor) {
      for (final pkg in packages) {
        final version = versions?[pkg] ?? 'any';
        editor.update(['dependencies', pkg], version);
      }
    });
  }

  /// Add [packages] to pubspec.yaml `dev_dependencies` block.
  void addDevDependencies(
    List<String> packages, {
    Map<String, String>? versions,
  }) {
    _editPubspec((editor) {
      for (final pkg in packages) {
        final version = versions?[pkg] ?? 'any';
        editor.update(['dev_dependencies', pkg], version);
      }
    });
  }

  /// Remove [packages] from `dependencies` in pubspec.yaml.
  ///
  /// Packages not present are silently skipped.
  void removeDependencies(List<String> packages) {
    _editPubspecWithParsed((parsed, editor) {
      final deps = parsed['dependencies'];
      if (deps is YamlMap) {
        for (final pkg in packages) {
          if (deps.containsKey(pkg)) {
            editor.remove(['dependencies', pkg]);
          }
        }
      }
    });
  }

  /// Remove [packages] from `dev_dependencies` in pubspec.yaml.
  ///
  /// Packages not present are silently skipped.
  void removeDevDependencies(List<String> packages) {
    _editPubspecWithParsed((parsed, editor) {
      final deps = parsed['dev_dependencies'];
      if (deps is YamlMap) {
        for (final pkg in packages) {
          if (deps.containsKey(pkg)) {
            editor.remove(['dev_dependencies', pkg]);
          }
        }
      }
    });
  }

  void _editPubspec(void Function(YamlEditor editor) mutate) {
    final pubspecPath = p.join(ctx.projectPath, 'pubspec.yaml');
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      throw StateError('pubspec.yaml not found at $pubspecPath');
    }
    final content = file.readAsStringSync();
    final editor = YamlEditor(content);
    mutate(editor);
    file.writeAsStringSync(editor.toString());
  }

  void _editPubspecWithParsed(
    void Function(YamlMap parsed, YamlEditor editor) mutate,
  ) {
    final pubspecPath = p.join(ctx.projectPath, 'pubspec.yaml');
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      throw StateError('pubspec.yaml not found at $pubspecPath');
    }
    final content = file.readAsStringSync();
    final parsed = loadYaml(content);
    if (parsed is! YamlMap) return;
    final editor = YamlEditor(content);
    mutate(parsed, editor);
    file.writeAsStringSync(editor.toString());
  }

  // ---------------------------------------------------------------------------
  // File operations
  // ---------------------------------------------------------------------------

  /// Write [content] to [relPath] (relative to project root).
  /// Creates parent directories as needed.
  void writeFile(String relPath, String content) {
    final file = File(p.join(ctx.projectPath, relPath));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  /// Delete the file at [relPath] if it exists.
  void deleteFile(String relPath) {
    final file = File(p.join(ctx.projectPath, relPath));
    if (file.existsSync()) file.deleteSync();
  }

  /// Delete directory at [relPath] if it exists (recursive).
  void deleteDirectory(String relPath) {
    final dir = Directory(p.join(ctx.projectPath, relPath));
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }

  // ---------------------------------------------------------------------------
  // agentic.yaml tracking
  // ---------------------------------------------------------------------------

  /// Mark [moduleName] as installed in `.info/agentic.yaml`.
  void markInstalled(String moduleName) {
    final config = AgenticConfig(projectPath: ctx.projectPath);
    final data = config.read();
    final modules = List<String>.from(
      (data['modules'] as List?)?.cast<String>() ?? [],
    );
    if (!modules.contains(moduleName)) {
      modules.add(moduleName);
      config.write({'modules': modules});
    }
  }

  /// Remove [moduleName] from `.info/agentic.yaml` modules list.
  void markUninstalled(String moduleName) {
    final config = AgenticConfig(projectPath: ctx.projectPath);
    final data = config.read();
    final modules = List<String>.from(
      (data['modules'] as List?)?.cast<String>() ?? [],
    )..remove(moduleName);
    config.write({'modules': modules});
  }
}
