# Theming Guide

## Technology: Material 3

The app uses Material 3 with a custom color scheme and typography.
Theme is defined in `lib/core/theme/`.

## File Structure

```
lib/core/theme/
├── app_theme.dart          # ThemeData assembly (light + dark)
├── color_schemes.dart      # ColorScheme for light and dark
├── component_themes.dart   # Per-component overrides
├── typography.dart         # TextTheme with custom fonts
├── spacing.dart            # AppSpacing constants
├── radius.dart             # AppRadius constants
└── extensions/
    └── theme_extensions.dart  # Custom ThemeExtension
```

## Color Scheme

Colors are defined as `ColorScheme` objects in `color_schemes.dart`.
Use semantic color tokens, not raw hex values in widgets:

```dart
// Good — semantic
color: context.colorScheme.primary

// Bad — hardcoded
color: Color(0xFF6750A4)
```

Access via context extension:
```dart
context.colorScheme.primary
context.colorScheme.surface
context.colorScheme.onSurface
```

## Typography

Text styles from `context.textTheme`:
```dart
context.textTheme.headlineLarge
context.textTheme.bodyMedium
context.textTheme.labelSmall
```

## Spacing & Radius

Use constants instead of magic numbers:

```dart
// Spacing
AppSpacing.xs   // 4
AppSpacing.sm   // 8
AppSpacing.md   // 16
AppSpacing.lg   // 24
AppSpacing.xl   // 32
AppSpacing.xxl  // 48

// Radius
AppRadius.sm    // 4
AppRadius.md    // 8
AppRadius.lg    // 16
AppRadius.xl    // 24
AppRadius.full  // 999 (pill)
```

## Responsive Sizing

`flutter_screenutil` is initialized in `AppScreenUtilInit`.
Use `.r`, `.w`, `.h`, `.sp` suffixes for responsive dimensions:

```dart
SizedBox(height: 16.h, width: 16.w)
Text('Hello', style: TextStyle(fontSize: 14.sp))
BorderRadius.circular(8.r)
```

## Custom Theme Extension

For values not covered by Material tokens, use `AppThemeExtension`:
```dart
context.appTheme.cardElevation
context.appTheme.shimmerBaseColor
```

Add new values to `extensions/theme_extensions.dart` and register
in `AppTheme.lightTheme` and `AppTheme.darkTheme`.

## Dark Mode

`AppTheme` exposes both `lightTheme` and `darkTheme`.
`App` widget uses `MediaQuery.platformBrightnessOf` by default.
User preference override can be wired through a `ThemeCubit` if needed.
