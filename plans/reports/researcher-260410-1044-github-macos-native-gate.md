---
title: "GitHub Actions macOS native gate for generated Flutter apps"
date: 2026-04-10
status: research
scope: "CI strategy for enforcing macOS/iOS validation on generated Flutter apps"
sources:
  - ".github/workflows/ci.yml"
  - "my_app/tools/ci-check.sh"
  - "docs/06-deployment-guide.md"
  - "plans/260410-1026-dual-github-gitlab-cicd-selection/plan.md"
  - "plans/260410-1026-dual-github-gitlab-cicd-selection/phase-03-tests-docs-and-validation.md"
  - "https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax"
  - "https://docs.github.com/en/enterprise-cloud@latest/actions/reference/workflows-and-actions/workflow-syntax"
  - "https://docs.flutter.dev/add-to-app/ios/project-setup"
---

# GitHub Actions macOS native gate for generated Flutter apps

## Executive Summary

Best shape here: keep one always-on GitHub Actions workflow for PRs and pushes to `main`, with Ubuntu jobs for package analyze/test and a separate macOS job that validates the generated app contract by running `./tools/ci-check.sh`. That script already adds a Darwin-only `flutter build ios --simulator` step, so the macOS job is the actual native gate.

Do not use workflow-level `paths` / `paths-ignore` on a required check. GitHub documents that skipped workflows from path or branch filtering stay Pending and can block merges. If you need to save minutes later, gate only non-required helper jobs; do not skip the native gate itself.

`macos-latest` is acceptable for a rolling image, but it is not the lowest-risk choice for a required gate. GitHub says `-latest` is a stable image alias, not necessarily the newest OS vendor release. For a long-lived gate, pinning a macOS image is safer than depending on drift.

## Research Methodology

- Sources consulted: 6
- Source credibility:
  - High: GitHub docs, Flutter docs, repo-local workflow/script files
  - Medium: plan files, because they are intent and not implementation
- Date range:
  - Repo state read on 2026-04-10
  - Flutter doc page last updated 2025-11-11
- Key terms:
  - required checks, path filtering, macos-latest, iOS simulator, Flutter Apple Silicon, generated app validation

## Key Findings

### 1. Current repo contract

- Root CI today is Ubuntu-only analyze/test in [`.github/workflows/ci.yml`](/Users/biendh/base/.github/workflows/ci.yml#L1-L29).
- The generated app contract already has a macOS branch in [`my_app/tools/ci-check.sh`](/Users/biendh/base/my_app/tools/ci-check.sh#L9-L36): on Darwin it adds `flutter build ios --simulator`.
- The repo deployment guide still describes only package CI at root and no native gate in root automation in [`docs/06-deployment-guide.md`](/Users/biendh/base/docs/06-deployment-guide.md#L10-L23).

### 2. GitHub Actions semantics

- GitHub docs are explicit: if a workflow is skipped due to branch or path filtering, checks for that workflow remain Pending and can block merging when required.
- GitHub runner docs show `macos-latest` is an ARM64 M1 image and that `-latest` means latest stable image, not vendor-newest OS.

### 3. Flutter/macOS behavior

- Flutter docs note that Apple Silicon Macs build iOS simulator targets as `arm64`, and some plugins can fail there unless simulator architectures are adjusted.
- That makes the macOS job a real regression detector for native flavor and plugin integration issues, not just a platform vanity check.

### 4. Plan fit

- Current plan text already says root GitHub Actions should validate both scaffold variants, but it does not yet state the macOS native gate explicitly.
- That gap should be closed in [`plans/260410-1026-dual-github-gitlab-cicd-selection/phase-03-tests-docs-and-validation.md`](/Users/biendh/base/plans/260410-1026-dual-github-gitlab-cicd-selection/phase-03-tests-docs-and-validation.md#L56-L77) and the parent plan.

## Trade-off Matrix

| Option | Coverage | Complexity | Maintenance | Cost | Risk | Rank |
| --- | --- | --- | --- | --- | --- | --- |
| One workflow, Ubuntu analyze/test + separate macOS native job, no path filters | High | Medium | Low | Medium | Low | 1 |
| Two workflows, package CI and native gate separated | High | High | Medium | Medium | Medium | 2 |
| Path-filtered workflow / required job skipping | Medium | Low | Low | Low | High | 3 |

## Recommendation

1. Keep a single required GitHub Actions workflow on PRs and pushes to `main`.
2. Add a separate macOS job for native validation.
3. Make that job run the generated app contract end-to-end:
   - set up Flutter
   - generate or enter the generated app workspace
   - run `./tools/ci-check.sh`
   - let the script execute the Darwin-only `flutter build ios --simulator` step
4. Do not put workflow-level path filters on the required workflow.
5. If branch protection should expose one check only, add a final aggregate gate job; otherwise require the job checks directly.

### Runner label guidance

- Best default for a required gate: pin a macOS image, not `macos-latest`.
- If you do use `macos-latest`, treat it as a deliberate rolling-image choice, not a stability guarantee.
- I would rank `macos-15` above `macos-latest` for this repo if the goal is a durable gate with fewer surprise breakages.

## Plan Wording

Suggested wording for `plan.md` and phase 03:

> Root GitHub Actions CI remains the enforcement point for generated-app validation. Keep Ubuntu jobs for package analyze/test, and add a separate macOS job that exercises a generated app end-to-end by running `./tools/ci-check.sh`, including the iOS simulator build gate. Do not use workflow-level path filters on required checks.

## Acceptance Criteria

- PRs and pushes to `main` always trigger the macOS native gate.
- A generated app that fails `flutter build ios --simulator` fails the macOS job.
- Required checks cannot be bypassed by workflow path filtering.
- Root CI still covers package analyze/test on Ubuntu.
- Plan/docs distinguish package automation from generated-app native validation.

## Limitations

- I did not inspect branch protection settings in GitHub; recommendation assumes required checks are enforced there.
- I did not implement or test the workflow shape; this is planning guidance only.

## References

- [GitHub workflow syntax docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub workflow syntax docs, enterprise mirror](https://docs.github.com/en/enterprise-cloud@latest/actions/reference/workflows-and-actions/workflow-syntax)
- [Flutter iOS project setup](https://docs.flutter.dev/add-to-app/ios/project-setup)
- [Repo CI workflow](/Users/biendh/base/.github/workflows/ci.yml)
- [Generated app ci-check contract](/Users/biendh/base/my_app/tools/ci-check.sh)
- [Deployment guide](/Users/biendh/base/docs/06-deployment-guide.md)
