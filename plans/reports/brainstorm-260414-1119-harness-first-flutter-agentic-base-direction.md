---
title: Harness-First Flutter Agentic Base Direction
type: brainstorm-report
status: agreed-direction
created_at: 2026-04-14T11:19:00+07:00
updated_at: 2026-04-14T11:32:28+07:00
project: agentic_base
skill: ck:brainstorm
---

# Harness-First Flutter Agentic Base Direction

## Summary

The repo has already moved beyond the idea stage. It is now a real Flutter agent-ready generator with contracts, docs, modules, CI/deploy scaffolding, and a green package test suite.

However, the current north star is still not accurate enough. The product still leans toward a scaffold generator. The agreed direction is to shift it into a harness-first generator: the generated repo must help an agent understand, run, verify, evolve, and release the system with mechanical guardrails and explicit human approval boundaries.

Main conclusion:

- Flutter-first
- extract the reusable kernel later
- support all mainstream Flutter product app profiles through a tiered support model
- do not claim v1 support for game/Flame, heavy native/FFI, embedded/kiosk, or 3D/XR

## Problem Statement

The original goal was to build a Dart tool that generates Flutter codebases where agentic coding handles most execution and humans remain responsible for review and the most important decisions.

Current problems:

- the original vision leaned too much toward package choices and scaffold surfaces
- it did not define clearly what a trustworthy agentic codebase actually is
- it did not separate scaffold, harness, and future cross-stack reuse clearly enough
- the claim of supporting "all Flutter apps" becomes an overclaim unless the support envelope and support tiers are explicit

## Requirements

### Functional

- generate a Flutter repo with strong architecture and high agent legibility
- support multiple mainstream app profiles
- allow modules/capabilities to be attached based on project needs
- provide a release flow with explicit human approval boundaries
- allow provider replacement without breaking capability contracts

### Non-Functional

- reliability is the top priority
- deterministic, reproducible, measurable
- honest product claims, no overpromising
- maintainable, extractable later
- legible enough for agents to operate in the repo with minimal extra context

## Current Repo Assessment

The current repo is strong at:

- scaffold generation
- repo contract
- docs plus thin adapters
- module install/remove flows
- generated scripts
- CI/deploy contract

The current repo is weaker at:

- harness artifact model
- evidence bundles for agent runs
- an eval pipeline richer than `analyze + test`
- support tier encoding
- manifest-level capability/provider modeling
- a sufficiently strong SDK/version-manager strategy

Short verdict:

- scaffold-strong
- harness-partial
- cross-stack-not-ready

## Evaluated Approaches

### Option A — Universal Flutter Kitchen-Sink Scaffold

Idea:

- create one very large base
- try to cover every need in the default scaffold
- let each app disable what it does not use

Pros:

- appears complete at first glance
- easy to demo
- reduces up-front choices for users

Cons:

- over-engineered
- drifts quickly
- makes repos harder for agents to understand
- makes support claims hard to keep honest
- reduces reliability because of too many variant paths

Verdict:

- not recommended

### Option B — Cross-Stack Core From Day One

Idea:

- design a generic core for Flutter, web, backend, and other stacks immediately
- treat Flutter as only the first adapter

Pros:

- looks strategic
- attractive if the long-term goal is multi-stack reuse

Cons:

- abstraction happens too early
- Flutter runtime/build/release constraints are too specific
- likely to produce a weakest-common-denominator core
- slows reliability hardening

Verdict:

- not recommended at the current stage

### Option C — Harness-First, Flutter-First, Tiered Support

Idea:

- make Flutter excellent first
- separate harness core, Flutter adapter, and capability packs
- support multiple app profiles through support tiers

Pros:

- honest
- practical
- reliability-first
- still keeps a path open for later kernel extraction
- matches the current state of the repo

Cons:

- requires accepting that the system is not generic yet
- requires accepting that some profiles are not first-class in v1

Verdict:

- recommended

## Final Recommended Solution

Updated repo definition:

> `agentic_base` should be a harness-first Flutter project generator that emits repos agents can understand, run, verify, evolve, and release with mechanical guardrails and explicit human approval boundaries.

### Strategic Direction

- Flutter-first
- extract the reusable kernel later
- do not force cross-stack generic abstractions from day one

### Support Envelope

Claim support for mainstream Flutter product apps.

Do not claim v1 support for:

- game/Flame
- heavy native/FFI
- embedded/kiosk
- 3D/XR

### App Profile Model

Supported profile catalog:

- consumer-app
- internal-business-app
- subscription-commerce-app
- content-community-app
- offline-first-field-app

Each app should not use "all profiles" as its identity.

Each app should define:

- `primary_profile`: exactly one profile
- `secondary_traits`: zero or more traits

Example:

```yaml
app_profile:
  primary: subscription-commerce-app
  secondary:
    - consumer-app
    - content-community-app
```

### Support Tiers For V1

Tier-1:

- consumer-app
- internal-business-app
- subscription-commerce-app

Tier-2:

- content-community-app
- offline-first-field-app

Rationale:

- tier-1 covers the most common business and commercial app categories
- content/community remains close to consumer-app but does not need first-class maturity in v1
- offline-first field apps are materially harder because of sync, conflict resolution, retry behavior, and local-first correctness

## Recommended Architecture

### 1. Harness Core

This layer should stay generic enough to extract later:

- manifest/state machine
- docs contract
- run/eval contract
- evidence artifact model
- approval gates
- support tier matrix
- capability/provider registry
- failure taxonomy
- quality score / release-readiness model

### 2. Flutter Adapter

This layer remains Flutter-specific:

- flutter/fvm/puro environment handling
- flutter create
- flavors
- codegen
- analyze/test/golden/integration/native checks
- Fastlane/mobile release flow
- runtime/bootstrap/theme/router/localization/state wiring

### 3. Capability Packs

Composable capability layer driven by app needs:

- auth
- analytics
- crash reporting
- notifications
- payments
- ads
- storage
- remote config
- maps
- media/device/location

Capabilities must stay separate from providers.

Example:

- capability: crash-reporting
- providers: firebase-crashlytics, sentry

## Implementation Considerations

### Reliability Principles

The generated repo should optimize for agent reliability:

- deterministic commands
- deterministic versioning
- explicit human boundaries
- measurable quality gates
- reproducible verification
- observable runs with evidence

### Versioning Principle

Do not use:

- always use the newest available SDK

Use instead:

- use the newest tested SDK
- separate the upgrade flow from the normal generation flow

### Repo Design Consequence

The tool should not optimize first for:

- package breadth
- superficial scaffold polish
- raw module count

The tool should optimize first for:

- legibility
- evaluability
- enforceability
- run reproducibility
- release governance

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Overclaiming "all Flutter apps" | trust erosion | use support envelope and support tiers |
| Generic design too early | wrong abstractions, slower progress | stay Flutter-first, extract later |
| Kitchen-sink base | harder repos, more agent failures | use primary profile plus secondary traits |
| Shallow eval model | false confidence | design harness contract plus evidence bundles |
| SDK drift | flaky generation and verification | pin newest tested SDK |
| Provider coupling | hard vendor replacement | capability/provider split in manifest and seams |

## Success Metrics

### Product-Level

- a generated repo can be understood and operated by an agent with minimal extra context
- a generated repo exposes a reproducible verification flow
- the release flow has explicit human boundaries
- support claims map cleanly to support tiers

### Harness-Level

- each meaningful run emits clear evidence artifacts
- the eval pipeline is layered enough to reduce false positives
- the repo contract is mechanically enforceable
- the upgrade flow does not destroy a previously verified baseline

### Architecture-Level

- capability swaps do not change business-facing contracts
- the app profile model does not create a kitchen-sink scaffold
- Flutter-specific concerns stay separate from harness core

## Validation Criteria

- the new north star does not conflict with the current repo direction
- the direction is specific enough to derive a manifest schema
- the direction is specific enough to derive a support-tier matrix
- the direction is specific enough to derive an implementation plan without re-guessing intent

## Next Steps

1. Define `Harness Contract v1`
2. Define `Support Tier Matrix v1`
3. Define the manifest schema for app profile, capabilities, providers, quality gates, and approval gates
4. Define the eval/evidence pipeline
5. Define the approval state machine
6. Only then derive the implementation plan

## Recommendation

The next step should be to design `Harness Contract v1`.

Do not jump into implementation yet.

If the contract remains unclear:

- the module model will drift
- the docs will overclaim
- later cross-stack extraction will rest on the wrong abstraction boundary

## References

- [README.md](../../README.md)
- [docs/01-project-overview-pdr.md](../../docs/01-project-overview-pdr.md)
- [docs/04-system-architecture.md](../../docs/04-system-architecture.md)
- [docs/05-project-roadmap.md](../../docs/05-project-roadmap.md)

## Unresolved Questions

- Should tier-2 profiles have some profile-specific gates in v1, or should they inherit only the core gates?
- Should quality score be represented as one scalar or multiple dimensions?
- Should the capability/provider registry live entirely in `.info/agentic.yaml`, or should it move into a separate schema/file?
