import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void _createConfigFile(Directory tempDir, String content) {
  Directory(p.join(tempDir.path, '.info'))
    ..createSync(recursive: true)
    ..uri; // force eval
  File(
    p.join(tempDir.path, '.info', 'agentic.yaml'),
  ).writeAsStringSync(content);
}

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
      expect(config.read(), isEmpty);
    });

    test('exists returns true when file exists', () {
      _createConfigFile(tempDir, 'test: data\n');
      expect(AgenticConfig(projectPath: tempDir.path).exists, true);
    });

    test('write can add fields to config', () {
      _createConfigFile(tempDir, 'project_name: my_app\n');
      final config = AgenticConfig(projectPath: tempDir.path)
        ..write({'new_field': 'new_value'});
      expect(config.read()['new_field'], equals('new_value'));
    });

    test('write creates .info directory if it does not exist', () {
      final infoDir = Directory(p.join(tempDir.path, '.info'));
      expect(infoDir.existsSync(), false);

      AgenticConfig(projectPath: tempDir.path).write({'key': 'value'});
      expect(infoDir.existsSync(), true);
    });

    test('read parses modules list correctly', () {
      _createConfigFile(
        tempDir,
        'modules:\n  - analytics\n  - auth\n  - payments\n',
      );
      final data = AgenticConfig(projectPath: tempDir.path).read();
      expect(data['modules'], isA<List<dynamic>>());
      expect(data['modules'], contains('analytics'));
    });

    test('read returns empty map for empty YAML file', () {
      _createConfigFile(tempDir, '');
      expect(AgenticConfig(projectPath: tempDir.path).read(), isEmpty);
    });

    test('config path is correctly computed', () {
      final expectedPath = p.join(tempDir.path, '.info', 'agentic.yaml');
      _createConfigFile(tempDir, 'test: data\n');
      expect(File(expectedPath).existsSync(), true);
    });

    test('handles platforms list with multiple items', () {
      _createConfigFile(
        tempDir,
        'platforms:\n  - ios\n  - android\n  - web\n  - macos\n',
      );
      final data = AgenticConfig(projectPath: tempDir.path).read();
      expect(data['platforms'], isA<List<dynamic>>());
      expect((data['platforms'] as List<dynamic>).length, equals(4));
    });

    test('createInitial persists ci_provider from enum serialization', () {
      AgenticConfig.createInitial(
        projectPath: tempDir.path,
        projectName: 'demo_app',
        org: 'com.example',
        stateManagement: 'cubit',
        platforms: const ['android', 'ios'],
        flavors: const ['dev', 'staging', 'prod'],
        toolVersion: '0.1.0',
        ciProvider: CiProvider.gitlab,
      );

      final data = AgenticConfig(projectPath: tempDir.path).read();
      expect(data['ci_provider'], equals('gitlab'));
    });

    test(
      'resolveCiProviderFromConfig falls back to inferred provider files',
      () {
        Directory(p.join(tempDir.path, '.gitlab', 'ci')).createSync(
          recursive: true,
        );
        File(
          p.join(tempDir.path, '.gitlab-ci.yml'),
        ).writeAsStringSync('include: []');

        final resolved = resolveCiProviderFromConfig(
          config: const <String, dynamic>{},
          projectPath: tempDir.path,
        );

        expect(resolved, equals(CiProvider.gitlab));
      },
    );
  });
}
