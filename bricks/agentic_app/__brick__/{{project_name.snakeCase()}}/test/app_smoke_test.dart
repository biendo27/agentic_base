@Tags(<String>['app-smoke'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/app/app.dart';
import 'package:{{project_name.snakeCase()}}/app/bootstrap.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';

void main() {
  testWidgets('boots the generated app shell', (tester) async {
    FlavorConfig.init(Flavor.dev);
    ObservabilityService.instance.resetForTest();

    await bootstrap(() => const App(), initializeModules: false);
    await tester.pump();
    // The starter shell can keep short-lived progress indicators or route
    // transitions alive while bootstrap and home loading finish. For smoke
    // coverage we only need the app shell to become visible, not globally idle.
    for (var attempt = 0; attempt < 8; attempt++) {
      if (find.byType(Scaffold).evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    final settingsAction = find.byIcon(Icons.settings_suggest_outlined);
    if (settingsAction.evaluate().isNotEmpty) {
      await tester.tap(settingsAction.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    _writeObservabilitySnapshot();
  });
}

void _writeObservabilitySnapshot() {
  final contextPath =
      Platform.environment['AGENTIC_RUNTIME_TELEMETRY_CONTEXT_FILE'];
  final eventsPath =
      Platform.environment['AGENTIC_RUNTIME_TELEMETRY_EVENTS_FILE'];
  final metricsPath =
      Platform.environment['AGENTIC_RUNTIME_TELEMETRY_METRICS_FILE'];
  if (contextPath == null || eventsPath == null || metricsPath == null) {
    return;
  }

  final snapshot = ObservabilityService.instance.snapshot();
  final contextFile = File(contextPath)..parent.createSync(recursive: true);
  final eventsFile = File(eventsPath)..parent.createSync(recursive: true);
  final metricsFile = File(metricsPath)..parent.createSync(recursive: true);

  contextFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(snapshot['runtime_context']),
  );
  final existingEvents =
      eventsFile.existsSync() ? eventsFile.readAsLinesSync() : const <String>[];
  final runtimeEvents = (snapshot['events'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(jsonEncode)
      .toList(growable: false);
  final mergedEvents = <String>[
    ...existingEvents.where((line) => line.trim().isNotEmpty),
    ...runtimeEvents,
  ];
  eventsFile.writeAsStringSync(
    mergedEvents.isEmpty ? '' : '${mergedEvents.join('\n')}\n',
  );
  metricsFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(snapshot['metrics']),
  );
}
