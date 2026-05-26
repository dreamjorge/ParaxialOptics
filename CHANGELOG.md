# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Changed
- Build release packages from an explicit allowlist to exclude internal process and agent metadata.
- Clarify canonical `+paraxial/` usage while preserving legacy compatibility surfaces.

### Removed
- Removed tracked local agent registry metadata from the public repository surface.
- Archived root-level historical planning notes under `docs/archive/`.

## [v1.0.0] - 2026-05-19 — First Release

### Added
- **Canonical package namespace `+paraxial/`**: Full beam propagation library in modern package format.
- **BeamFactory.create()**: Factory API for creating beam instances by name (gaussian, hermite, laguerre, elegant_hermite, elegant_laguerre, hankel, hankel_hermite, nhermite, xlaguerre, elegant_nhermite, elegant_xlaguerre).
- **Beam classes**: GaussianBeam, HermiteBeam, LaguerreBeam, ElegantHermiteBeam, ElegantLaguerreBeam, HankelHermite, HankelLaguerre, NHermiteBeam, XLaguerreBeam, ElegantNHermiteBeam, ElegantXLaguerreBeam.
- **Parameter classes**: GaussianParameters, HermiteParameters, LaguerreParameters, ElegantHermiteParameters, ElegantLaguerreParameters.
- **Field propagators**: FFTPropagator, AnalyticPropagator.
- **Ray propagators**: RayTracer, HankelRayTracer, RayBundle, RayTracePropagator, HankelRayTracePropagator.
- **Utilities**: GridUtils, FFTUtils, PhysicalConstants.
- **GitHub Actions CI**: octave.yml and matlab.yml workflows for portable test suite.
- **Release workflow**: release.yml generates Octave .tar.gz and MATLAB .mltbx packages.
- **Portable test runner**: tests/portable_runner.m for Octave and MATLAB compatibility.

### Changed
- Strangler Fig migration: `+paraxial/` is canonical, `src/` is deprecated transition adapter.
- AGENTS.md reflects current project shape with canonical API guidance.
- README.md updated with project structure, installation, and usage examples.
- setpaths.m configured for `+paraxial/` only by default.

### Deprecated
- `src/` adapters are transitional. Use `BeamFactory.create()` or direct `+paraxial/` classes.
- `examples/legacy/` contains archived research scripts (not recommended for new users).

### Removed
- Stale CircleCI configuration.
- Plans and migration docs moved to archive/openspec.
- AI agent directories (.atl, .pi, .opencode, .worktrees, .agent).

## [Unreleased] — Historical

See git history for pre-v1.0.0 changes.