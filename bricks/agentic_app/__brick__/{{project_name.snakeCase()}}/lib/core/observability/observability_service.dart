import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/redaction_policy.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/trace_context.dart';

class ObservabilityService {
  ObservabilityService._();

  static final ObservabilityService instance = ObservabilityService._();
  static const _maxEvents = 200;

  final RedactionPolicy _redactionPolicy = const RedactionPolicy();
  final List<Map<String, dynamic>> _events = <Map<String, dynamic>>[];
  final Map<String, int> _counters = <String, int>{};
  final Map<String, _DurationAccumulator> _durations =
      <String, _DurationAccumulator>{};
  final Set<String> _sessionSignals = <String>{};

  TraceContext? _runtimeContext;
  String _flavor = 'unknown';
  String _appName = 'unknown';

  String get runId => _ensureContext().runId;
  int get bufferedEventCount => _events.length;

  void bootstrap({required String flavor, required String appName}) {
    if (_runtimeContext != null) {
      return;
    }
    _runtimeContext = TraceContext.root(name: 'app.bootstrap');
    _flavor = flavor;
    _appName = appName;
    increment('bootstrap_runs');
    log(
      'bootstrap.started',
      fields: <String, Object?>{'flavor': flavor, 'app_name': appName},
    );
  }

  void log(
    String name, {
    String level = 'info',
    Map<String, Object?> fields = const <String, Object?>{},
    TraceContext? context,
  }) {
    _record(
      kind: 'log',
      name: name,
      stateOrLevel: level,
      attrs: fields,
      context: context ?? _ensureContext(),
    );
  }

  TraceContext startSpan(
    String name, {
    Map<String, Object?> fields = const <String, Object?>{},
    TraceContext? parent,
  }) {
    final context = (parent ?? _ensureContext()).child(name: name);
    _record(
      kind: 'span_start',
      name: name,
      stateOrLevel: 'started',
      attrs: fields,
      context: context,
    );
    return context;
  }

  void finishSpan(
    TraceContext context, {
    String state = 'ok',
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    final duration = DateTime.now().toUtc().difference(context.startedAt);
    recordDuration(
      context.name,
      duration,
      fields: <String, Object?>{'state': state, ...fields},
    );
    _record(
      kind: 'span_end',
      name: context.name,
      stateOrLevel: state,
      attrs: <String, Object?>{
        'duration_ms': duration.inMilliseconds,
        ...fields,
      },
      context: context,
    );
  }

  void trackScreenView(
    String screenName, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    if (!_markSignal('screen', screenName, fields)) {
      return;
    }
    increment('screen_views');
    log(
      'screen.view',
      fields: <String, Object?>{'screen': screenName, ...fields},
    );
  }

  void trackStarterSurface(
    String surfaceName, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    if (!_markSignal('surface', surfaceName, fields)) {
      return;
    }
    increment('starter_surface_views');
    log(
      'starter.surface',
      fields: <String, Object?>{'surface': surfaceName, ...fields},
    );
  }

  void increment(String metric, {int by = 1}) {
    _counters[metric] = (_counters[metric] ?? 0) + by;
  }

  void recordDuration(
    String metric,
    Duration duration, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    final accumulator = _durations.putIfAbsent(
      metric,
      _DurationAccumulator.new,
    );
    accumulator.add(duration);
    _record(
      kind: 'metric',
      name: metric,
      stateOrLevel: 'duration',
      attrs: <String, Object?>{
        'duration_ms': duration.inMilliseconds,
        ...fields,
      },
      context: _ensureContext(),
    );
  }

  Map<String, dynamic> snapshot() {
    final context = _ensureContext();
    return <String, dynamic>{
      'runtime_context': <String, dynamic>{
        ...context.toJson(),
        'app_name': _appName,
        'flavor': _flavor,
        'mode': 'local-first',
      },
      'events': List<Map<String, dynamic>>.from(_events),
      'metrics': <String, dynamic>{
        'counters': Map<String, int>.from(_counters),
        'durations': _durations.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      },
    };
  }

  void resetForTest() {
    _runtimeContext = null;
    _events.clear();
    _counters.clear();
    _durations.clear();
    _sessionSignals.clear();
    _flavor = 'unknown';
    _appName = 'unknown';
  }

  bool _markSignal(
    String kind,
    String name,
    Map<String, Object?> fields,
  ) {
    final normalizedFields = _redactionPolicy.sanitizeMap(fields);
    final sortedKeys = normalizedFields.keys.toList()..sort();
    final fieldParts =
        sortedKeys
            .map((key) => '$key=${normalizedFields[key]}')
            .toList(growable: false);
    final signature = <String>[
      kind,
      name,
      ...fieldParts,
    ].join('|');
    return _sessionSignals.add(signature);
  }

  TraceContext _ensureContext() {
    return _runtimeContext ??= TraceContext.root(name: 'runtime');
  }

  void _record({
    required String kind,
    required String name,
    required String stateOrLevel,
    required Map<String, Object?> attrs,
    required TraceContext context,
  }) {
    final event = <String, dynamic>{
      'ts': DateTime.now().toUtc().toIso8601String(),
      'kind': kind,
      'name': name,
      'state_or_level': stateOrLevel,
      'source': 'generated_app',
      ...context.toJson(),
      'attrs': _redactionPolicy.sanitizeMap(attrs),
    };
    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeAt(0);
    }
    if (kDebugMode) {
      debugPrint('[observability] ${jsonEncode(event)}');
    }
  }
}

class _DurationAccumulator {
  void add(Duration duration) {
    _count += 1;
    _totalMs += duration.inMilliseconds;
    if (duration.inMilliseconds > _maxMs) {
      _maxMs = duration.inMilliseconds;
    }
  }

  int _count = 0;
  int _totalMs = 0;
  int _maxMs = 0;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'count': _count,
      'total_ms': _totalMs,
      'max_ms': _maxMs,
      'avg_ms': _count == 0 ? 0 : (_totalMs / _count).round(),
    };
  }
}
