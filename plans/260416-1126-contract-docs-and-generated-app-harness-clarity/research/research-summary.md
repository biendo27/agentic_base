---
title: "Research Summary — Contract Docs and Generated App Harness Clarity"
created: 2026-04-16
status: complete
---

# Research Summary

## Summary

Two review findings are real and symptomatic, not cosmetic:

- root canonical docs still mix shipped status with future-tense contract language
- generated testing docs still teach bare `flutter test` despite manager-aware harness wrappers

The deeper issue is information architecture. Root docs, generated docs, and shared contracts all now contain enough truth, but not yet in the cleanest or most finite shape for agents.

## Findings

1. Root `README.md` says Harness Contract V1 is implemented, but `docs/08-13` still frame core clauses as design targets or future waves.
2. Root docs still keep `docs/02-codebase-summary.md` as part of the canonical index even though much of it duplicates `README.md` and `docs/04-system-architecture.md`.
3. Generated app docs explain runtime architecture and verification surfaces, but they do not yet give agents one explicit “how to work in this repo” harness-flow narrative.
4. Generated testing docs still leak direct `flutter test` usage and therefore undercut manager-aware toolchain honesty.
5. `lib/core/contracts` is now minimal and cleaner than before, but it is still under-specified relative to the user’s desired base contract set: request-side pagination, richer response variants, and multi-language payload handling.
6. The external `meup` reference shows two valuable ideas:
   - a more complete request/response contract surface
   - explicit separation between intrinsic model data and convenience behavior
7. The same `meup` reference also shows a risk:
   - locale/DI-dependent convenience logic inside extensions can easily leak runtime coupling into core models if copied blindly
8. The repo now documents classic Gitflow at the package level, but generated agentic-core surfaces still carry no branch-policy guidance. That means downstream repos currently inherit no explicit branch model, even if the top-level repo now does.

## Recommendations

- prune redundant canonical docs instead of adding more explanatory files at root
- make generated docs more explicit about the Harness Engineer development loop
- align all generated command examples to manager-aware wrappers or `make`/`tools/*.sh` surfaces
- decide one explicit policy for `lib/core/contracts`:
  - what belongs in the base contract package
  - what stays intrinsic methods
  - what must move to extensions or adapters
- evaluate `library` + `part` only inside `lib/core/contracts`, not repo-wide
- decide whether generated agentic-core docs/adapters should:
  - inherit classic Gitflow by default
  - treat it as recommended but optional team policy
  - stay repo-agnostic

## Proposed Defaults

- remove `docs/02-codebase-summary.md` from the canonical root doc surface after merging any unique value into nearby docs
- keep contract docs split by concern, but scrub future-tense language and reduce duplicate status prose
- add one dedicated generated-app harness workflow doc unless validation rejects that direction
- keep runtime-agnostic logic inside core contract classes; move locale- or DI-aware convenience to extensions/services outside the raw data models
- keep Gitflow out of `.info/agentic.yaml` unless validation explicitly decides it belongs in the machine contract

## Resolution Note

- Validation kept [`docs/02-codebase-summary.md`](../../docs/02-codebase-summary.md) in the canonical root docs surface.
- Validation chose file-per-contract packaging for now inside `lib/core/contracts`, with `base.dart` + `part` deferred unless the package becomes clearly cohesive.
- Validation chose a runtime-agnostic base multi-language model, with locale-aware selection outside raw core contracts.
- Validation approved a dedicated generated-app workflow doc for the Harness Engineer loop.
- Validation chose downstream Gitflow as a recommended default team policy, carried only in human-readable docs and thin adapters.
- Validation limited any generated Gitflow automation in this wave to GitHub-generated repos; GitLab remains docs-only.
