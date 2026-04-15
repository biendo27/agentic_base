import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/app/locale/app_locale_contract.dart';
import 'package:{{project_name.snakeCase()}}/app/theme/app_theme_scope.dart';
import 'package:{{project_name.snakeCase()}}/core/extensions/context_extensions.dart';

@RoutePage()
class StarterSettingsPage extends StatelessWidget {
  const StarterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = AppThemeScope.of(context);
    final settings = context.t.home.settings;
    return Scaffold(
      appBar: AppBar(title: Text(settings.title)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.adaptiveContentMaxWidth,
          ),
          child: ListView(
            padding: context.adaptivePagePadding,
            children: [
              Text(settings.subtitle, style: context.textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(
                settings.themeModeTitle,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text(settings.themeModeSystem),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text(settings.themeModeLight),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text(settings.themeModeDark),
                  ),
                ],
                selected: <ThemeMode>{themeController.themeMode},
                onSelectionChanged: (selection) {
                  themeController.setThemeMode(selection.first);
                },
              ),
              const SizedBox(height: 24),
              Text(settings.localeTitle, style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: AppLocaleContract.useDeviceLocale,
                child: Text(settings.localeSystem),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonal(
                    onPressed: () => AppLocaleContract.setLocale(AppLocale.en),
                    child: Text(settings.localeEnglish),
                  ),
                  FilledButton.tonal(
                    onPressed: () => AppLocaleContract.setLocale(AppLocale.vi),
                    child: Text(settings.localeVietnamese),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
