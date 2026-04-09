# Phase 4 — CI/CD & Deploy (v0.4.0)

## Context Links
- [Architecture Report](../reports/brainstorm-260409-1103-agentic-base-architecture.md) — Sections 9, 16.15
- [Phase 1](./phase-01-tool-scaffold-and-create-command.md)

## Overview
- **Priority**: P2
- **Status**: Completed
- **Effort**: 15h
- **Depends on**: Phase 1 (Phase 2-3 not strictly required)

Add CI/CD workflow generation to generated projects (GitHub Actions + Fastlane), build `deploy` command (triggers workflows via `gh` CLI), and enhance Makefile/tools/ scripts.

## Requirements

### Functional
- Generated project includes full GitHub Actions workflows: ci.yml, cd-dev.yml, cd-staging.yml, cd-prod.yml, release.yml
- Generated project includes Fastlane setup (Appfile, Fastfile, Matchfile)
- `agentic_base deploy <dev|staging|prod>` triggers GitHub Actions via `gh workflow run`
- Makefile targets delegate to tools/ scripts
- All tools/ scripts use _common.sh shared functions

### Non-Functional
- CI workflow runs in <10 minutes
- Deploy command validates git state before triggering

## Related Code Files

### Files to Create
- `lib/src/cli/commands/deploy_command.dart`

### Mason Brick Updates (agentic_app)
- `.github/workflows/ci.yml` — lint + test + build (all flavors)
- `.github/workflows/cd-dev.yml` — deploy dev (on merge to develop)
- `.github/workflows/cd-staging.yml` — deploy staging (manual trigger)
- `.github/workflows/cd-prod.yml` — deploy prod (manual, requires approval)
- `.github/workflows/release.yml` — Fastlane store release
- `fastlane/Appfile`
- `fastlane/Fastfile`
- `fastlane/Matchfile`
- Update `Makefile` to delegate to tools/
- Finalize all `tools/*.sh` scripts

### Tests
- `test/src/cli/commands/deploy_command_test.dart`

## Implementation Steps

### Step 1: GitHub Actions Workflows
1. Create `ci.yml` template:
   - Trigger: PR to main/develop
   - Steps: checkout → setup Flutter → pub get → dart analyze → flutter test → build APK (all flavors)
   - Cache: pub cache, build_runner output
2. Create `cd-dev.yml`: trigger on merge to develop → build dev → deploy to Firebase App Distribution
3. Create `cd-staging.yml`: manual trigger → build staging → deploy to TestFlight/Internal Testing
4. Create `cd-prod.yml`: manual trigger + environment approval → build prod → Fastlane release
5. Create `release.yml`: Fastlane-specific release workflow

### Step 2: Fastlane Setup
1. Create `Appfile` template (app_identifier, apple_id from env vars)
2. Create `Fastfile` with lanes: build_dev, build_staging, build_prod, deploy_ios, deploy_android
3. Create `Matchfile` for iOS code signing
4. All sensitive values from env vars (not hardcoded)

### Step 3: Deploy Command
1. Create `deploy_command.dart`
2. Flow: validate git status (all committed, pushed) → `gh workflow run cd-{env}.yml`
3. Display workflow URL after trigger
4. Handle: `gh` not installed, not authenticated, workflow not found
5. Write tests

### Step 4: Finalize Scripts
1. Ensure all tools/ scripts consistent with _common.sh
2. `build.sh` — accepts flavor arg, applies obfuscation for all flavors
3. `ci-check.sh` — runs lint + test + build (mirrors CI workflow locally)
4. `release.sh` — version bump + changelog + git tag
5. All scripts self-documented with `--help`

## Todo List
- [x] ci.yml workflow template
- [x] cd-dev.yml, cd-staging.yml, cd-prod.yml workflows
- [x] release.yml workflow
- [x] Fastlane setup (Appfile, Fastfile, Matchfile)
- [x] Deploy command (gh workflow run)
- [x] Finalize Makefile targets
- [x] Finalize all tools/ scripts with _common.sh

## Success Criteria
- [x] Generated project CI workflow runs successfully on GitHub Actions
- [x] `agentic_base deploy dev` triggers cd-dev.yml via gh CLI
- [x] Fastlane lanes configured for all flavors
- [x] All tools/ scripts work standalone and via Makefile
- [x] CI-check script mirrors actual CI workflow

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| iOS signing requires real certs | Can't test iOS CI | Document setup, test Android only in CI |
| gh CLI not installed | Deploy fails | Doctor checks gh, clear error message |
| GitHub Actions billing | Cost for private repos | Document free tier limits |

## Next Steps
→ Phase 5: Extended Modules (independent from Phase 4)
