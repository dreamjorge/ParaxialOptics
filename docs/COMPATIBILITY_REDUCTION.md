# Compatibility Reduction Plan

This document defines gates for any future reduction of deprecated `src/` behavior. It is intentionally separate from cleanup-only modernization work.

## Current Policy

- `+paraxial/` is the canonical namespace for new code.
- `BeamFactory.create()` is the preferred high-level construction API.
- `src/` remains deprecated/transitional during the Strangler Fig migration.
- Cleanup-only changes MUST NOT remove `src/` paths, classes, adapters, or compatibility tests.

## Required Gates Before Reducing `src/`

1. **Compatibility audit**
   - List all public classes/functions still reachable through `src/`.
   - Identify equivalent `+paraxial/` or `BeamFactory` migration paths.

2. **Test coverage**
   - Keep `tests/legacy_compat/` passing until the removal change explicitly updates the compatibility contract.
   - Add migration tests that prove canonical APIs cover the supported use cases.

3. **User-facing migration notes**
   - Document replacement imports/construction calls.
   - Mark removed aliases or adapters with clear before/after examples.

4. **Dedicated SDD change**
   - Create a separate OpenSpec change for any removal or behavior reduction.
   - Include rollback instructions and release-note requirements.

5. **Release coordination**
   - Update `CHANGELOG.md`.
   - Avoid bundling compatibility reduction with unrelated cleanup or physics changes.

## Non-Goals for Cleanup Changes

- No deletion of `src/`.
- No removal of legacy examples solely because they use deprecated paths.
- No beam physics rewrites.
- No change to `BeamFactory.supportedTypes()` names without a dedicated API change.

## Candidate Future Work

- Convert remaining direct `src/` example usage to `BeamFactory.create()` where examples are still maintained.
- Decide whether deprecated constructors should remain as adapters or move to a compatibility package.
- Split addon plotting helpers from runtime ray helpers after inventory follow-up.
