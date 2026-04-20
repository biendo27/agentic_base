import 'dart:convert';
import 'dart:io';

import 'package:agentic_base/src/cli/commands/inspect_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('InspectCommand', () {
    late Directory tempDir;
    late List<String> outputs;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('inspect-command-test-');
      outputs = <String>[];
      AgenticConfig.createInitial(
        projectPath: tempDir.path,
        projectName: 'demo_app',
        org: 'com.example',
        stateManagement: 'cubit',
        platforms: ['android', 'ios'],
        flavors: ['dev', 'staging', 'prod'],
        toolVersion: 'test',
      );
      _seedEvidenceRun(
        p.join(tempDir.path, 'artifacts', 'evidence', 'verify', 'latest'),
      );
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        InspectCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
          emit: outputs.add,
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('renders markdown for the latest verify bundle by default', () async {
      final exitCode = await runner.run(['inspect']);

      expect(exitCode, equals(0));
      expect(outputs.single, contains('# Run Inspection'));
      expect(outputs.single, contains('`verify` / `verify-1`'));
    });

    test('renders the derived run ledger as json', () async {
      final exitCode = await runner.run(['inspect', '--format', 'json']);

      expect(exitCode, equals(0));
      expect(outputs.single, contains('"run_id": "verify-1"'));
      expect(outputs.single, contains('"telemetry_present": true'));
      expect(outputs.single, contains('"summary": "Contract surface passed."'));
    });

    test('accepts a check file path as the explicit inspect target', () async {
      final exitCode = await runner.run([
        'inspect',
        'artifacts/evidence/verify/latest/checks/contract-surface.json',
        '--format',
        'json',
      ]);

      expect(exitCode, equals(0));
      expect(outputs.single, contains('"run_id": "verify-1"'));
      expect(outputs.single, contains('"summary": "Contract surface passed."'));
    });
  });
}

void _seedEvidenceRun(String runDir) {
  Directory(p.join(runDir, 'checks')).createSync(recursive: true);
  Directory(p.join(runDir, 'telemetry')).createSync(recursive: true);
  File(p.join(runDir, 'summary.json')).writeAsStringSync(
    jsonEncode(<String, dynamic>{
      'run_id': 'verify-1',
      'run_kind': 'verify',
      'timestamp': '2026-04-20T01:00:00Z',
      'approval_state': 'ReadyForReview',
      'overall_state': 'pass',
      'quality_dimensions': <String, dynamic>{
        'correctness': 'pass',
        'release_readiness': 'risk',
        'evidence_quality': 'pass',
        'ux_confidence': 'pass',
      },
      'next_required_human_action': 'none',
      'executed_gates': <Map<String, dynamic>>[
        <String, dynamic>{'id': 'contract-surface', 'state': 'pass'},
      ],
    }),
  );
  File(p.join(runDir, 'checks', 'contract-surface.json')).writeAsStringSync(
    jsonEncode(<String, dynamic>{
      'timestamp': '2026-04-20T01:00:00Z',
      'gate': 'contract-surface',
      'state': 'pass',
      'command': './tools/verify.sh',
      'summary': 'Contract surface passed.',
    }),
  );
  File(p.join(runDir, 'commands.ndjson')).writeAsStringSync(
    '${jsonEncode(<String, dynamic>{'timestamp': '2026-04-20T01:00:01Z', 'gate': 'contract-surface', 'command': './tools/verify.sh'})}\n',
  );
  File(
    p.join(runDir, 'telemetry', 'runtime-context.json'),
  ).writeAsStringSync(
    jsonEncode(<String, dynamic>{
      'run_id': 'verify-1',
      'mode': 'local-first',
      'app_name': 'Demo App',
    }),
  );
  File(p.join(runDir, 'telemetry', 'events.ndjson')).writeAsStringSync(
    '${jsonEncode(<String, dynamic>{'ts': '2026-04-20T01:00:00Z', 'kind': 'approval_transition', 'name': 'approval_state', 'state_or_level': 'ReadyForReview'})}\n',
  );
  File(p.join(runDir, 'telemetry', 'metrics.json')).writeAsStringSync(
    jsonEncode(<String, dynamic>{
      'counters': <String, int>{'screen_views': 2},
      'durations': <String, dynamic>{},
    }),
  );
}
