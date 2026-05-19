%% DemoElegantModes - Elegant Beam Mode Demonstration
%% Demonstrates Elegant Hermite-Gaussian and Elegant Laguerre-Gaussian modes.
%
% Elegant beams use the complex beam parameter q(z) in the argument of
% Hermite/Laguerre polynomials, providing a more compact representation.
%
% This demo shows:
%   - Creation of Elegant Hermite-Gaussian modes via BeamFactory
%   - Creation of Elegant Laguerre-Gaussian modes via BeamFactory
%   - Comparison with standard modes
%   - Phase structure visualization
%
% Compatible with GNU Octave and MATLAB
%
% References:
%   - Siegman, A. E. (1986). Lasers. University Science Books.
%   - Siegman, A. E. (1996). Defining and measuring laser beam quality. JOSA A.
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+demos/DemoElegantModes.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoHermiteLaguerre.m
%   +paraxial/+applications/+propagation/PropagationElegant.m

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

fprintf('=== Elegant Beam Mode Demo ===\n');
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
%% ELEGANT HERMITE-GAUSSIAN MODES
%% ============================================================================
fprintf('\n--- Elegant Hermite-Gaussian Modes ---\n');

modesEHg = {[1, 0], [1, 1], [2, 1], [2, 2]};
nModes   = length(modesEHg);
fieldsEHg = cell(nModes, 1);
namesEHg  = cell(nModes, 1);

for i = 1:nModes
    n = modesEHg{i}(1);
    m = modesEHg{i}(2);
    
    fprintf('  Creating Elegant HG_{%d,%d}... ', n, m);
    
    eh = BeamFactory.create('elegant_hermite', w0, lambda, 'n', n, 'm', m);
    fieldsEHg{i} = eh.opticalField(X, Y, 0);
    namesEHg{i}  = sprintf('E-HG_{%d,%d}', n, m);
    
    fprintf('done\n');
end

%% ============================================================================
%% ELEGANT LAGUERRE-GAUSSIAN MODES
%% ============================================================================
fprintf('\n--- Elegant Laguerre-Gaussian Modes ---\n');

modesELg = {[1, 0], [2, 0], [0, 1], [3, 1]};
fieldsELg = cell(length(modesELg), 1);
namesELg  = cell(length(modesELg), 1);

for i = 1:length(modesELg)
    l = modesELg{i}(1);
    p = modesELg{i}(2);
    
    fprintf('  Creating Elegant LG_{%d,%d}... ', l, p);
    
    el = BeamFactory.create('elegant_laguerre', w0, lambda, 'l', l, 'p', p);
    fieldsELg{i} = el.opticalField(X, Y, 0);
    namesELg{i}  = sprintf('E-LG_{%d,%d}', l, p);
    
    fprintf('done\n');
end

%% ============================================================================
%% VISUALIZATION: ELEGANT HERMITE-GAUSSIAN
%% ============================================================================
figure(1);
clf;
nCols = 2;
nRows = ceil(nModes / nCols);

for i = 1:nModes
    subplot(nRows, nCols, i);
    imagesc(abs(fieldsEHg{i}).^2);
    colormap('hot');
    axis square;
    title(namesEHg{i});
    colorbar;
end
sgtitle('Elegant Hermite-Gaussian Modes (intensity at z=0)');

%% ============================================================================
%% VISUALIZATION: ELEGANT LAGUERRE-GAUSSIAN
%% ============================================================================
figure(2);
clf;
nCols = 2;
nRows = ceil(length(modesELg) / nCols);

for i = 1:length(modesELg)
    subplot(nRows, nCols, i);
    imagesc(abs(fieldsELg{i}).^2);
    colormap('hot');
    axis square;
    title(namesELg{i});
    colorbar;
end
sgtitle('Elegant Laguerre-Gaussian Modes (intensity at z=0)');

%% ============================================================================
%% COMPARISON: STANDARD VS ELEGANT
%% ============================================================================
fprintf('\n--- Standard vs Elegant Comparison ---\n');

figure(3);
clf;

% Standard Hermite-Gaussian
subplot(2, 3, 1);
hg = BeamFactory.create('hermite', w0, lambda, 'n', 2, 'm', 1);
imagesc(abs(hg.opticalField(X, Y, 0)).^2);
colormap('hot');
axis square;
title('Standard HG_{2,1}');
colorbar;

% Elegant Hermite-Gaussian
subplot(2, 3, 2);
ehg = BeamFactory.create('elegant_hermite', w0, lambda, 'n', 2, 'm', 1);
imagesc(abs(ehg.opticalField(X, Y, 0)).^2);
colormap('hot');
axis square;
title('Elegant HG_{2,1}');
colorbar;

% Phase difference
subplot(2, 3, 3);
phaseDiff = angle(hg.opticalField(X, Y, 0)) - angle(ehg.opticalField(X, Y, 0));
imagesc(unwrap(phaseDiff, [], 1));
colormap('jet');
axis square;
title('Phase Difference (unwrap)');
colorbar;

% Standard Laguerre-Gaussian
subplot(2, 3, 4);
lg = BeamFactory.create('laguerre', w0, lambda, 'l', 2, 'p', 0);
imagesc(abs(lg.opticalField(X, Y, 0)).^2);
colormap('hot');
axis square;
title('Standard LG_{2,0}');
colorbar;

% Elegant Laguerre-Gaussian
subplot(2, 3, 5);
elg = BeamFactory.create('elegant_laguerre', w0, lambda, 'l', 2, 'p', 0);
imagesc(abs(elg.opticalField(X, Y, 0)).^2);
colormap('hot');
axis square;
title('Elegant LG_{2,0}');
colorbar;

% Phase difference
subplot(2, 3, 6);
phaseDiff = angle(lg.opticalField(X, Y, 0)) - angle(elg.opticalField(X, Y, 0));
imagesc(unwrap(phaseDiff, [], 1));
colormap('jet');
axis square;
title('Phase Difference (unwrap)');
colorbar;

%% ============================================================================
%% PROPAGATION COMPARISON
%% ============================================================================
fprintf('\n--- Propagation Comparison ---\n');

zPlanes = linspace(0, zr, 5);
fftOps  = FFTUtils(true, true);
[Kx, Ky] = simGrid.createFreqGrid();

figure(4);
clf;

for iz = 1:length(zPlanes)
    z = zPlanes(iz);
    
    % Standard vs Elegant at each z
    subplot(2, length(zPlanes), iz);
    hg_z = hg.opticalField(X, Y, z);
    imagesc(abs(hg_z).^2);
    colormap('hot');
    axis square;
    title(sprintf('HG z=%.1fz_R', z/zr));
    colorbar;
    
    subplot(2, length(zPlanes), iz + length(zPlanes));
    ehg_z = ehg.opticalField(X, Y, z);
    imagesc(abs(ehg_z).^2);
    colormap('hot');
    axis square;
    title(sprintf('E-HG z=%.1fz_R', z/zr));
    colorbar;
end

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Demo Complete ===\n');
fprintf('Figures:\n');
fprintf('  1: Elegant Hermite-Gaussian modes at z=0\n');
fprintf('  2: Elegant Laguerre-Gaussian modes at z=0\n');
fprintf('  3: Standard vs Elegant comparison (intensity + phase)\n');
fprintf('  4: Propagation comparison over z_R\n');