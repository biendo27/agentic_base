import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/starter/starter_runtime_profile.dart';

class StarterSettingsPreviewCard extends StatelessWidget {
  const StarterSettingsPreviewCard({
    required this.subtitle,
    super.key,
  });

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: const Icon(Icons.tune_outlined),
        title: Text(
          'Trustworthy starter defaults',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$subtitle ${StarterRuntimeProfile.primaryProfileLabel} keeps theme and locale previews honest before product preferences exist.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
