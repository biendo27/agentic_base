---
title: "Researcher 02 Report - Current Repo Gap Analysis"
date: 2026-04-13
status: final
---

# Researcher 02 Report - Current Repo Gap Analysis

## Summary

The repo already has a strong generator core. The blocker is not absence of scaffolding. The blocker is that the generated contract is not yet honest or fully executable for agents.

## Findings

1. Generated agent guidance is still template-level, not canonical, and already drifts by profile.
   - [AGENTS.md](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md:26) hardcodes Cubit even though the generator supports Riverpod and MobX.
2. Bootstrap still overwrites framework error wiring after module initialization.
   - [bootstrap.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart:34)
3. Release flow is not real yet.
   - [tools/release.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release.sh:7) is still TODO comments and warnings.
4. GitHub workflow templating is not contract-safe.
   - Template source is correct in [ci.yml](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/ci.yml:9)
   - Generated output is broken in [my_app/.github/workflows/ci.yml](/Users/biendh/base/my_app/.github/workflows/ci.yml:9)
   - Current validator does not catch it in [generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart:451)
5. Deployment guide still documents generated-project deploy as workflow triggers plus shared scripts, but the release contract is still shallow.
   - [06-deployment-guide.md](/Users/biendh/base/docs/06-deployment-guide.md:52)
6. `.info/agentic.yaml` is a good foundation for machine-readable state, but it is still too narrow for a full agent-ready contract.
   - [agentic_config.dart](/Users/biendh/base/lib/src/config/agentic_config.dart:53)
7. Repo docs already state the right standard for modules:
   - installable modules must land as working runtime integrations, not inert file drops
   - [03-code-standards.md](/Users/biendh/base/docs/03-code-standards.md:39)

## What Already Exists

- CLI command surface is already broad enough.
- Generator layer and contract validation layer already exist.
- `.info/agentic.yaml` already exists and can be extended safely.
- The repo already has root docs, plans, and smoke tests.

## Minimum Change Set

Minimum credible pivot:

1. reset product/docs contract
2. make canonical agent context + vendor adapters
3. add deterministic harness scripts
4. harden contract validation
5. make release and runtime integration honest

Anything beyond that is second-order.

## Recommendations

1. Do not invent a new planning/spec DSL.
2. Upgrade the generated repo contract in place.
3. Use one canonical source for docs/adapters.
4. Fix release and runtime seams before adding new AI-facing abstractions.

## Unresolved Questions

None.
