# Post-PR Next Steps

This note captures work that should happen after the current BeamFactory/Addons repair PR is integrated. It intentionally keeps follow-up cleanup out of this PR so the reviewed diff stays focused.

## Immediate after merge

1. Sync the local branch from the integration branch.
2. Re-run the portable suite from a clean checkout:
   ```powershell
   octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
   ```
3. Confirm `git status --short` has no generated local state.

## Untracked file disposition

| Path | Current decision | Reason |
|------|------------------|--------|
| `.atl/.skill-registry.cache.json` | Do not commit; ignore/remove locally | Generated local cache, not project source. |
| `AGENTS.md` | Commit project guidance | High-signal repo instructions for future coding-agent sessions. |
| `docs/plans/2026-04-30-addons-deep-inventory-*.md` | Do not include in this PR | Historical planning material for the already-completed Addons inventory; only commit in a separate documentation/archive PR if maintainers want historical plans versioned. |
| `openspec/changes/second-solution-beams/` | Do not include in this PR | SDD artifacts for the already-merged second-solution beam feature. Archive or remove in a dedicated SDD housekeeping PR, not in this repair PR. |

## Follow-up PR candidates

### 1. SDD artifact housekeeping

- Decide whether `openspec/changes/second-solution-beams/` should be archived under `openspec/changes/archive/` with an `archive-report.md`, or discarded as stale untracked workspace output.
- If archived, verify it matches the implementation already in `origin/master` before committing.

### 2. Addons cleanup, narrowly scoped

- Start a dedicated OpenSpec change for `addons-copy-helpers-removal` before deleting any Addons files.
- Limit the first removal candidate set to:
  - `ParaxialBeams/Addons/copy2Ray.m`
  - `ParaxialBeams/Addons/copyElementRay.m`
  - `ParaxialBeams/Addons/copyElementsOnRay.m`
- Add/extend guardrails proving no references in active source, tests, or legacy examples before removal.
- Do not remove runtime-required, plotting-only, or vendored-license files in the same PR.

### 3. Documentation alignment

- If `AGENTS.md` remains accepted, keep its `BeamFactory.supportedTypes()` list aligned with `ParaxialBeams/BeamFactory.m` and `tests/modern/test_RepositoryGuardrails.m`.
- If future Addons cleanup proceeds, update `docs/ADDONS_INVENTORY.md`, `docs/ADDONS_CLEANUP_READINESS.md`, and guardrails in the same work unit.

## Non-goals for the current PR

- No additional Addons deletion.
- No OpenSpec archival for unrelated completed work.
- No package artifact builds.
- No physics or numerical behavior changes.
