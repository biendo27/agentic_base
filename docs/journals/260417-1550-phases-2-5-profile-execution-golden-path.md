---
title: Phases 2-5 Profile Execution and Golden-Path Rollout
date: 2026-04-17 15:50
severity: Medium
component: Profile presets, starter runtime, verify canary, rollout docs
status: Resolved
---

## Context

Phases 2-5 were the execution half of the harness-profile rollout. The contract freeze from phase 1 was already done; this wave had to make that contract real in generator behavior, starter UI, verify output, tests, and migration docs.

## What Happened

Shipped the preset resolver, made `subscription-commerce-app` the actual CLI default lane, rendered profile-aware starter seams and verify gates from one policy source, refreshed the starter theme to the trustworthy-commerce family, and replaced the old provider-neutral payments starter with store-native `in_app_purchase`. Root docs, roadmap, changelog, migration guidance, and all phase files are now synced to that shipped behavior.

Verification also exposed a practical regression in the package slow canary. The generated app-shell smoke was doing more than it needed to and the package test was paying for native readiness locally even though CI already has a dedicated native gate. Fixed that by skipping module startup hooks in the app-shell smoke, draining the fake home-data timer before teardown, adding a fast verify mode for the package canary, and streaming verify output directly from the integration helper.

## Reflection

The contract work itself was straightforward. The expensive part was not architecture, it was test honesty. Once the default lane picked up real module seams, the old “just run create with verify and wait” strategy stopped being cheap or transparent. The right answer was not a bigger timeout. The right answer was to separate what the package smoke test must prove from what the dedicated native CI lane already proves.

## Decisions

Kept generated `verify.sh` fully capable for real repos, but let package smoke use `AGENTIC_VERIFY_FAST=1` so local regression coverage stays fast and legible. Kept native readiness in the dedicated CI job instead of duplicating it in the package canary. Kept the app-shell smoke focused on shell visibility rather than pretending plugin-backed module startup is part of a widget-shell assertion.

## Next

`dart analyze --fatal-infos`, docs tests, focused preset/generator tests, shell syntax checks, the full generated-app smoke file, and the full `dart test` suite all passed after the canary hardening. Remaining work is future generator polish and any expansion of non-default profile coverage.

Unresolved questions: none.
