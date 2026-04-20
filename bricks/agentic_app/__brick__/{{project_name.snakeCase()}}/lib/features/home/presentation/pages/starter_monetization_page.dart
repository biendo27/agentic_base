import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
{{#is_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
{{^is_riverpod}}
import 'package:{{project_name.snakeCase()}}/core/di/injection.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/core/extensions/context_extensions.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_paywall_snapshot.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/usecases/get_starter_paywall.dart';
{{#is_riverpod}}
import 'package:{{project_name.snakeCase()}}/features/home/presentation/controller/starter_monetization_controller.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_monetization_overview_card.dart';

@RoutePage()
{{#is_riverpod}}
class StarterMonetizationPage extends ConsumerWidget {
  const StarterMonetizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ObservabilityService.instance.trackScreenView('starter_monetization');
    final monetization = context.t.home.monetization;
    final snapshot = ref.watch(starterPaywallProvider);
    return Scaffold(
      appBar: AppBar(title: Text(monetization.title)),
      body: snapshot.when(
        data: (value) => _StarterPaywallView(snapshot: value),
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
{{/is_riverpod}}
{{^is_riverpod}}
class StarterMonetizationPage extends StatefulWidget {
  const StarterMonetizationPage({super.key});

  @override
  State<StarterMonetizationPage> createState() => _StarterMonetizationPageState();
}

class _StarterMonetizationPageState extends State<StarterMonetizationPage> {
  late final Future<StarterPaywallSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = getIt<GetStarterPaywall>()();
  }

  @override
  Widget build(BuildContext context) {
    ObservabilityService.instance.trackScreenView('starter_monetization');
    final monetization = context.t.home.monetization;
    return Scaffold(
      appBar: AppBar(title: Text(monetization.title)),
      body: FutureBuilder<StarterPaywallSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return _StarterPaywallView(snapshot: snapshot.requireData);
        },
      ),
    );
  }
}
{{/is_riverpod}}

class _StarterPaywallView extends StatelessWidget {
  const _StarterPaywallView({required this.snapshot});

  final StarterPaywallSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    ObservabilityService.instance.trackStarterSurface(
      'starter_paywall',
      fields: <String, Object?>{
        'offers': snapshot.offers.length,
        'entitlement_active': snapshot.currentEntitlement.isActive,
      },
    );
    final monetization = context.t.home.monetization;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.adaptiveContentMaxWidth),
        child: ListView(
          padding: context.adaptivePagePadding,
          children: [
            StarterMonetizationOverviewCard(
              snapshot: snapshot,
              subtitle: monetization.subtitle,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(snapshot.currentEntitlement.name),
                subtitle: Text(snapshot.currentEntitlement.description),
                trailing: Chip(
                  label: Text(
                    snapshot.currentEntitlement.isActive
                        ? monetization.activeStatus
                        : monetization.inactiveStatus,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              monetization.availablePlansTitle,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...snapshot.offers.map(
              (offer) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(offer.title),
                  subtitle: Text('${offer.priceLabel} - ${offer.billingLabel}'),
                  trailing: Text(
                    offer.highlight,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(snapshot.supportNote, style: context.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
