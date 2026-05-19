# Paraxial Beam Applications Suite

Comprehensive collection of application scripts for beam propagation, analysis, and visualization using the paraxial optics simulation library.

## Directory Structure

```
+paraxial/+applications/
├── +applications.m       # Package marker and documentation
├── +demos/
│   ├── DemoGaussian.m         # Gaussian beam fundamentals
│   ├── DemoHermiteLaguerre.m  # Hermite and Laguerre-Gaussian modes
│   └── DemoElegantModes.m     # Elegant Hermite/Laguerre modes
├── +propagation/
│   ├── PropagationFFT.m              # FFT angular spectrum propagation
│   ├── PropagationAnalytic.m        # Analytic beam propagation
│   ├── PropagationWithObstruction.m # Propagation through obstructions
│   └── PropagationElegant.m          # Elegant beam propagation
├── +analysis/
│   ├── WavefrontAnalysis.m    # Wavefront extraction and Zernike fitting
│   ├── RayBundleAnalysis.m    # Ray tracing and bundle analysis
│   └── SelfHealingAnalysis.m  # Self-healing behavior analysis
└── +visualization/
    ├── GenerateSlices3D.m     # 3D slice visualization
    ├── GenerateVideo.m        # Video generation from propagation
    └── GenerateFigures.m     # Publication-quality figure generation
```

## Quick Start

### Running Demos

```matlab
% Run Gaussian beam demo
cd Simulation_Scripts
run('+paraxial/+applications/+demos/DemoGaussian.m')
```

### Running from Octave/MATLAB Command Line

```bash
octave --no-gui --eval "run('+paraxial/+applications/+demos/DemoGaussian.m')"
```

### Basic Usage Pattern

All scripts are self-contained and configure paths automatically:

```matlab
scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..', '..');
addpath(repoRoot);
setpaths();

% Create beam using BeamFactory
beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);

% Compute field
field = beam.opticalField(X, Y, 0);
```

## Category Descriptions

### Demos (+demos/)

Basic demonstrations designed for learning and onboarding:

| Script | Description |
|--------|-------------|
| `DemoGaussian.m` | Gaussian beam basics: waist, Rayleigh distance, propagation |
| `DemoHermiteLaguerre.m` | Hermite-Gaussian (n,m) and Laguerre-Gaussian (l,p) modes |
| `DemoElegantModes.m` | Elegant Hermite/Laguerre modes using complex beam parameter |

### Propagation (+propagation/)

Scripts focused on beam propagation techniques:

| Script | Description |
|--------|-------------|
| `PropagationFFT.m` | FFT-based angular spectrum method with Hankel beam support |
| `PropagationAnalytic.m` | Direct formula evaluation for standard modes |
| `PropagationWithObstruction.m` | Diffraction through circular/rectangular obstructions |
| `PropagationElegant.m` | Propagation of elegant beam families |

### Analysis (+analysis/)

Scripts for beam analysis and characterization:

| Script | Description |
|--------|-------------|
| `WavefrontAnalysis.m` | Wavefront extraction, Zernike fitting, metrics (RMS, PV, Strehl) |
| `RayBundleAnalysis.m` | Ray tracing, bundle statistics, trajectory visualization |
| `SelfHealingAnalysis.m` | Quantification of self-healing (NCC, RMSD, healing time) |

### Visualization (+visualization/)

Scripts for advanced visualization and figure generation:

| Script | Description |
|--------|-------------|
| `GenerateSlices3D.m` | 3D volume slicing with MATLAB `slice()` and isosurfaces |
| `GenerateVideo.m` | AVI/MP4 video generation from propagation sequences |
| `GenerateFigures.m` | Publication-quality multi-panel figures (PNG, PDF, EPS) |

## API Contract

These scripts demonstrate the official API:

```matlab
% Beam creation
beam = BeamFactory.create(type, w0, lambda, 'Name', Value, ...)

% Field computation
E = beam.opticalField(X, Y, z)

% Parameters
params = beam.getParameters(z)

% Propagation
field = FFTUtils().propagate(field, Kx, Ky, dz, lambda)

% Analysis
wf = Wavefront(E, lambda, grid)
coeffs = wf.fitZernike(36)
```

## Dependencies

| Component | Location | Purpose |
|-----------|----------|---------|
| `+paraxial/+beams/` | Canonical namespace | Beam classes |
| `BeamFactory` | `ParaxialBeams/` | Factory pattern |
| `GridUtils` | `ParaxialBeams/` | Grid utilities |
| `FFTUtils` | `ParaxialBeams/` | FFT operations |
| `Wavefront` | `+paraxial/+visualization/` | Wavefront analysis |

## Examples by Task

### Beam Creation
```matlab
% Gaussian
beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);

% Hermite-Gaussian (n=2, m=1)
beam = BeamFactory.create('hermite', 100e-6, 632.8e-9, 'n', 2, 'm', 1);

% Laguerre-Gaussian (l=1, p=0)
beam = BeamFactory.create('laguerre', 100e-6, 632.8e-9, 'l', 1, 'p', 0);

% Elegant Hermite-Gaussian
beam = BeamFactory.create('elegant_hermite', 100e-6, 632.8e-9, 'n', 2, 'm', 1);
```

### Propagation
```matlab
% FFT propagation
grid = GridUtils(512, 512, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();
[Kx, Ky] = grid.createFreqGrid();
fftOps = FFTUtils();

for iz = 1:Nz
    field = fftOps.propagate(field, Kx, Ky, dz, lambda);
end
```

### Analysis
```matlab
% Wavefront analysis
wf = Wavefront(field, lambda, grid);
coeffs = wf.fitZernike(36);
metrics = wf.getMetrics(36);
```

## Supported Beam Types

| Type | Factory String | Parameters |
|------|---------------|------------|
| Gaussian | `'gaussian'` | w0, λ |
| Hermite-Gaussian | `'hermite'` | w0, λ, n, m |
| Laguerre-Gaussian | `'laguerre'` | w0, λ, l, p |
| Elegant Hermite | `'elegant_hermite'` | w0, λ, n, m |
| Elegant Laguerre | `'elegant_laguerre'` | w0, λ, l, p |
| Hankel Laguerre | `'hankel'` | w0, λ, l, p, type |
| Hankel Hermite | `'hankel_hermite'` | w0, λ, n, m, type |

## Version

Part of the Simulation_Scripts library.
See `+paraxial/simulation_scripts_version.m` for version information.

## See Also

- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - Architecture documentation
- [ROADMAP.md](../../docs/ROADMAP.md) - Development roadmap
- [README.md](../../README.md) - Project overview