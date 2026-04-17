# Phase 03: Refactor Smoke Verification for Speed and Confidence

## Context Links

- [Plan Overview](./plan.md)
- [Research Summary](./research/research-summary.md)
- [Smoke Reliability Report](../reports/researcher-260417-0912-smoke-verification-reliability.md)
- [Smoke Suite](/Users/biendh/base/test/integration/generated_app_smoke_test.dart)
- [Generated Verify Script](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh>)

## Overview

- Priority: P0
- Status: Complete
- Goal: reduce smoke runtime enough for a comfortable completion gate without weakening harness honesty

<!-- Updated: Validation Session 1 - fast lane always blocking, slow canary conditional -->

## Key Insights

- Every smoke case currently pays the full `create -> verify` cost.
- `verify.sh` likely boots `test/app_smoke_test.dart` twice.
- Darwin native readiness is the slowest, most fragile gate.
- The best first move is an internal repo-test fast path, not a broader generated verify-contract rewrite.

## Requirements

- Keep at least one honest full end-to-end canary that still proves generated verify behavior.
- Remove obvious duplicated work.
- Separate fast parity coverage from the heaviest host-dependent coverage where that split stays honest.
- Keep downstream `create` plus generated `tools/verify.sh` semantics intact unless a tiny verify-script change is the only credible way to remove duplicate smoke work.
- Final lane policy for this wave:
  - fast lane always blocking
  - slow canary blocking only for harness, verify, evidence, or native-surface changes

## Architecture

- One canary lane should still prove:
  - `agentic_base create`
  - generated contract validation
  - verify evidence bundle shape
  - named gates including app-shell smoke
- Lighter parity lanes can reuse the generated output differently if they still prove the specific dimension under test.
- Preferred split:
  - fast internal repo lane: generate -> `GeneratedProjectContract.validate(...)` -> starter/runtime assertions
  - slow canary lane: generate -> generated `tools/verify.sh` -> evidence and gate assertions
- App-shell smoke should run exactly once per verify pass by excluding `test/app_smoke_test.dart` from the generic `flutter test` pass and keeping it as the explicit named smoke gate.

## Related Code Files

- Modify:
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
  - `/Users/biendh/base/test/src/generators/project_generator_test.dart`
  - `/Users/biendh/base/lib/src/generators/project_generator.dart` if the repo test needs an internal fast-path hook
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh` only if duplicate app-smoke execution cannot be removed honestly from the current contract shape
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart` only if gate names or expectations move
- Create:
  - at most one small shared smoke helper if repetition blocks readability
- Delete: none expected

## Implementation Steps

1. Remove duplicate app-shell smoke execution inside one verify run.
2. Implement an internal fast smoke path for this repo that does not weaken downstream repo semantics.
3. Decide the minimal blocking matrix:
   - one full slow canary
   - lighter parity checks for remaining state/module surfaces
4. Keep native readiness either in the slow canary or an explicit heavy lane; do not silently drop it.
5. Tighten assertions so faster lanes still prove the contract they claim to cover.
6. Re-measure the targeted smoke suite and compare against the previous stuck behavior.
7. Encode the lane policy clearly in tests or docs so reviewers know when the slow canary must block.

## Todo List

- [x] Deduplicate app-shell smoke execution
- [x] Split canary vs parity smoke responsibilities
- [x] Keep native readiness in an explicit honest lane
- [x] Update smoke assertions and helper structure
- [x] Re-measure targeted runtime
- [x] Encode blocking policy for fast vs slow lanes

## Success Criteria

- The smoke suite has one clear heavy canary and lighter parity coverage for the remaining dimensions.
- Duplicate Flutter startup cost is removed from verify.
- Reviewers can obtain a full targeted smoke pass without the current “stuck for a long time” feeling.

## Risk Assessment

- Risk: speed work quietly weakens verification breadth.
- Mitigation: keep named gate coverage explicit and document what moved from canary to parity.

## Security Considerations

- Keep release-preflight and native-readiness coverage explicit wherever credentials and host tooling matter.

## Next Steps

- Phase 04 completed with docs/test sync and final verification.
