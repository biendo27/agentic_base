# Research Summary

## Scope

Plan the next remediation wave for `agentic_base` after the post-implementation review surfaced unresolved contract, docs, and generated-app architecture issues.

## Main Findings

- Root docs are mostly complete but not cleanly layered.
- Root `README.md` is too broad for a landing page.
- Several contract docs still speak in future tense even where implementation already exists.
- Generated app docs are more focused, but generated `README.md` still overlaps heavily with generated docs.
- `eval` still shells out to bare `flutter`.
- `doctor` still partially depends on bare system `dart`.
- The generated app theme is light/dark only for one family, not structurally ready for multiple theme families.
- `AppLocaleContract` is correctly outside the generated Slang output tree, but the reasoning is only lightly documented.
- `FlavorConfig` works but repeats env-driven configuration in a noisy way.
- `AppFailure` is a good candidate for `freezed`; generic contracts are not automatically worth codegen.
- Missing modularization is mostly about oversized files, not lack of `library/part`.
- Command surface has no unified `--dry-run` behavior.

## Implications

- The repo is close to the desired bar, but still not honest enough to claim a fully aligned harness-first surface.
- The next plan should not be another broad product redesign. It should be a focused alignment wave.
- Docs, CLI semantics, generated app structure, and tests need to move together.

## Recommended Direction

- compress and re-layer docs before adding more prose
- add one shared dry-run contract across commands
- fix manager-aware `eval` and `doctor`
- refactor theme into family-aware architecture
- migrate only high-value modeled surfaces to `freezed`
- add drift-proof tests before declaring the wave complete

## Open Questions

- exact dry-run semantics for read-only commands
- whether to keep any snapshot-style doc inside canonical root docs
- how much `freezed` should spread beyond `AppFailure`
