# Red-Team Review

## Verdict

Proceed, but keep the wave focused. The draft is sound if it avoids scope inflation.

## Main Attacks

1. **Dry-run scope can explode.**
   - Risk: every command gets bespoke preview logic and output drift.
   - Required mitigation: define one shared dry-run contract first, then retrofit commands through that abstraction.

2. **Docs cleanup can become a rewrite spiral.**
   - Risk: spending too long on prose while contract bugs remain.
   - Required mitigation: Phase 01 only sets taxonomy and removes contradictions. Do not rewrite every sentence in every doc.

3. **Multi-theme can become over-engineering.**
   - Risk: adding theme registries, settings UI, and family switching complexity before any second family exists.
   - Required mitigation: build family-ready architecture, but ship one default family unless validation explicitly asks for more.

4. **Broad `freezed` adoption is likely wasteful.**
   - Risk: codegen churn on generic containers that gain little from unions.
   - Required mitigation: prioritize `AppFailure`; require a higher bar for `AppResponse` and pagination.

5. **File-splitting can fight docs drift if done late.**
   - Risk: phase ordering causes architecture docs to describe structures that are about to change again.
   - Required mitigation: keep docs sync last, but lock target structure decisions early in the plan.

## Recommended Revisions Applied

- theme phase explicitly targets architecture readiness, not feature-rich theme packs
- contract-modeling phase explicitly limits `part` to codegen leaf files
- docs sync is final phase, not interleaved prose churn
- dry-run phase centers on one shared abstraction

## Remaining Risks

- `doctor` may still need a deliberate exception for globally activated Dart tools
- `brick` dry-run semantics may be less valuable than other commands and should not dominate the wave
- snapshot doc handling still needs user confirmation

## Recommendation

Validate:

- dry-run semantics for read-only commands
- multi-theme rollout scope
- `freezed` scope
- snapshot doc policy
