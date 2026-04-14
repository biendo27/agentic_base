# Phase 02: Fix GitLab Release Contract And Provider Entrypoints

## Context Links

- [Plan overview](./plan.md)
- [Phase 01](./phase-01-repair-init-contract-truth-and-canonical-context.md)
- [Review findings snapshot](./reports/agent-ready-review-findings.md)
- [`docs/06-deployment-guide.md`](../../docs/06-deployment-guide.md)

## Overview

- Priority: P0
- Status: Proposed
- Goal: make provider-specific deploy surfaces resolve to real generated jobs and shared local scripts.

## Key Insights

- The current GitLab flow is not merely undocumented; it is broken because the coordinator targets job names the template does not generate.
- Provider wrappers are acceptable only if they delegate to one local contract and keep naming stable.
- Release-preflight honesty is useless if the deploy entrypoint itself cannot target a real job.

## Requirements

- Align CLI deploy targeting with real GitLab manual job names after generation.
- Keep provider-specific CI wrappers calling shared local scripts and contracts.
- Preserve the v1 human boundary: agent handles preflight/build/upload plumbing, human approves final publish.
- Add generation-time and package-time regression tests for both provider mappings.

## Architecture

- Introduce one explicit deploy target mapping layer from logical environment to provider-specific job names.
- Generated GitLab jobs must either share normalized names or publish an internal manifest the CLI can read deterministically.
- Shared `tools/release-preflight.sh` and related scripts remain the execution contract; CI only wraps them.

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/deploy/deploy_coordinator.dart`
  - `/Users/biendh/base/lib/src/cli/commands/deploy_command.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab-ci.yml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/deploy.yml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml`
  - `/Users/biendh/base/docs/06-deployment-guide.md`

## Implementation Steps

1. Inventory current logical deploy environments and the generated provider jobs for each.
2. Choose one stable mapping strategy and encode it in code plus templates.
3. Remove synthetic GitLab target names that do not exist post-generation.
4. Add regression tests that generate provider-specific repos and assert deploy targeting is valid.
5. Update deploy docs to describe only the supported flows and human approval boundary.

## Todo List

- [ ] Define stable provider deploy target mapping
- [ ] Repair GitLab job naming or coordinator targeting
- [ ] Keep GitHub and GitLab wrappers aligned to shared scripts
- [ ] Add provider release contract tests
- [ ] Sync deployment docs

## Success Criteria

- `deploy` can target a real generated GitLab job for every supported environment.
- CI/release templates contain no dead job names or fake wiring.
- Generated docs and CLI help describe the same deploy contract.

## Risk Assessment

- Risk: naming is fixed in code but drifts again in templates.
- Mitigation: assert mapping against freshly generated provider fixtures in tests.

## Security Considerations

- Do not blur the line between build/upload plumbing and final store approval.
- Fail cleanly when provider auth or signing prerequisites are absent.

## Next Steps

- Phase 03 removes nondeterminism from module installation so generated release/runtime surfaces stay reproducible.
