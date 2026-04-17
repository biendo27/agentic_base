import 'package:flutter/material.dart';

class StarterSignalCard extends StatelessWidget {
  const StarterSignalCard({
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyMedium),
            if (badge != null) ...[
              const SizedBox(height: 16),
              Chip(label: Text(badge!)),
            ],
          ],
        ),
      ),
    );
  }
}
