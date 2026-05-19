# AGENTS.md

High-signal repo guidance for future agent sessions. Prefer executable sources of truth (`tests/portable_runner.m`, workflows, `setpaths.m`) over stale prose.

## Project shape

- **Language**: MATLAB/GNU Octave library for paraxial beam propagation and wavefront analysis.
- **Runtime**: GNU Octave 11.1.0+ and MATLAB R2020b+.
- **Canonical namespace**: `+paraxial/`
- **Deprecated/transitional**: `src/` adapters (transitional, use canonical instead).
- **Factory API**: `BeamFactory.create()` in `ParaxialBeams/BeamFactory.m`.
- **Supported beam types**: `gaussian`, `hermite`, `laguerre`, `elegant_hermite`, `elegant_laguerre`, `hankel`, `hankel_hermite`, `nhermite`, `xlaguerre`, `elegant_nhermite`, `elegant_xlaguerre`.

## Path setup

- **Preferred**: `run('setpaths.m')` from repo root.
- **Package resolution**: Add repo root (not internal `+package` folders) so MATLAB/Octave resolves `+paraxial/` through package semantics.
- **Test setup**: `tests/portable_runner.m` adds repo root, `ParaxialBeams/`, `legacy/compat/`, and `tests/modern/`.

## Test commands

**Full portable suite (Octave)**:
```powershell
octave --no-gui --eval "run('tests/test_all.m')"
```

**CI-style (Octave)**:
```powershell
octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

**MATLAB CI**:
```powershell
matlab -batch "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

## CI/CD

- **Canonical CI**: GitHub Actions (`.github/workflows/octave.yml`, `.github/workflows/matlab.yml`).
- **Release**: `.github/workflows/release.yml` generates Octave `.tar.gz` and MATLAB `.mltbx` on git tags `v*`.
- **Test runner**: `tests/portable_runner.m` — script-based and class-based tests.

## Release checklist

1. Update `CHANGELOG.md` with version and changes.
2. Update `DESCRIPTION` version field.
3. Create git tag: `git tag v1.0.0 && git push origin v1.0.0`.
4. Release workflow builds packages automatically.

## Non-goals

- Do not expand `src/` unless maintaining legacy compatibility.
- Do not add `+package` subfolders directly to path (breaks package semantics).
- Do not modify deprecated adapters without explicit migration justification.