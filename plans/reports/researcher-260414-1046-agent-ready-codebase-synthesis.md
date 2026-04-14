# Agent-Ready Codebase Synthesis: Principles & Patterns

**Research Date:** 2026-04-14 | **Sources:** 10 authoritative (OpenAI, Anthropic, GitHub, MCP spec, Aider)

## Executive Summary

An agent-ready codebase is not primarily about code quality—it's about *agent interpretability and autonomous execution safety*. The "harness" is the set of guardrails, structure, and self-healing mechanisms that allow agents to operate reliably within bounded contexts. Three pillars dominate: **deterministic discovery**, **isolated autonomy**, and **automated validation**.

## Core Principles

### 1. Deterministic Discovery (Repomap/Context Patterns)
Agents cannot rely on trial-and-error navigation. Codebases must expose a hierarchical map of intentions:
- **Repomap pattern** (Aider): Agents consume a graph-ranked summary of classes, functions, signatures, and cross-file dependencies. This is not documentation—it's a concise navigation index that fits in token limits.
- **API clarity**: All public surfaces (endpoints, functions, classes) must have explicit input/output schemas and error contracts. Agents use these to predict call outcomes before execution.
- **File naming discipline**: Kebab-case, self-documenting names (e.g., `database-connection-pool.ts` not `db.ts`) let agents grep patterns without reading files.
- **Structural predictability**: Standard layouts (e.g., `src/api`, `src/models`, `src/services`) allow agents to infer file purposes.

### 2. Isolated Autonomy (Harness Boundaries)
Harness = pre-execution environment setup that eliminates discovery failures:
- **Pre-installed dependencies**: Don't let agents discover dependencies at runtime (slow, unreliable for private packages). Use `copilot-setup-steps` (GitHub Actions) or equivalent to stage everything.
- **Ephemeral runners**: Each agent execution runs in a fresh, single-use sandbox (Linux/Windows/custom). No state leakage between runs. Security by isolation.
- **Environment provisioning**: Network access, credentials, tool paths declared upfront via environment variables (never hardcoded). Agents inherit a complete, reproducible context.
- **Scaling tiers**: Standard runners work for simple tasks; larger runners (CPU/memory/disk) required for compilation/testing. Pre-allocate capacity; don't make agents negotiate resources.

### 3. Automated Validation & Self-Healing
Agents must be able to fix their own mistakes:
- **Integrated toolchain**: CodeQL + dependency scanning + secret detection baked into the agent workflow, not post-facto. Agents see validation failures as tool results and self-correct before submitting PRs.
- **Output schemas**: Tools expose `inputSchema` and `outputSchema` (MCP spec). Agents validate results against schemas; mismatches trigger retry logic.
- **Error feedback loops**: Tool execution errors (not protocol errors) describe actionable problems: "Invalid date: must be future. Current: 2026-04-14." Agents re-invoke with corrected parameters.
- **Vision validation**: Browser/screenshot capability (Playwright MCP) lets agents reproduce bugs and visually validate fixes before claiming done.

## Architectural Patterns

### Architect-Editor Separation (Aider Model)
Split planning from implementation:
- **Architect phase**: Reasoning-capable model (e.g., Claude, o1) proposes solution structure.
- **Editor phase**: Implementation-capable model (e.g., GPT-4) translates proposal into precise file edits.
- **Why**: No single model excels at both reasoning and file manipulation. This mirrors human collaboration.
- **Generator implication**: Generated codebases should embed architect/editor hints in `.claude/CLAUDE.md`—protocols that guide agents when delegating sub-tasks.

### Human-in-the-Loop Control Points
- **Tool invocation**: MCP requires user confirmation for state-changing operations (not just read discovery).
- **Security gates**: Before pushing to main/dev, agents halt for human review of security findings.
- **UI transparency**: Clear indication when tools are invoked; no silent background operations.

### MCP Tool Design (Generator-as-Tool Pattern)
Generators should expose themselves as MCP tools:
- **Well-defined input schema**: What args does the generator accept? Types, constraints, examples.
- **Output schema**: What does generated code look like? Structural expectations (file list, component counts).
- **Error semantics**: Distinguishing between user input errors ("invalid package name") and server failures ("disk full").
- **Deterministic ordering**: Tools list in same order across calls; enables LLM prompt cache hits.

## Verification & Eval Patterns

### Pre-submission Validation
1. **Syntax/compilation** (fails fast, prevents broken PRs).
2. **Security analysis** (CodeQL, secrets, dependencies).
3. **Code quality review** (linting, style; agent attempts auto-fix).
4. **Integration tests** (hit real databases, not mocks; mocks hide production mismatches).
5. **Visual verification** (if UI: screenshot and diff against expected).

### Success Criteria
- All tests pass (agent does not skip failing tests to pass CI).
- No secrets in diffs.
- No new security vulnerabilities introduced.
- Output matches output schema (when provided).

## Security Considerations

1. **Sandboxing**: Ephemeral, single-use runners; no cross-run state.
2. **Secrets isolation**: Environment variables only; never in code or git history.
3. **Rate limiting**: Prevent agent abuse (too many tool calls, infinite loops).
4. **Audit logging**: Every tool invocation logged; human can review agent's decision trail.
5. **Input validation**: All tool inputs validated server-side before execution.
6. **Trusted servers only**: MCP tool sources (and annotations) must be vetted; untrusted servers have limited scope.

## Patterns for Code Generators (Agent-Ready Output)

Generated codebases should:

1. **Include a `.claude/CLAUDE.md`**: Explicit instructions for agent helpers—workflows, file ownership patterns, test requirements.
2. **Expose repo-map-friendly structure**: Flat files for small modules, logical grouping for large; no deep nesting without purpose.
3. **Self-document via naming**: File and function names are queries; agents grep efficiently.
4. **Pre-stage dependencies**: Include `Makefile` or `script/setup` that agents can run blindly; don't require dependency discovery.
5. **Define error contracts**: Each public function/endpoint has documented failure modes and error message formats.
6. **Include validation hooks**: Pre-commit scripts (linting, formatting) that agents can run before staging changes.
7. **Test-first scaffolding**: Generated tests are not mocks; they use real databases/services and validate actual behavior.
8. **Architect hints**: Comments indicating where agents should apply architect-before-coding (major refactors, new subsystems).

## Synthesis for a Generator Tool

A generator that produces agent-ready codebases must:
- Output deterministic structure (same ordering, predictable file layout).
- Include harness setup files (`Makefile`, CI workflow, environment setup).
- Generate `.claude/CLAUDE.md` with agent-friendly workflows.
- Provide example `.env.example` (not `.env`—no secrets in generated code).
- Include `repomap`-style documentation (class diagrams, call graphs) for agent discovery.
- Emit schema files for validation (e.g., `schemas/api-responses.json`).
- Pre-install common dependencies in lock files; don't rely on agents to discover.

## Unresolved Questions

1. **Prompt caching for generated code**: How should generated `.claude/CLAUDE.md` be structured to maximize MCP prompt cache hits when agents re-invoke?
2. **Generator-as-MCP-server**: Should a code generator expose a MCP tool endpoint for programmatic invocation by agents, or remain CLI-only?
3. **Trust model for generated harness**: If a generator outputs a GitHub Actions workflow, who audits it? Are there signed, verified workflow templates?
4. **Repo-map format standardization**: Aider's repomap is not standardized. Should generators emit a common format that all agents can consume?
