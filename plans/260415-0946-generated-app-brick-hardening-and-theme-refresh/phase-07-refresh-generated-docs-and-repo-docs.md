# Phase 07: Refresh Generated Docs And Repo Docs

## Context Links

- [Plan overview](./plan.md)
- [Research summary](./research/research-summary.md)
- [Design guidelines](../../docs/07-design-guidelines.md)
- [`ck:docs` skill](</Users/biendh/.agents/skills/docs/SKILL.md>)

## Overview

- Priority: P1
- Status: Completed
- Goal: make the generator docs honest again after runtime, base-contract, theme, starter-flow, and test changes land.

## Key Insights

- repo docs have previously drifted ahead of code
- generated docs must describe the actual starter app, theme structure, test matrix, and feature flow
- docs refresh should happen last so claims match shipped behavior

## Requirements

- update generated app docs inside `agentic_app`
- update root docs for generator architecture, roadmap, design, and deployment/testing where affected
- use `ck:docs update` after implementation settles to catch architectural drift

## Architecture

- generated docs remain part of the downstream contract
- root docs remain the source of truth for the generator package
- docs should describe selective `part` policy, shared contracts, theme strategy, starter flow, verification layers, and test-speed strategy

## Related Code Files

- Modify:
  - `/Users/biendh/base/docs/04-system-architecture.md`
  - `/Users/biendh/base/docs/05-project-roadmap.md`
  - `/Users/biendh/base/docs/07-design-guidelines.md`
  - generated app docs under `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/`
  - `/Users/biendh/base/README.md`
- Create:
  - any missing generated architecture docs required by the new base app
- Delete:
  - stale docs that describe removed or dead scaffolding

## Implementation Steps

1. Identify doc surfaces changed by phases 1-6.
2. Update generated docs first so downstream contract stays coherent.
3. Update root docs and roadmap language.
4. Run `ck:docs update` to perform the final architectural sync pass.
5. Verify no public claim outruns the shipped code or tests.

## Todo List

- [x] Refresh generated app docs
- [x] Refresh root docs and roadmap
- [x] Run `ck:docs update` after implementation
- [x] Remove stale statements and dead references
- [x] Verify claim-safe wording everywhere

## Execution Notes

- completed in repo state as of 2026-04-15
- root docs now describe the visible full-feature spec contract, the retained heavy verification matrix, and the intentional `--simple` boundary
- generated app docs already matched the shipped starter-flow, theming, and testing surfaces; final sync work was claim-safety review plus root-doc wording alignment

## Success Criteria

- generated docs, root docs, and shipped behavior all agree
- no dead scaffolding is still described as supported
- theme, starter flow, and verification docs match the final output

## Risk Assessment

- Risk: docs refresh happens too early and drifts again
- Mitigation: keep this phase last and gate it on tests plus manual review

## Security Considerations

- docs must not include secrets, private endpoints, or misleading operational guarantees

## Next Steps

- After this phase, the repo is ready for an implementation pass and final validation.
