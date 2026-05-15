# Simulation_Scripts Architecture

## Overview

MATLAB/Octave library for paraxial optical beam propagation simulation. Supports Gaussian, Hermite-Gaussian, Laguerre-Gaussian, and Elegant beam modes with multiple propagation methods.

`+paraxial/` is the canonical package namespace for new code. The historical `src/` layout remains as a deprecated transitional surface during the Strangler Fig migration, and `BeamFactory.create()` is the preferred high-level construction API.

## Class Hierarchy

```
ParaxialBeam (abstract base)
├── GaussianBeam
├── HermiteBeam
├── LaguerreBeam
├── ElegantHermiteBeam
├── ElegantLaguerreBeam
├── HankelLaguerre
└── HankelHermite
```

## Design Patterns

### 1. Strategy Pattern — Propagators

All propagation algorithms implement the `IPropagator` interface, enabling runtime selection of propagation method.

```
IPropagator (interface)
├── FFTPropagator       — Angular spectrum via FFT
├── AnalyticPropagator  — Direct beam.opticalField evaluation
└── RayTracePropagator  — Phase-gradient ray tracing
```

**Why**: Users can swap propagation methods without changing beam code.

**Usage**:
```matlab
beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);
grid = GridUtils(256, 256, 1e-3, 1e-3);

prop = FFTPropagator(grid, 632.8e-9);
field = prop.propagate(beam, 0.1);
```

### 2. Factory Pattern — BeamFactory

`BeamFactory.create()` instantiates any beam type by name string.

```matlab
% Create by type string
beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);
beam = BeamFactory.create('hermite', 100e-6, 632.8e-9, 'n', 2, 'm', 1);
beam = BeamFactory.create('laguerre', 100e-6, 632.8e-9, 'l', 1, 'p', 0);
```

**Why**: Decouples calling code from concrete beam classes, simplifies API.

### 3. Parameters Pattern — BeamParameters + Computation Layer

Each beam type has a corresponding Parameters class:

```
GaussianParameters
HermiteParameters
LaguerreParameters
ElegantHermiteParameters
ElegantLaguerreParameters
```

Parameters classes provide:
- Waist at given z
- Rayleigh distance
- Gouy phase
- Radius of curvature

**Why**: Separates beam geometry (parameters) from field computation.

**Computation Layer**: Parameter classes delegate formula evaluation to a stateless utility layer. This separates the *what* (parameter values) from the *how* (numerical computation).

```
Parameters (state: w0, lambda, z)
    │
    └─── delegates formula evaluation ──→ BeamComputation (static methods)
                                               rayleighDistance(w0, lambda)
                                               waveNumber(lambda)
                                               waist(w0, z, zr)
                                               gouyPhase(z, zr)
                                               radiusOfCurvature(z, zr)
                                               complexBeamParameter(z, zr)
                                               complexAlpha(q, k)
```

**Migration complete (2026-04-21)**: GaussianParameters now delegates all formulas to `BeamComputation`. HermiteParameters.getHermiteSolutions delegates to `HermiteComputation`. Legacy inline formulas have been extracted to the computation layer with deprecation comments in the parameter classes.

**Invariant**: classes under `src/parameters/` are parameter/data facades and should not implement or duplicate core beam formulas. Formula logic belongs in `src/computation/` and parameter classes must delegate to it (including static helper methods kept for backward compatibility).

## Beam API Contract

Every `ParaxialBeam` subclass MUST implement:

| Method | Returns | Description |
|--------|---------|-------------|
| `opticalField(X, Y, z)` | `[Ny x Nx] complex` | Complex field on Cartesian grid |
| `getParameters(z)` | `GaussianParameters` | Beam params evaluated at z |
| `beamName()` | `char` | String identifier like 'hermite_3_2' |

## Phase Convention

- The beam implementations use the phasor convention `exp(-i*k*z)`.
- Gaussian carrier phase terms are `exp(-i*psi(z))` for Gouy and `exp(+i*k*r^2/(2R(z)))` for curvature.
- Higher-order modal terms use the same sign convention as the carrier Gouy term (`exp(-i*phi_mode)`), where:
  - Hermite: `phi_mode = (n+m)*psi(z)`
  - Laguerre/Hankel: `phi_mode = (|l|+2p)*psi(z)`

## Data Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                         User Script                                   │
│   examples/canonical/MainGauss_refactored.m, etc.                    │
└──────────────────────────────┬───────────────────────────────────────┘
                               │ setpaths / BeamFactory / +paraxial
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         BeamFactory                                   │
│        beam = BeamFactory.create(type, w0, lambda, ...)              │
└──────────────────────────────┬───────────────────────────────────────┘
                               │ creates concrete beam
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    ParaxialBeam (abstract)                            │
│   opticalField(X,Y,z) │ getParameters(z) │ beamName()                │
└───────┬───────┬───────┬───────┬───────┬───────┬───────────────────────┘
        │       │       │       │       │       │
   ┌────┴┐ ┌───┴───┐ ┌─┴──┐ ┌──┴──┐ ┌──┴──┐ ┌────┴────┐
   │Gauss│ │Hermit│ │Lag │ │ElegH│ │ElegL│ │HankelL │
   └─────┘ └──────┘ └────┘ └─────┘ └─────┘ └────────┘
        │       │       │       │       │       │
        └───────┴───────┴───────┴───────┴───────┘
                          │ propagate(beam, z)
                          ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      IPropagator (Strategy)                          │
│                                                                       │
│   ┌────────────────┐ ┌─────────────────┐ ┌─────────────────────┐   │
│   │ FFTPropagator  │ │AnalyticPropagat│ │RayTracePropagator   │   │
│   │ angular spec.  │ │ direct formula │ │ phase-gradient RK4 │   │
│   └────────────────┘ └─────────────────┘ └─────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        Output                                         │
│   complex field [Ny x Nx]  or  RayBundle (for ray tracing)            │
└──────────────────────────────────────────────────────────────────────┘
```

## Utility Classes

| Class | Purpose |
|-------|---------|
| `PhysicalConstants` | k, zr, waist, R, Gouy phase calculations |
| `GridUtils` | 2D grid, frequency grid, polar grid creation |
| `FFTUtils` | Normalized FFT operations |
| `AnalysisUtils` | Phase gradient to ray slope conversion |
| `PolynomialUtils` | Hermite and Laguerre polynomial evaluation |
| `VisualizationUtils` | Plot helpers |

## Directory Structure

```
Simulation_Scripts/
├── +paraxial/                  ← Canonical package namespace
│   ├── +beams/
│   ├── +parameters/
│   ├── +computation/
│   ├── +propagation/
│   └── +visualization/
├── src/                        ← Deprecated transitional adapters/layout
│   ├── beams/
│   │   ├── ParaxialBeam.m        ← Abstract base (contract)
│   │   ├── GaussianBeam.m
│   │   ├── HermiteBeam.m
│   │   ├── LaguerreBeam.m
│   │   ├── ElegantHermiteBeam.m
│   │   ├── ElegantLaguerreBeam.m
│   │   └── HankelLaguerre.m
│   ├── computation/           ← Stateless formula layer
│   │   ├── BeamComputation.m       — Core formulas (Rayleigh, waist, Gouy, q, α)
│   │   └── HermiteComputation.m    — Hermite polynomial evaluation
│   ├── parameters/
│   │   ├── GaussianParameters.m
│   │   ├── HermiteParameters.m
│   │   ├── LaguerreParameters.m
│   │   ├── ElegantHermiteParameters.m
│   │   └── ElegantLaguerreParameters.m
│   ├── propagation/
│   │   ├── field/
│   │   │   ├── IPropagator.m         ← Strategy interface
│   │   │   ├── FFTPropagator.m
│   │   │   └── AnalyticPropagator.m
│   │   └── rays/
│   │       ├── RayTracePropagator.m
│   │       ├── OpticalRay.m
│   │       ├── CylindricalRay.m
│   │       ├── RayBundle.m
│   │       └── RayTracer.m
│   └── visualization/
│       └── VisualizationUtils.m
├── ParaxialBeams/
│   ├── BeamFactory.m         ← Factory
│   ├── PhysicalConstants.m
│   ├── GridUtils.m
│   ├── FFTUtils.m
│   ├── AnalysisUtils.m
│   ├── PolynomialUtils.m
│   └── Addons/               ← Helper functions
├── examples/                  ← Usage examples
│   ├── canonical/
│   │   ├── MainGauss_refactored.m
│   │   ├── MainMultiMode.m
│   │   └── ExampleRayTracing.m
│   └── ... (many legacy scripts)
├── tests/                     ← Test suite (~380 tests)
├── docs/
│   ├── ARCHITECTURE.md
│   └── ROADMAP.md
├── README.md
└── plan.md                     ← Historical pre-merge plan
```

## API Surface Policy

| Surface | Status | Intended usage |
|---------|--------|----------------|
| `+paraxial/` | Canonical | New direct class access and package namespace. |
| `BeamFactory.create()` | Preferred | Stable high-level construction API for examples and users. |
| `src/` | Deprecated transitional | Compatibility/adapters during migration; not recommended for new code. |
| `examples/legacy/` | Historical/compatibility | Archive, research, and generator scripts; not the default onboarding path. |

## Dependencies

```
PhysicalConstants (singleton utility)
     │
     └── ParaxialBeam.k, GridUtils.createFreqGrid()

GridUtils ──────────────────→ FFTUtils (frequency grid)

ParaxialBeam ────────────────→ IPropagator (Strategy pattern)
     │                               │
     │                    ┌──────────┼──────────┐
     │                    ▼          ▼          ▼
     │              FFTProp   Analytic   RayTrace
     │
     └── getParameters ──→ GaussianParameters/HermiteParameters/...
```

## Octave/MATLAB Compatibility

All code is written for compatibility with:
- **GNU Octave 11.1.0+**
- **MATLAB R2020b+**

No `classdef` folders (@Folder). All classes in single `.m` files.

## References

- Kogelnik, H., & Li, T. (1966). Laser beams and resonators. *Applied Optics*.
- Siegman, A. E. (1986). *Lasers*. University Science Books.

## References by Implementation

### GaussianBeam (`+paraxial/+beams/GaussianBeam.m`, adapter: `src/beams/GaussianBeam.m`)

- Kogelnik, H., & Li, T. (1966). *Laser Beams and Resonators*. Applied Optics, 5(10), 1550-1567.
  - Foundation for the paraxial formalism: waist `w(z)`, radius of curvature `R(z)`, Gouy phase `psi(z)`.
- Siegman, A. E. (1986). *Lasers*. University Science Books.
  - Classic reference for notation and phase conventions of Gaussian beams.

### HermiteBeam / LaguerreBeam (`+paraxial/+beams/HermiteBeam.m`, `+paraxial/+beams/LaguerreBeam.m`)

- Saleh, B. E. A., & Teich, M. C. (2007). *Fundamentals of Photonics* (2nd ed.). Wiley.
  - Derivation of transverse HG/LG modes and modal structure in Cartesian/polar coordinates.
- Allen, L., Beijersbergen, M. W., Spreeuw, R. J. C., & Woerdman, J. P. (1992).
  *Orbital angular momentum of light and the transformation of Laguerre-Gaussian laser modes*.
  Physical Review A, 45(11), 8185-8189.
  - Framework for azimuthal index `l`, radial order `p`, and azimuthal phase `exp(i*l*theta)`.

### ElegantHermiteBeam / ElegantLaguerreBeam (`+paraxial/+beams/ElegantHermiteBeam.m`, `+paraxial/+beams/ElegantLaguerreBeam.m`)

- Siegman, A. E. (1996). *Defining and measuring laser beam quality*. JOSA A, 13(5), 952-964.
  - Use of the complex beam parameter `q(z)` and the "elegant" formulation with complex arguments.
- Siegman, A. E. (1986). *Lasers*. University Science Books.
  - Theoretical context for the amplitude-phase coupling in elegant beam families.

### HankelLaguerre (`+paraxial/+beams/HankelLaguerre.m`)

- Kotlyar, V. V., Kovalev, A. A., & Porfirev, A. P. (2012). *Hankel beams and their properties*.
  Optics Letters / JOSA A literature on Hankel-type structured beams.
  - Conceptual basis for the combination `H^(1,2) = LG +/- i*XLG` used in the implementation.

### MATLAB/Octave Support (numerical semantics)

- MathWorks. `cart2pol` documentation.
  - Verifies output order `[theta, rho]`, used when mapping `(X,Y)->(theta,r)`.
- MathWorks. Symbolic Math Toolbox `laguerreL` documentation.
  - Associated Laguerre polynomial convention consistent with `L_p^{|l|}`.

### Phase Convention Note

- Different sources use different phasor conventions (`exp(+i*k*z)` vs `exp(-i*k*z)`).
- This repository uses `exp(-i*k*z)` and maintains internal consistency across:
  - Gaussian carrier,
  - curvature phase,
  - modal Gouy phase (`exp(-i*phi_mode)`).
