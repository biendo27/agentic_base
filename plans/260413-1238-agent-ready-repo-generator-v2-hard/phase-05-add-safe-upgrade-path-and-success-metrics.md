# Phase 05: Add Safe Upgrade Path And Success Metrics

## Context Links

- [Plan overview](./plan.md)
- [Phase 04](./phase-04-make-ci-release-and-runtime-integrations-honest.md)
- [Red Team Review](./reports/red-team-review.md)
- [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: make the v2 contract adoptable by existing generated apps and measurable over time.

## Key Insights

- Without a safe upgrade path, v2 only helps new repos.
- Without metrics, "agent-ready" stays marketing language.
- Upgrade must respect user-owned code boundaries.

## Requirements

<!-- Updated: Validation Session 1 - upgrade rewrite boundary locked to generator-owned files -->
- Define what `upgrade` may rewrite and what it must never touch.
- Add migration coverage for older generated repos.
- Add measurable success metrics to docs and validation flows.
- Keep fixture outputs in sync with the new contract.

## Architecture

<!-- Updated: Validation Session 1 - app-layer rewrites excluded from automatic upgrade -->
- Upgrade scope:
  - generator-owned docs
  - harness scripts
  - metadata
  - CI and release surfaces
  - excludes automatic rewrites of user-owned app-layer code
- Metrics:
  - time to first successful verify
  - first-pass verify rate
  - manual-edit ratio before release preflight
  - contract drift count

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/cli/commands/upgrade_command.dart`
  - `/Users/biendh/base/lib/src/generators/project_generator.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/docs/05-project-roadmap.md`
  - `/Users/biendh/base/docs/06-deployment-guide.md`
  - `/Users/biendh/base/my_app/**`

## Implementation Steps

1. Define the safe rewrite boundary for `upgrade`.
2. Add tests for upgrading older generated repos into v2.
3. Add metrics and success criteria to roadmap/docs.
4. Refresh `my_app` only after contract tests are green.
5. Document the migration path for existing downstream apps.

## Todo List

- [x] Define safe upgrade rewrite boundary
- [x] Add migration tests
- [x] Add success metrics
- [x] Refresh fixture app under the new contract
- [x] Document migration path

## Success Criteria

- Existing generated repos can adopt v2 with bounded, documented changes.
- Repo docs can show objective evidence of the new contract working.
- Fixture drift becomes visible quickly.

## Risk Assessment

- Risk: `upgrade` becomes destructive.
- Mitigation: rewrite generator-owned assets only and keep app-code rewrites opt-in.

## Security Considerations

- Upgrade must never overwrite secrets or local credential files.
- Migration docs must clearly separate agent-owned files from human-managed credentials.

## Next Steps

- After this phase, the repo can honestly market itself as a generator for agent-ready repos.
