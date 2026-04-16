import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/app_theme_family.dart';

abstract class AppTheme {
  static ThemeData light({
    String familyId = AppThemeFamilies.defaultFamilyId,
  }) => _buildTheme(familyId: familyId, brightness: Brightness.light);

  static ThemeData dark({
    String familyId = AppThemeFamilies.defaultFamilyId,
  }) => _buildTheme(familyId: familyId, brightness: Brightness.dark);

  static ThemeData _buildTheme({
    required String familyId,
    required Brightness brightness,
  }) {
    final family = AppThemeFamilies.resolve(familyId);
    final colorScheme = family.colorSchemeFor(brightness);
    final textTheme = family.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final baseTheme = ThemeData.from(
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
    ).copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: family.extensionsFor(brightness),
    );

    return family.compose(baseTheme, colorScheme);
  }
}
