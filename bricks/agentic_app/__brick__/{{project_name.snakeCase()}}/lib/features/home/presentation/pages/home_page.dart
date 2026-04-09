import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        appBar: AppBar(title: const Text('{{project_name.titleCase()}}')),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => switch (state) {
            HomeInitial() => const SizedBox.shrink(),
            HomeLoading() => const Center(child: CircularProgressIndicator()),
            HomeLoaded(:final items) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    HomeItemCard(item: items[index]),
              ),
            HomeError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<HomeCubit>().loadItems(),
                      child: const Text('Retry'),
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
