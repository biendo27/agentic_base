# Red-Team Review

## Summary

The implementation direction is correct, but there are three likely failure modes if execution is sloppy.

## Findings

### 1. Manifest-Only Progress

There is a risk of landing the `harness` manifest shape without wiring generated docs, scripts, and validators tightly enough. That would create a cleaner config file without a real contract upgrade.

Mitigation:

- keep validators in Phase 01
- keep generated-surface sync in Phase 02
- do not count config-only changes as milestone completion

### 2. Evidence Theater

There is a risk of emitting JSON files that look sophisticated but do not materially improve trust or reviewability.

Mitigation:

- keep the evidence bundle minimal in v1
- require every evidence file to answer a concrete review question
- test bundle contents, not only existence

### 3. SDK Policy Drift

There is a risk of documenting manager/version rules without actually blocking mismatched toolchains.

Mitigation:

- make mismatch states explicit in `doctor`
- block inappropriate release-preflight or upgrade paths where needed
- add tests for mismatch handling, not only happy-path detection

### 4. Docs Leading Code Again

There is a risk of updating README/docs language too early because the design package is already polished.

Mitigation:

- keep claim updates in the final phase
- only update public guarantees after tests and smoke outputs are green

## Verdict

Proceed. The remaining work is well-scoped and implementation-focused. The main discipline requirement is to keep every new claim tied to a generated surface or a regression test.

## Unresolved Questions

- Whether CI should merely preserve evidence artifacts or also summarize them in workflow output can be decided during implementation.
