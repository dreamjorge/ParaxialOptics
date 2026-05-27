---
title: API overview
---

# API overview

The public API is organized around beam objects, grid utilities, propagation strategies, and wavefront analysis tools. New code should use `BeamFactory.create()` or direct `paraxial.beams.*` classes.

## Beam factory

`BeamFactory.create(type, w0, lambda, ...)` constructs a beam by public type name.

```matlab
g  = BeamFactory.create('gaussian', 100e-6, 632.8e-9);
hg = BeamFactory.create('hermite', 100e-6, 632.8e-9, 'n', 2, 'm', 1);
lg = BeamFactory.create('laguerre', 100e-6, 632.8e-9, 'l', 1, 'p', 0);
hl = BeamFactory.create('hankel', 100e-6, 632.8e-9, 'l', 2, 'type', 1);
```

Supported type names include `gaussian`, `hermite`, `laguerre`, `elegant_hermite`, `elegant_laguerre`, `hankel`, `hankel_hermite`, `nhermite`, `xlaguerre`, `elegant_nhermite`, and `elegant_xlaguerre`.

## Beam contract

Every beam exposes the same core methods.

```matlab
field = beam.opticalField(X, Y, z); % complex field on the input grid
params = beam.getParameters(z);     % beam parameters evaluated at z
name = beam.beamName();             % stable descriptive name
```

`X` and `Y` are coordinate arrays in meters. `z` is the propagation distance in meters. The returned field is complex-valued and can be converted to normalized intensity with `abs(field).^2`.

## Grid utilities

```matlab
grid = GridUtils(Nx, Ny, Dx, Dy);
[X, Y] = grid.create2DGrid();
[Kx, Ky] = grid.createFreqGrid();
[r, theta] = grid.createPolarGrid();
```

`Nx` and `Ny` define the sample count. `Dx` and `Dy` define the physical aperture size in meters.

## Propagators

```matlab
fftProp = FFTPropagator(grid, lambda);
field_z = fftProp.propagate(beam, z);

analyticProp = AnalyticPropagator(grid);
field_direct = analyticProp.propagate(beam, z);

rayProp = RayTracePropagator(grid, 'RK4', 1e-3);
bundle = rayProp.propagate(beam, z);
```

FFT propagation uses an angular spectrum-style method. Analytic propagation evaluates the beam formula at the destination plane. Ray tracing follows local phase-gradient directions and returns ray-bundle data instead of a field array.

## Physical constants and wavefronts

```matlab
k = PhysicalConstants.waveNumber(lambda);
zr = PhysicalConstants.rayleighDistance(w0, lambda);
R = PhysicalConstants.radiusOfCurvature(z, zr);
gouy = PhysicalConstants.gouyPhase(z, zr);
```

Wavefront utilities live under `+paraxial/+visualization/` and support intensity, phase, Zernike fitting, reconstruction, RMS, PV, and Strehl-style diagnostics.
