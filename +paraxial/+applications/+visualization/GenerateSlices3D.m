%% GenerateSlices3D - 3D Visualization of Beam Propagation
%% Generates 3D slice visualizations of beam intensity over propagation.
%
% This script shows:
%   - 3D volume visualization of beam propagation
%   - Interactive slicing at configurable z-planes
%   - Combination with ray trajectory overlay
%   - Publication-quality figure generation
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+visualization/GenerateSlices3D.m')"
%
% Related:
%   +paraxial/+applications/+propagation/PropagationFFT.m
%   +paraxial/+applications/+visualization/GenerateVideo.m

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

fprintf('=== 3D Slices Visualization ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);
fprintf('  Rayleigh distance: %.4f m\n', zr);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 256;               % Reduced resolution for 3D visualization
Dx  = 2 * w0;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();
[Kx, Ky] = simGrid.createFreqGrid();
fftOps = FFTUtils();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% PROPAGATION PARAMETERS
%% ============================================================================
Dz    = zr;
Nz    = 32;
dz    = Dz / Nz;
z_vec = linspace(0, Dz, Nz);

fprintf('  Propagation: Dz = %.4f m, Nz = %d planes\n', Dz, Nz);

%% ============================================================================
%% BEAM SELECTION
%% ============================================================================
fprintf('\n--- Beam Selection ---\n');

beamType = 'hermite';  % Options: 'gaussian', 'hermite', 'laguerre'
nMode = 2;
mMode = 2;

if strcmp(beamType, 'gaussian')
    beam = BeamFactory.create('gaussian', w0, lambda);
    beamName = 'Gaussian';
elseif strcmp(beamType, 'hermite')
    beam = BeamFactory.create('hermite', w0, lambda, 'n', nMode, 'm', mMode);
    beamName = sprintf('HG_{%d,%d}', nMode, mMode);
else
    beam = BeamFactory.create('laguerre', w0, lambda, 'l', nMode, 'p', 0);
    beamName = sprintf('LG_{%d,0}', nMode);
end

fprintf('  Beam: %s\n', beamName);

%% ============================================================================
%% PROPAGATION AND VOLUME BUILDING
%% ============================================================================
fprintf('\n--- Building Intensity Volume ---\n');

% Build 3D intensity volume [Nx, Nx, Nz]
field = beam.opticalField(X, Y, 0);
V = zeros(Nx, Nx, Nz);

for iz = 1:Nz
    V(:, :, iz) = abs(field).^2;
    if iz < Nz
        field = fftOps.propagate(field, Kx, Ky, dz, lambda);
    end
    if mod(iz, 8) == 0
        fprintf('  z-plane %d/%d\n', iz, Nz);
    end
end

fprintf('  Volume built: %d x %d x %d\n', Nx, Nx, Nz);

%% ============================================================================
%% VISUALIZATION: 3D SLICE PLOT
%% ============================================================================
fprintf('\n--- Visualization ---\n');

% Define slice positions (fractions of z_R)
slicePositions = [0, 0.1, 0.25, 0.5];
z_slices = slicePositions * zr;

% Create figure
figure(1);
clf;

% Use slice function for 3D visualization
[x_slice, y_slice, z_slice] = meshgrid(X(1,:), Y(:,1), z_vec);

% Transparency for better visualization
alpha_val = 0.8;

% Create isosurface or slice visualization
subplot(2, 2, 1);
hold on;

% Slices at different z positions
for i = 1:length(z_slices)
    idx = find(z_vec >= z_slices(i), 1);
    if ~isempty(idx)
        slice(X(1,:), Y(:,1), z_vec, V, [], [], z_slices(i));
    end
end

colormap('hot');
caxis([0, max(V(:))]);
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title(sprintf('%s Beam Propagation Slices', beamName));
view(45, 30);
grid on;
lighting gouraud;
material shiny;

%% ============================================================================
%% VISUALIZATION: LATERAL SLICES
%% ============================================================================
subplot(2, 2, 2);
hold on;

% Slices at x and y positions
xslice_val = 0;
yslice_val = 0;

% XZ slice (y=0)
slice(X(1,:), Y(:,1), z_vec, V, [], Nx/2+1, []);

% YZ slice (x=0)
slice(X(1,:), Y(:,1), z_vec, V, Nx/2+1, [], []);

colormap('hot');
caxis([0, max(V(:))]);
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title(sprintf('%s Beam Lateral Slices (XZ, YZ)', beamName));
view(0, 0);
grid on;

%% ============================================================================
%% VISUALIZATION: XZ CUT WITH CONTOUR
%% ============================================================================
subplot(2, 2, 3);

% XZ slice at y = center
xz_slice = squeeze(V(Nx/2+1, :, :));
imagesc(z_vec/zr, X(1,:)/w0, xz_slice);
colormap('hot');
hold on;
contour(z_vec/zr, X(1,:)/w0, xz_slice, 'k-', 'LineWidth', 0.5);
hold off;
set(gca, 'YDir', 'normal');
xlabel('z / z_R');
ylabel('x / w_0');
title(sprintf('%s XZ-Cut with Contour', beamName));
colorbar;

%% ============================================================================
%% VISUALIZATION: ISOSURFACE
%% ============================================================================
subplot(2, 2, 4);

% Create isosurface at 50% of max intensity
isosurface(X(1,:), Y(:,1), z_vec, V, 0.3 * max(V(:)));

colormap('hot');
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title(sprintf('%s Isosurface (30%% max)', beamName));
view(45, 30);
grid on;
lighting gouraud;

%% ============================================================================
%% ADVANCED: TRANSPARENT SLICES WITH RAYS
%% ============================================================================
fprintf('\n--- Advanced: Transparent Slices with Rays ---\n');

% Create ray bundle
bundle = RayBundle.createCircularContour(16, w0, 0, w0, 0);
bundle = RayTracer.propagateToPlanes(bundle, beam, z_vec, dz, 'RK4');

figure(2);
clf;
hold on;

% Plot rays first
Nrays = bundle.Ny * bundle.Nx;
for ii = 1:Nrays
    [ri, ci] = ind2sub([bundle.Ny, bundle.Nx], ii);
    plot3(squeeze(bundle.z(ri,ci,:)), ...
          squeeze(bundle.x(ri,ci,:)), ...
          squeeze(bundle.y(ri,ci,:)), ...
          'c-', 'LineWidth', 0.5);
end

% Plot slices at z positions
for i = 1:length(z_slices)
    idx = find(z_vec >= z_slices(i), 1);
    if ~isempty(idx)
        z_s = z_vec(idx);
        h = slice(X(1,:), Y(:,1), z_vec, V, [], [], z_s);
        set(h, 'FaceAlpha', 0.6);
        set(h, 'EdgeColor', 'none');
    end
end

colormap('hot');
caxis([0, max(V(:))]);
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title(sprintf('%s: Transparent Slices with Ray Trajectories', beamName));
view(45, 30);
grid on;

%% ============================================================================
%% PUBLICATION FIGURE: 3D VOLUME SLICES
%% ============================================================================
fprintf('\n--- Publication Figure ---\n');

figure(3);
clf;
fig3.Position = [100, 100, 1200, 800];

% Create 2x3 grid of slices
nRows = 2;
nCols = 3;
sliceFracs = linspace(0, 1, nRows * nCols);

for i = 1:nRows*nCols
    subplot(nRows, nCols, i);
    
    z_frac = sliceFracs(i);
    z_idx = round(z_frac * (Nz-1)) + 1;
    
    imagesc(X(1,:)/w0, Y(:,1)/w0, V(:, :, z_idx));
    colormap('hot');
    axis square;
    title(sprintf('z = %.2f z_R', z_vec(z_idx)/zr));
    xlabel('x / w_0');
    ylabel('y / w_0');
    
    % Add waist contour
    params = beam.getParameters(z_vec(z_idx));
    % Draw waist circle at this z
    [TH, R] = meshgrid(linspace(0, 2*pi, 64), linspace(0, params.Waist/w0, 32));
    % Only draw if needed
    
    caxis([0, max(V(:))]);
end

sgtitle(sprintf('%s Beam: Intensity at %d z-planes', beamName, nRows*nCols));

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== 3D Slices Visualization Complete ===\n');
fprintf('  Beam: %s\n', beamName);
fprintf('  Volume: %d x %d x %d\n', Nx, Nx, Nz);
fprintf('  Slice positions: %s\n', mat2str(slicePositions));
fprintf('\nFigures:\n');
fprintf('  1: Multi-view 3D slices\n');
fprintf('  2: Transparent slices with ray overlay\n');
fprintf('  3: Publication-style multi-panel figure\n');

% Export options
fprintf('\nTo export figures:\n');
fprintf('  export_fig(''Slices3D_Summary'', ''-png'', ''-transparent'')\n');