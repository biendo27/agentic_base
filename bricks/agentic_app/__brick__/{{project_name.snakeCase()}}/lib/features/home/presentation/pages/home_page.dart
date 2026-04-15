import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
{{#is_cubit}}
import 'package:flutter_bloc/flutter_bloc.dart';
{{/is_cubit}}
{{#is_mobx}}
import 'package:flutter_mobx/flutter_mobx.dart';
{{/is_mobx}}
{{#is_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
{{#uses_get_it}}
import 'package:{{project_name.snakeCase()}}/core/di/injection.dart';
{{/uses_get_it}}
import 'package:{{project_name.snakeCase()}}/core/extensions/context_extensions.dart';
import 'package:{{project_name.snakeCase()}}/core/router/app_router.gr.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
{{#is_cubit}}
import 'package:{{project_name.snakeCase()}}/features/home/presentation/cubit/home_cubit.dart';
{{/is_cubit}}
import 'package:{{project_name.snakeCase()}}/features/home/presentation/cubit/home_state.dart';
{{#is_riverpod}}
import 'package:{{project_name.snakeCase()}}/features/home/presentation/controller/home_controller.dart';
{{/is_riverpod}}
{{#is_mobx}}
import 'package:{{project_name.snakeCase()}}/features/home/presentation/store/home_store.dart';
{{/is_mobx}}
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/home_item_card.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/runtime_diagnostics_card.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_action_card.dart';

@RoutePage()
{{#is_cubit}}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<HomeCubit>();
        unawaited(cubit.loadItems());
        return cubit;
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => _HomeScaffold(
          state: state,
          onRetry: () => context.read<HomeCubit>().loadItems(),
        ),
      ),
    );
  }
}
{{/is_cubit}}
{{#is_riverpod}}
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(
        () => ref.read(homeControllerProvider.notifier).loadItems(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    return _HomeScaffold(
      state: state,
      onRetry: () => ref.read(homeControllerProvider.notifier).loadItems(),
    );
  }
}
{{/is_riverpod}}
{{#is_mobx}}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt<HomeStore>();
    unawaited(_store.loadItems());
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder:
          (_) => _HomeScaffold(
            state: _store.state.value,
            onRetry: _store.loadItems,
          ),
    );
  }
}
{{/is_mobx}}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold({required this.state, required this.onRetry});

  final HomeState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.app.title)),
      body: switch (state) {
        HomeInitial() => const SizedBox.shrink(),
        HomeLoading() => const Center(child: CircularProgressIndicator()),
        HomeLoaded(:final items) => _StarterDashboard(items: items),
        HomeError(:final message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.t.home.loadError),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(context.t.home.retry),
              ),
            ],
          ),
        ),
      },
    );
  }
}

class _StarterDashboard extends StatelessWidget {
  const _StarterDashboard({required this.items});

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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t.home.headline,
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.t.home.body,
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const RuntimeDiagnosticsCard(),
            const SizedBox(height: 24),
            Text(
              context.t.home.journeyTitle,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final shouldStack = constraints.maxWidth < 720;
                final settingsCard = StarterActionCard(
                  icon: Icons.settings_suggest_outlined,
                  title: context.t.home.actions.settings.title,
                  description: context.t.home.actions.settings.description,
                  onTap: () => context.router.push(
                    const StarterSettingsRoute(),
                  ),
                );
                final monetizationCard = StarterActionCard(
                  icon: Icons.workspace_premium_outlined,
                  title: context.t.home.actions.monetization.title,
                  description: context.t.home.actions.monetization.description,
                  onTap: () => context.router.push(
                    const StarterMonetizationRoute(),
                  ),
                );
                if (shouldStack) {
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
                onTap: () => context.router.push(
                  StarterDetailRoute(itemId: item.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
