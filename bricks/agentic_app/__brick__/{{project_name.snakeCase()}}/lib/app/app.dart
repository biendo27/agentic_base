import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/core/router/app_router.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return TranslationProvider(
      child: Builder(
        builder:
            (context) => MaterialApp.router(
              title: FlavorConfig.instance.appName,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              routerConfig: appRouter.config(),
              debugShowCheckedModeBanner: false,
            ),
      ),
    );
  }
}
