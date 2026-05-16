%% Canonical Example: Wavefront Analysis
%% Demonstrates wavefront extraction, Zernike fitting, and metrics.
%
% This script shows:
%   1. Creating Wavefront from complex field
%   2. Extracting phase and intensity
%   3. Zernike polynomial fitting
%   4. Computing wavefront metrics (RMS, PV, Strehl)
%   5. Visualization of results

scriptPath = fileparts(mfilename('fullpath'));
repoRoot = fullfile(scriptPath, '..', '..');
addpath(repoRoot);
setpaths();

%% Create a Gaussian beam field
fprintf('Creating Gaussian beam field...\n');
w0 = 100e-6;       % 100 microns
lambda = 632.8e-9; % HeNe laser
z = 0;             % at waist (planar wavefront)

grid = GridUtils(256, 256, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();

beam = BeamFactory.create('gaussian', w0, lambda);
E = beam.opticalField(X, Y, z);

%% Create Wavefront from field
fprintf('Creating Wavefront object...\n');
wf = Wavefront(E, lambda, grid);

%% Extract field properties
fprintf('\n--- Field Properties ---\n');
I = wf.getIntensity();
phi = wf.getPhase();
fprintf('Grid size: %d x %d\n', wf.Ny, wf.Nx);
fprintf('Intensity range: [%.3f, %.3f]\n', min(I(:)), max(I(:)));

%% Fit Zernike polynomials
fprintf('\n--- Zernike Fitting ---\n');
nTerms = 36;
coeffs = wf.fitZernike(nTerms);
fprintf('Fitted %d Zernike terms\n', nTerms);
fprintf('Piston (Z1): %.6f rad\n', coeffs(1));
fprintf('Tilt X (Z2): %.6f rad\n', coeffs(2));
fprintf('Tilt Y (Z3): %.6f rad\n', coeffs(3));

%% Compute metrics
fprintf('\n--- Wavefront Metrics ---\n');
metrics = wf.getMetrics(nTerms);
fprintf('RMS wavefront error: %.6f rad (%.4f waves)\n', ...
    metrics.rms, metrics.rms/(2*pi));
fprintf('PV wavefront error: %.6f rad (%.4f waves)\n', ...
    metrics.pv, metrics.pv/(2*pi));
fprintf('Strehl ratio: %.4f\n', metrics.strehl);
fprintf('Residual RMS (36 terms): %.2e rad\n', metrics.residualRMS);

%% Visualize results
fprintf('\n--- Generating visualizations ---\n');

% Phase map
figure(1);
wf.plotWavefront();
title(sprintf('Gaussian Beam Phase (z=0, waist)'));

% Intensity
figure(2);
wf.plotIntensity();
title(sprintf('Gaussian Beam Intensity'));

% Zernike coefficients
figure(3);
wf.plotZernikeCoeffs(coeffs);
title(sprintf('Zernike Coefficients (1-%d)', nTerms));

% Phase slice
figure(4);
wf.plotPhaseSlice('x', floor(wf.Ny/2));
title('Phase Slice at Center');

%% Verify planar wavefront behavior
fprintf('\n--- Verification ---\n');
fprintf('At waist (z=0), Gaussian beam has planar wavefront:\n');
fprintf('  - Piston term dominant: %.6f rad\n', coeffs(1));
fprintf('  - Tilt terms ~0: Z2=%.6f, Z3=%.6f\n', coeffs(2), coeffs(3));
fprintf('  - Strehl ratio ~1 (no aberration): %.4f\n', metrics.strehl);

fprintf('\nDone.\n');