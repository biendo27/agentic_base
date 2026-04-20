import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';

class RuntimeDiagnosticsCard extends StatelessWidget {
  const RuntimeDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final observability = ObservabilityService.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t.home.diagnosticsTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.t.home.diagnosticsHint,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _RuntimeRow(
              label: context.t.home.appNameLabel,
              value: FlavorConfig.instance.appName,
            ),
            _RuntimeRow(
              label: context.t.home.flavorLabel,
              value: FlavorConfig.instance.flavor.name,
            ),
            _RuntimeRow(
              label: context.t.home.apiBaseUrlLabel,
              value: FlavorConfig.instance.apiBaseUrl,
            ),
            _RuntimeRow(
              label: 'Observability mode',
              value: 'Local-first runtime telemetry',
            ),
            _RuntimeRow(
              label: 'Run correlation',
              value: observability.runId,
            ),
            _RuntimeRow(
              label: 'Buffered telemetry events',
              value: '${observability.bufferedEventCount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _RuntimeRow extends StatelessWidget {
  const _RuntimeRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
