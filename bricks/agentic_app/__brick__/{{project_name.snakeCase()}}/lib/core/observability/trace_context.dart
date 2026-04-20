class TraceContext {
  const TraceContext({
    required this.runId,
    required this.sessionId,
    required this.traceId,
    required this.spanId,
    required this.name,
    required this.startedAt,
    this.parentSpanId,
  });

  factory TraceContext.root({required String name}) {
    final now = DateTime.now().toUtc();
    return TraceContext(
      runId: generateObservabilityId(prefix: 'run'),
      sessionId: generateObservabilityId(prefix: 'session'),
      traceId: generateObservabilityId(prefix: 'trace'),
      spanId: generateObservabilityId(prefix: 'span'),
      name: name,
      startedAt: now,
    );
  }

  final String runId;
  final String sessionId;
  final String traceId;
  final String spanId;
  final String name;
  final DateTime startedAt;
  final String? parentSpanId;

  TraceContext child({required String name}) {
    return TraceContext(
      runId: runId,
      sessionId: sessionId,
      traceId: traceId,
      spanId: generateObservabilityId(prefix: 'span'),
      name: name,
      parentSpanId: spanId,
      startedAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'run_id': runId,
      'session_id': sessionId,
      'trace_id': traceId,
      'span_id': spanId,
      if (parentSpanId != null) 'parent_span_id': parentSpanId,
      'name': name,
      'started_at': startedAt.toIso8601String(),
    };
  }
}

String generateObservabilityId({required String prefix}) {
  final microseconds = DateTime.now().toUtc().microsecondsSinceEpoch;
  return '$prefix-${microseconds.toRadixString(36)}';
}
