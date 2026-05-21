# Simulation_Scripts

Paraxial beam propagation and wavefront analysis in GNU Octave and MATLAB.

**Author:** Ugalde-Ontiveros J.A.

[![Octave CI](https://github.com/dreamjorge/Simulation_Scripts/actions/workflows/octave.yml/badge.svg)](https://github.com/dreamjorge/Simulation_Scripts/actions/workflows/octave.yml)
[![MATLAB CI](https://github.com/dreamjorge/Simulation_Scripts/actions/workflows/matlab.yml/badge.svg)](https://github.com/dreamjorge/Simulation_Scripts/actions/workflows/matlab.yml)

## Project Status

**v1.0.0** — First release. `+paraxial/` is the canonical namespace.

`src/` is deprecated and only kept for backward compatibility during the Strangler Fig migration. Use `BeamFactory.create()` or direct `+paraxial/` classes.

GitHub Actions is the canonical CI system for this repository. The active workflows are:

Active workflows:
- `.github/workflows/octave.yml` — Octave portable tests.
- `.github/workflows/matlab.yml` — MATLAB portable tests.
- `.github/workflows/release.yml` — Package generation on `v*` tags.

## Project Structure

```
Simulation_Scripts/
├── +paraxial/                  # Canonical package namespace
│   ├── +beams/                 # Beam classes
│   ├── +parameters/            # Parameter classes
│   ├── +computation/           # Formula/logic layer
│   ├── +propagation/           # Field and ray propagation
│   └── +visualization/         # Visualization utilities
├── ParaxialBeams/              # Utilities (BeamFactory, GridUtils, etc.)
├── examples/
│   ├── canonical/              # Recommended examples for new users
│   └── legacy/                 # Archived research scripts
├── tests/
│   ├── portable_runner.m       # Canonical test runner (CI uses this)
│   ├── modern/                 # Test suite for +paraxial/ classes
│   └── edge_cases/             # Edge case and regression tests
├── src/                        # Deprecated transition adapters
├── docs/
│   ├── ARCHITECTURE.md         # Architecture documentation
│   └── ROADMAP.md              # Active roadmap
├── setpaths.m                  # Path initialization
├── CHANGELOG.md
└── DESCRIPTION                 # Package metadata
```

## Quick Start

### Install Package

**Octave:**
```matlab
pkg install 'https://github.com/dreamjorge/Simulation_Scripts/releases/latest/download/simulation_scripts-1.0.0.tar.gz'
```

**MATLAB:** Double-click the `.mltbx` from [releases](https://github.com/dreamjorge/Simulation_Scripts/releases).

### Manual Setup

```matlab
% Option 1: setpaths() utility
setpaths

% Option 2: Add paths directly
addpath('+paraxial/+beams', '+paraxial/+parameters', '+paraxial/+computation');
addpath('ParaxialBeams');
```

### Create and Propagate Beam

```matlab
% Via BeamFactory (preferred)
beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);

% Create grid
grid = GridUtils(1024, 1024, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();

% Field at waist
field = beam.opticalField(X, Y, 0);

% Propagate via FFT
prop = FFTPropagator(grid, 632.8e-9);
field_z = prop.propagate(beam, 0.1);
```

## Supported Beam Types

| Type | Class | Parameters |
|------|-------|------------|
| Gaussian | `GaussianBeam` | w0, λ |
| Hermite | `HermiteBeam` | w0, λ, n, m |
| Laguerre | `LaguerreBeam` | w0, λ, l, p |
| Elegant Hermite | `ElegantHermiteBeam` | w0, λ, n, m |
| Elegant Laguerre | `ElegantLaguerreBeam` | w0, λ, l, p |
| Hankel | `HankelLaguerre` | w0, λ, l, p, type |
| Hankel Hermite | `HankelHermite` | w0, λ, n, m, type |

## Beam API Contract

Every beam implements:

```matlab
field = beam.opticalField(X, Y, z)    % [Ny x Nx] complex
params = beam.getParameters(z)       % BeamParameters at z
name = beam.beamName()               % 'gaussian', 'hermite_2_1', etc.
```

## Propagation Methods

```matlab
% FFT (angular spectrum)
prop = FFTPropagator(grid, lambda);
field = prop.propagate(beam, z);

% Analytic (direct formula)
prop = AnalyticPropagator(grid);
field = prop.propagate(beam, z);

% Ray tracing
prop = RayTracePropagator(grid, 'RK4', 1e-3);
bundle = prop.propagate(beam, z);
```

## Utilities

```matlab
% Physical constants
k = PhysicalConstants.waveNumber(lambda);
zr = PhysicalConstants.rayleighDistance(w0, lambda);

% Grid creation
grid = GridUtils(Nx, Ny, Dx, Dy);
[X, Y] = grid.create2DGrid();
[Kx, Ky] = grid.createFreqGrid();

## Beam API Contract

Every beam implements:

```matlab
field = beam.opticalField(X, Y, z)    % [Ny x Nx] complex
params = beam.getParameters(z)       % BeamParameters at z
name = beam.beamName()               % 'gaussian', 'hermite_2_1', etc.
```

## Propagation Methods

Three interchangeable propagation methods:

```matlab
% FFT (angular spectrum)
prop = FFTPropagator(grid, lambda);
field = prop.propagate(beam, z);

% Analytic (direct formula)
prop = AnalyticPropagator(grid);
field = prop.propagate(beam, z);

% Ray tracing
prop = RayTracePropagator(grid, 'RK4', 1e-3);
bundle = prop.propagate(beam, z);
```

## Factory Pattern — BeamFactory

```matlab
% All beams via Factory
g  = BeamFactory.create('gaussian', 100e-6, 632.8e-9);
hg = BeamFactory.create('hermite', 100e-6, 632.8e-9, 'n', 2, 'm', 1);
lg = BeamFactory.create('laguerre', 100e-6, 632.8e-9, 'l', 1, 'p', 0);
hl = BeamFactory.create('hankel', 100e-6, 632.8e-9, 'l', 2, 'type', 1);
```

## Canonical Examples

Recommended examples for new users (in `examples/canonical/`):

| File | Description |
|------|-------------|
| `MainGauss_refactored.m` | Gaussian beam propagation |
| `MainMultiMode.m` | Multi-mode Hermite/Laguerre |
| `ExampleRayTracing.m` | Ray tracing visualization |

## PhysicalConstants

```matlab
k   = PhysicalConstants.waveNumber(lambda);
zr  = PhysicalConstants.rayleighDistance(w0, lambda);
R   = PhysicalConstants.radiusOfCurvature(z, zr);
gouy = PhysicalConstants.gouyPhase(z, zr);
```

## GridUtils

```matlab
grid = GridUtils(Nx, Ny, Dx, Dy);
[X, Y] = grid.create2DGrid();
[Kx, Ky] = grid.createFreqGrid();
[r, theta] = grid.createPolarGrid();
```

## FFTUtils

```matlab
fftOps = FFTUtils(true, true);  % normalize, shift
G = fftOps.fft2(field);
```

## Tests

```bash
# Octave
octave --no-gui --eval "run('tests/test_all.m')"

# MATLAB
matlab -batch "run('tests/test_all.m')"
```

CI uses `tests/portable_runner.m` and fails on non-zero exit code.

## Version

```matlab
ver = simulation_scripts_version()
% Returns 'v1.0.0' or 'v1.0.0-3-gabc1234' if dirty
```

## Compatibility

- **GNU Octave 11.1.0+**
- **MATLAB R2020b+**

No `classdef` folders are used. All files are individual `.m` files.

## Changelog

See `CHANGELOG.md` for release history.

## Uninstall

**Octave:** `pkg uninstall simulation_scripts`
**MATLAB:** `matlab.addons.uninstall('Simulation_Scripts')`
