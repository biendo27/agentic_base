import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';

class HomeItemCard extends StatelessWidget {
  const HomeItemCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final HomeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = switch (item.id) {
      'ownership' => (
        context.t.home.cards.ownership.title,
        context.t.home.cards.ownership.description,
        Icons.account_tree_outlined,
      ),
      'localization' => (
        context.t.home.cards.localization.title,
        context.t.home.cards.localization.description,
        Icons.translate_outlined,
      ),
      _ => (
        context.t.home.cards.flavors.title,
        context.t.home.cards.flavors.description,
        Icons.tune_outlined,
      ),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(details.$3),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(details.$1, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(details.$2, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
