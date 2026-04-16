import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/radius.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/typography.dart';

WidgetStateProperty<T> _stateSelected<T>(T selected, T unselected) =>
    WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? selected : unselected,
    );

abstract final class AppControlThemes {
  static SwitchThemeData switchTheme(ColorScheme colorScheme) =>
      SwitchThemeData(
        thumbColor: _stateSelected(colorScheme.onPrimary, colorScheme.outline),
        trackColor: _stateSelected(
          colorScheme.primary,
          colorScheme.surfaceContainerHighest,
        ),
      );

  static CheckboxThemeData checkboxTheme(ColorScheme colorScheme) =>
      CheckboxThemeData(
        fillColor: _stateSelected(colorScheme.primary, Colors.transparent),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.checkboxAll),
      );

  static RadioThemeData radioTheme(ColorScheme colorScheme) => RadioThemeData(
    fillColor: _stateSelected(
      colorScheme.primary,
      colorScheme.onSurfaceVariant,
    ),
  );

  static TabBarThemeData tabBarTheme(ColorScheme colorScheme) =>
      TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: colorScheme.outlineVariant,
        labelStyle: AppTypography.textTheme.labelLarge,
        unselectedLabelStyle: AppTypography.textTheme.labelLarge,
      );
}
