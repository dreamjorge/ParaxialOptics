# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added
- OpenSpec change plan for cleanup and modernization alignment.
- Repository guardrail test covering local tooling policy, active CI docs, canonical API docs, canonical examples, and BeamFactory registry.
- Post-v2 modernization roadmap.

### Changed
- Aligned documentation around GitHub Actions as canonical CI, Octave 11.1.0+ / MATLAB R2020b+ support, and `+paraxial/` / `BeamFactory` as canonical APIs.
- Marked the root pre-merge implementation plan as historical.

### Removed
- Stale CircleCI welcome-only configuration.

## [2026-04-15] - Legacy Migration Checkpoint

### Added
- Legacy compatibility regression suites under `tests/legacy_compat/`:
  - `test_HankelCompatibility.m`
  - `test_LegacyBeamConstructors.m`
  - `test_HankelAliasStaticDelegation.m`
  - `test_HankelAliasEdgeCases.m`
- Legacy-only runner: `tests/legacy_compat/run_legacy_compat.m`.

### Changed
- Updated canonical test entrypoint `tests/portable_runner.m` to include legacy compatibility suites.
- Expanded migration documentation and compatibility matrix in `docs/migration/LEGACY_MIGRATION_PLAN.md`.
- Documented test workflow and legacy-only command in `tests/README.md`.

### Fixed
- Aligned modal Gouy phase convention across HG/LG/Elegant/Hankel beam implementations.
- Hardened path bootstrap for legacy scripts and compatibility tests using `setpaths()` and `legacy/compat`.
