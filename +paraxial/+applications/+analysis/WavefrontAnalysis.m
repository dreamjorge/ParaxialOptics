%% WavefrontAnalysis - Wavefront Extraction and Zernike Analysis
%% Demonstrates wavefront extraction from complex fields and Zernike fitting.
%
% This script shows:
%   - Creating Wavefront object from complex field
%   - Extracting phase and intensity
%   - Zernike polynomial fitting
%   - Computing wavefront metrics (RMS, PV, Strehl ratio)
%   - Visualization of results
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+analysis/WavefrontAnalysis.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoGaussian.m
%   +paraxial/+applications/+analysis/RayBundleAnalysis.m

scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..');
addpath(repoRoot);
setpaths();

%% ============================================================================
%% BEAM PARAMETERS
%% ============================================================================
w0     = 100e-6;          % Initial waist: 100 microns
lambda = 632.8e-9;       % HeNe laser wavelength: 632.8 nm

fprintf('=== Wavefront Analysis Demo ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx   = 256;
Dx   = 1e-3;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% GAUSSIAN BEAM AT Z = 0 (Planar Wavefront)
%% ============================================================================
fprintf('\n--- Gaussian Beam at Waist (z=0) ---\n');

GB = BeamFactory.create('gaussian', w0, lambda);
E0 = GB.opticalField(X, Y, 0);

fprintf('  Creating Gaussian beam: %s\n', GB.beamName());

% Create Wavefront from field
wf0 = Wavefront(E0, lambda, simGrid);

fprintf('\n  Field properties at z=0:');
fprintf('    Grid size: %d x %d\n', wf0.Ny, wf0.Nx);

%% ============================================================================
%% WAVEFRONT EXTRACTION
%% ============================================================================
fprintf('\n--- Wavefront Extraction ---\n');

% Get intensity and phase
I0 = wf0.getIntensity();
phi0 = wf0.getPhase();

fprintf('  Intensity range: [%.4f, %.4f]\n', min(I0(:)), max(I0(:)));
fprintf('  Phase range (unwrapped): [%.4f, %.4f] rad\n', ...
        min(phi0(:)), max(phi0(:)));

%% ============================================================================
%% ZERNIKE POLYNOMIAL FITTING
%% ============================================================================
fprintf('\n--- Zernike Fitting ---\n');

nTerms = 36;
coeffs0 = wf0.fitZernike(nTerms);

fprintf('  Fitted %d Zernike terms\n', nTerms);
fprintf('\n  Key coefficients:\n');
fprintf('    Z1 (Piston):     %.6e rad\n', coeffs0(1));
fprintf('    Z2 (Tilt X):    %.6e rad\n', coeffs0(2));
fprintf('    Z3 (Tilt Y):    %.6e rad\n', coeffs0(3));
fprintf('    Z4 (Defocus):   %.6e rad\n', coeffs0(4));
fprintf('    Z5 (Astig 45):  %.6e rad\n', coeffs0(5));
fprintf('    Z6 (Astig 0):   %.6e rad\n', coeffs0(6));

%% ============================================================================
%% WAVEFRONT METRICS
%% ============================================================================
fprintf('\n--- Wavefront Metrics ---\n');

metrics0 = wf0.getMetrics(nTerms);

fprintf('  RMS wavefront error: %.6e rad (%.4f waves)\n', ...
        metrics0.rms, metrics0.rms/(2*pi));
fprintf('  PV wavefront error:  %.6e rad (%.4f waves)\n', ...
        metrics0.pv, metrics0.pv/(2*pi));
fprintf('  Strehl ratio:        %.6f\n', metrics0.strehl);
fprintf('  Residual RMS:        %.2e rad\n', metrics0.residualRMS);

%% ============================================================================
%% VISUALIZATION: GAUSSIAN BEAM AT Z=0
%% ============================================================================
fprintf('\n--- Visualization ---\n');

% Phase map
figure(1);
clf;
wf0.plotWavefront();
title(sprintf('Gaussian Beam Phase at z=0 (waist)'));

% Intensity
figure(2);
clf;
wf0.plotIntensity();
title(sprintf('Gaussian Beam Intensity at z=0'));

% Zernike coefficients
figure(3);
clf;
wf0.plotZernikeCoeffs(coeffs0);
title(sprintf('Zernike Coefficients (1-%d) at z=0', nTerms));

% Phase slice
figure(4);
clf;
wf0.plotPhaseSlice('x', floor(Nx/2));
title('Phase Slice at Center (y = 0)');

%% ============================================================================
%% PROPAGATED BEAM (Curved Wavefront)
%% ============================================================================
fprintf('\n--- Gaussian Beam at z = z_R/2 (Curved Wavefront) ---\n');

z_prop = 0.5;  % Propagate to z_R/2
E_prop = GB.opticalField(X, Y, z_prop);
wf_prop = Wavefront(E_prop, lambda, simGrid);

fprintf('  Creating propagated field at z = %.2f m\n', z_prop);

% Fit Zernike polynomials
coeffs_prop = wf_prop.fitZernike(nTerms);
metrics_prop = wf_prop.getMetrics(nTerms);

fprintf('\n  Key coefficients:\n');
fprintf('    Z1 (Piston):     %.6e rad\n', coeffs_prop(1));
fprintf('    Z2 (Tilt X):    %.6e rad\n', coeffs_prop(2));
fprintf('    Z3 (Tilt Y):    %.6e rad\n', coeffs_prop(3));
fprintf('    Z4 (Defocus):   %.6e rad\n', coeffs_prop(4));

fprintf('\n  Metrics:\n');
fprintf('    RMS: %.6e rad, PV: %.6e rad\n', metrics_prop.rms, metrics_prop.pv);
fprintf('    Strehl: %.6f\n', metrics_prop.strehl);

%% ============================================================================
%% VISUALIZATION: PROPAGATED BEAM
%% ============================================================================
figure(5);
clf;
wf_prop.plotWavefront();
title(sprintf('Gaussian Beam Phase at z = %.2f m', z_prop));

figure(6);
clf;
wf_prop.plotZernikeCoeffs(coeffs_prop);
title(sprintf('Zernike Coefficients (1-%d) at z = %.2f m', nTerms, z_prop));

%% ============================================================================
%% COMPARISON: Z=0 VS Z=Z_R/2
%% ============================================================================
figure(7);
clf;

% Phase comparison
subplot(2, 2, 1);
imagesc(wf0.getPhase());
colormap('jet');
colorbar;
title('Phase at z=0 (planar)');

subplot(2, 2, 2);
imagesc(wf_prop.getPhase());
colormap('jet');
colorbar;
title(sprintf('Phase at z=%.2f m', z_prop));

% Coefficient comparison
subplot(2, 2, 3);
stem(1:10, coeffs0(1:10), 'b', 'MarkerFaceColor', 'b');
hold on;
stem(1:10, coeffs_prop(1:10), 'r', 'MarkerFaceColor', 'r');
hold off;
xlabel('Zernike Index');
ylabel('Coefficient (rad)');
title('Zernike Coefficients Comparison');
legend('z=0', sprintf('z=%.2f m', z_prop), 'Location', 'best');

% Metrics comparison
subplot(2, 2, 4);
metrics_names = {'RMS', 'PV', 'Strehl'};
metrics0_vals = [metrics0.rms, metrics0.pv, 1-metrics0.strehl];
metrics_prop_vals = [metrics_prop.rms, metrics_prop.pv, 1-metrics_prop.strehl];

bar([metrics0_vals; metrics_prop_vals]');
set(gca, 'xticklabel', metrics_names);
ylabel('Value');
title('Wavefront Metrics Comparison');
legend('z=0', sprintf('z=%.2f m', z_prop), 'Location', 'best');
grid on;

%% ============================================================================
%% HERMITE-GAUSSIAN WAVEFRONT ANALYSIS
%% ============================================================================
fprintf('\n--- Hermite-Gaussian Wavefront Analysis ---\n');

nHG = 2;
mHG = 1;

HG = BeamFactory.create('hermite', w0, lambda, 'n', nHG, 'm', mHG);
E_HG = HG.opticalField(X, Y, 0);
wf_HG = Wavefront(E_HG, lambda, simGrid);

fprintf('  Creating Hermite-Gaussian: %s\n', HG.beamName());

coeffs_HG = wf_HG.fitZernike(nTerms);
metrics_HG = wf_HG.getMetrics(nTerms);

fprintf('\n  Metrics:\n');
fprintf('    RMS: %.6e rad, PV: %.6e rad\n', metrics_HG.rms, metrics_HG.pv);
fprintf('    Strehl: %.6f\n', metrics_HG.strehl);

figure(8);
clf;
wf_HG.plotWavefront();
title(sprintf('Hermite-Gaussian %s Phase at z=0', HG.beamName()));

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Wavefront Analysis Complete ===\n');
fprintf('  Gaussian beam at z=0: planar wavefront (Strehl ~ 1)\n');
fprintf('  Gaussian beam at z=%.2f m: curved wavefront\n', z_prop);
fprintf('  Hermite-Gaussian %s: complex phase structure\n', HG.beamName());
fprintf('\nFigures:\n');
fprintf('  1: Gaussian phase at z=0\n');
fprintf('  2: Gaussian intensity at z=0\n');
fprintf('  3: Zernike coefficients at z=0\n');
fprintf('  4: Phase slice at z=0\n');
fprintf('  5: Gaussian phase at z=%.2f m\n', z_prop);
fprintf('  6: Zernike coefficients at z=%.2f m\n', z_prop);
fprintf('  7: Comparison: z=0 vs z=%.2f m\n', z_prop);
fprintf('  8: Hermite-Gaussian phase\n');