import 'dart:convert';
import 'dart:io';

import 'package:agentic_base/src/observability/telemetry_bundle.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('TelemetryBundle', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('telemetry-bundle-test-');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('normalizes check and telemetry files back to the run directory', () {
      final runDir = p.join(
        tempDir.path,
        'artifacts',
        'evidence',
        'verify',
        'latest',
      );
      expect(
        TelemetryBundle.normalizeRunDirectoryPath(
          p.join(runDir, 'checks', 'contract-surface.json'),
        ),
        equals(runDir),
      );
      expect(
        TelemetryBundle.normalizeRunDirectoryPath(
          p.join(runDir, 'telemetry', 'events.ndjson'),
        ),
        equals(runDir),
      );
      expect(
        TelemetryBundle.normalizeRunDirectoryPath(
          p.join(runDir, 'summary.json'),
        ),
        equals(runDir),
      );
    });

    test('resolveRunDirectory ignores incomplete newer runs', () {
      final runRoot = Directory(
        p.join(tempDir.path, 'artifacts', 'evidence', 'verify'),
      )..createSync(recursive: true);
      _seedCompleteRun(p.join(runRoot.path, '20260420T010000Z-111'));
      Directory(
        p.join(runRoot.path, '20260420T020000Z-222'),
      ).createSync(recursive: true);
      Directory(p.join(runRoot.path, 'latest')).createSync(recursive: true);

      final resolved = TelemetryBundle.resolveRunDirectory(
        projectPath: tempDir.path,
        evidenceDir: 'artifacts/evidence',
        runKind: 'verify',
      );

      expect(resolved, endsWith('20260420T010000Z-111'));
    });
  });
}

void _seedCompleteRun(String runDir) {
  Directory(p.join(runDir, 'checks')).createSync(recursive: true);
  Directory(p.join(runDir, 'telemetry')).createSync(recursive: true);
  File(p.join(runDir, 'summary.json')).writeAsStringSync(
    jsonEncode(<String, dynamic>{
      'run_id': 'verify-1',
      'run_kind': 'verify',
      'timestamp': '2026-04-20T01:00:00Z',
    }),
  );
}
