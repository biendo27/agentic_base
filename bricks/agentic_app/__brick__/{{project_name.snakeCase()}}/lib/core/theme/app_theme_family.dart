import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/color_schemes.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/component_themes.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/extensions/theme_extensions.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/typography.dart';

typedef ThemeComposer =
    ThemeData Function(
      ThemeData theme,
      ColorScheme colorScheme,
    );

final class AppThemeFamily {
  const AppThemeFamily({
    required this.id,
    required this.lightColorScheme,
    required this.darkColorScheme,
    required this.lightColors,
    required this.darkColors,
    required this.compose,
  });

  final String id;
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final AppColors lightColors;
  final AppColors darkColors;
  final ThemeComposer compose;

  TextTheme get textTheme => AppTypography.textTheme;

  ColorScheme colorSchemeFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkColorScheme : lightColorScheme;
  }

  List<ThemeExtension<dynamic>> extensionsFor(Brightness brightness) {
    return [brightness == Brightness.dark ? darkColors : lightColors];
  }
}

abstract final class AppThemeFamilies {
  static const defaultFamilyId = 'material-default';

  static const AppThemeFamily defaultFamily = AppThemeFamily(
    id: defaultFamilyId,
    lightColorScheme: AppColorSchemes.light,
    darkColorScheme: AppColorSchemes.dark,
    lightColors: AppColors.light,
    darkColors: AppColors.dark,
    compose: AppComponentThemes.apply,
  );

  static const List<AppThemeFamily> all = [defaultFamily];

  static AppThemeFamily resolve(String familyId) {
    for (final family in all) {
      if (family.id == familyId) {
        return family;
      }
    }
    return defaultFamily;
  }
}
