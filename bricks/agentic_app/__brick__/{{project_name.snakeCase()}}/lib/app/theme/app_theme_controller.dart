import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/app_theme_family.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController({
    ThemeMode initialThemeMode = ThemeMode.system,
    String initialThemeFamilyId = AppThemeFamilies.defaultFamilyId,
  }) : _themeMode = initialThemeMode,
       _themeFamilyId = AppThemeFamilies.resolve(initialThemeFamilyId).id;

  ThemeMode _themeMode;
  String _themeFamilyId;

  ThemeMode get themeMode => _themeMode;
  String get themeFamilyId => _themeFamilyId;

  bool get usesSystemTheme => _themeMode == ThemeMode.system;
  bool get usesDefaultFamily =>
      _themeFamilyId == AppThemeFamilies.defaultFamilyId;

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) {
      return;
    }
    _themeMode = value;
    notifyListeners();
  }

  void setThemeFamily(String value) {
    final resolvedFamilyId = AppThemeFamilies.resolve(value).id;
    if (_themeFamilyId == resolvedFamilyId) {
      return;
    }
    _themeFamilyId = resolvedFamilyId;
    notifyListeners();
  }
}
