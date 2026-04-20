# Phase 02 — Re-layer Generated App Docs for Agentic Harness Workflow Clarity

## Context Links

- [plan.md](./plan.md)
- [research-summary.md](./research/research-summary.md)
- [bricks/agentic_app README](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md)
- [generated architecture doc](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md)
- [generated testing guide](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: give generated repos a finite, agent-readable workflow surface instead of a set of partially overlapping docs

## Key Insights

- generated docs already explain architecture, testing, and release boundaries
- what is missing is a single workflow narrative for Agentic Coding under a Harness Engineer model
- generated README currently duplicates too much of docs/01 and docs/06
- if generated repos are meant to inherit classic Gitflow, the workflow doc is the correct place to explain branch roles and PR flow
- validation chose downstream Gitflow as a recommended default workflow, not a mandatory harness law

## Requirements

- generated docs must explain where to start, what files are source-of-truth, how to verify, and when humans must approve
- generated testing docs must teach manager-aware surfaces only
- generated docs should stay compact enough for agents to scan quickly
- add one dedicated generated workflow doc for the Harness Engineer loop
- generated workflow guidance must encode Gitflow as a recommended default policy for downstream repos

## Architecture

- README = entrypoint + contract summary + command index
- architecture/testing docs = technical detail
- one explicit workflow doc or equivalent integrated section = agent execution loop
- Gitflow, if adopted downstream, belongs in the workflow surface first, not spread ad hoc through every generated doc
- thin adapters should carry only a short Gitflow summary and then defer to the workflow doc

## Related Code Files

- Modify:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md`
- Create:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/07-agentic-development-flow.md`

## Implementation Steps

1. Map current generated-doc overlap: contract summary, starter flow, verify ladder, release boundary, canonical context.
2. Remove repeated prose from generated README and keep it as the shortest trustworthy entrypoint.
3. Replace bare `flutter test` guidance with `make test`, `./tools/test.sh`, `./tools/verify.sh`, or other manager-aware surfaces only.
4. Add `docs/07-agentic-development-flow.md` as the explicit harness workflow narrative covering:
   - spec/source of truth
   - implementation loop
   - verification loop
   - release-preflight and human approval boundary
   - recommended branch/PR/release flow for teams following classic Gitflow
5. Ensure `AGENTS.md`/`CLAUDE.md` can point agents to the same finite docs path, carry a short Gitflow summary, and reference that policy as recommended rather than universal.

## Todo List

- [x] compress generated README
- [x] fix manager-aware testing guidance
- [x] add `docs/07-agentic-development-flow.md`
- [x] encode downstream Gitflow as recommended default guidance
- [x] re-check docs overlap after rewrite

## Success Criteria

- an agent can open the generated README and know exactly where to go next
- generated testing docs no longer recommend bare `flutter test`
- the generated docs make the Harness Engineer development loop explicit through a dedicated workflow doc
- the generated workflow doc states Gitflow as recommended default guidance and thin adapters reflect that same level of strictness

## Risk Assessment

- adding one more generated doc without actually reducing duplication
- over-explaining the workflow and inflating the doc surface again

## Security Considerations

- human approval and credential ownership language must remain explicit

## Next Steps

- complete
