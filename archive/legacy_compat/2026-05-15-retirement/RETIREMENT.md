# Legacy Compat Retirement Record

**Date:** 2026-05-15  
**Branch:** `chore/archive-legacy-compat-and-modernize-paths`  
**Status:** Archived

## Rationale

The `tests/legacy_compat/` test suite was created during the Week 6 phase of the legacy migration (Strangler Fig Strategy) to validate the removal of deprecated `HankeleHermite` and `HankeleLaguerre` aliases.

All four legacy removal gates (A–D) from `docs/migration/LEGACY_MIGRATION_PLAN.md` were marked complete:
- **Gate A (Usage):** No internal references to aliases in `src/`, `examples/canonical/`, or `tests/modern/`.
- **Gate B (Test):** Alias removal was validated via dedicated branch runs.
- **Gate C (Documentation):** README and migration docs no longer recommend legacy aliases.
- **Gate D (Release):** Deprecation warnings were emitted and aliases were removed in a stable release.

The tests in this folder were **transitional artifacts**: they validated a one-time migration event, not ongoing behavior. Once the migration was complete, these tests had no further value and would fail if executed (because `legacy/compat/` is empty and `src/` is no longer on the default path).

## Archived Files

| File | Purpose | Retirement Reason |
|------|---------|-------------------|
| `run_legacy_compat.m` | Runner with `LEGACY_ALIAS_REMOVAL_MODE=1` | Runner for obsolete test suite |
| `test_LegacyBeamConstructors.m` | Validated `GaussianBeam(X,Y,params)` legacy ctor | Legacy constructors deprecated; modern API (`w0, lambda`) is the contract |
| `test_HankelCompatibility.m` | Validated `Hankele*` alias removal behavior | Aliases already removed; test would fail |
| `test_HankelAliasStaticDelegation.m` | Validated static delegation parity `Hankele*` → `Hankel*` | Aliases removed; test would fail |
| `test_HankelAliasEdgeCases.m` | Edge cases for static delegation | Aliases removed; test would fail |

## Preservation Note

These files are archived **without warranty**. They are kept for historical reference and rollback capability only.

If you need to re-validate the alias removal migration in the future:
1. Restore files from this archive
2. Add `src/` to the path manually
3. Run with `LEGACY_ALIAS_REMOVAL_MODE=1` in an isolated environment

## Next Steps

- `tests/legacy_compat/` folder removed from repo
- `src/` path now conditional (commented by default, opt-in only)
- Modern API (`+paraxial/`, `BeamFactory.create()`) is the default entrypoint
- See `openspec/changes/2026-05-15-modernization-migration/` for migration SDD artifacts

## Related Documentation

- `docs/migration/LEGACY_MIGRATION_PLAN.md`
- `docs/migration/ALIAS_REMOVAL_RELEASE_PLAN.md`
- `legacy/compat/README.md`