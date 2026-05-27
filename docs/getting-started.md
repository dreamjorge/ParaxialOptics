---
title: Getting started
---

# Getting started

This page shows the shortest path from installation to a propagated paraxial field. All physical quantities are expressed in SI units unless a plot label states otherwise.

## Octave package installation

Install the release package and load it before using the public classes.

```matlab
pkg install 'https://github.com/dreamjorge/ParaxialOptics/releases/latest/download/paraxial_optics-1.0.1.tar.gz'
pkg load paraxial_optics
```

The package exposes `BeamFactory`, grid utilities, propagators, and the canonical `+paraxial/` beam implementations.

## Source checkout setup

Clone the repository and initialize paths from the repository root.

```bash
git clone https://github.com/dreamjorge/ParaxialOptics.git
cd ParaxialOptics
```

```matlab
setpaths
```

The root directory must be on the MATLAB/Octave path for `+paraxial/` package resolution. Avoid adding internal `+paraxial/+...` directories directly in new scripts.

## Create a Gaussian beam

```matlab
w0 = 100e-6;        % waist radius [m]
lambda = 632.8e-9; % wavelength [m]
beam = BeamFactory.create('gaussian', w0, lambda);
```

`BeamFactory.create()` returns an object implementing the beam API contract: `opticalField(X,Y,z)`, `getParameters(z)`, and `beamName()`.

## Evaluate and propagate the field

```matlab
grid = GridUtils(512, 512, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();

field0 = beam.opticalField(X, Y, 0);
I0 = abs(field0).^2;

prop = FFTPropagator(grid, lambda);
field_z = prop.propagate(beam, 0.05);
Iz = abs(field_z).^2;
```

`I0` and `Iz` are normalized intensity maps in arbitrary units unless the caller applies a physical power normalization. The coordinates returned by `GridUtils` are in meters.

## Run the test suite

```bash
octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

The portable runner exercises canonical package classes, legacy compatibility adapters, beam factories, propagation methods, and wavefront analysis.
