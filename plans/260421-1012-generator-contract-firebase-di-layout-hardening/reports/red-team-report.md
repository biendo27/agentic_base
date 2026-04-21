# Red-Team Review Report

## Critical Findings Applied

- Phase ownership overlapped across `uni_links`, Firebase runtime, and Firebase-backed modules.
- Firebase setup needed rollback/atomic mutation requirements.
- Android native launch smoke was optional even though native boot was the observed failure mode.

## High Findings Applied

- Backwards compatibility for `upgrade` and `init` needed explicit rules.
- State-management validation needed `cubit`, `riverpod`, and `mobx`.
- Firebase command contract needed `.info/agentic.yaml`, project-dir, and toolchain resolution rules.
- Startup hook ordering and failure policy needed a real model.
- AdMob sample ids needed prod release-preflight rejection.

## Medium Findings Applied

- Dependency refresh needed measurable reports and non-circular tests.
- `run.sh` argument parsing needed `shift`/default behavior tests.
- Plan branch needed Gitflow-compatible feature branch.

## Remaining Decisions

- Fresh `create` emits only `tools/run.sh`.
- `upgrade` performs a breaking generator-owned script replacement with explicit warning, not a permanent wrapper.
- Firebase setup supports default platforms Android/iOS/web. Other selected platforms fail before mutation unless implemented.
- Android device/emulator launch smoke is blocking for claiming this plan complete.

**Status:** DONE

