import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/component_themes/buttons.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/component_themes/controls.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/component_themes/surfaces.dart';

abstract final class AppComponentThemes {
  static ThemeData apply(ThemeData theme, ColorScheme colorScheme) {
    return theme.copyWith(
      appBarTheme: AppSurfaceThemes.appBarTheme(colorScheme),
      cardTheme: AppSurfaceThemes.cardTheme(colorScheme),
      elevatedButtonTheme: AppButtonThemes.elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: AppButtonThemes.outlinedButtonTheme(colorScheme),
      textButtonTheme: AppButtonThemes.textButtonTheme(colorScheme),
      inputDecorationTheme: AppSurfaceThemes.inputDecorationTheme(colorScheme),
      chipTheme: AppSurfaceThemes.chipTheme(colorScheme),
      dialogTheme: AppSurfaceThemes.dialogTheme,
      bottomNavigationBarTheme: AppSurfaceThemes.bottomNavTheme(colorScheme),
      navigationBarTheme: AppSurfaceThemes.navigationBarTheme(colorScheme),
      floatingActionButtonTheme: AppSurfaceThemes.fabTheme(colorScheme),
      snackBarTheme: AppSurfaceThemes.snackBarTheme(colorScheme),
      dividerTheme: AppSurfaceThemes.dividerTheme(colorScheme),
      bottomSheetTheme: AppSurfaceThemes.bottomSheetTheme,
      listTileTheme: AppSurfaceThemes.listTileTheme,
      switchTheme: AppControlThemes.switchTheme(colorScheme),
      checkboxTheme: AppControlThemes.checkboxTheme(colorScheme),
      radioTheme: AppControlThemes.radioTheme(colorScheme),
      tabBarTheme: AppControlThemes.tabBarTheme(colorScheme),
    );
  }
}
