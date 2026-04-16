# Phase 03 — Rework Shared Contract Modeling with Meup-Informed Boundaries

## Context Links

- [plan.md](./plan.md)
- [research-summary.md](./research/research-summary.md)
- [generated contracts](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts)
- [`meup` responses](</Users/biendh/StudioProjects/meup/lib/core/base/responses>)
- [`meup` request](</Users/biendh/StudioProjects/meup/lib/core/base/request/page_break_request.dart>)

## Overview

- Priority: P0
- Status: Completed
- Goal: define a richer but still disciplined shared contract package for generated apps

## Key Insights

- current scaffold contracts are minimal and clean, but not yet complete enough for the user’s preferred base package
- `meup` offers useful ideas for request/response and multilingual payloads
- `meup` also mixes in locale-aware convenience that should not automatically live in scaffold core contracts
- validation chose a file-per-contract layout for now, with `base.dart` + `part` only as a future option if cohesion becomes obvious

## Requirements

- decide which shared contract types belong in `lib/core/contracts`
- define a policy for intrinsic methods vs extension methods vs external helpers
- keep `lib/core/contracts` file-per-contract for this wave unless implementation proves a cohesive library package is materially better
- every added contract type must have at least one generated usage example or regression test

## Architecture

- core contracts should stay runtime-agnostic
- intrinsic invariants and value-object behavior belong on the class
- app-context-aware convenience belongs in extensions or adapter services outside raw models
- request/response contracts should align with `fpdart` boundaries, not replace them
- packaging stays file-per-contract first; cohesion must be proven before switching to `base.dart` + `part`

## Related Code Files

- Modify:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_result.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart`
  - generated docs that reference these files
- Create as needed:
  - base response/request/multilanguage files
  - barrel export if needed
  - contract extensions file if policy allows it

## Implementation Steps

1. Compare current scaffold contracts against `meup` shapes and list what is missing, what is portable, and what is too coupled.
2. Lock a contract-package policy:
   - file layout
   - why file-per-contract stays the default for now
   - method-vs-extension rule
3. Add only the contract types that improve the default scaffold materially:
   - response variants
   - pagination request/response
   - multi-language payload support only if it remains runtime-agnostic
4. Update starter examples or docs so the new contract surface is exercised and discoverable.
5. Add tests for serialization, invariants, and convenience behavior boundaries.

## Todo List

- [x] compare current contracts with `meup`
- [x] lock packaging policy for `lib/core/contracts`
- [x] add only justified contract types
- [x] document intrinsic-method vs extension-method rule
- [x] add usage and regression tests

## Success Criteria

- generated apps ship a contract package that is richer but still coherent
- no DI- or locale-runtime coupling leaks into raw core contracts
- the packaging style for `lib/core/contracts` is deliberate and documented

## Risk Assessment

- overgrowing the scaffold with unused base abstractions
- turning the contract package into an opaque convenience layer agents cannot inspect quickly

## Security Considerations

- request/response helpers must not encourage hidden credential or token storage in the model layer

## Next Steps

- complete
