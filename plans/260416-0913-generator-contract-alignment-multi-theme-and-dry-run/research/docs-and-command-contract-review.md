# Docs And Command Contract Review

## Root Docs

- `README.md` currently mixes:
  - landing-page introduction
  - CLI usage
  - generator contract summary
  - harness contract summary
  - module catalog
  - flag reference
  - CI provider notes
  - full documentation index
- This makes it useful, but not concise.

## Root Doc Drift

- `docs/08-13` still contain “future implementation wave” language.
- `docs/05-project-roadmap.md` says the contract is implemented and docs are aligned.
- Those two stories cannot both stay true.

## Generated Docs

- Generated `README.md` is good as a downstream entrypoint, but still duplicates:
  - canonical context
  - starter flow
  - commands
  - CI contract
  - release boundary
- Generated `docs/01-06` should own more of the detail.

## Command Contract

- `create`, `add`, `remove`, `gen`, and `upgrade` are manager-aware now.
- `eval` still uses bare `flutter`.
- `doctor` still checks bare `dart` for some behavior.
- Generated testing docs still teach bare `flutter test`.

## Dry-Run Gap

- No shared dry-run abstraction exists.
- If added piecemeal, semantics will drift by command.
- `deploy` and `brick` need special treatment because they can cause external side effects or shell mutations.

## Recommendation

- fix docs taxonomy first
- then implement shared dry-run and manager-aware command semantics
- then rewrite command docs from one contract

## Open Questions

- should read-only commands in dry-run print plan only, or still execute safe checks?
- should `docs/codebase-summary.md` stay in canonical root docs?
