# Theming Guide

## Technology: Material 3

The app uses Material 3 with the exact default colors from the supplied
Material 3 Figma design kit, explicit typography,
semantic component defaults, and Flutter-native adaptive helpers.
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
The generator uses the exact light and dark values from the Material 3
Figma `Color Modes` collection as the default palette.

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

Use constants instead of magic numbers. Radius values align to the base
Material 3 measurements, and spacing also exposes shared control heights:

```dart
// Spacing
AppSpacing.xxs  // 4
AppSpacing.xs   // 8
AppSpacing.sm   // 12
AppSpacing.md   // 16
AppSpacing.lg   // 24
AppSpacing.xl   // 32
AppSpacing.xxl  // 48

// Control heights
AppSpacing.controlHeightSm  // 40
AppSpacing.controlHeightMd  // 56
AppSpacing.controlHeightLg  // 72

// Radius
AppRadius.field   // 4
AppRadius.chip    // 8
AppRadius.card    // 12
AppRadius.medium  // 16
AppRadius.large   // 28
AppRadius.full    // 999
```

## Adaptive Layout

The scaffold does not use global scaling libraries like ScreenUtil.
Use `BuildContextX` in `lib/core/extensions/context_extensions.dart`
for width-aware layout decisions:

```dart
context.isCompactWidth
context.isExpandedWidth
context.adaptiveHorizontalPadding
context.adaptivePagePadding
context.adaptiveContentMaxWidth
```

## Custom Theme Extension

For values not covered by Material tokens, use the status-only
`AppColors` extension:
```dart
context.appColors.success
context.appColors.warning
context.appColors.info
```

Add new values to `extensions/theme_extensions.dart` and register
in `AppTheme.light` and `AppTheme.dark`.

## Dark Mode

`AppTheme` exposes both `light` and `dark`.
`App` widget uses `MediaQuery.platformBrightnessOf` by default.
User preference override can be wired through a `ThemeCubit` if needed.
