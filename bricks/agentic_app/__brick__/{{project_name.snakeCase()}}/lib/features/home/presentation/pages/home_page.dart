import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/core/di/injection.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/cubit/home_cubit.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/cubit/home_state.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/home_item_card.dart';

@RoutePage()
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
      child: Scaffold(
        appBar: AppBar(title: Text(context.t.app.title)),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder:
              (context, state) => switch (state) {
                HomeInitial() => const SizedBox.shrink(),
                HomeLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                HomeLoaded(:final items) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t.home.headline,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.t.home.body,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t.home.diagnosticsTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.t.home.diagnosticsHint,
                              style: Theme.of(context).textTheme.bodyMedium,
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.t.home.checklistTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...items.map((item) => HomeItemCard(item: item)),
                  ],
                ),
                HomeError(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.t.home.loadError),
                      const SizedBox(height: 8),
                      Text(message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<HomeCubit>().loadItems(),
                        child: Text(context.t.home.retry),
                      ),
                    ],
                  ),
                ),
              },
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
