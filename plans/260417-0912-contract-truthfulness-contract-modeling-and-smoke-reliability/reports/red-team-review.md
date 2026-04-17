# Red Team Review

## Summary

No critical reason to reject the plan. The main red-team pressure was scope control, not architecture replacement.

## Findings and Adjudication

| Severity | Finding | Disposition | Plan Update |
| --- | --- | --- | --- |
| High | Findings 1 and 2 are already fixed in the current tree; reopening broad doc edits would create churn without closing new risk. | Accept | Keep phase 01 as regression-proofing only. |
| High | A broad `core/contracts` redesign or `base.dart`/`part` repackaging would bloat the wave and distract from the actual mismatch. | Accept | Keep file-per-contract packaging; scope phase 02 to helper placement and test/doc sync only. |
| High | Smoke-speed work can silently weaken the generated repo contract if it rewrites `tools/verify.sh` or drops heavy coverage everywhere. | Accept | Make the preferred strategy an internal fast repo lane plus one honest slow canary. |
| Medium | Native readiness is the slowest gate; if the blocking policy is vague, implementation may either keep it everywhere or drop it too far. | Accept | Validate the blocking policy explicitly before implementation. |
| Medium | Guard tests can become brittle prose snapshots if they assert whole files instead of reviewed phrases/surfaces. | Accept | Keep phrase/surface-level guards only. |

## Net Result

The plan remains valid after red-team review, but with tighter boundaries:

1. No broad doc rewrite.
2. No contract-package redesign.
3. No silent weakening of verify semantics.
4. One explicit validation decision is required for the slow canary policy.

## Resolution Note

Proceed to validation. The main remaining decisions are policy choices, not missing research.
