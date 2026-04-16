---
title: "Red Team Review — Contract Docs and Generated App Harness Clarity"
created: 2026-04-16
status: complete
---

# Red Team Review

## Summary

This plan is directionally correct, but it can still fail in three predictable ways: cargo-culting external contracts, over-pruning docs, or adding a harness workflow doc that just repeats architecture/test content.

## Critical Challenges

1. **External-pattern cargo cult**
   - The `meup` contract package is a reference, not a standard to clone.
   - If the scaffold copies locale-aware text getters or request semantics that the starter does not exercise, it will raise complexity without improving agent reliability.

2. **Docs deletion without canonical replacement**
   - Removing `docs/02-codebase-summary.md` is good only if unique content is merged elsewhere first.
   - A smaller docs surface that loses navigation value is worse than a slightly noisy one.

3. **Harness-flow doc duplication**
   - A dedicated generated-app flow doc is only worth it if it becomes the single place that explains:
     - where specs live
     - how an agent should move from change request to verify to release-preflight
     - where human approval stops automation
   - If it just restates README bullets, it should not exist.

4. **Method vs extension confusion**
   - A vague policy will create drift immediately.
   - Without an explicit rule, different contributors will keep mixing:
     - intrinsic value-object behavior
     - response parsing helpers
     - locale/DI-aware convenience methods

## Hard Recommendations

- treat contract-package redesign as a boundary exercise, not a model-count exercise
- require every added contract type to have at least one generated usage example or test
- write one short policy section that states:
  - intrinsic behavior lives on the class
  - runtime-aware or app-context-aware convenience lives in extensions/services
  - `library` + `part` is allowed only if the contract package is explicitly chosen as one cohesive library
- do not leave root docs in mixed tense after this plan lands; that would invalidate the whole cleanup effort

## Exit Criteria

- no root canonical doc claims “implemented” while sibling docs still say “future wave”
- generated testing docs teach only truthful manager-aware or wrapper entrypoints
- generated app docs give an agent one finite workflow narrative
- any expanded base contract surface is both documented and exercised

## Resolution Note

- Validation kept `docs/02-codebase-summary.md` in place.
- Validation deferred `base.dart` + `part` adoption unless the contract package proves cohesive enough after implementation.
- Validation approved a dedicated generated workflow doc and rejected locale-aware runtime coupling inside raw core contract models.
