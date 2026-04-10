# Red Team Review

## Summary

Red-team review accepted the architecture direction and pushed the plan to tighten five areas:

1. hard-fail generator semantics
2. real `create` smoke gate
3. explicit run matrix across CLI/IDE/scripts/CI
4. `my_app` as generated verification fixture, not source of truth
5. feature-scaffold alignment with the new module i18n contract

## Accepted Findings

- Critical generator steps must abort and roll back on failure.
- Fresh temp-app generation must be part of the verification gate.
- Forbidden `.idea` artifacts need explicit negative guardrails.
- The module-based i18n contract must include feature scaffolding, not just the app brick.

## Accepted With Modification

- App-id normalization remains in scope, but only as one generator-owned helper with documented behavior and fail-fast validation.
- Doc sync remains in scope, but narrowed to canonical surfaces and stale generated guides only.

## Rejected Findings

- Removing shared `.idea/runConfigurations` from scope.
  - Reason: explicit user requirement for IDE flavor/env support in both VS Code and JetBrains.

## Outcome

Plan files updated inline. No unresolved blockers remain for implementation planning.
