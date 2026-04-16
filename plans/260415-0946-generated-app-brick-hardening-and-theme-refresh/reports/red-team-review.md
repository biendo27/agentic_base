# Red-Team Review

## Summary

The scope is correct, but it can fail in four predictable ways if execution gets sloppy.

## Findings

### 1. Overusing `library` + `part`

Risk:

- turning feature and core folders into part-based mega-libraries will reduce local import clarity, make tests harder to isolate, and work against the repo's "easy for agents to navigate" goal

Mitigation:

- limit `part` to codegen-required files and only a few cohesive token libraries if they materially improve the public surface
- prefer normal files plus barrel exports for cross-layer discoverability

### 2. Fake theme refresh

Risk:

- implementation may copy a prettier `ThemeData` setup and claim "Figma-driven Material 3 refresh" without extracting or validating a real token strategy

Mitigation:

- start the theme phase by resolving the exact usable Figma node/output
- if token extraction is blocked, document the fallback explicitly and use official Material guidance plus visual references
- do not claim token sync or Figma parity that the code cannot prove

### 3. Starter app bloat

Risk:

- trying to satisfy every Flutter app profile will turn the starter into a kitchen-sink showcase instead of an honest base app

Mitigation:

- keep one coherent starter flow that proves the shell, theming, localization, diagnostics, and one real feature seam
- push profile-specific behavior into optional modules or future traits, not the base app

### 4. Speed work that hides regressions

Risk:

- speeding up tests too early may quietly delete the only checks that currently prove generated output works end to end

Mitigation:

- freeze the target assurance model first
- only optimize by deduplicating equivalent heavy paths, moving contract checks downward, and reusing fixtures where assertions are identical
- keep at least one full end-to-end generated repo lane per major surface

## Verdict

Proceed. The plan is worth doing, but it must stay disciplined: repair honesty first, improve generated-base quality second, optimize speed third, and update docs last.

## Resolution Note

No unresolved planning questions remain.
