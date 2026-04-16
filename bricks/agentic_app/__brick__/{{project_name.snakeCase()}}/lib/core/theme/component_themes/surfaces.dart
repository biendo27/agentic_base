import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/radius.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/spacing.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/typography.dart';

WidgetStateProperty<T> _stateSelected<T>(T selected, T unselected) =>
    WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? selected : unselected,
    );

abstract final class AppSurfaceThemes {
  static AppBarTheme appBarTheme(ColorScheme colorScheme) => AppBarTheme(
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
      color: colorScheme.onSurface,
    ),
  );

  static CardThemeData cardTheme(ColorScheme colorScheme) => CardThemeData(
    elevation: 1,
    margin: EdgeInsets.zero,
    surfaceTintColor: colorScheme.surfaceTint,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
  );

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.fieldPaddingComfortable,
        ),
      );

  static ChipThemeData chipTheme(ColorScheme colorScheme) => ChipThemeData(
    backgroundColor: colorScheme.surfaceContainerLow,
    selectedColor: colorScheme.secondaryContainer,
    labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 14),
    side: BorderSide(color: colorScheme.outlineVariant),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipAll),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
  );

  static DialogThemeData get dialogTheme => DialogThemeData(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
  );

  static BottomNavigationBarThemeData bottomNavTheme(ColorScheme colorScheme) =>
      BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      );

  static NavigationBarThemeData navigationBarTheme(ColorScheme colorScheme) =>
      NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: 0,
        iconTheme: _stateSelected(
          IconThemeData(color: colorScheme.onSecondaryContainer),
          IconThemeData(color: colorScheme.onSurfaceVariant),
        ),
        labelTextStyle: _stateSelected(
          TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      );

  static FloatingActionButtonThemeData fabTheme(ColorScheme colorScheme) =>
      FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
      );

  static SnackBarThemeData snackBarTheme(ColorScheme colorScheme) =>
      SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      );

  static DividerThemeData dividerTheme(ColorScheme colorScheme) =>
      DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      );

  static BottomSheetThemeData get bottomSheetTheme =>
      const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
        ),
        showDragHandle: true,
        elevation: 1,
      );

  static ListTileThemeData get listTileTheme => const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
    minVerticalPadding: AppSpacing.sm,
  );
}
