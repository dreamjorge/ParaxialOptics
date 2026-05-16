%% SelfHealingAnalysis - Self-Healing Behavior Analysis
%% Analyzes the self-healing phenomenon in obstructed beams.
%
% Self-healing (or self-reconstruction) occurs when a beam that has been
% obstructed reconstructs its original profile as it propagates, due to
% the wave nature of light.
%
% This script shows:
%   - Propagation through various obstruction types
%   - Self-healing quantification metrics
%   - Comparison of different beam modes
%   - Time evolution of reconstruction
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+analysis/SelfHealingAnalysis.m')"
%
% Related:
%   +paraxial/+applications/+propagation/PropagationWithObstruction.m
%   +paraxial/+applications/+demos/DemoHermiteLaguerre.m

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

fprintf('=== Self-Healing Analysis ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);
fprintf('  Rayleigh distance: %.4f m\n', zr);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 512;
Dx  = 4 * w0;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();
[Kx, Ky] = simGrid.createFreqGrid();
fftOps = FFTUtils();

fprintf('\nGrid: %d x %d points, window %.4f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% PROPAGATION PARAMETERS
%% ============================================================================
Dz    = 2 * zr;           % Propagation window: 2 z_R
Nz    = 64;               % Number of z-planes
dz    = Dz / Nz;
z_vec = linspace(0, Dz, Nz);

fprintf('  Propagation: Dz = %.4f m (2 z_R), Nz = %d planes\n', Dz, Nz);

%% ============================================================================
%% OBSTRUCTION DEFINITIONS
%% ============================================================================
fprintf('\n--- Obstruction Configurations ---\n');

% Circular obstruction (centered)
R_obs = 0.5 * w0;
mask_circ = double(sqrt(X.^2 + Y.^2) > R_obs);
fprintf('  Circular centered: R = %.1f w_0\n', R_obs/w0);

% Rectangular obstruction
lx_obs = 0.6 * w0;
ly_obs = 0.4 * w0;
mask_rect = double(~((abs(X) < lx_obs/2) & (abs(Y) < ly_obs/2)));
fprintf('  Rectangular: %.1f x %.1f w_0\n', lx_obs/w0, ly_obs/w0);

%% ============================================================================
%% BEAM MODE COMPARISON
%% ============================================================================
fprintf('\n--- Beam Mode Comparison ---\n');

modes = {
    {'gaussian', 0, 0}, ...
    {'hermite',  1, 0}, ...
    {'hermite',  2, 0}, ...
    {'hermite',  2, 2}, ...
    {'laguerre', 1, 0}, ...
    {'laguerre', 2, 0}, ...
    {'laguerre', 3, 0} ...
};

nModes = length(modes);

%% ============================================================================
%% PROPAGATION AND METRICS COMPUTATION
%% ============================================================================
fprintf('\n--- Computing Self-Healing Metrics ---\n');

% Metrics: Normalized Cross-Correlation (NCC) and RMSD
results = cell(nModes, 1);

for i = 1:nModes
    modeName = modes{i}{1};
    n = modes{i}{2};
    m = modes{i}{3};
    
    % Create beam
    if strcmp(modeName, 'gaussian')
        beam = BeamFactory.create('gaussian', w0, lambda);
        beamName = 'Gaussian';
    elseif strcmp(modeName, 'hermite')
        beam = BeamFactory.create('hermite', w0, lambda, 'n', n, 'm', m);
        beamName = sprintf('HG_{%d,%d}', n, m);
    else  % laguerre
        beam = BeamFactory.create('laguerre', w0, lambda, 'l', n, 'p', m);
        beamName = sprintf('LG_{%d,%d}', n, m);
    end
    
    fprintf('  %s: ', beamName);
    
    % Reference field at z=0
    field_ref = beam.opticalField(X, Y, 0);
    
    % Normalize reference
    field_ref_norm = field_ref / sqrt(sum(abs(field_ref(:)).^2));
    
    % Obstructed field at z=0
    field_obs = field_ref .* mask_circ;
    field_obs_norm = field_obs / sqrt(sum(abs(field_obs(:)).^2));
    
    % Propagate both
    fields_ref  = zeros(Nx, Nx, Nz);
    fields_obs  = zeros(Nx, Nx, Nz);
    
    f_ref = field_ref_norm;
    f_obs = field_obs_norm;
    
    for iz = 1:Nz
        fields_ref(:, :, iz) = f_ref;
        fields_obs(:, :, iz) = f_obs;
        
        if iz < Nz
            f_ref = fftOps.propagate(f_ref, Kx, Ky, dz, lambda);
            f_obs = fftOps.propagate(f_obs, Kx, Ky, dz, lambda);
        end
    end
    
    % Compute metrics at each z-plane
    NCC = zeros(Nz, 1);
    RMSD = zeros(Nz, 1);
    
    for iz = 1:Nz
        % Normalized cross-correlation
        E_ref = fields_ref(:, :, iz);
        E_obs = fields_obs(:, :, iz);
        
        % NCC = |<E_ref|E_obs>|^2 / (<E_ref|E_ref><E_obs|E_obs>)
        numerator = abs(sum(E_ref(:) .* conj(E_obs(:))));
        denom = sqrt(sum(abs(E_ref(:)).^2) * sum(abs(E_obs(:)).^2));
        NCC(iz) = (numerator / denom)^2;
        
        % RMSD
        diff = abs(E_ref(:)) - abs(E_obs(:));
        RMSD(iz) = sqrt(mean(diff.^2));
    end
    
    results{i} = struct('name', beamName, 'NCC', NCC, 'RMSD', RMSD);
    fprintf('NCC(z_R) = %.4f, RMSD(z_R) = %.4f\n', NCC(end), RMSD(end));
end

%% ============================================================================
%% VISUALIZATION: NCC EVOLUTION
%% ============================================================================
fprintf('\n--- Visualization ---\n');

figure(1);
clf;
hold on;
colors = lines(nModes);

for i = 1:nModes
    plot(z_vec/zr, results{i}.NCC, ...
         'Color', colors(i, :), ...
         'LineWidth', 2, ...
         'DisplayName', results{i}.name);
end

hold off;
xlabel('z / z_R');
ylabel('Normalized Cross-Correlation (NCC)');
title('Self-Healing: NCC Evolution');
legend('Location', 'best');
grid on;
xlim([0, 2]);

%% ============================================================================
%% VISUALIZATION: RMSD EVOLUTION
%% ============================================================================
figure(2);
clf;
hold on;

for i = 1:nModes
    plot(z_vec/zr, results{i}.RMSD, ...
         'Color', colors(i, :), ...
         'LineWidth', 2, ...
         'DisplayName', results{i}.name);
end

hold off;
xlabel('z / z_R');
ylabel('Root Mean Square Difference (RMSD)');
title('Self-Healing: RMSD Evolution');
legend('Location', 'best');
grid on;
xlim([0, 2]);

%% ============================================================================
%% KEY Z-PLANES VISUALIZATION
%% ============================================================================
keyPlanes = [1, 8, 16, 32, Nz];
z_key = z_vec(keyPlanes);

figure(3);
clf;
nCols = length(keyPlanes);
nRows = 2;  % Reference and Obstructed

% Show Gaussian as example
ref_idx = 1;
ref_name = results{ref_idx}.name;

for col = 1:nCols
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
    title(sprintf('z=%.2f z_R', z/zr));
    
    % Obstructed
    subplot(nRows, nCols, col + nCols);
    imagesc(abs(fields_obs(:, :, iz)).^2);
    colormap('hot');
    axis square;
    axis off;
    if col == 1
        ylabel('Obstructed');
    end
end

sgtitle(sprintf('Self-Healing: %s Reference vs Obstructed', ref_name));

%% ============================================================================
%% HEALING TIME ESTIMATION
%% ============================================================================
fprintf('\n--- Healing Time Estimation ---\n');

% Find z where NCC > threshold (e.g., 0.9)
threshold = 0.9;
healingTimes = zeros(nModes, 1);

for i = 1:nModes
    idx_healed = find(results{i}.NCC > threshold, 1);
    if isempty(idx_healed)
        healingTimes(i) = NaN;
        fprintf('  %s: NCC never reaches %.0f%%\n', results{i}.name, threshold*100);
    else
        healingTimes(i) = z_vec(idx_healed);
        fprintf('  %s: heals at z = %.3f m (%.2f z_R)\n', ...
                results{i}.name, healingTimes(i), healingTimes(i)/zr);
    end
end

figure(4);
clf;
bar(1:nModes, healingTimes/zr);
set(gca, 'xticklabel', {results{:}.name});
xlabel('Beam Mode');
ylabel('Healing Time / z_R');
title(sprintf('Time to reach NCC = %.0f%%', threshold*100));
grid on;

%% ============================================================================
%% CROSS-SECTION COMPARISON
%% ============================================================================
figure(5);
clf;

% Select Gaussian and Hermite-Gaussian (2,2) for comparison
idx_gauss = 1;
idx_hg22 = 4;

cutRow = Nx/2 + 1;
x_norm = X(1,:) / w0;

subplot(1, 2, 1);
hold on;
for iz = keyPlanes
    z = z_vec(iz);
    plot(x_norm, abs(squeeze(fields_ref(cutRow, :, iz))).^2, ...
         'LineWidth', 1.2);
end
hold off;
xlabel('x / w_0');
ylabel('Intensity (Reference)');
title(sprintf('%s Reference Profiles', results{idx_gauss}.name));
grid on;
xlim([-3, 3]);
legend(arrayfun(@(z) sprintf('z=%.1f', z/zr), z_key, 'UniformOutput', false));

subplot(1, 2, 2);
hold on;
for iz = keyPlanes
    z = z_vec(iz);
    plot(x_norm, abs(squeeze(fields_obs(cutRow, :, iz))).^2, ...
         'LineWidth', 1.2);
end
hold off;
xlabel('x / w_0');
ylabel('Intensity (Obstructed)');
title(sprintf('%s Obstructed Profiles', results{idx_gauss}.name));
grid on;
xlim([-3, 3]);

%% ============================================================================
%% INTENSITY PROFILE RECONSTRUCTION
%% ============================================================================
figure(6);
clf;

% Show reconstruction at z=0, z=z_R/4, z=z_R, z=2z_R
reconPlanes = [1, 16, 32, 64];
z_recon = z_vec(reconPlanes);

for col = 1:length(reconPlanes)
    iz = reconPlanes(col);
    z = z_vec(iz);
    
    % Reference
    subplot(2, length(reconPlanes), col);
    imagesc(x_norm, x_norm, abs(fields_ref(:, :, iz)).^2);
    colormap('hot');
    axis square;
    axis off;
    title(sprintf('Ref z=%.1fz_R', z/zr));
    
    % Obstructed
    subplot(2, length(reconPlanes), col + length(reconPlanes));
    imagesc(x_norm, x_norm, abs(fields_obs(:, :, iz)).^2);
    colormap('hot');
    axis square;
    axis off;
    if col == 1
        ylabel('Obstructed');
    end
    title(sprintf('Obs z=%.1fz_R', z/zr));
end

sgtitle('Intensity Reconstruction Over Propagation');

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Self-Healing Analysis Complete ===\n');
fprintf('  Modes analyzed: %d\n', nModes);
fprintf('  Obstruction: Circular, R = %.1f w_0\n', R_obs/w0);
fprintf('  Propagation: %.1f z_R\n', Dz/zr);
fprintf('\nFigures:\n');
fprintf('  1: NCC evolution over propagation\n');
fprintf('  2: RMSD evolution over propagation\n');
fprintf('  3: Intensity comparison at key z-planes\n');
fprintf('  4: Healing time comparison (bar chart)\n');
fprintf('  5: Cross-section profiles (reference vs obstructed)\n');
fprintf('  6: 2D intensity reconstruction\n');

% Print summary table
fprintf('\n--- Summary Table ---\n');
fprintf('%-20s | %8s | %12s\n', 'Mode', 'NCC(z_R)', 'RMSD(z_R)');
fprintf('%s\n', repmat('-', 1, 45));
for i = 1:nModes
    fprintf('%-20s | %8.4f | %12.4f\n', ...
            results{i}.name, results{i}.NCC(end), results{i}.RMSD(end));
end