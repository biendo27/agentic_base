import 'package:agentic_base/src/observability/telemetry_bundle.dart';

class RunLedger {
  const RunLedger._(this._data);

  factory RunLedger.fromBundle(TelemetryBundle bundle) {
    final summary = bundle.summary;
    final gates = _mergeGates(
      summaryGates: (summary['executed_gates'] as List<dynamic>? ??
              const <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (gate) => gate.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          )
          .toList(growable: false),
      checks: bundle.checks,
      fallbackTimestamp: summary['timestamp']?.toString(),
    );

    final timeline = <Map<String, dynamic>>[
      ...bundle.events,
      ...bundle.commands.map((command) {
        return <String, dynamic>{
          'ts': command['timestamp'] ?? summary['timestamp'],
          'kind': 'command',
          'name': command['gate'] ?? 'command',
          'state_or_level': 'invoked',
          'attrs': <String, dynamic>{'command': command['command']},
        };
      }),
      ...gates.map((gate) {
        return <String, dynamic>{
          'ts': gate['timestamp'] ?? summary['timestamp'],
          'kind': 'gate',
          'name': gate['id'] ?? 'gate',
          'state_or_level': gate['state'] ?? 'unknown',
          'attrs': <String, dynamic>{
            if (gate['summary'] != null) 'summary': gate['summary'],
            if (gate['command'] != null) 'command': gate['command'],
          },
        };
      }),
    ]..sort(
      (left, right) => (left['ts']?.toString() ?? '').compareTo(
        right['ts']?.toString() ?? '',
      ),
    );

    return RunLedger._(<String, dynamic>{
      'run_id': summary['run_id'],
      'run_kind': summary['run_kind'],
      'bundle_path': bundle.runDirectory.path,
      'approval_state': summary['approval_state'],
      'next_required_human_action': summary['next_required_human_action'],
      'overall_state': summary['overall_state'],
      'quality_dimensions': summary['quality_dimensions'],
      'gates': gates,
      'timeline': timeline,
      'metrics': bundle.metrics,
      'runtime_context': bundle.runtimeContext,
      'artifacts': <String, dynamic>{
        'summary': 'summary.json',
        'commands': 'commands.ndjson',
        'telemetry_dir': 'telemetry/',
        'checks_dir': 'checks/',
        'logs_dir': 'logs/',
      },
      'telemetry_present': bundle.telemetryPresent,
    });
  }

  final Map<String, dynamic> _data;

  Map<String, dynamic> toJson() => _data;
}

List<Map<String, dynamic>> _mergeGates({
  required List<Map<String, dynamic>> summaryGates,
  required List<Map<String, dynamic>> checks,
  required String? fallbackTimestamp,
}) {
  final merged = <String, Map<String, dynamic>>{};

  for (final gate in summaryGates) {
    final id = gate['id']?.toString();
    if (id == null || id.isEmpty) {
      continue;
    }
    merged[id] = <String, dynamic>{
      'id': id,
      'state': gate['state'] ?? 'unknown',
      if (fallbackTimestamp != null) 'timestamp': fallbackTimestamp,
    };
  }

  for (final check in checks) {
    final id = check['gate']?.toString();
    if (id == null || id.isEmpty) {
      continue;
    }
    merged[id] = <String, dynamic>{
      ...?merged[id],
      'id': id,
      'state': check['state'] ?? merged[id]?['state'] ?? 'unknown',
      'timestamp':
          check['timestamp']?.toString() ??
          merged[id]?['timestamp'] ??
          fallbackTimestamp,
      if (check['summary'] != null) 'summary': check['summary'],
      if (check['command'] != null) 'command': check['command'],
    };
  }

  return merged.values.toList(growable: false)..sort((left, right) {
    return (left['id']?.toString() ?? '').compareTo(
      right['id']?.toString() ?? '',
    );
  });
}
