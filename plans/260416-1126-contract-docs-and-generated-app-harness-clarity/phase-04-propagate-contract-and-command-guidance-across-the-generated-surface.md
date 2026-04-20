# Phase 04 — Propagate Contract and Command Guidance Across the Generated Surface

## Context Links

- [phase-02](./phase-02-re-layer-generated-app-docs-for-agentic-harness-workflow-clarity.md)
- [phase-03](./phase-03-rework-shared-contract-modeling-with-meup-informed-boundaries.md)
- [generated testing guide](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: make all generated examples, docs, and starter seams agree on the same command and contract story

## Key Insights

- docs drift returns quickly when command examples and starter code are not checked together
- generated repos should teach wrappers and canonical seams first, not raw underlying tools
- thin adapters and generated README are the likely place where downstream Gitflow policy will drift first if not propagated deliberately
- validation limited Gitflow automation in this wave to GitHub-generated repos; GitLab remains docs-only

## Requirements

- update generated examples, snippets, and starter seams to use the chosen shared contracts
- keep testing guidance manager-aware
- keep docs and starter code aligned on the same harness loop
- if downstream Gitflow is adopted, propagate it consistently through generated README, thin adapters, and workflow docs
- keep downstream Gitflow out of `.info/agentic.yaml`

## Architecture

- command guidance should point to wrapper surfaces first
- starter repositories/services should showcase the new base contracts where they add value
- docs must reference the same finite workflow introduced in Phase 02
- Gitflow policy, if present, should be summarized in entrypoints and explained in the dedicated workflow doc
- any generated Gitflow automation in this wave should target GitHub scaffolds only

## Related Code Files

- Modify generated brick docs and starter code paths touched by contract updates
- Modify generator validation/tests that assert generated doc contents where needed

## Implementation Steps

1. Replace outdated command snippets and examples across generated docs.
2. Update starter repository or request/response examples to showcase the final contract package.
3. Align README, architecture doc, network guide, and testing guide wording.
4. Propagate the chosen recommended Gitflow policy through generated README, `AGENTS.md`, and `CLAUDE.md`.
5. If this wave adds downstream Gitflow automation, implement it for GitHub scaffolds only and keep GitLab guidance documentation-only.
6. Re-check `AGENTS.md` and `CLAUDE.md` templates so they point at the workflow doc and do not overstate any Gitflow policy.

## Todo List

- [x] update generated command snippets
- [x] update contract usage examples
- [x] propagate downstream Gitflow policy
- [x] scope generated Gitflow automation to GitHub only if implemented
- [x] align thin adapters if needed

## Success Criteria

- no generated doc teaches a lower-level command when a truthful wrapper exists
- starter examples and docs agree on the same contract package
- generated entrypoints and thin adapters agree on the chosen downstream Gitflow policy level
- any generated Gitflow automation added in this wave exists only on GitHub scaffolds and matches the documented recommended flow

## Risk Assessment

- hidden drift in templated code snippets

## Security Considerations

- do not weaken human approval or credential guidance while simplifying prose

## Next Steps

- complete
