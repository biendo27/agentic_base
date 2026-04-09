import 'package:flutter/material.dart';
import 'package:my_app/core/theme/color_schemes.dart';
import 'package:my_app/core/theme/component_themes.dart';
import 'package:my_app/core/theme/extensions/theme_extensions.dart';
import 'package:my_app/core/theme/typography.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColorSchemes.light,
        textTheme: AppTypography.textTheme,
        extensions: const [AppColors.light],
        appBarTheme: AppComponentThemes.appBarTheme(AppColorSchemes.light),
        cardTheme: AppComponentThemes.cardTheme,
        elevatedButtonTheme:
            AppComponentThemes.elevatedButtonTheme(AppColorSchemes.light),
        outlinedButtonTheme:
            AppComponentThemes.outlinedButtonTheme(AppColorSchemes.light),
        textButtonTheme:
            AppComponentThemes.textButtonTheme(AppColorSchemes.light),
        inputDecorationTheme:
            AppComponentThemes.inputDecorationTheme(AppColorSchemes.light),
        chipTheme: AppComponentThemes.chipTheme(AppColorSchemes.light),
        dialogTheme: AppComponentThemes.dialogTheme,
        bottomNavigationBarTheme:
            AppComponentThemes.bottomNavTheme(AppColorSchemes.light),
        navigationBarTheme:
            AppComponentThemes.navigationBarTheme(AppColorSchemes.light),
        floatingActionButtonTheme:
            AppComponentThemes.fabTheme(AppColorSchemes.light),
        snackBarTheme:
            AppComponentThemes.snackBarTheme(AppColorSchemes.light),
        dividerTheme:
            AppComponentThemes.dividerTheme(AppColorSchemes.light),
        bottomSheetTheme: AppComponentThemes.bottomSheetTheme,
        listTileTheme: AppComponentThemes.listTileTheme,
        switchTheme: AppComponentThemes.switchTheme(AppColorSchemes.light),
        checkboxTheme:
            AppComponentThemes.checkboxTheme(AppColorSchemes.light),
        radioTheme: AppComponentThemes.radioTheme(AppColorSchemes.light),
        tabBarTheme: AppComponentThemes.tabBarTheme(AppColorSchemes.light),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: AppColorSchemes.dark,
        textTheme: AppTypography.textTheme,
        extensions: const [AppColors.dark],
        appBarTheme: AppComponentThemes.appBarTheme(AppColorSchemes.dark),
        cardTheme: AppComponentThemes.cardTheme,
        elevatedButtonTheme:
            AppComponentThemes.elevatedButtonTheme(AppColorSchemes.dark),
        outlinedButtonTheme:
            AppComponentThemes.outlinedButtonTheme(AppColorSchemes.dark),
        textButtonTheme:
            AppComponentThemes.textButtonTheme(AppColorSchemes.dark),
        inputDecorationTheme:
            AppComponentThemes.inputDecorationTheme(AppColorSchemes.dark),
        chipTheme: AppComponentThemes.chipTheme(AppColorSchemes.dark),
        dialogTheme: AppComponentThemes.dialogTheme,
        bottomNavigationBarTheme:
            AppComponentThemes.bottomNavTheme(AppColorSchemes.dark),
        navigationBarTheme:
            AppComponentThemes.navigationBarTheme(AppColorSchemes.dark),
        floatingActionButtonTheme:
            AppComponentThemes.fabTheme(AppColorSchemes.dark),
        snackBarTheme:
            AppComponentThemes.snackBarTheme(AppColorSchemes.dark),
        dividerTheme:
            AppComponentThemes.dividerTheme(AppColorSchemes.dark),
        bottomSheetTheme: AppComponentThemes.bottomSheetTheme,
        listTileTheme: AppComponentThemes.listTileTheme,
        switchTheme: AppComponentThemes.switchTheme(AppColorSchemes.dark),
        checkboxTheme:
            AppComponentThemes.checkboxTheme(AppColorSchemes.dark),
        radioTheme: AppComponentThemes.radioTheme(AppColorSchemes.dark),
        tabBarTheme: AppComponentThemes.tabBarTheme(AppColorSchemes.dark),
      );
}
