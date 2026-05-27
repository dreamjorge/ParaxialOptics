# ParaxialOptics Modernization Roadmap

This roadmap tracks public cleanup and modernization work for ParaxialOptics. Internal plans, agent notes, generated site scaffolding, and release scratch reports are intentionally kept out of `docs/` for the v1.0.1 public surface.

## Current Architecture Direction

- `+paraxial/` is the canonical package namespace for new code.
- `BeamFactory.create()` is the preferred high-level beam construction API.
- `src/` remains deprecated/transitional during the Strangler Fig migration.
- `examples/canonical/` is the onboarding path for new users.
- `examples/legacy/` is retained for archive, generator, research, and compatibility use only.
- GitHub Actions is the canonical CI system.

## Phase 1: Repository Hygiene

- Ignore local agent/tooling metadata such as `.opencode/` and `.atl/` unless explicitly promoted to project tooling.
- Remove stale CI/configuration surfaces that no longer reflect the active workflow.
- Keep planning documents, agent notes, release scratch reports, and generated site scaffolding out of the default public documentation surface.

## Phase 2: Documentation Alignment

- Keep `README.md`, `docs/ARCHITECTURE.md`, and `tests/README.md` aligned on:
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
- [ ] Confirm `DESCRIPTION` uses Octave package metadata format and receives the tag-derived version in the release workflow.
- [ ] Confirm `.github/workflows/release.yml` stages packages through `tools/stage_release_package.sh` and uploads both `.tar.gz` and `.mltbx` artifacts.
- [ ] Smoke-check package installation when practical.
- [ ] Update `CHANGELOG.md`.

## Phase 5: Legacy and Addons Cleanup

- Classify `ParaxialBeams/Addons/` as runtime-required, plotting-only, vendored third-party, or removable.
- Keep legacy examples documented as archive/generator/research material.
- Avoid presenting legacy examples as the default user path.

## Completed Cleanup Baseline

The v1.0.x cleanup wave established these public invariants:

- Clarify runner path setup so `+paraxial/` is resolved via the repo root package parent.
- Keep `src/` paths available only as deprecated/transitional compatibility paths.
- Inventory `ParaxialBeams/Addons/` before any migration or removal decision.
- Document compatibility reduction gates before reducing deprecated `src/` behavior.
- Keep `docs/` focused on public architecture, roadmap, compatibility, and addon policy documents.

## Explicit Non-Goals

- No beam physics rewrites in cleanup-only changes.
- No removal of `src/` without a dedicated compatibility change.
- No deletion of historical examples without usage review and compatibility policy updates.
