# Research Report: GitLab macOS/iOS Validation Gate for Generated Flutter Apps

Date: 2026-04-10 10:41 Asia/Saigon
Scope: planning guidance only; no code changes

## Executive Summary

GitLab cannot use generic hosted Linux runners as the gate for iOS/macOS validation. GitLab's own macOS runner setup requires a macOS machine, Bash shell executor, Xcode, and a `macos` tag. Flutter's iOS docs also assume Xcode/macOS for native iOS build and validation. For generated Flutter apps, the contract should say this gate is macOS-only and fails open only in the sense that the job stays unavailable until a macOS runner exists. Do not imply Linux can validate native flavor regressions.

For v1 deploy/env selection, manual per-environment jobs are the better GitLab contract than pipeline variables. GitLab docs say pipeline variables have high precedence, can override other values, and GitLab 17.7+ recommends pipeline inputs over pipeline variables. Manual jobs plus protected environments are more explicit and safer for `dev`, `staging`, and `prod`. Use pipeline variables later only if a single parametric deploy path becomes necessary.

## Research Methodology

- Sources consulted: 6 official docs pages
- Key terms: GitLab macOS runner, shell executor, Xcode, manual jobs, protected environments, pipeline variables, GitLab environments, Flutter iOS build
- Date range: GitLab docs crawled 2-4 weeks ago; Flutter docs crawled/published within the last 2 months
- Credibility: official GitLab and Flutter docs only; no tutorials or community posts used

## Key Findings

### 1. Realistic GitLab contract for macOS validation

The contract should be explicit, not implied:

- The validation job runs on a macOS runner registered to the project.
- The runner uses the `shell` executor.
- The runner is tagged `macos`.
- Xcode is installed and configured on that machine.
- CocoaPods and iOS simulator tooling are available if the validation script needs them.

That matches GitLab's macOS runner setup guidance and Flutter's iOS build prerequisites.

Recommended contract language:

> GitLab-generated projects must emit a dedicated native validation job for iOS/macOS flavor checks. That job must target a macOS runner (`tags: [macos]`), use a shell executor on a macOS machine, and require Xcode. Linux-only runners are not valid for this gate.

### 2. Can generic hosted Linux runners handle this gate?

No.

Reason:

- GitLab's macOS runner docs describe a macOS machine with Bash shell executor and Xcode as prerequisites.
- Flutter iOS build/validation flows depend on Xcode/macOS.

Explicit runner requirement for the plan:

- `macos` runner
- `shell` executor
- Xcode installed
- runner availability documented as a hard prerequisite for GitLab native validation

If the project has only Linux runners, it can still do Dart analyze/test, but not native iOS/macOS validation. The plan should say that plainly.

### 3. Deploy/env selection for v1

Ranked recommendation:

1. Manual per-env jobs
2. Pipeline variables, only later

Why manual jobs win for v1:

- GitLab supports `when: manual` directly for deployment jobs.
- Manual jobs can be paired with protected environments, which is the right default for `prod`.
- Static environment names make the pipeline readable and auditable.
- Pipeline variables have high precedence and can override other values unexpectedly.
- GitLab 17.7+ recommends pipeline inputs over pipeline variables, so variables are already the less-preferred path.

Practical v1 shape:

- `deploy_dev`
- `deploy_staging`
- `deploy_prod`
- `deploy_prod` protected/manual

This is more verbose than a single env variable, but safer and easier to reason about in generated projects.

### 4. Trade-off matrix

| Decision point | Option | Fit | Risk | Recommendation |
| --- | --- | --- | --- | --- |
| Native validation runner | Generic hosted Linux runner | None | Silent false confidence | Reject |
| Native validation runner | macOS runner with shell executor + Xcode | Required | Runner availability burden | Use |
| Env selection | Pipeline variables | Medium for automation, low for safety | High precedence, easier to misroute deploys | Defer |
| Env selection | Manual per-env jobs | High for v1 | Slightly more YAML | Use |

## Plan Wording Recommendation

Use wording like this in the plan:

> GitLab support for generated Flutter apps must include a macOS-native validation gate. The generated `.gitlab-ci.yml` must require a macOS runner (`tags: [macos]`), shell executor, and Xcode. GitLab support is conditional on that runner existing; there is no Linux fallback for iOS/macOS validation. Deployment selection in v1 should use explicit manual jobs per environment rather than pipeline variables.

## Success Criteria Recommendation

- Generated GitLab apps include a native validation job that is clearly macOS-only.
- The generated docs state the macOS runner/Xcode requirement upfront.
- The generated deploy contract uses explicit per-environment manual jobs in v1.
- `prod` is protected/manual by default.
- The plan/docs do not claim Linux runners can validate iOS/native flavor regressions.
- Repo-level docs distinguish package-repo CI from generated-project GitLab support.

## Documentation Caveats

- The generator does not provision Apple hardware, Xcode, signing certs, or App Store credentials.
- GitLab Linux runners are acceptable for Dart-only checks, not the native gate.
- If GitLab env selection later moves to variables, document the precedence risk and note that GitLab now prefers pipeline inputs over pipeline variables.
- Keep the docs honest: GitLab support is a generated-project capability, not a promise that the `agentic_base` repo itself runs GitLab CI.

## Sources

- GitLab macOS runner setup: https://docs.gitlab.com/runner/configuration/macos_setup/
- GitLab runner overview: https://docs.gitlab.com/ci/runners/
- GitLab manual jobs and protected environments: https://docs.gitlab.com/ci/jobs/job_control/
- GitLab environments: https://docs.gitlab.com/ci/environments/
- GitLab CI/CD variables: https://docs.gitlab.com/ci/variables/
- Flutter iOS development: https://docs.flutter.dev/platform-integration/ios/install-ios/install-ios-from-macos
- Flutter iOS release/build: https://docs.flutter.dev/deployment/ios

## Unresolved Questions

- None for the research question itself. Implementation detail left open: how the CLI will trigger GitLab deploy jobs, but that is outside this research scope.
