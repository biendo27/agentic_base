# Phase 02: Realign Shared Contract Modeling

## Context Links

- [Plan Overview](./plan.md)
- [Research Summary](./research/research-summary.md)
- [Generated Coding Standards](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/02-coding-standards.md>)
- [Contract Package](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts>)

## Overview

- Priority: P0
- Status: Complete
- Goal: remove the policy/code mismatch in generated `lib/core/contracts` without repackaging the contract package

<!-- Updated: Validation Session 1 - keep extension-oriented helpers, add best-practice check -->

## Key Insights

- The current docs say intrinsic contract behavior belongs on the contract class.
- The current generated code still keeps intrinsic helpers in extensions.
- Validation chose to keep the extension-oriented model unless targeted best-practice research proves a strong reason to reopen the decision.
- The mismatch is still unacceptable because agents cannot tell which rule is real.

## Requirements

- Choose one rule and make code, docs, and tests agree.
- Keep contracts runtime-agnostic.
- Avoid broad `base.dart` or `library/part` expansion unless the package proves cohesive enough to justify it.
- Run a narrow best-practice check before final implementation details land, then document the chosen extension-oriented rationale explicitly.

## Architecture

- Chosen direction for this wave:
  - raw contracts stay runtime-agnostic data models
  - pure convenience and serialization helpers may remain in extensions when they keep Freezed models smaller and preserve generated clarity
  - runtime-aware convenience still remains outside raw contracts
- Phase work must explicitly separate:
  - extension-safe pure helpers
  - runtime-aware helpers that belong elsewhere
- Keep file-per-contract packaging unless implementation proves a stronger library boundary is necessary.

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_list_response.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/localized_text.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/02-coding-standards.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test/core/contracts/*.dart`
- Create: none expected
- Delete:
  - only extension blocks that become redundant after the final rule is documented

## Implementation Steps

1. Run a targeted best-practice check for Freezed/shared-model helper placement in Dart/Flutter codebases and document the rationale briefly.
2. Audit each helper and classify it as pure extension-safe vs runtime-aware.
3. Keep or rehome only the helpers that truly need external runtime context.
4. Sync the generated coding-standards doc and any examples to the final extension-oriented rule.
5. Update contract tests and any generated examples to follow the chosen API shape.

## Todo List

- [x] Run targeted best-practice check
- [x] Classify every contract helper
- [x] Remove or rehome only runtime-aware helpers that violate the chosen rule
- [x] Update tests and examples
- [x] Sync generated coding standards

## Success Criteria

- Generated contracts and generated docs teach the same modeling rule.
- Contract tests still cover serialization, success semantics, locale fallback, and pagination helpers.
- The final rule is explicit enough that agents do not need to guess between class methods and extensions.

## Risk Assessment

- Risk: best-practice check points the other way and clashes with the validated direction.
- Mitigation: record the trade-off honestly, but keep the validated extension-oriented decision unless a truly serious downside appears.

## Security Considerations

- Preserve boundary semantics for parsed server payloads and reserved pagination keys.

## Next Steps

- Phase 03 completed on top of the updated contract/test baseline.
