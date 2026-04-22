---
type: research
created: 2026-04-21
scope: generated-cicd-native-runtime
---

# Research Report: Generated CI/CD And Native Runtime Contracts

## Executive Summary

Generated project CI should prove the app is buildable without credentials, but deployment lanes must remain explicit human/credential boundaries. PR CI should not build `prod` if `tools/build.sh` refuses to use `env/prod.env.example` for production. That refusal is correct; the workflow is wrong if it calls prod in a credentialless PR.

iOS AdMob setup requires `GADApplicationIdentifier` in `ios/Runner/Info.plist`. The generated module currently inserts before the first `</dict>`, which can place the key inside nested plist dictionaries. The fix is a root-dict-aware insertion plus a regression test.

## Sources

- [Flutter Google Mobile Ads cookbook](https://docs.flutter.dev/cookbook/plugins/google-mobile-ads)
- [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup)
- [GitHub Actions workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub Actions dependency caching](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching)
- [GitLab manual jobs](https://docs.gitlab.com/ci/jobs/job_control/)
- [GitLab protected environments](https://docs.gitlab.com/ci/environments/protected_environments.html)

## Key Findings

1. Google Mobile Ads requires Android metadata and an iOS `GADApplicationIdentifier` entry. iOS crashes at launch if the application ID is absent or unreadable by the native SDK.
2. Firebase setup is credentialed and project-specific. The CLI should check for `firebase` and `flutterfire`, then run an explicit setup command or give actionable install instructions. It should not auto-configure Firebase during normal `create`.
3. FlutterFire should be rerun when platforms or Firebase products change. Generated Firebase setup must be repeatable.
4. GitHub and GitLab deployment jobs should use protected/manual environments for staging/prod. This matches the user's boundary: human owns credentials/product decisions/prod publish.
5. Generated workflows must not contain unresolved Mason tokens. Contract tests should scan generated YAML for `{{...}}` after rendering while allowing GitHub expressions `${{ ... }}`.

## Recommended Generated CI Shape

### GitHub Generated Project

- `ci.yml`:
  - runs on PRs to `main`/`develop` and pushes to `develop`
  - verifies harness contract
  - builds `dev` and `staging` debug artifacts only
  - does not build `prod`
  - uploads `artifacts/evidence`
- `cd-dev.yml`:
  - optional push-to-develop or manual dev distribution
  - requires Firebase Distribution variables/secrets if invoked
- `cd-staging.yml`:
  - manual workflow dispatch
  - protected `staging` environment
- `cd-prod.yml` and `release.yml`:
  - manual/tag-driven, protected `production` environment
  - calls `release-preflight` before store upload/build

### GitLab Generated Project

- Keep manual deployment jobs.
- Use protected environments for staging/prod.
- Keep macOS native validation explicit. If a faster Linux verify job is added, it cannot replace native validation for iOS readiness.

## Native Runtime Gates

- Contract test: generated `Info.plist` has one top-level `GADApplicationIdentifier`.
- macOS simulator smoke: generate app with ads module and run/build iOS simulator in CI when native/module paths change.
- Physical iOS device run remains human/local due Apple signing/provisioning. CI should detect and document this boundary, not fake it.

## Unresolved Questions

None.
