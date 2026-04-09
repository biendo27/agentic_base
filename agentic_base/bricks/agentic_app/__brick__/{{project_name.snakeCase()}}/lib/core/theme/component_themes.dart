import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/radius.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/spacing.dart';

// ── Private helpers ───────────────────────────────────────────────────────────

WidgetStateProperty<T> _stateSelected<T>(T selected, T unselected) =>
    WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? selected : unselected,
    );

// ── Component themes ──────────────────────────────────────────────────────────

abstract class AppComponentThemes {
  static AppBarTheme appBarTheme(ColorScheme cs) => AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
      );

  static CardThemeData get cardTheme => CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        margin: const EdgeInsets.all(AppSpacing.xs),
      );

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
          elevation: 0,
        ),
      );

  static OutlinedButtonThemeData outlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
          side: BorderSide(color: cs.outline),
        ),
      );

  static TextButtonThemeData textButtonTheme(ColorScheme cs) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        ),
      );

  static InputDecorationTheme inputDecorationTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      );

  static ChipThemeData chipTheme(ColorScheme cs) => ChipThemeData(
        backgroundColor: cs.surfaceContainerLow,
        selectedColor: cs.secondaryContainer,
        labelStyle: TextStyle(color: cs.onSurface, fontSize: 14),
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      );

  static DialogThemeData get dialogTheme => DialogThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      );

  static BottomNavigationBarThemeData bottomNavTheme(ColorScheme cs) =>
      BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      );

  static NavigationBarThemeData navigationBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.secondaryContainer,
        elevation: 0,
        iconTheme: _stateSelected(
          IconThemeData(color: cs.onSecondaryContainer),
          IconThemeData(color: cs.onSurfaceVariant),
        ),
        labelTextStyle: _stateSelected(
          TextStyle(
            color: cs.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
        ),
      );

  static FloatingActionButtonThemeData fabTheme(ColorScheme cs) =>
      FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      );

  static SnackBarThemeData snackBarTheme(ColorScheme cs) => SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
        actionTextColor: cs.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      );

  static DividerThemeData dividerTheme(ColorScheme cs) =>
      DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1);

  static BottomSheetThemeData get bottomSheetTheme =>
      const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        showDragHandle: true,
        elevation: 1,
      );

  static ListTileThemeData get listTileTheme => const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minVerticalPadding: AppSpacing.sm,
      );

  static SwitchThemeData switchTheme(ColorScheme cs) => SwitchThemeData(
        thumbColor: _stateSelected(cs.onPrimary, cs.outline),
        trackColor: _stateSelected(cs.primary, cs.surfaceContainerHighest),
      );

  static CheckboxThemeData checkboxTheme(ColorScheme cs) => CheckboxThemeData(
        fillColor: _stateSelected(cs.primary, Colors.transparent),
        checkColor: WidgetStateProperty.all(cs.onPrimary),
        side: BorderSide(color: cs.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      );

  static RadioThemeData radioTheme(ColorScheme cs) => RadioThemeData(
        fillColor: _stateSelected(cs.primary, cs.onSurfaceVariant),
      );

  static TabBarThemeData tabBarTheme(ColorScheme cs) => TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: cs.outlineVariant,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
      );
}
