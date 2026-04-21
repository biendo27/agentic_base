import 'dart:io';

import 'package:path/path.dart' as p;

final class ProjectMutationJournal {
  final Map<String, _TrackedFileState> _trackedStates =
      <String, _TrackedFileState>{};
  final Map<String, bool> _trackedDirectories = <String, bool>{};

  void trackFile(String path) {
    _trackFile(path);
  }

  void trackDirectory(String path) {
    final normalizedPath = p.normalize(path);
    if (_trackedDirectories.containsKey(normalizedPath)) return;

    final directory = Directory(normalizedPath);
    final existed = directory.existsSync();
    _trackedDirectories[normalizedPath] = existed;
    if (!existed) return;

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is File) {
        _trackFile(entity.path);
      }
    }
  }

  void writeFile(String path, String content) {
    _trackFile(path);
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  void deleteFile(String path) {
    _trackFile(path);
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  void mutateTextFile(String path, String Function(String current) mutate) {
    _trackFile(path);
    final file = File(path);
    final current = file.existsSync() ? file.readAsStringSync() : '';
    final next = mutate(current);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(next);
  }

  void rollback() {
    _deleteUntrackedFilesInTrackedDirectories();

    final reversedPaths = _trackedStates.keys.toList().reversed;
    for (final path in reversedPaths) {
      final state = _trackedStates[path]!;
      final file = File(path);
      if (state.existed) {
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(state.bytes!);
      } else if (file.existsSync()) {
        file.deleteSync();
        _deleteEmptyParents(file.parent);
      }
    }

    _cleanupTrackedDirectories();
  }

  void _trackFile(String path) {
    final normalizedPath = p.normalize(path);
    if (_trackedStates.containsKey(normalizedPath)) return;
    final file = File(normalizedPath);
    _trackedStates[normalizedPath] = _TrackedFileState(
      existed: file.existsSync(),
      bytes: file.existsSync() ? file.readAsBytesSync() : null,
    );
  }

  void _deleteUntrackedFilesInTrackedDirectories() {
    for (final rootPath in _trackedDirectories.keys.toList().reversed) {
      final root = Directory(rootPath);
      if (!root.existsSync()) continue;

      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File) continue;
        final filePath = p.normalize(entity.path);
        if (_trackedStates.containsKey(filePath)) continue;
        entity.deleteSync();
      }
    }
  }

  void _cleanupTrackedDirectories() {
    for (final entry in _trackedDirectories.entries.toList().reversed) {
      final directory = Directory(entry.key);
      if (!directory.existsSync()) continue;

      _deleteEmptyDescendants(directory);
      if (!entry.value && directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    }
  }

  void _deleteEmptyDescendants(Directory directory) {
    if (!directory.existsSync()) return;
    final descendants =
        directory.listSync(recursive: true).whereType<Directory>().toList()
          ..sort((a, b) => b.path.length.compareTo(a.path.length));
    for (final descendant in descendants) {
      if (descendant.existsSync() && descendant.listSync().isEmpty) {
        descendant.deleteSync();
      }
    }
  }

  void _deleteEmptyParents(Directory directory) {
    var current = directory;
    while (true) {
      if (current.path == p.rootPrefix(current.path) ||
          current.listSync().isNotEmpty) {
        return;
      }
      current.deleteSync();
      final parentPath = p.dirname(current.path);
      if (parentPath == current.path) return;
      current = Directory(parentPath);
    }
  }
}

final class _TrackedFileState {
  const _TrackedFileState({required this.existed, required this.bytes});

  final bool existed;
  final List<int>? bytes;
}
