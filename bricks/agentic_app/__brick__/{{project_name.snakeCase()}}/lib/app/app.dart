import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/app/locale/app_locale_contract.dart';
import 'package:{{project_name.snakeCase()}}/app/theme/app_theme_controller.dart';
import 'package:{{project_name.snakeCase()}}/app/theme/app_theme_scope.dart';
import 'package:{{project_name.snakeCase()}}/core/router/app_router.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _appRouter;
  late final AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    _themeController = AppThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      notifier: _themeController,
      child: TranslationProvider(
        child: AnimatedBuilder(
          animation: _themeController,
          builder:
              (context, _) => Builder(
                builder:
                    (context) => MaterialApp.router(
                      title: FlavorConfig.instance.appName,
                      locale: TranslationProvider.of(context).flutterLocale,
                      supportedLocales:
                          AppLocaleContract.supportedFlutterLocales,
                      localizationsDelegates:
                          GlobalMaterialLocalizations.delegates,
                      theme: AppTheme.light,
                      darkTheme: AppTheme.dark,
                      themeMode: _themeController.themeMode,
                      routerConfig: _appRouter.config(),
                      debugShowCheckedModeBanner: false,
                    ),
              ),
        ),
      ),
    );
  }
}
