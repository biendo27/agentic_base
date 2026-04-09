import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/router/app_router.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MaterialApp.router(
      title: '{{project_name.titleCase()}}',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}
