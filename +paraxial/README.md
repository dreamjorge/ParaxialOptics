# +paraxial Package

Canonical MATLAB package namespace for ParaxialOptics beam physics library.

## Status

**This is the canonical (recommended) namespace.** The `+paraxial/` package is fully populated and is the default location for all beam, propagation, and visualization classes.

Legacy classes in `src/` remain functional but emit deprecation warnings. Use `BeamFactory.create()` or `setpaths()` to initialize.

## Structure

```
+paraxial/
├── +beams/                  % Beam classes
│   ├── ParaxialBeam.m      % Abstract base class
│   ├── GaussianBeam.m
│   ├── HermiteBeam.m
│   ├── LaguerreBeam.m
│   ├── ElegantHermiteBeam.m
│   ├── ElegantLaguerreBeam.m
│   ├── HankelHermite.m
│   └── HankelLaguerre.m
├── +parameters/             % Beam parameter classes
│   ├── GaussianParameters.m
│   ├── HermiteParameters.m
│   ├── LaguerreParameters.m
│   ├── ElegantHermiteParameters.m
│   └── ElegantLaguerreParameters.m
├── +computation/            % Formula/logic layer
│   ├── BeamComputation.m
│   └── HermiteComputation.m
├── +propagation/
│   ├── +field/             % Field-based propagation
│   │   ├── IPropagator.m
│   │   ├── FFTPropagator.m
│   │   └── AnalyticPropagator.m
│   └── +rays/              % Ray-based propagation
│       ├── RayTracePropagator.m
│       ├── RayBundle.m
│       ├── RayTracer.m
│       ├── OpticalRay.m
│       ├── CylindricalRay.m
│       ├── HankelRayTracer.m
│       └── HankelRayTracePropagator.m
├── +visualization/
│   ├── VisualizationUtils.m
│   ├── Wavefront.m
│   └── ZernikeUtils.m
├── init.m                   % Package initialization
└── README.md               % This file
```

## Usage

```matlab
% Initialize paths
setpaths();

% Recommended: use BeamFactory for beam creation
beam = BeamFactory.create('hermite', w0, lambda, 'n', 1, 'm', 2);

% Alternative: use package directly (Octave: import not supported)
beam = paraxial.beams.HermiteBeam(w0, lambda, 'n', 1, 'm', 2);

% Field computation
field = beam.opticalField(X, Y, z);

% Propagation
grid = GridUtils(256, 256, 1e-3, 1e-3);
prop = paraxial.propagation.field.AnalyticPropagator(grid);
result = prop.propagate(beam, 0.1);
```

## Migration from `src/`

The `src/` directory is deprecated. Migration:

```matlab
% Before (deprecated)
addpath('src/beams');
GB = GaussianBeam(w0, lambda);

% After (canonical)
setpaths();
GB = BeamFactory.create('gaussian', w0, lambda);
% or
GB = paraxial.beams.GaussianBeam(w0, lambda);
```

## Strangler Fig Pattern

This project uses the Strangler Fig migration pattern:

1. **`+paraxial/`** — canonical namespace (new code)
2. **`src/`** — deprecated legacy (emits warnings, will be removed)
3. **`BeamFactory`** — routes automatically to `+paraxial/` by default

See `docs/migration/LEGACY_MIGRATION_PLAN.md` for full details.

## References

- [MATLAB Packages Documentation](https://mathworks.com/help/matlab/matlab_prog/create-and-use-packages.html)
- [MATLAB Packages Namespaces](https://mathworks.com/help/matlab/matlab_oop/package-overview.html)
