import 'package:agentic_base/src/observability/run_ledger.dart';

class OperatorReportRenderer {
  const OperatorReportRenderer();

  String renderMarkdown(RunLedger ledger) {
    final data = ledger.toJson();
    final metrics = data['metrics'] as Map<String, dynamic>? ?? const {};
    final counters = metrics['counters'] as Map<String, dynamic>? ?? const {};
    final durations = metrics['durations'] as Map<String, dynamic>? ?? const {};
    final gates = (data['gates'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (gate) => '- `${gate['id']}`: `${gate['state']}`',
        )
        .join('\n');
    final timeline = (data['timeline'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .take(12)
        .map((event) {
          return '- `${event['ts']}` `${event['kind']}` `${event['name']}` -> `${event['state_or_level']}`';
        })
        .join('\n');
    final gatesSection = gates.isEmpty ? '- none recorded' : gates;
    final timelineSection =
        timeline.isEmpty ? '- no timeline events recorded' : timeline;

    return [
      '# Run Inspection',
      '',
      '- Run: `${data['run_kind']}` / `${data['run_id']}`',
      '- Bundle: `${data['bundle_path']}`',
      '- State: `${data['overall_state']}`',
      '- Approval: `${data['approval_state']}`',
      '- Next human action: `${data['next_required_human_action']}`',
      '- Telemetry present: `${data['telemetry_present']}`',
      '',
      '## Gates',
      gatesSection,
      '',
      '## Runtime Metrics',
      '- Counters: `${counters.isEmpty ? '{}' : counters}`',
      '- Durations: `${durations.isEmpty ? '{}' : durations}`',
      '',
      '## Timeline',
      timelineSection,
    ].join('\n');
  }
}
