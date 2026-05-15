# Simulation_Scripts Modernization Roadmap

This roadmap tracks the active post-v2 cleanup and modernization work. Historical implementation plans live in `docs/plans/` or archived OpenSpec changes.

## Current Architecture Direction

- `+paraxial/` is the canonical package namespace for new code.
- `BeamFactory.create()` is the preferred high-level beam construction API.
- `src/` remains deprecated/transitional during the Strangler Fig migration.
- `examples/canonical/` is the onboarding path for new users.
- `examples/legacy/` is retained for archive, generator, research, and compatibility use only.
- GitHub Actions is the canonical CI system.

## Phase 1: Repository Hygiene

- Ignore local agent/tooling metadata such as `.opencode/` unless explicitly promoted to project tooling.
- Remove stale CI/configuration surfaces that no longer reflect the active workflow.
- Keep root-level planning documents either current or clearly marked as historical.

## Phase 2: Documentation Alignment

- Keep `README.md`, `docs/ARCHITECTURE.md`, `tests/README.md`, and `.atl/skill-registry.md` aligned on:
  - GNU Octave 11.1.0+ support.
  - MATLAB R2020b+ support.
  - `tests/test_all.m` / `portable_runner()` as canonical test entrypoints.
  - GitHub Actions workflow ownership.
  - `+paraxial/` and `BeamFactory.create()` as canonical API surfaces.

## Phase 3: Guardrails

- Keep `tests/modern/test_RepositoryGuardrails.m` registered in the portable suite.
- Prevent canonical examples from directly depending on deprecated `src/beams` paths.
- Verify public docs continue to identify canonical and deprecated surfaces correctly.
- Verify BeamFactory supported type names remain explicit.

## Phase 4: Packaging and Release Hardening

Before tagging a release:

- [ ] Run the portable test suite in Octave.
- [ ] Run the portable test suite in MATLAB, when a MATLAB runner/license is available.
- [ ] Confirm `DESCRIPTION` receives the tag-derived version in the release workflow.
- [ ] Confirm `.github/workflows/release.yml` uploads both `.tar.gz` and `.mltbx` artifacts.
- [ ] Smoke-check package installation when practical.
- [ ] Update `CHANGELOG.md`.

## Phase 5: Legacy and Addons Cleanup

- Classify `ParaxialBeams/Addons/` as runtime-required, plotting-only, vendored third-party, or removable.
- Keep legacy examples documented as archive/generator/research material.
- Avoid presenting legacy examples as the default user path.

## Completed Follow-up: `post-v2-modernization-next-steps`

The archived OpenSpec change `openspec/changes/archive/2026-04-30-post-v2-modernization-next-steps/` completed the bounded cleanup wave for:

- Clarify runner path setup so `+paraxial/` is resolved via the repo root package parent.
- Keep `src/` paths available only as deprecated/transitional compatibility paths.
- Inventory `ParaxialBeams/Addons/` before any migration or removal decision.
- Document compatibility reduction gates before reducing deprecated `src/` behavior.

## Explicit Non-Goals

- No beam physics rewrites in cleanup-only changes.
- No removal of `src/` without a dedicated migration SDD.
- No deletion of historical examples without usage review and compatibility policy updates.
