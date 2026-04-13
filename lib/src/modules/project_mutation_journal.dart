import 'dart:io';

import 'package:path/path.dart' as p;

final class ProjectMutationJournal {
  final Map<String, _TrackedFileState> _trackedStates =
      <String, _TrackedFileState>{};

  void writeFile(String path, String content) {
    _track(path);
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  void deleteFile(String path) {
    _track(path);
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  void mutateTextFile(String path, String Function(String current) mutate) {
    _track(path);
    final file = File(path);
    final current = file.existsSync() ? file.readAsStringSync() : '';
    final next = mutate(current);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(next);
  }

  void rollback() {
    final reversedPaths = _trackedStates.keys.toList().reversed;
    for (final path in reversedPaths) {
      final state = _trackedStates[path]!;
      final file = File(path);
      if (state.existed) {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(state.content!);
      } else if (file.existsSync()) {
        file.deleteSync();
        _deleteEmptyParents(file.parent);
      }
    }
  }

  void _track(String path) {
    if (_trackedStates.containsKey(path)) return;
    final file = File(path);
    _trackedStates[path] = _TrackedFileState(
      existed: file.existsSync(),
      content: file.existsSync() ? file.readAsStringSync() : null,
    );
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
  const _TrackedFileState({required this.existed, required this.content});

  final bool existed;
  final String? content;
}
