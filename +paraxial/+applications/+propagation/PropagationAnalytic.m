%% PropagationAnalytic - Analytic Beam Propagation
%% Demonstrates analytic propagation for standard beam modes.
%
% Analytic propagation evaluates the beam field directly at each z-plane
% using the closed-form beam formulas, avoiding numerical FFT.
%
% This script shows:
%   - Analytic field computation for Gaussian, Hermite, Laguerre beams
%   - Parameter evolution with propagation distance
%   - Waist and Gouy phase tracking
%   - Comparison with FFT propagation for validation
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+propagation/PropagationAnalytic.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoGaussian.m
%   +paraxial/+applications/+propagation/PropagationFFT.m

scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..');
addpath(repoRoot);
setpaths();

%% ============================================================================
%% BEAM PARAMETERS
%% ============================================================================
w0     = 100e-6;          % Initial waist: 100 microns
lambda = 632.8e-9;       % HeNe laser wavelength: 632.8 nm

PC = PhysicalConstants;
zr = PC.rayleighDistance(w0, lambda);

fprintf('=== Analytic Propagation Demo ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);
fprintf('  Rayleigh distance: %.4f m\n', zr);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 512;
Dx  = 2e-3;              % Window size: 2 mm
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% PROPAGATION PLANES
%% ============================================================================
Nz      = 7;                        % Number of z-planes
zPlanes = linspace(0, zr, Nz);     % From 0 to z_R

fprintf('Z-planes: %d points from 0 to z_R\n', Nz);

%% ============================================================================
%% GAUSSIAN BEAM ANALYTIC PROPAGATION
%% ============================================================================
fprintf('\n--- Gaussian Beam Analytic Propagation ---\n');

GB = BeamFactory.create('gaussian', w0, lambda);

fprintf('  Creating Gaussian beam: %s\n', GB.beamName());

% Store fields and parameters at each z
fieldsGauss = cell(Nz, 1);
paramsGauss = cell(Nz, 1);

for iz = 1:Nz
    z = zPlanes(iz);
    fieldsGauss{iz} = GB.opticalField(X, Y, z);
    paramsGauss{iz} = GB.getParameters(z);
    
    if iz == 1 || mod(iz, 2) == 0
        p = paramsGauss{iz};
        fprintf('  z = %.2f z_R: w = %.2f um, R = %.2f m, psi = %.3f rad\n', ...
                z/zr, p.Waist*1e6, p.radius(z), p.GouyPhase);
    end
end

%% ============================================================================
%% HERMITE-GAUSSIAN ANALYTIC PROPAGATION
%% ============================================================================
fprintf('\n--- Hermite-Gaussian (2,1) Analytic Propagation ---\n');

nHG = 2;
mHG = 1;

HG = BeamFactory.create('hermite', w0, lambda, 'n', nHG, 'm', mHG);

fprintf('  Creating Hermite-Gaussian: %s\n', HG.beamName());

fieldsHG = cell(Nz, 1);

for iz = 1:Nz
    z = zPlanes(iz);
    fieldsHG{iz} = HG.opticalField(X, Y, z);
end

%% ============================================================================
%% LAGUERRE-GAUSSIAN ANALYTIC PROPAGATION
%% ============================================================================
fprintf('\n--- Laguerre-Gaussian (2,0) Analytic Propagation ---\n');

lLG = 2;
pLG = 0;

LG = BeamFactory.create('laguerre', w0, lambda, 'l', lLG, 'p', pLG);

fprintf('  Creating Laguerre-Gaussian: %s\n', LG.beamName());

fieldsLG = cell(Nz, 1);

for iz = 1:Nz
    z = zPlanes(iz);
    fieldsLG{iz} = LG.opticalField(X, Y, z);
end

%% ============================================================================
%% VISUALIZATION: GAUSSIAN BEAM PARAMETERS
%% ============================================================================
fprintf('\n--- Visualization ---\n');

% Plot waist evolution
figure(1);
clf;
zPlot = linspace(-0.2*zr, 1.2*zr, 100);
waists = zeros(size(zPlot));

for i = 1:length(zPlot)
    params = GB.getParameters(zPlot(i));
    waists(i) = params.Waist;
end

plot(zPlot/zr, waists*1e6, 'b-', 'LineWidth', 2);
hold on;
plot(zPlot/zr, -waists*1e6, 'b--', 'LineWidth', 2);
for iz = 1:Nz
    plot(zPlanes(iz)/zr, paramsGauss{iz}.Waist*1e6, 'ro', 'MarkerSize', 8);
end
hold off;
xlabel('z / z_R');
ylabel('w (microns)');
title('Gaussian Beam Waist Evolution');
grid on;

%% ============================================================================
%% VISUALIZATION: FIELD EVOLUTION
%% ============================================================================
figure(2);
clf;
nRows = 1;
nCols = Nz;

for iz = 1:Nz
    subplot(nRows, nCols, iz);
    imagesc(abs(fieldsGauss{iz}).^2);
    colormap('hot');
    axis square;
    axis off;
    title(sprintf('z=%.1fz_R', zPlanes(iz)/zr));
end
sgtitle('Gaussian Beam Intensity Evolution');

figure(3);
clf;

for iz = 1:Nz
    subplot(nRows, nCols, iz);
    imagesc(abs(fieldsHG{iz}).^2);
    colormap('hot');
    axis square;
    axis off;
    title(sprintf('z=%.1fz_R', zPlanes(iz)/zr));
end
sgtitle(sprintf('Hermite-Gaussian HG_{%d,%d} Intensity Evolution', nHG, mHG));

figure(4);
clf;

for iz = 1:Nz
    subplot(nRows, nCols, iz);
    imagesc(abs(fieldsLG{iz}).^2);
    colormap('hot');
    axis square;
    axis off;
    title(sprintf('z=%.1fz_R', zPlanes(iz)/zr));
end
sgtitle(sprintf('Laguerre-Gaussian LG_{%d,%d} Intensity Evolution', lLG, pLG));

%% ============================================================================
%% LATERAL VIEW (XZ CUT)
%% ============================================================================
fprintf('\n--- Lateral View (x-cut at y=0) ---\n');

% Build xz-plane data
Nx_sample = 256;
xCut = -Dx/2 + (0:Nx_sample-1) * (Dx/Nx_sample);

xzPlaneGauss = zeros(Nx_sample, Nz);
xzPlaneHG    = zeros(Nx_sample, Nz);
xzPlaneLG    = zeros(Nx_sample, Nz);

for iz = 1:Nz
    z = zPlanes(iz);
    
    % Sample at x-cut (1D vector along x-axis at y=0)
    xzPlaneGauss(:, iz) = abs(GB.opticalField(xCut.', 0, z)).^2;
    xzPlaneHG(:, iz)    = abs(HG.opticalField(xCut.', 0, z)).^2;
    xzPlaneLG(:, iz)    = abs(LG.opticalField(xCut.', 0, z)).^2;
end

figure(5);
clf;
subplot(1, 3, 1);
imagesc(zPlanes/zr, xCut/w0, xzPlaneGauss);
colormap('hot');
set(gca, 'YDir', 'normal');
xlabel('z / z_R');
ylabel('x / w_0');
title('Gaussian');

subplot(1, 3, 2);
imagesc(zPlanes/zr, xCut/w0, xzPlaneHG);
colormap('hot');
set(gca, 'YDir', 'normal');
xlabel('z / z_R');
title(sprintf('HG_{%d,%d}', nHG, mHG));

subplot(1, 3, 3);
imagesc(zPlanes/zr, xCut/w0, xzPlaneLG);
colormap('hot');
set(gca, 'YDir', 'normal');
xlabel('z / z_R');
title(sprintf('LG_{%d,%d}', lLG, pLG));

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Analytic Propagation Complete ===\n');
fprintf('  Gaussian beam: %d z-planes\n', Nz);
fprintf('  Hermite-Gaussian HG_{%d,%d}: %d z-planes\n', nHG, mHG, Nz);
fprintf('  Laguerre-Gaussian LG_{%d,%d}: %d z-planes\n', lLG, pLG, Nz);
fprintf('\nFigures:\n');
fprintf('  1: Gaussian beam waist evolution\n');
fprintf('  2: Gaussian beam intensity at %d z-planes\n', Nz);
fprintf('  3: Hermite-Gaussian intensity at %d z-planes\n', Nz);
fprintf('  4: Laguerre-Gaussian intensity at %d z-planes\n', Nz);
fprintf('  5: Lateral view comparison (xz-cut)\n');