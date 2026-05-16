%% DemoHermiteLaguerre - Multi-Mode Beam Demonstration
%% Demonstrates Hermite-Gaussian and Laguerre-Gaussian beam modes.
%
% This demo shows:
%   - Creation of Hermite-Gaussian (n,m) modes via BeamFactory
%   - Creation of Laguerre-Gaussian (l,p) modes via BeamFactory
%   - Intensity visualization for both beam families
%   - Parameter extraction for each mode
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+demos/DemoHermiteLaguerre.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoGaussian.m
%   +paraxial/+applications/+demos/DemoElegantModes.m
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

fprintf('=== Multi-Mode Beam Demo ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 512;               % Grid resolution
Dx  = 1.5e-3;            % Window size: 1.5 mm
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% HERMITE-GAUSSIAN MODES
%% ============================================================================
fprintf('\n--- Hermite-Gaussian Modes ---\n');

modesHG = {[1, 1], [2, 0], [0, 2], [3, 3]};
nModes  = length(modesHG);
fieldsHG = cell(nModes, 1);
namesHG  = cell(nModes, 1);

for i = 1:nModes
    n = modesHG{i}(1);
    m = modesHG{i}(2);
    
    fprintf('  Creating HG_{%d,%d}... ', n, m);
    
    hb = BeamFactory.create('hermite', w0, lambda, 'n', n, 'm', m);
    fieldsHG{i} = hb.opticalField(X, Y, 0);
    namesHG{i}  = sprintf('HG_{%d,%d}', n, m);
    
    fprintf('done\n');
end

%% ============================================================================
%% LAGUERRE-GAUSSIAN MODES
%% ============================================================================
fprintf('\n--- Laguerre-Gaussian Modes ---\n');

modesLG = {[1, 0], [2, 0], [0, 1], [3, 0]};
fieldsLG = cell(length(modesLG), 1);
namesLG  = cell(length(modesLG), 1);

for i = 1:length(modesLG)
    l = modesLG{i}(1);
    p = modesLG{i}(2);
    
    fprintf('  Creating LG_{%d,%d}... ', l, p);
    
    lb = BeamFactory.create('laguerre', w0, lambda, 'l', l, 'p', p);
    fieldsLG{i} = lb.opticalField(X, Y, 0);
    namesLG{i}  = sprintf('LG_{%d,%d}', l, p);
    
    fprintf('done\n');
end

%% ============================================================================
%% VISUALIZATION: HERMITE-GAUSSIAN
%% ============================================================================
figure(1);
clf;
nCols = 2;
nRows = ceil(nModes / nCols);

for i = 1:nModes
    subplot(nRows, nCols, i);
    imagesc(abs(fieldsHG{i}).^2);
    colormap('hot');
    axis square;
    title(namesHG{i});
    colorbar;
end
title('Hermite-Gaussian Modes (intensity)');

%% ============================================================================
%% VISUALIZATION: LAGUERRE-GAUSSIAN
%% ============================================================================
figure(2);
clf;
nCols = 2;
nRows = ceil(length(modesLG) / nCols);

for i = 1:length(modesLG)
    subplot(nRows, nCols, i);
    imagesc(abs(fieldsLG{i}).^2);
    colormap('hot');
    axis square;
    title(namesLG{i});
    colorbar;
end
title('Laguerre-Gaussian Modes (intensity)');

%% ============================================================================
%% VISUALIZATION: COMPARISON AT z = z_R/2
%% ============================================================================
z_prop = 0.5;  % Propagate to z = 0.5 m

fprintf('\n--- Propagation to z = %.1f m ---\n', z_prop);

figure(3);
clf;

% Hermite-Gaussian at z
subplot(1, 2, 1);
hb = BeamFactory.create('hermite', w0, lambda, 'n', 1, 'm', 1);
fieldHG_z = hb.opticalField(X, Y, z_prop);
imagesc(abs(fieldHG_z).^2);
colormap('hot');
axis square;
title(sprintf('HG_{1,1} at z = %.1f m', z_prop));
colorbar;

% Laguerre-Gaussian at z
subplot(1, 2, 2);
lb = BeamFactory.create('laguerre', w0, lambda, 'l', 1, 'p', 0);
fieldLG_z = lb.opticalField(X, Y, z_prop);
imagesc(abs(fieldLG_z).^2);
colormap('hot');
axis square;
title(sprintf('LG_{1,0} at z = %.1f m', z_prop));
colorbar;

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Demo Complete ===\n');
fprintf('Figures:\n');
fprintf('  1: Hermite-Gaussian modes at z=0\n');
fprintf('  2: Laguerre-Gaussian modes at z=0\n');
fprintf('  3: HG and LG modes at z=0.5 m\n');

% Print beam names
fprintf('\nBeam names from BeamFactory:\n');
for i = 1:nModes
    hb = BeamFactory.create('hermite', w0, lambda, 'n', modesHG{i}(1), 'm', modesHG{i}(2));
    fprintf('  %s: %s\n', namesHG{i}, hb.beamName());
end