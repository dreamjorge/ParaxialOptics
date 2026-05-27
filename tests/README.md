# ParaxialOptics Test Suite

This directory contains tests for the ParaxialBeams simulation library.

## Running Tests

`tests/portable_runner.m` is the canonical non-interactive runner. `tests/test_all.m` is the portable wrapper used by humans and CI.

For local development setup before direct script invocation, run `setpaths()` from the repository root. This preserves MATLAB/Octave package semantics by adding the repo root as the parent of `+paraxial/` instead of adding internal `+package` folders directly.

```bash
octave --no-gui --eval "run('tests/test_all.m')"
```

Or run the runner directly in Octave:

```bash
octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

MATLAB:

```bash
matlab -batch "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

GitHub Actions is the canonical CI system and uses the same non-zero `portable_runner()` status contract.

## Test Coverage

### PhysicalConstants
- Wave number calculation
- Rayleigh distance
- Waist at z position
- Radius of curvature
- Gouy phase

### GridUtils
- 2D grid creation
- Frequency grid generation
- Static meshgrid methods

### FFTUtils
- FFT roundtrip
- Transfer function
- Propagation

### GaussianParameters
- Rayleigh distance, waist, wave number
- Vector z-coordinate support
- Gouy phase
- Divergence angle

### Hermite and Laguerre Models
- HermiteParameters, LaguerreParameters
- GaussianBeam, HermiteBeam, LaguerreBeam
- ElegantHermiteBeam, ElegantLaguerreBeam

### Legacy Compatibility
- `legacy_compat/test_HankelCompatibility.m`
- `legacy_compat/test_LegacyBeamConstructors.m`
- `legacy_compat/test_HankelAliasStaticDelegation.m`
- `legacy_compat/test_HankelAliasEdgeCases.m`

These suites ensure backward compatibility for historical scripts while modern APIs remain the canonical entrypoint.

### Repository Guardrails
- `modern/test_RepositoryGuardrails.m`
- Verifies local tooling policy, active CI documentation, canonical API documentation, canonical example boundaries, and BeamFactory type registry.

### AnalysisUtils
- **gradientRZ**: Calculate ray slope in r-z plane
  - Interior point calculation with 10x10 field slices
  - Handles zero gradient (uniform fields) gracefully
  
- **gradientXYZ**: Calculate local gradients in 3D
  - Returns three gradient values (mzx, mzy, mxy)
  - Bounds checking with 64x64 field slices

### ElegantHermiteParameters
- Stores n and m mode indices
- Alpha complex parameter at z>0
- Alpha at waist matches k/(2*zr)
- Default indices (n=0, m=0)

### ElegantLaguerreParameters
- Stores l (topological charge) and p (radial index)
- Alpha matches ElegantHermiteParameters formula
- Default indices (l=0, p=0)

## Test Patterns

Tests follow consistent patterns:
- Use `fprintf` for PASS/FAIL output
- Increment `passed` and `failed` counters
- Tolerance: 1e-5 for physical values, 1e-10 for phase values
- Octave/MATLAB compatible classdef syntax

## Portable Runner

`tests/portable_runner.m` is the canonical non-interactive runner used by `tests/test_all.m`.
It executes canonical tests and legacy compatibility suites. The runner adds the repository root for `+paraxial/` package resolution and keeps `src/` paths only as deprecated/transitional compatibility paths.

For a faster legacy-only check during migration work:

```matlab
run('tests/legacy_compat/run_legacy_compat.m')
```
