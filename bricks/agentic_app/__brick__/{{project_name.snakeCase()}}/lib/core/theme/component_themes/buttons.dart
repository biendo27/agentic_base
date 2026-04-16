import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/radius.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/spacing.dart';

ButtonStyle _buttonStyle({
  Color? backgroundColor,
  Color? foregroundColor,
  BorderSide? side,
}) => ButtonStyle(
  backgroundColor:
      backgroundColor == null ? null : WidgetStatePropertyAll(backgroundColor),
  foregroundColor:
      foregroundColor == null ? null : WidgetStatePropertyAll(foregroundColor),
  minimumSize: const WidgetStatePropertyAll(
    Size(64, AppSpacing.controlHeightSm),
  ),
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
  ),
  side: side == null ? null : WidgetStatePropertyAll(side),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
  ),
  elevation: const WidgetStatePropertyAll(0),
);

abstract final class AppButtonThemes {
  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) =>
      ElevatedButtonThemeData(
        style: _buttonStyle(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      );

  static OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) =>
      OutlinedButtonThemeData(
        style: _buttonStyle(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
        ),
      );

  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) =>
      TextButtonThemeData(
        style: _buttonStyle(foregroundColor: colorScheme.primary),
      );
}
