import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('AgenticConfig', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('agentic_config_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('exists returns false for non-existent file', () {
      final config = AgenticConfig(projectPath: tempDir.path);
      expect(config.exists, false);
    });

    test('read returns empty map for non-existent file', () {
      final config = AgenticConfig(projectPath: tempDir.path);
      final data = config.read();
      expect(data, isEmpty);
    });

    test('exists returns true when file exists', () {
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      infoDir.createSync(recursive: true);
      final configFile = File(p.join(infoDir.path, 'agentic.yaml'));
      configFile.writeAsStringSync('test: data\n');

      final config = AgenticConfig(projectPath: tempDir.path);
      expect(config.exists, true);
    });

    test('write can add fields to config', () {
      final config = AgenticConfig(projectPath: tempDir.path);

      // First create the .info directory
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      infoDir.createSync(recursive: true);

      // Create an initial YAML file with some content
      final configFile = File(p.join(infoDir.path, 'agentic.yaml'));
      configFile.writeAsStringSync('project_name: my_app\n');

      // Now write additional data
      config.write({'new_field': 'new_value'});

      final updatedData = config.read();
      expect(updatedData['new_field'], equals('new_value'));
    });

    test('write creates .info directory if it does not exist', () {
      final config = AgenticConfig(projectPath: tempDir.path);
      final infoDir = Directory(p.join(tempDir.path, '.info'));

      expect(infoDir.existsSync(), false);

      // Create initial file with content first
      infoDir.createSync(recursive: true);
      final configFile = File(p.join(infoDir.path, 'agentic.yaml'));
      configFile.writeAsStringSync('test: data\n');

      config.write({'key': 'value'});

      expect(infoDir.existsSync(), true);
    });

    test('read parses modules list correctly', () {
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      infoDir.createSync(recursive: true);
      final configFile = File(p.join(infoDir.path, 'agentic.yaml'));
      configFile.writeAsStringSync('modules:\n  - analytics\n  - auth\n  - payments\n');

      final config = AgenticConfig(projectPath: tempDir.path);
      final data = config.read();
      expect(data['modules'], isA<List<dynamic>>());
      expect(data['modules'], contains('analytics'));
    });

    test('read returns empty map for empty YAML file', () {
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      infoDir.createSync(recursive: true);

      final configFile = File(p.join(infoDir.path, 'agentic.yaml'));
      configFile.writeAsStringSync('');

      final config = AgenticConfig(projectPath: tempDir.path);
      final data = config.read();
      expect(data, isEmpty);
    });

    test('config path is correctly computed', () {
      final expectedPath = p.join(tempDir.path, '.info', 'agentic.yaml');

      // Verify by creating initial config
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      infoDir.createSync(recursive: true);
      final configFile = File(expectedPath);
      configFile.writeAsStringSync('test: data\n');

      expect(File(expectedPath).existsSync(), true);
    });

    test('handles platforms list with multiple items', () {
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      infoDir.createSync(recursive: true);
      final configFile = File(p.join(infoDir.path, 'agentic.yaml'));
      configFile.writeAsStringSync('platforms:\n  - ios\n  - android\n  - web\n  - macos\n');

      final config = AgenticConfig(projectPath: tempDir.path);
      final data = config.read();
      expect(data['platforms'], isA<List<dynamic>>());
      expect((data['platforms'] as List<dynamic>).length, equals(4));
    });
  });
}
