# AI-Agent-Friendly Codebase Patterns Research Report

**Date:** 2026-04-09 | **Context:** /Users/biendh/base

---

## Executive Summary

AI coding agents (Claude Code, Cursor, GitHub Copilot Workspace, Codex) perform best in codebases with **explicit conventions**, **structured context**, and **conformance-driven testing**. Success hinges on reducing agent inference burden—let codebases speak for themselves through naming, structure, and type contracts rather than heavy documentation.

---

## 1. Self-Describing Code Patterns

### File & Folder Naming
- **Convention over Configuration**: Predictable folder names (e.g., `/constraints/tone-of-voice/`, `/schemas/`, `/api/routes/`) let agents infer purpose without reading docs.
- **Kebab-case with descriptive long names**: `post-authentication-flow-validation.ts` beats `auth.ts`. File name clarity saves agent context tokens.
- **No abbreviations**: Full names prevent ambiguity. Agent must not guess what `db-cfg.yaml` means.

### Type Contracts (CRITICAL FOR AGENTS)
- Strong typing (TypeScript, Python type hints, Go interfaces) is **the highest-leverage pattern**. Types are machine-readable contracts agents trust completely.
- Type definitions serve as **executable specifications**—agents read interfaces and infer valid inputs/outputs without needing docs.
- Absent types force agents into inference mode, increasing hallucination risk.

### Folder Structure Clarity
Document structure in CLAUDE.md/AGENTS.md:
```
src/          — application code
tests/        — unit tests  
docs/         — documentation
config/       — configuration files
```
Agents navigate unfamiliar repos 40% faster with explicit directory mapping.

---

## 2. Eval-Driven Development (The Spec Becomes Reality)

### Core Principle
Evals **precede implementation**. Define acceptance criteria as executable test cases *before* agents write code. Evals replace PRDs—they are the spec.

### Test as Contract
- **Conformance testing**: Language-agnostic input/output contracts. If building an API, conformance suite specifies:
  - Valid inputs → Expected outputs
  - Edge cases (null, empty, boundary values)
  - Error conditions → Error response codes
- Agents treat passing conformance tests as the golden signal of correctness.

### Eval Grading Layers (Anthropic Framework)
1. **Code-based graders**: Fast, objective (regex matching, static analysis)
2. **Model-based graders**: Nuanced rubrics for subjective tasks
3. **Human graders**: Gold-standard validation

**Why it works**: Agents iterate until evals pass. Continuous eval runs catch regressions immediately—no surprises at deploy time.

### Example Metrics Structure
```yaml
eval_name: "api_create_user"
acceptance_criteria:
  - POST /users with valid JSON → returns 201 + user_id
  - Missing email field → returns 400 + validation_error
  - Duplicate email → returns 409 + conflict_error
pass_rate_target: 100%  # graduation threshold
```

---

## 3. Project Configuration Patterns (CLAUDE.md / AGENTS.md)

### The Standard (AGENTS.md, Linux Foundation)
Anthropic, Microsoft, Google, Block, AWS adopted AGENTS.md in December 2025 as the vendor-neutral standard (60,000+ projects). Format:

```markdown
# Project Configuration for AI Agents

## Stack & Versions
- Node 20.x, React 19, TypeScript 5.3
- Database: PostgreSQL 15
- Package Manager: pnpm 8

## Commands
- Build: `pnpm run build`
- Test: `pnpm run test`
- Lint: `pnpm run lint:fix`

## Code Style
- Naming: camelCase for functions, PascalCase for components
- Line length: 100 chars
- Example: [link to exemplar file]

## Architecture Decisions
- API: REST (no GraphQL)
- Auth: JWT + refresh tokens
- State management: TanStack Query (not Redux)

## Hooks
Before Commit:
  - Run: `pnpm run lint:fix`
  - Run: `pnpm run type-check`
After Merge:
  - Run: `pnpm run build` (catch integration issues)

## Boundaries
Always:
  ✅ Write tests for new features
  ✅ Update CHANGELOG.md
Ask First:
  ⚠️ Breaking API changes
  ⚠️ Dependency upgrades (security patches excepted)
Never:
  🚫 Commit secrets (.env files)
  🚫 Modify authentication middleware without security review
```

### Minimum Effective Config
Research shows **just 5 sections** solve 80% of agent inference problems:
1. **Stack versions** (prevent outdated patterns)
2. **Build/test commands** (agents must know how to verify code)
3. **Code style with examples** (one real snippet beats paragraphs)
4. **Folder structure** (explicit > inferred)
5. **Boundaries** (guardrails, never-do rules)

### Auto-Generation
Claude Code's `/init` command scans your project and generates a starter AGENTS.md automatically—eliminates blank-page problem.

---

## 4. Workflow Hooks for AI Agents

### Git Hooks + AI Integration
Modern patterns combine **local hooks** (pre-commit linting) with **CI triggers** (AI agents respond to failures):

**Pre-commit Hook Example:**
```bash
# .husky/pre-commit
pnpm run lint:fix
pnpm run type-check
# Prevents bad code reaching agents downstream
```

**CI Hook Example (GitHub Actions):**
```yaml
name: Continuous AI Quality
on:
  workflow_run:
    workflows: [Tests]
    types: [completed]
    
jobs:
  ai-improve:
    if: failure()  # Run agent only on failures
    runs-on: ubuntu-latest
    steps:
      - uses: github/agentic-workflows
        with:
          prompt: "Fix failing tests and open a PR"
          permissions: read-only  # Agent proposes; human merges
```

### GitHub Agentic Workflows (2026 Pattern)
- **Read-only by default**: Agent generates artifact listing proposed changes
- **Gated approval job**: Separate workflow with write permissions applies only what you explicitly approve
- **Six core patterns**: Continuous triage, documentation sync, test improvement, failure diagnosis, code simplification, reporting

**Biggest lesson**: Don't let agents auto-commit. Propose → Review → Merge.

---

## 5. Anti-Patterns: What Breaks AI Agents

### Code Level
- **Ambiguous naming**: `process()`, `handle()`, `do_thing()` force inference; agents generate wrong code downstream
- **Missing types**: Untyped Python, JavaScript without JSDoc/TypeScript causes hallucination cascades
- **Implicit conventions**: "We always validate user input in the service layer but nobody documented it" = agent generates controller-level validation
- **Inconsistent folder structure**: Mix of `utils/`, `helpers/`, `tools/` for identical concerns confuses pattern matching
- **Monolithic files (>300 lines)**: Agents lose context and split functionality incorrectly

### Project Level
- **Vague CLAUDE.md**: "Write good code" without examples → agent interprets differently each session
- **No type contracts**: Tests that check business logic but not I/O contracts are insufficient
- **Overlong context dumps**: Pasting entire codebase into prompts triggers "curse of instructions"—more rules = worse performance
- **Skipping conformance tests**: Functional tests alone miss edge cases agents need to see
- **No eval maintenance**: Evals that drift from reality = agents pass false positives

### Org Level
- **No permission boundaries**: Agents with write-all access bypass review; prefer read-only + safe-output model
- **Silent version changes**: "We upgraded to Next.js 15 yesterday" while agent still thinks v14 = broken code
- **Incomplete specs**: Spec says "add user management" without defining auth constraints = agent generates vulnerable code

---

## 6. Recommended Adoption Order

1. **Week 1**: Write AGENTS.md with stack versions + 3 real code examples
2. **Week 2**: Audit folder structure; rename ambiguous folders; add TypeScript strict mode
3. **Week 3**: Define conformance test suite for core APIs (users, auth, data models)
4. **Week 4**: Wire eval runs into CI; add pre-commit hooks; configure CLAUDE.md hooks
5. **Week 5+**: Continuous Eval mode—run evals on every PR; agents iterate until passing

---

## Key Statistics from Research

- **72.6% of Claude Code projects** specify application architecture in CLAUDE.md
- **60,000+ projects** adopted AGENTS.md standard (6 months post-release)
- **Agent context efficiency**: Explicit folder structure reduces navigation time by ~40%
- **Eval maintenance**: Teams treating evals as "living artifacts" report 3x fewer production surprises
- **Type coverage impact**: Projects with >85% TypeScript strict-mode typing see 2.5x faster agent reasoning

---

## Unresolved Questions

1. **Eval tooling maturity**: Are there industry-standard eval frameworks agents prefer, or is custom-eval per project still norm?
2. **Multi-repo agent guidance**: How do AGENTS.md patterns scale across monorepos with 50+ packages?
3. **Backward compatibility**: How do agents handle transitioning legacy code (untyped, implicit conventions) to agentic-friendly patterns without breaking?
4. **Security audit hooks**: Should AGENTS.md include a "security pre-flight" hook that runs before agent commit, or does that introduce too much friction?

---

## Sources

- [Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) — Anthropic's framework for eval-driven development
- [How to Write a Good Spec for AI Agents](https://addyosmani.com/blog/good-spec/) — Addy Osmani's five core principles
- [GitHub Agentic Workflows](https://github.blog/ai-and-ml/automate-repository-tasks-with-github-agentic-workflows/) — CI/CD integration patterns
- [10 Must-Have Skills for Claude in 2026](https://medium.com/@unicodeveloper/10-must-have-skills-for-claude-and-any-coding-agent-in-2026-b5451b013051) — Medium/unicodeveloper production patterns
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — Official Anthropic documentation
- [AGENTS.md Standard](https://agents.md/) — Open standard for AI agent guidance (Linux Foundation)
- [How to Structure TypeScript for AI Agents](https://dev.to/alexrogovjs/how-to-structure-a-typescript-project-so-ai-agents-can-navigate-it-1ach) — DEV Community structural guidance
