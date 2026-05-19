%% RayBundleAnalysis - Ray Bundle Analysis and Visualization
%% Demonstrates ray tracing, bundle manipulation, and trajectory analysis.
%
% This script shows:
%   - Creation of RayBundle objects (various initial configurations)
%   - Ray tracing propagation
%   - Trajectory visualization (2D and 3D)
%   - Bundle statistics and metrics
%   - Integration with field propagation
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+analysis/RayBundleAnalysis.m')"
%
% Related:
%   +paraxial/+applications/+propagation/PropagationFFT.m
%   +paraxial/+applications/+demos/DemoGaussian.m

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

fprintf('=== Ray Bundle Analysis ===\n');
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

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% PROPAGATION PARAMETERS
%% ============================================================================
Dz    = zr;
Nz    = 64;
dz    = Dz / Nz;
z_vec = (0:Nz) * dz;

fprintf('  Propagation: Dz = %.4f m, Nz = %d planes\n', Dz, Nz);

%% ============================================================================
%% RAY BUNDLE CREATION
%% ============================================================================
fprintf('\n--- Ray Bundle Creation ---\n');

% Create Gaussian beam for reference
GB = BeamFactory.create('gaussian', w0, lambda);

% Circular contour bundle (seeded on waist edge)
bundle_circ = RayBundle.createCircularContour(24, w0, 0, w0, 0);
fprintf('  Circular contour: %d rays (%.1f x %.1f grid)\n', ...
        bundle_circ.Ny * bundle_circ.Nx, bundle_circ.Ny, bundle_circ.Nx);

% Rectangular grid bundle
bundle_grid = RayBundle.createSquareGrid(8, 8, w0);
fprintf('  Square grid: %d rays (%.1f x %.1f grid)\n', ...
        bundle_grid.Ny * bundle_grid.Nx, bundle_grid.Ny, bundle_grid.Nx);

% Gaussian intensity-weighted bundle (sample more rays near center)
bundle_gauss = RayBundle.createGaussianWeighted(16, 16, w0, 0.5);
fprintf('  Gaussian-weighted: %d rays\n', ...
        bundle_gauss.Ny * bundle_gauss.Nx);

%% ============================================================================
%% RAY TRACING PROPAGATION
%% ============================================================================
fprintf('\n--- Ray Tracing Propagation ---\n');

% Propagate circular bundle
fprintf('  Propagating circular bundle... ');
bundle_circ = RayTracer.propagateToPlanes(bundle_circ, GB, z_vec, dz, 'RK4');
fprintf('done\n');

% Propagate grid bundle
fprintf('  Propagating grid bundle... ');
bundle_grid = RayTracer.propagateToPlanes(bundle_grid, GB, z_vec, dz, 'RK4');
fprintf('done\n');

% Propagate gaussian bundle
fprintf('  Propagating gaussian bundle... ');
bundle_gauss = RayTracer.propagateToPlanes(bundle_gauss, GB, z_vec, dz, 'RK4');
fprintf('done\n');

%% ============================================================================
%% TRAJECTORY VISUALIZATION: 2D
%% ============================================================================
fprintf('\n--- Visualization ---\n');

% Extract positions at key z-planes
keyPlanes = [1, 16, 32, Nz+1];
z_key = z_vec(keyPlanes);

figure(1);
clf;
nPlots = length(keyPlanes);

for i = 1:nPlanes
    zi = keyPlanes(i);
    subplot(1, nPlots, i);
    
    % Plot beam intensity at this z
    [Xz, Yz] = meshgrid(X(1,:), Y(:,1));
    E_z = GB.opticalField(Xz, Yz, z_vec(zi));
    
    % Normalize and display
    I_z = abs(E_z).^2 / max(abs(E_z(:)).^2);
    imagesc(X(1,:)/w0, Y(:,1)/w0, I_z);
    colormap('hot');
    hold on;
    set(gca, 'YDir', 'normal');
    
    % Overlay ray positions
    rx = squeeze(bundle_circ.x(:,:,zi)) / w0;
    ry = squeeze(bundle_circ.y(:,:,zi)) / w0;
    plot(rx(:), ry(:), 'c.', 'MarkerSize', 4);
    
    hold off;
    title(sprintf('z = %.2f z_R', z_vec(zi)/zr));
    xlabel('x / w_0');
    ylabel('y / w_0');
    axis square;
end

sgtitle('Ray Bundle Propagation (Circular Contour)');

%% ============================================================================
%% TRAJECTORY VISUALIZATION: 3D
%% ============================================================================
figure(2);
clf;
VisualizationUtils.plotRays3D(bundle_grid, 'b');
title('Square Grid Bundle: 3D Trajectories');
xlabel('z (m)');
ylabel('x (m)');
zlabel('y (m)');

figure(3);
clf;
VisualizationUtils.plotRays3D(bundle_gauss, 'r');
title('Gaussian-Weighted Bundle: 3D Trajectories');
xlabel('z (m)');
ylabel('x (m)');
zlabel('y (m)');

%% ============================================================================
%% TRAJECTORY COMPARISON
%% ============================================================================
figure(4);
clf;
hold on;

% Plot trajectories for each bundle type
Nrays_circ = bundle_circ.Ny * bundle_circ.Nx;
Nrays_grid = bundle_grid.Ny * bundle_grid.Nx;
Nrays_gauss = bundle_gauss.Ny * bundle_gauss.Nx;

% Sample trajectories (every 10th ray for clarity)
step = 10;

% Circular bundle
for ii = 1:step:Nrays_circ
    [ri, ci] = ind2sub([bundle_circ.Ny, bundle_circ.Nx], ii);
    plot3(squeeze(bundle_circ.z(ri,ci,:)), ...
          squeeze(bundle_circ.x(ri,ci,:)), ...
          squeeze(bundle_circ.y(ri,ci,:)), ...
          'b', 'LineWidth', 0.5);
end

% Grid bundle
for ii = 1:step:Nrays_grid
    [ri, ci] = ind2sub([bundle_grid.Ny, bundle_grid.Nx], ii);
    plot3(squeeze(bundle_grid.z(ri,ci,:)), ...
          squeeze(bundle_grid.x(ri,ci,:)), ...
          squeeze(bundle_grid.y(ri,ci,:)), ...
          'g', 'LineWidth', 0.5);
end

hold off;
grid on;
view(3);
xlabel('z (m)');
ylabel('x (m)');
zlabel('y (m)');
title('Trajectory Comparison: Circular (blue) vs Grid (green)');
legend('Sample every 10th ray');

%% ============================================================================
%% RAY BUNDLE STATISTICS
%% ============================================================================
fprintf('\n--- Bundle Statistics ---\n');

% Compute radial positions at each z-plane
radial_circ = zeros(Nz+1, 1);
radial_grid = zeros(Nz+1, 1);

for zi = 1:Nz+1
    % Circular bundle
    x_c = squeeze(bundle_circ.x(:,:,zi));
    y_c = squeeze(bundle_circ.y(:,:,zi));
    r_c = sqrt(x_c(:).^2 + y_c(:).^2);
    radial_circ(zi) = mean(r_c);
    
    % Grid bundle
    x_g = squeeze(bundle_grid.x(:,:,zi));
    y_g = squeeze(bundle_grid.y(:,:,zi));
    r_g = sqrt(x_g(:).^2 + y_g(:).^2);
    radial_grid(zi) = mean(r_g);
end

fprintf('  Mean radial position evolution:\n');
fprintf('    z=0:  circular = %.2f w_0, grid = %.2f w_0\n', ...
        radial_circ(1)/w0, radial_grid(1)/w0);
fprintf('    z=z_R: circular = %.2f w_0, grid = %.2f w_0\n', ...
        radial_circ(end)/w0, radial_grid(end)/w0);

% Plot radial evolution
figure(5);
clf;
plot(z_vec/zr, radial_circ/w0, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
hold on;
plot(z_vec/zr, radial_grid/w0, 'g-s', 'LineWidth', 2, 'MarkerSize', 6);
hold off;
xlabel('z / z_R');
ylabel('Mean radial position / w_0');
title('Ray Bundle Radial Expansion');
legend('Circular', 'Grid');
grid on;

%% ============================================================================
%% CONVERGENCE/DIVERGENCE ANALYSIS
%% ============================================================================
fprintf('\n--- Convergence/Divergence Analysis ---\n');

% Compute angular spread (from x-y positions at z)
% Use the slope of radial position vs z

% Circular bundle
dr_c = (radial_circ(end) - radial_circ(1)) / Dz;
% Grid bundle
dr_g = (radial_grid(end) - radial_grid(1)) / Dz;

% Angle in radians (assuming small angles)
theta_c = atan(dr_c);
theta_g = atan(dr_g);

% Convert to degrees
theta_c_deg = theta_c * 180 / pi;
theta_g_deg = theta_g * 180 / pi;

fprintf('  Mean divergence angles:\n');
fprintf('    Circular bundle: %.3f deg (%.4f rad)\n', theta_c_deg, theta_c);
fprintf('    Grid bundle:     %.3f deg (%.4f rad)\n', theta_g_deg, theta_g);

%% ============================================================================
%% INTERSECTION ANALYSIS
%% ============================================================================
fprintf('\n--- Waist Detection ---\n');

% Find z where radial position is minimum (waist)
[minRad_c, idxMin_c] = min(radial_circ);
[minRad_g, idxMin_g] = min(radial_grid);

z_waist_c = z_vec(idxMin_c);
z_waist_g = z_vec(idxMin_g);

fprintf('  Circular bundle waist: z = %.4f m (%.2f z_R)\n', z_waist_c, z_waist_c/zr);
fprintf('  Grid bundle waist:     z = %.4f m (%.2f z_R)\n', z_waist_g, z_waist_g/zr);

figure(6);
clf;
plot(z_vec/zr, radial_circ/w0, 'b-', 'LineWidth', 2);
hold on;
plot(z_vec/zr, radial_grid/w0, 'g-', 'LineWidth', 2);
plot(z_waist_c/zr, minRad_c/w0, 'bo', 'MarkerSize', 12, 'LineWidth', 2);
plot(z_waist_g/zr, minRad_g/w0, 'gs', 'MarkerSize', 12, 'LineWidth', 2);
hold off;
xlabel('z / z_R');
ylabel('Mean radial position / w_0');
title('Waist Detection (Minima of Radial Position)');
legend('Circular', 'Grid', 'Circular waist', 'Grid waist');
grid on;

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Ray Bundle Analysis Complete ===\n');
fprintf('  Circular contour: %d rays\n', Nrays_circ);
fprintf('  Square grid: %d rays\n', Nrays_grid);
fprintf('  Gaussian-weighted: %d rays\n', Nrays_gauss);
fprintf('  Propagation: %d z-planes to z_R\n', Nz);
fprintf('\nFigures:\n');
fprintf('  1: Ray positions at key z-planes (beam + rays)\n');
fprintf('  2: Square grid bundle 3D trajectories\n');
fprintf('  3: Gaussian-weighted bundle 3D trajectories\n');
fprintf('  4: Trajectory comparison (all types)\n');
fprintf('  5: Radial position evolution\n');
fprintf('  6: Waist detection\n');