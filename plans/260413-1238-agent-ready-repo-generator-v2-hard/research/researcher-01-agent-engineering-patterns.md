---
title: "Researcher 01 Report - Agent Engineering Patterns"
date: 2026-04-13
status: final
---

# Researcher 01 Report - Agent Engineering Patterns

## Summary

Best-practice direction is clear: do not build a magical feature generator. Build a repo harness that lets external agents execute reliably with low ambiguity.

## Findings

1. OpenAI's [Harness Engineering](https://openai.com/index/harness-engineering/) pushes the same operating model we need:
   - humans steer
   - agents execute
   - repo needs better tools, docs, abstractions, and feedback loops
   - `AGENTS.md` should be a table of contents, not the whole brain
2. OpenAI's [Practical Guide to Building Agents](https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf) keeps repeating the same backbone:
   - start with evals
   - standardize reusable tools
   - keep run loops explicit
   - do not jump to unnecessary orchestration complexity
3. Anthropic's [Building Effective AI Agents](https://resources.anthropic.com/hubfs/Building%20Effective%20AI%20Agents-%20Architecture%20Patterns%20and%20Implementation%20Frameworks.pdf?hsLang=en) reinforces:
   - start simple
   - single-agent + strong tooling beats premature multi-agent architecture
   - workflows are better than vague autonomy
4. GitHub Copilot agent docs show the real operational shape:
   - explicit environment bootstrap matters
   - browser/tool access matters
   - security/quality validation belongs in the loop, not afterthought
   - refs:
     - [customize coding agent environment](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-environment)
     - [browser access changelog](https://github.blog/changelog/2025-07-02-copilot-coding-agent-now-has-its-own-web-browser)
     - [automatic security validation changelog](https://github.blog/changelog/2025-10-28-copilot-coding-agent-now-automatically-validates-code-security-and-quality/)
5. Aider's [repo map](https://aider.chat/docs/repomap.html) and [architect/editor split](https://aider.chat/docs/usage/modes.html) show two useful patterns:
   - large repos need machine-legible context maps
   - architecture context and edit execution should stay separated
6. MCP specs for [tools](https://modelcontextprotocol.io/specification/draft/server/tools) and [prompts](https://modelcontextprotocol.io/specification/2025-06-18/server/prompts) support the same conclusion:
   - tools need explicit schemas
   - prompts should be structured entrypoints
   - sensitive actions should remain approval-gated

## Implications For agentic_base

- The central abstraction should be `agent-ready repo contract`, not `feature spec`.
- Canonical context should live in docs + machine-readable metadata, then fan out into thin vendor adapters.
- Local scripts and CI should expose deterministic entrypoints for setup, run, verify, build, and release preflight.
- Release automation should prepare and validate everything before the human approval boundary.

## Recommendations

1. Reframe the product promise now.
2. Generate canonical context and harness scripts before adding more feature generation ideas.
3. Treat evals/verification as part of the product, not support tooling.
4. Keep vendor-specific instruction files thin and generated from one source.

## Unresolved Questions

None.
