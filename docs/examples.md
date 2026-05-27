---
title: Examples
---

# Examples

The recommended scripts live in `examples/canonical/`. They use `setpaths`, `BeamFactory.create()`, and canonical package classes so the same examples work in MATLAB and GNU Octave.

## Gaussian propagation

Use `examples/canonical/MainGauss_refactored.m` to evaluate a fundamental Gaussian mode and compare field propagation behavior. The script is the starting point for checking waist size, Rayleigh distance, intensity normalization, and phase curvature.

```matlab
run('setpaths.m')
run('examples/canonical/MainGauss_refactored.m')
```

## Hermite and Laguerre modes

Use `examples/canonical/MainMultiMode.m` to generate higher-order Hermite-Gaussian and Laguerre-Gaussian beams through the factory API.

```matlab
run('setpaths.m')
run('examples/canonical/MainMultiMode.m')
```

Mode indices are passed as name-value arguments.

```matlab
hg = BeamFactory.create('hermite', 100e-6, 632.8e-9, 'n', 2, 'm', 1);
lg = BeamFactory.create('laguerre', 100e-6, 632.8e-9, 'l', 1, 'p', 1);
```

## Ray tracing diagnostics

Use `examples/canonical/ExampleRayTracing.m` to inspect ray bundles derived from beam phase gradients. Ray tracing is useful when comparing field-based propagation with local wavefront slopes.

```matlab
run('setpaths.m')
run('examples/canonical/ExampleRayTracing.m')
```

## Regenerating README and Pages images

The figures embedded in the README and this Pages site come from one script.

```bash
octave --no-gui tools/generate_readme_figures.m
```

The script writes PNG files to `docs/assets/`. Intensity plots use normalized `|E|^2` in arbitrary units; phase plots use radians.
