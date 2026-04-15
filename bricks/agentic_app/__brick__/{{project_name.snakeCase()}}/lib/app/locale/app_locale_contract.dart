import 'package:flutter/widgets.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';

final class AppSupportedLocale {
  const AppSupportedLocale({
    required this.appLocale,
    required this.displayName,
  });

  final AppLocale appLocale;
  final String displayName;

  Locale get flutterLocale => appLocale.flutterLocale;
  String get languageTag => flutterLocale.toLanguageTag();
}

final class AppLocaleContract {
  const AppLocaleContract._();

  static const AppLocale fallbackLocale = AppLocale.en;

  static List<AppSupportedLocale> get supported => AppLocale.values
      .map(_toSupportedLocale)
      .toList(growable: false);

  static List<Locale> get supportedFlutterLocales =>
      AppLocaleUtils.supportedLocales;

  static List<String> get supportedLanguageTags =>
      AppLocaleUtils.supportedLocalesRaw;

  static AppLocale resolve(Locale locale) {
    return AppLocaleUtils.parseLocaleParts(
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode,
      countryCode: locale.countryCode,
    );
  }

  static bool supports(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    return supported.any(
      (supportedLocale) =>
          supportedLocale.flutterLocale.languageCode.toLowerCase() ==
          languageCode,
    );
  }

  static Future<AppLocale> useDeviceLocale() => LocaleSettings.useDeviceLocale();

  static Future<void> setLocale(AppLocale locale) =>
      LocaleSettings.setLocale(locale);

  static AppSupportedLocale _toSupportedLocale(AppLocale locale) {
    if (locale == AppLocale.en) {
      return const AppSupportedLocale(
        appLocale: AppLocale.en,
        displayName: 'English',
      );
    }
    if (locale == AppLocale.vi) {
      return const AppSupportedLocale(
        appLocale: AppLocale.vi,
        displayName: 'Tieng Viet',
      );
    }
    return AppSupportedLocale(
      appLocale: locale,
      displayName: locale.flutterLocale.toLanguageTag(),
    );
  }
}
