%% PropagationWithObstruction - Beam Propagation with Obstructions
%% Demonstrates beam propagation through circular/obstruction apertures.
%
% This script shows:
%   - Creation of obstruction masks (circular, rectangular, off-center)
%   - Application of obstructions to beam fields
%   - Propagation through obstructions (diffraction effects)
%   - Self-healing behavior analysis for higher-order modes
%   - Ray tracing with obstructions
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+propagation/PropagationWithObstruction.m')"
%
% Related:
%   +paraxial/+applications/+propagation/PropagationFFT.m
%   +paraxial/+applications/+analysis/SelfHealingAnalysis.m

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

fprintf('=== Propagation with Obstructions ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);
fprintf('  Rayleigh distance: %.4f m\n', zr);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 512;
Dx  = 3 * w0;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();
[Kx, Ky] = simGrid.createFreqGrid();
fftOps = FFTUtils();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% OBSTRUCTION DEFINITIONS
%% ============================================================================
fprintf('\n--- Obstruction Configurations ---\n');

% Circular obstruction (centered)
R_obs_center = 0.4 * w0;
mask_center  = double(sqrt(X.^2 + Y.^2) > R_obs_center);
fprintf('  Circular centered: R = %.1f w_0\n', R_obs_center/w0);

% Circular obstruction (off-center)
R_obs_off = 0.3 * w0;
x_off = 0.3 * w0;
y_off = 0.2 * w0;
mask_off = double(sqrt((X-x_off).^2 + (Y-y_off).^2) > R_obs_off);
fprintf('  Circular off-center: R = %.1f w_0, offset (%.1f, %.1f) w_0\n', ...
        R_obs_off/w0, x_off/w0, y_off/w0);

% Rectangular obstruction
lx_obs = 0.5 * w0;
ly_obs = 0.3 * w0;
mask_rect = double(~((abs(X) < lx_obs/2) & (abs(Y) < ly_obs/2)));
fprintf('  Rectangular: %.1f x %.1f w_0\n', lx_obs/w0, ly_obs/w0);

%% ============================================================================
%% BEAM SELECTION (Hermite-Gaussian for self-healing demonstration)
%% ============================================================================
fprintf('\n--- Beam Selection ---\n');

nMode = 2;
mMode = 2;

HG = BeamFactory.create('hermite', w0, lambda, 'n', nMode, 'm', mMode);
fprintf('  Creating Hermite-Gaussian: %s\n', HG.beamName());

% Base field at z=0
field_base = HG.opticalField(X, Y, 0);

%% ============================================================================
%% PROPAGATION PARAMETERS
%% ============================================================================
Dz    = zr;               % Propagation window: 1 z_R
Nz    = 32;               % Number of z-planes
dz    = Dz / Nz;
z_vec = linspace(0, Dz, Nz);

fprintf('  Propagation: Dz = %.4f m, Nz = %d planes\n', Dz, Nz);

%% ============================================================================
%% PROPAGATION WITHOUT OBSTRUCTION (reference)
%% ============================================================================
fprintf('\n--- Propagation: Reference (no obstruction) ---\n');

fields_ref = zeros(Nx, Nx, Nz);
field = field_base;

for iz = 1:Nz
    fields_ref(:, :, iz) = field;
    if iz < Nz
        field = fftOps.propagate(field, Kx, Ky, dz, lambda);
    end
end

fprintf('  Reference propagation complete\n');

%% ============================================================================
%% PROPAGATION WITH CIRCULAR OBSTRUCTION
%% ============================================================================
fprintf('\n--- Propagation: Circular obstruction ---\n');

fields_circ = zeros(Nx, Nx, Nz);
field = field_base .* mask_center;

for iz = 1:Nz
    fields_circ(:, :, iz) = field;
    if iz < Nz
        field = fftOps.propagate(field, Kx, Ky, dz, lambda);
    end
end

fprintf('  Circular obstruction propagation complete\n');

%% ============================================================================
%% VISUALIZATION: COMPARISON AT KEY Z-PLANES
%% ============================================================================
fprintf('\n--- Visualization ---\n');

keyPlanes = [1, floor(Nz/4), floor(Nz/2), Nz];
z_key = z_vec(keyPlanes);

figure(1);
clf;
nCols = length(keyPlanes);
nRows = 3;

for col = 1:length(keyPlanes)
    iz = keyPlanes(col);
    z = z_vec(iz);
    
    % Reference
    subplot(nRows, nCols, col);
    imagesc(abs(fields_ref(:, :, iz)).^2);
    colormap('hot');
    axis square;
    axis off;
    if col == 1
        ylabel('Reference');
    end
    title(sprintf('z = %.2f z_R', z/zr));
    
    % Circular obstruction
    subplot(nRows, nCols, col + nCols);
    imagesc(abs(fields_circ(:, :, iz)).^2);
    colormap('hot');
    axis square;
    axis off;
    if col == 1
        ylabel('Circular');
    end
    
    % Cross-section comparison
    subplot(nRows, nCols, col + 2*nCols);
    cutRow = Nx/2;
    plot(X(1,:)/w0, abs(fields_ref(cutRow,:,iz)).^2, 'b-', 'LineWidth', 1.5);
    hold on;
    plot(X(1,:)/w0, abs(fields_circ(cutRow,:,iz)).^2, 'r--', 'LineWidth', 1.5);
    hold off;
    xlabel('x / w_0');
    if col == 1
        ylabel('Intensity');
    end
    grid on;
    xlim([-3, 3]);
end

sgtitle('Propagation Comparison: Reference vs Circular Obstruction');

%% ============================================================================
%% SELF-HEALING ANALYSIS
%% ============================================================================
fprintf('\n--- Self-Healing Analysis ---\n');

% Compute intensity profiles along propagation
x_norm = X(1,:) / w0;
cutRow = Nx/2;

% Normalize intensities
max_ref = max(abs(fields_ref(:)).^2);
max_circ = max(abs(fields_circ(:)).^2);

figure(2);
clf;
hold on;

for iz = keyPlanes
    z = z_vec(iz);
    
    % Normalized reference
    plot(x_norm, abs(fields_ref(cutRow,:,iz)).^2 / max_ref, ...
         'Color', [0, 0.5, 1], 'LineWidth', 1.2);
    
    % Normalized with obstruction
    plot(x_norm, abs(fields_circ(cutRow,:,iz)).^2 / max_circ, ...
         'Color', [1, 0.3, 0.3], 'LineWidth', 1.2, 'LineStyle', '--');
end

hold off;
xlabel('x / w_0');
ylabel('Normalized Intensity');
title('Self-Healing: Reference (solid) vs Obstructed (dashed)');
legend('z=0', 'z=0.25z_R', 'z=0.5z_R', 'z=z_R', 'Location', 'best');
grid on;
xlim([-4, 4]);

%% ============================================================================
%% ZOOM ON REGION NEAR OBSTRUCTION EDGE
%% ============================================================================
figure(3);
clf;

% Focus on region near obstruction edge
edgeRegion = (abs(X(1,:)) < 2*w0) & (abs(Y(:,1)) < 0.2*w0);
x_edge = X(1, edgeRegion);
y_edge = Y(edgeRegion, 1);

subplot(2, 2, 1);
imagesc(x_edge/w0, y_edge/w0, abs(fields_ref(edgeRegion, edgeRegion, 1)).^2);
colormap('hot');
title('Reference at z=0 (edge region)');
xlabel('x / w_0');
ylabel('y / w_0');
axis square;

subplot(2, 2, 2);
imagesc(x_edge/w0, y_edge/w0, abs(fields_circ(edgeRegion, edgeRegion, 1)).^2);
colormap('hot');
title('Obstructed at z=0 (edge region)');
xlabel('x / w_0');
ylabel('y / w_0');
axis square;

subplot(2, 2, 3);
imagesc(x_edge/w0, y_edge/w0, abs(fields_ref(edgeRegion, edgeRegion, floor(Nz/2))).^2);
colormap('hot');
title(sprintf('Reference at z=0.5z_R (edge region)'));
xlabel('x / w_0');
ylabel('y / w_0');
axis square;

subplot(2, 2, 4);
imagesc(x_edge/w0, y_edge/w0, abs(fields_circ(edgeRegion, edgeRegion, floor(Nz/2))).^2);
colormap('hot');
title(sprintf('Obstructed at z=0.5z_R (edge region)'));
xlabel('x / w_0');
ylabel('y / w_0');
axis square;

%% ============================================================================
%% LATERAL VIEW COMPARISON
%% ============================================================================
figure(4);
clf;

% Build xz-plane from cross-section
xz_ref  = squeeze(abs(fields_ref(cutRow, :, :))).^2;
xz_circ = squeeze(abs(fields_circ(cutRow, :, :))).^2;

subplot(1, 2, 1);
imagesc(z_vec/zr, X(1,:)/w0, xz_ref);
colormap('hot');
set(gca, 'YDir', 'normal');
xlabel('z / z_R');
ylabel('x / w_0');
title('Reference (xz-cut at y=0)');

subplot(1, 2, 2);
imagesc(z_vec/zr, X(1,:)/w0, xz_circ);
colormap('hot');
set(gca, 'YDir', 'normal');
xlabel('z / z_R');
ylabel('x / w_0');
title('Circular Obstruction (xz-cut at y=0)');

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Propagation with Obstruction Complete ===\n');
fprintf('  Beam: %s\n', HG.beamName());
fprintf('  Obstruction: Circular, R = %.1f w_0\n', R_obs_center/w0);
fprintf('  Propagation: %d z-planes to z_R\n', Nz);
fprintf('\nFigures:\n');
fprintf('  1: Comparison at key z-planes (intensity + cross-sections)\n');
fprintf('  2: Self-healing analysis (normalized profiles)\n');
fprintf('  3: Edge region zoom (z=0 and z=0.5z_R)\n');
fprintf('  4: Lateral view comparison (xz-cut)\n');