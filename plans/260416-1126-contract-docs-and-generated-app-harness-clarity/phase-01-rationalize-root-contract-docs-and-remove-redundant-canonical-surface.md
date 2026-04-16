# Phase 01 — Rationalize Root Contract Docs and Remove Redundant Canonical Surface

## Context Links

- [plan.md](./plan.md)
- [research-summary.md](./research/research-summary.md)
- [scout-report.md](./reports/scout-report.md)
- [README.md](../../README.md)
- [docs/02-codebase-summary.md](../../docs/02-codebase-summary.md)
- [docs/03-code-standards.md](../../docs/03-code-standards.md)
- [docs/05-project-roadmap.md](../../docs/05-project-roadmap.md)
- [docs/06-deployment-guide.md](../../docs/06-deployment-guide.md)
- [docs/08-harness-contract-v1.md](../../docs/08-harness-contract-v1.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: make the root canonical docs truthful, finite, and less repetitive

## Key Insights

- the remaining docs bug is not missing content; it is contradictory status language
- validation kept `docs/02-codebase-summary.md` in the canonical surface, so this phase must compress around it rather than remove it
- root `README.md` is too broad for a landing page and currently carries too much canonical detail
- repo docs now also encode classic Gitflow policy, so root-doc cleanup must preserve consistency across README, standards, roadmap, and deployment guidance

## Requirements

- remove future-tense or implementation-wave language from shipped contract docs
- keep `docs/02-codebase-summary.md` in the canonical surface while reducing overlap around it
- preserve the navigation value of the root docs index while reducing repetition
- keep root Gitflow narrative aligned across `README.md`, `docs/03`, `docs/05`, and `docs/06`

## Architecture

- `README.md` becomes the package landing page plus high-level contract map
- detailed contract docs remain split by concern, but use shipped-state language only
- `docs/02-codebase-summary.md` stays as a canonical orientation doc, not a removal candidate in this wave
- Gitflow docs remain distributed, but they must tell one consistent story that matches the checked-in workflows

## Related Code Files

- Modify:
  - `README.md`
  - `docs/01-project-overview-pdr.md`
  - `docs/02-codebase-summary.md`
  - `docs/03-code-standards.md`
  - `docs/05-project-roadmap.md`
  - `docs/06-deployment-guide.md`
  - `docs/08-harness-contract-v1.md`
  - `docs/09-support-tier-matrix.md`
  - `docs/10-manifest-schema.md`
  - `docs/11-eval-and-evidence-model.md`
  - `docs/12-approval-state-machine.md`
  - `docs/13-flutter-adapter-boundaries.md`

## Implementation Steps

1. Audit root docs for duplicated status lines, duplicate command guidance, duplicate contract summaries, and duplicated or divergent Gitflow policy language.
2. Rewrite `docs/08-13` so they describe shipped surfaces truthfully and distinguish current guarantees from explicit non-goals without sounding pre-implementation.
3. Tighten `docs/02-codebase-summary.md` so it keeps only orientation value that nearby docs do not already cover.
4. Reconcile the new Gitflow wording across `README.md`, `docs/03`, `docs/05`, and `docs/06` so branch roles, PR routes, and release expectations match one another.
5. Compress `README.md` into a smaller landing page that points to the right detail docs instead of repeating them.
6. Recheck the root documentation index so it stays finite without deleting approved canonical docs.

## Todo List

- [x] scrub future-tense contract status from root docs
- [x] decide canonical-vs-reference root docs list
- [x] tighten `docs/02-codebase-summary.md` without removing it
- [x] align Gitflow narrative across root docs
- [x] compress `README.md`

## Success Criteria

- no root doc contradicts the shipped Harness Contract V1 status
- `docs/02-codebase-summary.md` remains in the canonical index but carries distinct orientation value
- root Gitflow docs agree on branch roles, PR routing, and release expectations
- `README.md` is materially shorter and less repetitive

## Risk Assessment

- removing too much navigation context from root docs
- changing tense without checking generator behavior and tests

## Security Considerations

- none beyond preserving truthful approval-boundary language

## Next Steps

- complete
