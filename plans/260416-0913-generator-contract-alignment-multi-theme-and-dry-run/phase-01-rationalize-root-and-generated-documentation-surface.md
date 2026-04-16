# Phase 01 — Rationalize Root And Generated Documentation Surface

## Context Links

- [plan.md](./plan.md)
- [research-summary](./research/research-summary.md)
- [docs-and-command-contract-review](./research/docs-and-command-contract-review.md)
- [README.md](/Users/biendh/base/README.md)
- [Generated README](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md>)

## Overview

- Priority: P0
- Status: Pending
- Goal: reduce documentation noise, remove contradictory contract language, and assign a single clear role to each root doc, generated doc, and README surface.

## Key Insights

- Root docs currently mix evergreen contract docs with snapshot-style summaries.
- Root README is acting as landing page, roadmap summary, module catalog, flag reference, and contract explainer all at once.
- Generated README overlaps heavily with generated docs `01-06`.
- Several docs still say “future implementation wave” even where scripts/tests already exist.
<!-- Updated: Validation Session 1 - merge then delete snapshot-style docs from canonical root docs -->

## Requirements

- Keep enough information for human onboarding and agent context.
- Reduce duplicate explanations across README and numbered docs.
- Separate evergreen docs from volatile/snapshot material.
- Keep English only.

## Architecture

- Root surface:
  - `README.md` becomes landing page + shortest truthful usage guide.
  - `docs/` becomes evergreen reference only.
  - snapshot-like or audit-style summaries are merged where needed, then removed from canonical docs.
- Generated repo surface:
  - generated `README.md` becomes operator quick-start + contract summary.
  - generated `docs/01-06` own detailed architecture, testing, theming, and state runtime explanation.
  - `AGENTS.md` and `CLAUDE.md` stay thin adapters, not alternative docs.

## Related Code Files

- Modify:
  - [README.md](/Users/biendh/base/README.md)
  - [docs/02-codebase-summary.md](/Users/biendh/base/docs/02-codebase-summary.md)
  - [docs/codebase-summary.md](/Users/biendh/base/docs/codebase-summary.md)
  - [docs/05-project-roadmap.md](/Users/biendh/base/docs/05-project-roadmap.md)
  - [docs/08-harness-contract-v1.md](/Users/biendh/base/docs/08-harness-contract-v1.md)
  - [docs/09-support-tier-matrix.md](/Users/biendh/base/docs/09-support-tier-matrix.md)
  - [docs/10-manifest-schema.md](/Users/biendh/base/docs/10-manifest-schema.md)
  - [docs/11-eval-and-evidence-model.md](/Users/biendh/base/docs/11-eval-and-evidence-model.md)
  - [docs/12-approval-state-machine.md](/Users/biendh/base/docs/12-approval-state-machine.md)
  - [docs/13-flutter-adapter-boundaries.md](/Users/biendh/base/docs/13-flutter-adapter-boundaries.md)
  - [Generated README](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md>)
  - [Generated Architecture Doc](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md>)
  - [Generated Testing Guide](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md>)

## Implementation Steps

1. Inventory every root doc and generated doc by role: landing, reference, snapshot, guide, or adapter.
2. Define canonical-vs-supporting doc taxonomy and document it in root docs.
3. Compress root README so it links out instead of restating large sections from contract docs.
4. Merge any durable facts from snapshot-style docs into evergreen docs, then delete the snapshot docs from `docs/`.
5. Rewrite drifted contract language so docs describe current shipped behavior honestly.
6. Reduce generated README to quick start, contract summary, and where to go next.
7. Remove duplicated command/testing prose across generated README and generated docs where one source can own it.

## Todo List

- [ ] classify root docs by canonical role
- [ ] merge then delete snapshot-style docs from canonical root docs
- [ ] compress root README
- [ ] de-drift contract docs
- [ ] compress generated README
- [ ] de-duplicate generated testing/architecture docs

## Success Criteria

- Root README fits a landing-page role.
- No contract doc claims “future” where code already ships.
- Generated README becomes shorter and points to docs instead of re-explaining them.
- Canonical doc hierarchy is explicit and consistent.

## Risk Assessment

- Over-compression can remove context needed by agents.
- Moving snapshot docs can break references if not updated everywhere.

## Security Considerations

- Do not surface secrets or env examples beyond existing safe placeholders.

## Next Steps

- Feed the finalized doc taxonomy into dry-run/docs examples in Phase 02.
- Feed generated README boundaries into theme and contract docs in later phases.
