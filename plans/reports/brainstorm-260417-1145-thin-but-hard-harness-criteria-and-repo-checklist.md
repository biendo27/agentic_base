---
title: Thin-But-Hard Harness Criteria And Repo Checklist
type: brainstorm-report
status: agreed-direction
created_at: 2026-04-17T11:45:00+07:00
updated_at: 2026-04-17T11:45:00+07:00
project: agentic_base
skill: ck:brainstorm
---

# Thin-But-Hard Harness Criteria And Repo Checklist

## Summary

This report turns the agreed direction into an evaluation frame for `agentic_base`.

Main conclusion:

- keep V1 as a Flutter-first CLI generator
- keep the default base thin
- make every shipped claim mechanically enforced
- use `subscription-commerce-app` as the default Tier 1 profile if one default profile must be chosen
- do not treat profile metadata as enough; profile must affect starter behavior and gate behavior

Short verdict on current repo:

- harness core: strong
- Flutter adapter: strong
- capability packs: solid
- profile execution contract: partial
- run evidence: good
- agent observability: not present

## What "Thin But Hard" Means

### Thin

The default generated base should include only surfaces that most real apps need on day 0:

- machine contract
- canonical docs
- deterministic scripts
- environment and flavor shell
- router
- DI seam
- network seam
- error and result contract
- theme shell
- i18n shell
- codegen pipeline
- CI and release wrappers
- one honest starter journey proving the shell works

The default base should not include optional business capabilities just because many apps might want them later:

- ads
- payments provider runtime
- maps
- camera
- analytics runtime
- crash reporting runtime
- social login runtime
- remote config runtime

Those belong in capability packs.

### Hard

Every kept surface must be contract-backed and test-backed.

Hard means:

- docs match generated output
- manifest fields are validated
- scripts have stable names and real behavior
- support claims map to actual tests and gates
- provider choices are inspectable and replaceable
- approval pauses are finite and explicit
- SDK policy is deterministic

If a claim is not enforced, it is not part of the hard base.

## Official Criteria

### C1. Minimal Core Surface

Pass when:

- the generated default repo contains only universal app-shell surfaces
- optional capabilities are excluded from the default base
- starter output does not force product-specific providers

Fail when:

- the default repo behaves like a kitchen-sink starter
- optional capabilities are welded into app startup

### C2. Mechanical Contract Truth

Pass when:

- README, docs, thin adapters, manifest, scripts, and validators tell the same story
- package tests fail if the story drifts

Fail when:

- docs overclaim support or behavior
- manifest fields exist without validators

### C3. Deterministic Execution Surface

Pass when:

- setup, run, test, verify, build, release-preflight, and release are stable and script-driven
- local and CI use the same gate vocabulary

Fail when:

- CI invents a second contract
- important actions depend on undocumented manual shell sequences

### C4. Replaceable Capability Seams

Pass when:

- each optional capability has a declared seam
- providers are inspectable in `.info/agentic.yaml`
- changing provider does not require redefining core contracts

Fail when:

- capability packs create hidden control planes
- provider choice leaks into unrelated layers

### C5. Profile-As-Behavior, Not Metadata

Pass when:

- `primary_profile` changes starter defaults in meaningful ways
- Tier 1 profiles change required gate behavior, not only labels
- unsupported profiles are rejected or clearly non-first-class

Fail when:

- profile only changes docs, summaries, or manifest text
- `required_gate_pack` is stored but not used to alter gate execution

### C6. Eval And Evidence Integrity

Pass when:

- verify and release-preflight emit named gates and inspectable evidence
- skipped and blocked states are explicit
- evidence is safe to inspect and redactable

Fail when:

- success is mostly prose
- evidence cannot explain why a run passed or failed

### C7. Finite Human Approval Model

Pass when:

- human pauses are explicit and few
- current V1 pauses are limited to product decisions, credentials, and final prod publish

Fail when:

- the system requires vague human intervention
- PR merge review is implicitly mandatory despite CI-first policy

### C8. Deterministic SDK Policy

Pass when:

- the repo uses `newest_tested`, not `latest`
- preferred and resolved toolchains are both inspectable
- drift is reported honestly

Fail when:

- the tool silently jumps SDKs
- the product claims "always latest"

### C9. Honest Observability Vocabulary

Pass when:

- the repo distinguishes run evidence from richer agent telemetry
- `observability` means what the implementation really ships

Fail when:

- the word suggests transcript, trace, token, or tool-trajectory telemetry that does not exist

### C10. Cross-Stack Extraction Discipline

Pass when:

- harness core, Flutter adapter, and capability packs are separated
- cross-stack reuse remains a later extraction step

Fail when:

- Flutter-specific concerns leak into the harness core
- the repo claims a generic kernel before proving it

## Anti-Patterns

- kitchen-sink default base
- metadata-only profiles
- "latest SDK" as policy
- fake observability vocabulary
- hidden provider control planes
- cross-stack-first abstraction
- optional capabilities welded into app bootstrap

## Recommended Default V1 Profile

If V1 must pick one default profile, use:

- `subscription-commerce-app`

Why:

- stays in Tier 1
- forces stronger thinking about auth, entitlements, monetization seams, analytics, release readiness, and configuration
- covers more mainstream product concerns than `consumer-app`
- remains more realistic for V1 than `content-community-app`, which is broader but still Tier 2

Recommended default secondary trait:

- `multi-locale`

Not recommended as default traits:

- `real-time`
- `media-heavy`
- `geo-aware`

## Repo Checklist

### A. Already Strong

- [x] single machine-readable contract in `.info/agentic.yaml`
- [x] finite canonical doc surface in root docs and generated docs
- [x] deterministic script surface for setup, run, test, verify, build, release-preflight, release
- [x] explicit human approval states
- [x] toolchain manager and version contract with deterministic fallback
- [x] capability packs with provider mapping and install/remove flows
- [x] support envelope and support tier docs exist
- [x] package validators reject unsupported harness contract drift
- [x] generated-app smoke tests cover multiple state runtimes
- [x] local `dart analyze --fatal-infos` is clean

### B. Strong But Needs Tightening

- [ ] rename or narrow `observability` semantics to mean run evidence, not agent telemetry
- [ ] make README and docs say more explicitly that current observability is run-level, not agent-level
- [ ] audit module list against the "thin base" rule and keep optional capabilities fully opt-in
- [ ] keep command files moving toward the repo's under-200-LOC target

### C. Partial And Needs Real Work

- [ ] make `primary_profile` affect generated starter behavior in meaningful ways
- [ ] make Tier 1 profiles alter required verify behavior, not only `required_gate_pack` labels
- [ ] define profile-specific starter deltas:
  - `consumer-app`
  - `internal-business-app`
  - `subscription-commerce-app`
- [ ] define profile-specific gate deltas:
  - authenticated sanity for `internal-business-app`
  - entitlement or monetization readiness for `subscription-commerce-app`
  - keep Tier 2 profile extras advisory until deterministic
- [ ] add tests proving different profiles produce materially different starter or gate surfaces

### D. Missing For Deeper Harness Direction

- [ ] decide whether to keep `observability` as a quality dimension or split it into `evidence_quality`
- [ ] define a future V2 concept for agent telemetry:
  - agent run transcript
  - tool trajectory
  - token or cost accounting
  - screenshot or device trace attachments
- [ ] avoid implementing those V2 concepts in V1 docs unless they are truly shipped

## Priority Order

### P0

- turn profile from metadata into behavior
- turn Tier 1 gate packs from labels into execution differences

### P1

- tighten observability vocabulary
- choose and document the default V1 profile as `subscription-commerce-app`

### P2

- continue shrinking orchestration files
- expand profile-specific generated-app tests after the behavior exists

## Concrete Acceptance Checks

The repo can claim "thin but hard" more confidently when these checks are true:

1. creating the same app with `consumer-app` and `subscription-commerce-app` yields at least one meaningful starter or verify difference
2. Tier 1 and Tier 2 profiles do not emit the same required gate behavior
3. no optional capability is required for day-0 app boot
4. every capability provider claim in the manifest maps to a visible seam
5. docs never imply agent telemetry that the repo does not emit
6. SDK policy remains `newest_tested`

## Final Assessment

Current repo status against the agreed direction:

- thin base: mostly good
- hard contract: good
- truthful support envelope: good
- profile-backed execution: weak
- run evidence: good
- agent telemetry: absent by design, should stay unclaimed

This means the repo is already a credible harness-first Flutter CLI generator.

The next important leap is not adding more modules.

The next important leap is making profile and support-tier claims mechanically real.

## Next Steps

- adopt `subscription-commerce-app` as the default V1 profile if no stronger product reason exists
- implement profile-specific starter deltas
- implement profile-specific required gate deltas for Tier 1 only
- narrow `observability` wording before adding any richer telemetry concept
- keep V1 Flutter-first and resist early cross-stack extraction

## Unresolved Questions

- should `subscription-commerce-app` become only the default, or also the most heavily tested golden path
- should `observability` be renamed now, or only when a broader telemetry model is introduced
- how much starter variation by profile is enough to call the profile behaviorally real without turning the base into a kitchen sink
