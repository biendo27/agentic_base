import 'package:flutter/material.dart';
import 'package:my_app/features/home/domain/entities/home_item.dart';

class HomeItemCard extends StatelessWidget {
  const HomeItemCard({required this.item, super.key});
  final HomeItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          item.description,
          style: theme.textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
