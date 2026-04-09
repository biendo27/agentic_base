import 'package:flutter/material.dart';
import 'package:my_app/core/router/app_router.dart';
import 'package:my_app/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MaterialApp.router(
      title: 'My App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}
