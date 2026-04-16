# Theming Guide

## Technology: Material 3

The app uses Material 3 with the exact default colors from the supplied
Material 3 Figma design kit, explicit typography,
semantic component defaults, and Flutter-native adaptive helpers.
Theme is defined in `lib/core/theme/`.

## File Structure

```text
lib/core/theme/
├── app_theme.dart          # ThemeData assembly from family id + brightness
├── app_theme_family.dart   # Theme family registry (v1 ships one default family)
├── color_schemes.dart      # ColorScheme for the default family
├── component_themes.dart   # Theme composer entrypoint
├── component_themes/       # Per-component overrides split by concern
├── typography.dart         # TextTheme with custom fonts
├── spacing.dart            # AppSpacing constants
├── radius.dart             # AppRadius constants
└── extensions/
    └── theme_extensions.dart  # Custom ThemeExtension
```

## Color Scheme

Colors are defined as `ColorScheme` objects in `color_schemes.dart`.
The generator uses the exact light and dark values from the Material 3
Figma `Color Modes` collection as the default family palette.

## Theme Family vs Theme Mode

- Theme family chooses the palette bundle, typography, extensions, and component-theme composer.
- Theme mode chooses whether that family renders light, dark, or follows system.
- The starter keeps one bundled family only: `material-default`.
- `AppThemeController` stores both values so downstream apps can add another family later without rewiring the shell.

Use semantic color tokens, not raw hex values in widgets:

```dart
// Good - semantic
color: context.colorScheme.primary

// Bad - hardcoded
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
in the active `AppThemeFamily`.

## Dark Mode

`AppTheme` builds `light` and `dark` `ThemeData` from the selected family id.
`AppThemeController` owns the active `ThemeMode` and theme family id, and is
mounted through `AppThemeScope` in `App`.
`StarterSettingsPage` is the default surface for previewing system, light,
and dark mode without adding product-specific preferences or a demo family switcher.
