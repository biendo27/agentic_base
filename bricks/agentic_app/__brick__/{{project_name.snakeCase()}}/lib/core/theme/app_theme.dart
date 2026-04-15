import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/color_schemes.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/component_themes.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/extensions/theme_extensions.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/typography.dart';

abstract class AppTheme {
  static ThemeData get light =>
      _buildTheme(AppColorSchemes.light, AppColors.light);

  static ThemeData get dark =>
      _buildTheme(AppColorSchemes.dark, AppColors.dark);

  static ThemeData _buildTheme(ColorScheme colorScheme, AppColors colors) {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final baseTheme = ThemeData.from(
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [colors],
      appBarTheme: AppComponentThemes.appBarTheme(colorScheme),
      cardTheme: AppComponentThemes.cardTheme(colorScheme),
      elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: AppComponentThemes.outlinedButtonTheme(colorScheme),
      textButtonTheme: AppComponentThemes.textButtonTheme(colorScheme),
      inputDecorationTheme: AppComponentThemes.inputDecorationTheme(
        colorScheme,
      ),
      chipTheme: AppComponentThemes.chipTheme(colorScheme),
      dialogTheme: AppComponentThemes.dialogTheme,
      bottomNavigationBarTheme: AppComponentThemes.bottomNavTheme(colorScheme),
      navigationBarTheme: AppComponentThemes.navigationBarTheme(colorScheme),
      floatingActionButtonTheme: AppComponentThemes.fabTheme(colorScheme),
      snackBarTheme: AppComponentThemes.snackBarTheme(colorScheme),
      dividerTheme: AppComponentThemes.dividerTheme(colorScheme),
      bottomSheetTheme: AppComponentThemes.bottomSheetTheme,
      listTileTheme: AppComponentThemes.listTileTheme,
      switchTheme: AppComponentThemes.switchTheme(colorScheme),
      checkboxTheme: AppComponentThemes.checkboxTheme(colorScheme),
      radioTheme: AppComponentThemes.radioTheme(colorScheme),
      tabBarTheme: AppComponentThemes.tabBarTheme(colorScheme),
    );
  }
}
