# Official Observability Guidance

## Sources

- OpenAI, [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/), February 11, 2026.
- Anthropic, [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents), January 9, 2026.

## Key Takeaways

- Agent legibility is the goal. Logs, metrics, traces, UI state, and docs only matter if the agent can query them directly.
- Repository knowledge must stay the system of record. Observability rules need doc and contract surfaces, not tribal knowledge.
- Evals and observability are related but different. `evidence_quality` is not a substitute for runtime or agent observability.
- Traces or transcripts belong to the harness layer. They should record tool calls, intermediate steps, and outcomes without pretending the final app state alone is enough.
- Local-first observability stacks fit agent work better than opaque remote systems during implementation, debugging, and review.

## Implications For This Repo

- Do not rename `evidence_quality` back into a vague catch-all.
- Add bounded observability vocabulary beside the current eval/evidence contract.
- Prefer structured local artifacts and inspect commands before any hosted console ambition.
- Keep approval traces and run ledgers inspectable in-repo.

## Unresolved Questions

- none
