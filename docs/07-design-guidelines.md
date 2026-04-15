# 07. Design Guidelines

## Scope

This repository is a generator package, so these guidelines apply mainly to the Flutter apps produced by `agentic_base`, not to a UI shipped in this repo itself.

## Design Direction

Generated apps should bias toward:

- clear, explicit project structure
- Material 3 defaults instead of ad hoc widget styling
- theme tokens centralized in app/core theme files
- predictable feature boundaries that AI agents can navigate

## Template-Level Rules

- keep app-wide theming in shared app/core theme files, not scattered across features
- generated starter themes should default to the explicit Material 3 design-kit tokens, not a derived seed palette
- keep reusable UI primitives in shared locations; keep feature-specific widgets inside the feature
- prefer generated docs and clear file names over hidden conventions
- keep starter surfaces honest: app shell, flavor diagnostics, router, localization, settings, and the provider-neutral monetization seam should all be visible in the default home flow
- keep the starter monetization route polished, but do not present the demo adapter as a real billing integration
- keep full generated features visibly spec-driven in UI copy, while `agentic_base feature --simple` remains the intentionally lighter-weight leaf scaffold

## Feature UI Boundaries

Generated project structure should keep these concerns separate:

- `app/`: bootstrap, flavors, observers
- `assets/i18n/`: localization source of truth
- `core/`: cross-cutting services, routing, DI, theme, errors
- `features/`: feature-owned presentation and business logic
- `shared/`: reusable widgets and utilities

This matters for design consistency as much as for code structure. Feature teams should not rebuild app shell, tokens, or routing patterns in each feature.

## Accessibility And Consistency

Generated apps should aim for:

- meaningful text and action labels
- consistent spacing and typography scales
- no feature-local hardcoded color systems when a shared theme exists
- state-specific UX that matches the selected state-management pattern cleanly

## Generated Documentation

The app brick already includes generated-project docs such as:

- architecture
- coding standards
- state management
- network layer
- theming guide
- testing guide

Keep those docs aligned with the actual template output whenever the app brick changes.

## Current Repo Reality

What is verified here:

- the app brick ships explicit Material 3 default tokens from the supplied Figma kit
- the generator no longer exposes a create-time color override for the default theme
- the default starter journey now includes dashboard, detail, settings, and monetization surfaces
- the package README positions generated apps around Clean Architecture
- the generated app template includes a theming guide in its own `docs/`

What is not verified here:

- visual regression tooling
- token export pipelines
- design-system automation

## References

- [`README.md`](../README.md)
- [`bricks/agentic_app/brick.yaml`](../bricks/agentic_app/brick.yaml)
- [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`](../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md)
