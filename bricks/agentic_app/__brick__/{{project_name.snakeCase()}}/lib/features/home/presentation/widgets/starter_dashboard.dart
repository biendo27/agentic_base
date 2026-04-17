import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/core/extensions/context_extensions.dart';
import 'package:{{project_name.snakeCase()}}/core/router/app_router.gr.dart';
import 'package:{{project_name.snakeCase()}}/core/starter/starter_runtime_profile.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/home_item_card.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/runtime_diagnostics_card.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_action_card.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_journey_signal_card.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_signal_card.dart';

class StarterDashboard extends StatelessWidget {
  const StarterDashboard({required this.items, super.key});

  final List<HomeItem> items;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.adaptiveContentMaxWidth),
        child: ListView(
          padding: context.adaptivePagePadding,
          children: [
            StarterJourneySignalCard(
              headline: context.t.home.headline,
              body: context.t.home.body,
              journalBody: context.t.home.journalBody,
            ),
            const SizedBox(height: 16),
            const RuntimeDiagnosticsCard(),
            if (_signalCards.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Golden-path signals',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _SignalGrid(cards: _signalCards),
            ],
            const SizedBox(height: 24),
            Text(
              context.t.home.journeyTitle,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _ActionGrid(
              settingsCard: StarterActionCard(
                icon: Icons.settings_suggest_outlined,
                title: context.t.home.actions.settings.title,
                description: context.t.home.actions.settings.description,
                onTap: () => context.router.push(const StarterSettingsRoute()),
              ),
              monetizationCard: StarterActionCard(
                icon: Icons.workspace_premium_outlined,
                title: context.t.home.actions.monetization.title,
                description: context.t.home.actions.monetization.description,
                onTap:
                    StarterRuntimeProfile.commerceEnabled
                        ? () => context.router.push(
                          const StarterMonetizationRoute(),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.t.home.checklistTitle,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => HomeItemCard(
                item: item,
                onTap:
                    () => context.router.push(
                      StarterDetailRoute(itemId: item.id),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<StarterSignalCard> get _signalCards => [
    if (StarterRuntimeProfile.commerceEnabled)
      const StarterSignalCard(
        icon: Icons.subscriptions_outlined,
        title: 'Commerce and entitlements',
        description:
            'Store-native billing, entitlement seams, and safe starter offers stay visible without pretending live store configuration already exists.',
        badge: 'Golden path',
      ),
    if (StarterRuntimeProfile.configEnabled)
      const StarterSignalCard(
        icon: Icons.tune_outlined,
        title: 'Config and rollout controls',
        description:
            'Remote config and feature flags are surfaced as generated seams so rollout policy is visible on day 0.',
      ),
    if (StarterRuntimeProfile.consentEnabled || StarterRuntimeProfile.adsEnabled)
      const StarterSignalCard(
        icon: Icons.privacy_tip_outlined,
        title: 'Consent and ads safety',
        description:
            'Ads can be generated in the lane, but they stay inactive until consent and configuration say the path is safe.',
      ),
    if (StarterRuntimeProfile.lifecycleEnabled)
      const StarterSignalCard(
        icon: Icons.auto_awesome_motion_outlined,
        title: 'Lifecycle and retention hooks',
        description:
            'Notifications, deep links, in-app review, and app update stay replaceable without rewriting the starter shell.',
      ),
  ];
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.settingsCard,
    required this.monetizationCard,
  });

  final Widget settingsCard;
  final Widget monetizationCard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              settingsCard,
              const SizedBox(height: 12),
              monetizationCard,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: settingsCard),
            const SizedBox(width: 12),
            Expanded(child: monetizationCard),
          ],
        );
      },
    );
  }
}

class _SignalGrid extends StatelessWidget {
  const _SignalGrid({required this.cards});

  final List<StarterSignalCard> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                cards[index],
              ],
            ],
          );
        }
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              cards
                  .map(
                    (card) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: card,
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
