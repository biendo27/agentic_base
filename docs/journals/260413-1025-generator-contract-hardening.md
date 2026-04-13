# Generator Contract Hardening

**Date**: 2026-04-13 10:25
**Severity**: Medium
**Component**: CLI generator, init/add/remove, app and feature bricks
**Status**: Resolved

## What Happened

Finished the generator-contract-hardening pass in `/Users/biendh/base`. The CLI now uses typed metadata/provenance instead of raw string/map inference, `init` resolves evidence before writing config, add/remove mutations are journaled transactionally, and app/feature scaffolds stay parity-complete across `cubit`, `riverpod`, and `mobx`.

## The Brutal Truth

The old contract was too loose. It let templates guess, which is how you end up with generated projects that look valid but only fail after the user already paid the cost. That is a bad generator contract, full stop.

## Technical Details

Touched `lib/src/config/project_metadata.dart`, `lib/src/config/init_project_metadata_resolver.dart`, `lib/src/modules/project_mutation_journal.dart`, `lib/src/generators/generated_project_contract.dart`, and the brick templates/docs. Verification in `plans/reports/pm-260413-1021-generator-contract-hardening-sync.md` confirmed typed metadata/provenance config, safe `init` analysis setup, transactional add/remove journaling, module integration generation, cubit/riverpod/mobx parity, feature parity, analytics wiring, and expanded smoke coverage.

## What We Tried

Kept the public command surface stable. Rejected splitting the generator into more brick families or dropping flags, because that would have traded one contract problem for a bigger compatibility mess.

## Root Cause Analysis

The generator depended on inference and template drift instead of one canonical contract. Once state and module variants expanded, that guesswork stopped being safe.

## Lessons Learned

If the generator can infer it, it can misinfer it. Contract changes, journaling, docs, and smoke tests need to move together or the scaffold will drift again.

## Next Steps

Keep future state/module changes aligned with the journal/profile/docs update flow. No open blockers.
