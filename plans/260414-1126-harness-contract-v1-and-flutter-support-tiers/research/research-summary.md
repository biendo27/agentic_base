# Research Summary

## Summary

This plan uses prior repo exploration plus external agent-system references already gathered during brainstorming.

## Current Repo Findings

- Repo is scaffold-strong, harness-partial.
- Existing contract centers on docs, thin adapters, `.info/agentic.yaml`, and deterministic scripts.
- Current generated verification is still shallow relative to the desired harness reliability target.
- Existing test suite proves the repo is real and exercised, but not yet a full harness system.

## External Findings

- OpenAI Harness Engineering argues for structured repo knowledge, high legibility, and more direct agent access to observable runtime signals.
- OpenAI's practical guide recommends maximizing a single agent first, adding tools and guardrails before premature multi-agent complexity.
- Anthropic's guide emphasizes observability, explicit pause-for-human-review states, and building systems that scale with model improvements instead of growing more complex.
- Flutter version management tools like FVM and Puro solve per-project SDK stability; this supports "newest tested SDK" rather than "newest available SDK".

## Implications For This Plan

- The next step is contract design, not immediate implementation.
- Product scope needs a support envelope plus support tiers.
- Eval, evidence, and approval need to become first-class design surfaces.

## Unresolved Questions

- None beyond those already listed in the main plan and brainstorm report.

