import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/core/extensions/context_extensions.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';

@RoutePage()
class StarterDetailPage extends StatelessWidget {
  const StarterDetailPage({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    ObservabilityService.instance.trackScreenView(
      'starter_detail',
      fields: <String, Object?>{'item_id': itemId},
    );
    final detail = _resolveDetail(context);
    return Scaffold(
      appBar: AppBar(title: Text(detail.title)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.adaptiveContentMaxWidth,
          ),
          child: ListView(
            padding: context.adaptivePagePadding,
            children: [
              Text(detail.title, style: context.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(detail.body, style: context.textTheme.bodyLarge),
              const SizedBox(height: 24),
              ...detail.highlights.map(
                (highlight) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(highlight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StarterDetail _resolveDetail(BuildContext context) {
    final details = context.t.home.details;
    return switch (itemId) {
      'ownership' => _StarterDetail(
        title: details.ownership.title,
        body: details.ownership.body,
        highlights: details.ownership.highlights,
      ),
      'localization' => _StarterDetail(
        title: details.localization.title,
        body: details.localization.body,
        highlights: details.localization.highlights,
      ),
      _ => _StarterDetail(
        title: details.flavors.title,
        body: details.flavors.body,
        highlights: details.flavors.highlights,
      ),
    };
  }
}

class _StarterDetail {
  const _StarterDetail({
    required this.title,
    required this.body,
    required this.highlights,
  });

  final String title;
  final String body;
  final List<String> highlights;
}
