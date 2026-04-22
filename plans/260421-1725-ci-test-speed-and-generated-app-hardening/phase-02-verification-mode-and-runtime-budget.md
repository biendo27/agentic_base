# Phase 02: Verification Mode And Runtime Budget

## Context Links

- [Plan](./plan.md)
- [Phase 01](./phase-01-root-test-taxonomy-and-fast-ci-baseline.md)
- Generator: [`project_generator.dart`](../../lib/src/generators/project_generator.dart)
- Create command: [`create_command.dart`](../../lib/src/cli/commands/create_command.dart)
- Verify script template: [`tools/verify.sh`](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh)

## Overview

Priority: P0. Status: Completed.

Replace the internal `runVerify: bool` with an explicit verification mode so repo CI and power users can choose speed without lying about verification. Public default remains full verification.

## Key Insights

- `ProjectGenerator.generate(... runVerify: false)` already exists for tests.
- Root native gate currently risks verifying twice: once during `create`, once through `./tools/ci-check.sh`.
- `AGENTIC_VERIFY_FAST=1` exists but skips static/unit-widget gates, so it must not replace full verification globally.

## Requirements

- Functional:
  - Add typed verification mode: `full`, `fast`, `none`.
  - Keep `full` as default for `agentic_base create`.
  - Allow repo CI to generate with `none` when it immediately runs `tools/ci-check.sh`.
  - Allow explicit `fast` for local smoke loops.
  - Log verification mode and next required command when not full.
- Non-functional:
  - No hidden behavior changes for users who do not pass new flags.
  - No silent success claim when verification is skipped.

## Architecture

```text
CreateCommand --verify-mode --> ProjectGenerator
ProjectGenerator -> GeneratedVerificationMode
  full: bash tools/verify.sh
  fast: AGENTIC_VERIFY_FAST=1 AGENTIC_SKIP_NATIVE_READINESS=1 bash tools/verify.sh
  none: skip, log "unverified; run ./tools/verify.sh"
```

## Related Code Files

- Modify `/Users/biendh/base/lib/src/generators/project_generator.dart`.
- Modify `/Users/biendh/base/lib/src/cli/commands/create_command.dart`.
- Modify `/Users/biendh/base/test/src/cli/commands/create_command_test.dart`.
- Modify `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`.
- Modify `/Users/biendh/base/.github/workflows/ci.yml`.
- Possibly create a small enum file under `/Users/biendh/base/lib/src/generators/` if keeping `project_generator.dart` smaller.

## Implementation Steps

1. Add `GeneratedVerificationMode` enum with values `full`, `fast`, `none`.
2. Replace `runVerify: bool` parameter with `verificationMode`, keeping compatibility in tests by updating call sites.
3. Implement `_verify(projectDir, mode)`:
   - `full`: existing behavior.
   - `fast`: run `tools/verify.sh` with `AGENTIC_VERIFY_FAST=1` and `AGENTIC_SKIP_NATIVE_READINESS=1`.
   - `none`: log warning and skip.
4. Add `--verify-mode` to `create` with allowed values.
5. Keep default `full` for interactive and non-interactive create.
6. Update dry-run output to show selected verification mode.
7. Update native CI gate to call create with `--verify-mode none` before `./tools/ci-check.sh`.
8. Update generated-app smoke helper to use `GeneratedVerificationMode.none`.
9. Add tests for flag parsing, default mode, dry-run output, and generator command behavior.

## Todo List

- [x] Add verification mode enum.
- [x] Update generator API.
- [x] Add CLI flag and tests.
- [x] Update smoke helper and native CI gate.
- [x] Add warning text for `none`.
- [x] Measure runtime after change.

## Success Criteria

- Existing `agentic_base create my_app` still performs full verify by default.
- CI native gate no longer performs duplicate verification before `ci-check.sh`.
- Tests prove `--verify-mode fast` and `--verify-mode none` pass the expected environment/skip behavior.
- Runtime budget is documented:
  - fast package lane target: under 5 minutes
  - generated smoke fast target: under 15 minutes
  - native macOS target: under 25 minutes when it runs

## Risk Assessment

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Users misuse `none` and think app is verified | False confidence | Explicit warning and next command in CLI output |
| `fast` mode too weak | Missed failures | Do not use as required release gate; keep full verify in release/canary |
| API churn in tests | Short-term breakage | Update all call sites in one phase |

## Security Considerations

- No credentials involved.
- Avoid adding env vars that alter release behavior.

## Next Steps

Phase 03 fixes generated CI/CD templates and provider prompting.
