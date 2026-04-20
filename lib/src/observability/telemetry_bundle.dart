import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class TelemetryBundle {
  const TelemetryBundle({
    required this.runDirectory,
    required this.summary,
    required this.checks,
    required this.commands,
    required this.events,
    required this.runtimeContext,
    required this.metrics,
  });

  factory TelemetryBundle.load(String runDirectoryPath) {
    final normalizedRunDirectoryPath = normalizeRunDirectoryPath(
      runDirectoryPath,
    );
    final runDirectory = Directory(normalizedRunDirectoryPath);
    if (!runDirectory.existsSync()) {
      throw FormatException(
        'Missing evidence run directory: $normalizedRunDirectoryPath',
      );
    }

    return TelemetryBundle(
      runDirectory: runDirectory,
      summary: _readJsonMap(
        p.join(normalizedRunDirectoryPath, 'summary.json'),
      ),
      checks: _readJsonMaps(p.join(normalizedRunDirectoryPath, 'checks')),
      commands: _readNdjson(
        p.join(normalizedRunDirectoryPath, 'commands.ndjson'),
      ),
      events: _readNdjson(
        p.join(normalizedRunDirectoryPath, 'telemetry', 'events.ndjson'),
      ),
      runtimeContext: _readOptionalJsonMap(
        p.join(normalizedRunDirectoryPath, 'telemetry', 'runtime-context.json'),
      ),
      metrics: _readOptionalJsonMap(
        p.join(normalizedRunDirectoryPath, 'telemetry', 'metrics.json'),
      ),
    );
  }

  final Directory runDirectory;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> checks;
  final List<Map<String, dynamic>> commands;
  final List<Map<String, dynamic>> events;
  final Map<String, dynamic> runtimeContext;
  final Map<String, dynamic> metrics;

  bool get telemetryPresent =>
      events.isNotEmpty || runtimeContext.isNotEmpty || metrics.isNotEmpty;

  static String normalizeRunDirectoryPath(String candidatePath) {
    final normalized = p.normalize(candidatePath);
    final parent = p.dirname(normalized);
    final parentName = p.basename(parent);
    final basename = p.basename(normalized);

    if (basename == 'summary.json' || basename == 'commands.ndjson') {
      return parent;
    }
    if (parentName == 'checks' || parentName == 'telemetry') {
      return p.dirname(parent);
    }

    return normalized;
  }

  static String resolveRunDirectory({
    required String projectPath,
    required String evidenceDir,
    required String runKind,
  }) {
    final latestPath = p.join(projectPath, evidenceDir, runKind, 'latest');
    final latestDir = Directory(latestPath);
    if (latestDir.existsSync() && _isCompleteRunDirectory(latestPath)) {
      return latestPath;
    }

    final runRoot = Directory(p.join(projectPath, evidenceDir, runKind));
    if (!runRoot.existsSync()) {
      throw FormatException('No evidence runs found for "$runKind".');
    }

    final runDirectories =
        runRoot.listSync().whereType<Directory>().where((directory) {
            return p.basename(directory.path) != 'latest' &&
                _isCompleteRunDirectory(directory.path);
          }).toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    if (runDirectories.isEmpty) {
      throw FormatException('No evidence runs found for "$runKind".');
    }
    return runDirectories.last.path;
  }

  static Map<String, dynamic> _readJsonMap(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw FormatException('Missing required evidence file: $path');
    }
    return _decodeJsonMap(file.readAsStringSync(), path: path);
  }

  static Map<String, dynamic> _readOptionalJsonMap(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return const <String, dynamic>{};
    }
    return _decodeJsonMap(file.readAsStringSync(), path: path);
  }

  static List<Map<String, dynamic>> _readJsonMaps(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return const <Map<String, dynamic>>[];
    }

    final files =
        directory.listSync().whereType<File>().where((file) {
            return p.extension(file.path).toLowerCase() == '.json';
          }).toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    return files
        .map((file) {
          return _decodeJsonMap(file.readAsStringSync(), path: file.path);
        })
        .toList(growable: false);
  }

  static Map<String, dynamic> _decodeJsonMap(
    String source, {
    required String path,
  }) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw FormatException('Expected a JSON object in $path');
    }
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }

  static List<Map<String, dynamic>> _readNdjson(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return const <Map<String, dynamic>>[];
    }

    return file
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          final decoded = jsonDecode(line);
          if (decoded is! Map) {
            throw FormatException('Expected a JSON object line in $path');
          }
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        })
        .toList(growable: false);
  }

  static bool _isCompleteRunDirectory(String path) {
    return File(p.join(path, 'summary.json')).existsSync();
  }
}
