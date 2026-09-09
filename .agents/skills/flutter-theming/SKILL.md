---
name: flutter-theming
description: Apply colors, typography, spacing, and visual styling using the project's theme extension system. Use whenever writing code that involves colors, text styles, padding, margin, border radius, shadows, or any visual appearance of UI components. Apply when you see requests involving styling, colors, fonts, spacing, or visual design.
aliases: [theming, theme, colors, styling, design-system]
sources: [chat, code]
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 18:47:00 GMT
---

# Flutter Theming

This project uses theme extensions for all visual styling. Hardcoded visual values are not permitted anywhere in the codebase.

## Color Access

```dart
// Do not do this
color: const Color(0xFF6750A4)
color: Colors.deepPurple
backgroundColor: Theme.of(context).colorScheme.primary

// Do this
color: context.appColors.primary
backgroundColor: context.appColors.surface
```

`context.appColors` is an extension on `BuildContext` defined in `core/theme/app_colors_extension.dart`. It provides typed access to the full color palette with names that communicate intent.

### Available colors

- **Branding and surfaces**: `context.appColors.primary` for the main brand color, `context.appColors.secondary` for secondary accents, `context.appColors.surface` for card and container backgrounds, `context.appColors.background` for screen backgrounds
- **States**: `context.appColors.error` for error states, `context.appColors.success` for success states
- **Text**: `context.appColors.textPrimary` for primary readable text, `context.appColors.textSecondary` for captions, labels, and secondary information, `context.appColors.textDisabled` for disabled controls and text

## Spacing

```dart
// Do not do this
padding: const EdgeInsets.all(16)
margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8)

// Do this
padding: const EdgeInsets.all(AppSpacing.md)
margin: const EdgeInsets.symmetric(
  horizontal: AppSpacing.lg,
  vertical: AppSpacing.sm,
)
```

`AppSpacing` is defined in `core/constants/app_spacing.dart` and provides the following spacing values:

| Constant | Value |
|----------|-------|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `xxl` | 48 |

## Typography

```dart
// Do not do this
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)

// Do this
style: context.appTypography.bodyMedium
style: context.appTypography.headlineLarge.copyWith(
  color: context.appColors.textPrimary,
)
```

`context.appTypography` is an extension on `BuildContext` providing the full type scale.

## Border Radius

```dart
// Do not do this
borderRadius: BorderRadius.circular(8)

// Do this
borderRadius: BorderRadius.circular(AppRadius.sm)
```

`AppRadius` constants: `xs` (4), `sm` (8), `md` (12), `lg` (16), `xl` (24), `round` (999).

## What This Skill Does Not Cover

- Hardcoded colors — always use `context.appColors`
- Hardcoded spacing — always use `AppSpacing`
- Hardcoded font sizes — always use `context.appTypography`
- Hardcoded border radius — always use `AppRadius`