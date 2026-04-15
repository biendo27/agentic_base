import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/extensions/theme_extensions.dart';
import 'package:{{project_name.snakeCase()}}/core/theme/spacing.dart';

const _compactWidthBreakpoint = 600.0;
const _expandedWidthBreakpoint = 840.0;

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  AppColors get appColors =>
      theme.extension<AppColors>() ??
      (isDark ? AppColors.dark : AppColors.light);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isCompactWidth => screenWidth < _compactWidthBreakpoint;
  bool get isMediumWidth =>
      screenWidth >= _compactWidthBreakpoint &&
      screenWidth < _expandedWidthBreakpoint;
  bool get isExpandedWidth => screenWidth >= _expandedWidthBreakpoint;
  double get adaptiveHorizontalPadding => switch (screenWidth) {
    < _compactWidthBreakpoint => AppSpacing.md,
    < _expandedWidthBreakpoint => AppSpacing.lg,
    _ => AppSpacing.xl,
  };
  EdgeInsets get adaptivePagePadding => EdgeInsets.symmetric(
    horizontal: adaptiveHorizontalPadding,
    vertical: AppSpacing.lg,
  );
  double get adaptiveContentMaxWidth => isExpandedWidth ? 960 : double.infinity;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
