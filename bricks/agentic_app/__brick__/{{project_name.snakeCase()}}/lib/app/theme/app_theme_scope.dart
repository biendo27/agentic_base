import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/app/theme/app_theme_controller.dart';

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope is not available in this context.');
    return scope!.notifier!;
  }
}
