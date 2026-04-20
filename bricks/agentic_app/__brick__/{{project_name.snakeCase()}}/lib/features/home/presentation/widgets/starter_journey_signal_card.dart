import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/starter/starter_runtime_profile.dart';

class StarterJourneySignalCard extends StatelessWidget {
  const StarterJourneySignalCard({
    required this.headline,
    required this.body,
    required this.journalBody,
    super.key,
  });

  final String headline;
  final String body;
  final String journalBody;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(StarterRuntimeProfile.primaryProfileLabel)),
                Chip(label: Text(StarterRuntimeProfile.supportTierLabel)),
                Chip(
                  avatar: const Icon(Icons.verified_outlined, size: 18),
                  label: Text(StarterRuntimeProfile.requiredGatePack),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              headline,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              journalBody,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
