import 'dart:io';

import 'package:agentic_base/src/observability/run_ledger.dart';
import 'package:agentic_base/src/observability/telemetry_bundle.dart';
import 'package:test/test.dart';

void main() {
  test('joins commands, gates, and telemetry into one derived timeline', () {
    final bundle = TelemetryBundle(
      runDirectory: Directory.systemTemp,
      summary: <String, dynamic>{
        'run_id': 'verify-1',
        'run_kind': 'verify',
        'timestamp': '2026-04-20T01:00:00Z',
        'approval_state': 'ReadyForReview',
        'next_required_human_action': 'none',
        'overall_state': 'pass',
        'quality_dimensions': <String, dynamic>{'correctness': 'pass'},
        'executed_gates': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'contract-surface', 'state': 'pass'},
        ],
      },
      checks: <Map<String, dynamic>>[
        <String, dynamic>{
          'timestamp': '2026-04-20T01:00:00Z',
          'gate': 'contract-surface',
          'state': 'pass',
          'command': './tools/verify.sh',
          'summary': 'Contract surface passed.',
        },
      ],
      commands: <Map<String, dynamic>>[
        <String, dynamic>{
          'timestamp': '2026-04-20T01:00:02Z',
          'gate': 'contract-surface',
          'command': './tools/verify.sh',
        },
      ],
      events: <Map<String, dynamic>>[
        <String, dynamic>{
          'ts': '2026-04-20T01:00:01Z',
          'kind': 'approval_transition',
          'name': 'approval_state',
          'state_or_level': 'EvalRunning',
        },
      ],
      runtimeContext: <String, dynamic>{'mode': 'local-first'},
      metrics: <String, dynamic>{
        'counters': <String, int>{'screen_views': 1},
      },
    );

    final ledger = RunLedger.fromBundle(bundle).toJson();
    final timeline =
        (ledger['timeline'] as List<dynamic>).cast<Map<String, dynamic>>();

    expect(ledger['telemetry_present'], isTrue);
    expect(timeline, hasLength(3));
    expect(timeline.first['kind'], equals('gate'));
    final attrs = timeline.first['attrs'] as Map<String, dynamic>;
    expect(
      attrs['summary'],
      equals('Contract surface passed.'),
    );
    expect(timeline[1]['kind'], equals('approval_transition'));
    expect(timeline.last['kind'], equals('command'));
  });
}
