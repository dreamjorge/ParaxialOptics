%% PropagationFFT - Angular Spectrum Propagation with Hankel Beams
%% Demonstrates FFT-based propagation for Hankel-Hermite and Hankel-Laguerre beams.
%
% This script shows:
%   - Beam creation via direct constructors (HankelHermite, HankelLaguerre)
%   - FFT field propagation (angular spectrum, step-by-step)
%   - Hankel ray tracing via HankelRayTracePropagator
%   - Combined visualization: intensity + ray overlay per z-step
%   - Video generation (MATLAB only, Octave skips gracefully)
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+propagation/PropagationFFT.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoGaussian.m
%   +paraxial/+applications/+propagation/PropagationAnalytic.m
%   +paraxial/+applications/+analysis/RayBundleAnalysis.m

scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..');
addpath(repoRoot);
setpaths();

GenerateVideo = true;  % Set to false to skip video generation

%% ============================================================================
%% PHYSICAL PARAMETERS (SI units)
%% ============================================================================
w0     = 100e-6;          % Initial waist: 100 microns
lambda = 632.8e-9;       % HeNe laser wavelength: 632.8 nm
k      = 2 * pi / lambda;
zr     = pi * w0^2 / lambda;  % Rayleigh distance

fprintf('=== FFT Propagation with Hankel Beams ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);
fprintf('  Rayleigh distance: %.4f m\n', zr);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx   = 512;
Dx   = 15 * w0;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();
[Kx, Ky] = simGrid.createFreqGrid();
fftOps = FFTUtils();

fprintf('\nGrid: %d x %d, window = %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% PROPAGATION PARAMETERS
%% ============================================================================
Dz    = zr;               % Propagation window: 1 z_R
Nz    = 64;               % Number of z-planes
dz    = Dz / Nz;
z_vec = (0:Nz) * dz;

fprintf('Propagation: Dz = %.4f m (%d z_R), Nz = %d planes\n', Dz, 1, Nz);

%% ============================================================================
%% OBSTRUCTION SETUP (Optional)
%% ============================================================================
R_obs = 0.6 * w0;  % Obstruction radius: 0.6 w0
mask  = (sqrt((X-0.95*R_obs).^2 + (Y).^2) > R_obs);
fprintf('Circular obstruction: R = %.1f w_0\n', R_obs/w0);

%% ============================================================================
%% HANKEL-HERMITE PROPAGATION (4 types: 11, 12, 21, 22)
%% ============================================================================
fprintf('\n--- Hankel-Hermite Propagation ---\n');

n_mode = 3;
m_mode = 2;

beam_h11 = HankelHermite(w0, lambda, n_mode, m_mode, 11);
beam_h12 = HankelHermite(w0, lambda, n_mode, m_mode, 12);
beam_h21 = HankelHermite(w0, lambda, n_mode, m_mode, 21);
beam_h22 = HankelHermite(w0, lambda, n_mode, m_mode, 22);

field_h11 = beam_h11.opticalField(X, Y, 0) .* mask;
field_h12 = beam_h12.opticalField(X, Y, 0) .* mask;
field_h21 = beam_h21.opticalField(X, Y, 0) .* mask;
field_h22 = beam_h22.opticalField(X, Y, 0) .* mask;

fprintf('  Hankel-Hermite H^{(xy)}_{%d,%d}: 4 types created\n', n_mode, m_mode);

% Ray tracing setup - seed rays on obstruction contour
bundle_h11 = RayBundle.createCircularContour(32, R_obs, 0, R_obs, 0);
bundle_h11.ht(:) = 11;
bundle_h11 = HankelRayTracer.propagateToPlanes(bundle_h11, beam_h11, z_vec, dz, 'RK4');

fprintf('  Ray bundle: %d rays, %d z-planes\n', bundle_h11.Ny * bundle_h11.Nx, Nz+1);

%% ============================================================================
%% VIDEO SETUP (MATLAB only)
%% ============================================================================
vidFile = fullfile(scriptPath, 'HankelHermitePropagation.avi');
if GenerateVideo
    try
        vidObj = VideoWriter(vidFile);
        vidObj.Quality = 95;
        vidObj.FrameRate = 15;
        open(vidObj);
        hasVideo = true;
    catch
        hasVideo = false;
        fprintf('  VideoWriter not available (Octave). Skipping.\n');
    end
else
    hasVideo = false;
end

%% ============================================================================
%% VISUALIZATION LOOP: HANKEL-HERMITE
%% ============================================================================
figure(1);
clf;
x_axis = X(1,:) / w0;
y_axis = Y(:,1) / w0;

for zi = 1:Nz+1
    % Left panel: H^(11) intensity with ray overlay
    subplot(1, 2, 1);
    imagesc(x_axis, y_axis, abs(field_h11).^2);
    set(gca, 'YDir', 'normal');
    colormap('hot');
    hold on;
    if zi <= size(bundle_h11.x, 3)
        rx = squeeze(bundle_h11.x(:,:,zi)) / w0;
        ry = squeeze(bundle_h11.y(:,:,zi)) / w0;
        plot(rx(:), ry(:), 'c.', 'MarkerSize', 6);
    end
    hold off;
    title(sprintf('H^{(11)}_{%d,%d}  z=%.2f z_R', n_mode, m_mode, z_vec(zi)/zr));
    xlabel('x / w_0');
    ylabel('y / w_0');

    % Right panel: Coherent sum (Gaussian beam)
    subplot(1, 2, 2);
    field_total = field_h11 + field_h12 + field_h21 + field_h22;
    imagesc(x_axis, y_axis, abs(field_total).^2);
    set(gca, 'YDir', 'normal');
    colormap('hot');
    title(sprintf('Gaussian (Sum)  z=%.2f z_R', z_vec(zi)/zr));
    xlabel('x / w_0');
    ylabel('y / w_0');

    drawnow;

    if hasVideo
        writeVideo(vidObj, getframe(gcf));
    end

    % Propagate fields one step
    if zi <= Nz
        field_h11 = fftOps.propagate(field_h11, Kx, Ky, dz, lambda);
        field_h12 = fftOps.propagate(field_h12, Kx, Ky, dz, lambda);
        field_h21 = fftOps.propagate(field_h21, Kx, Ky, dz, lambda);
        field_h22 = fftOps.propagate(field_h22, Kx, Ky, dz, lambda);
    end
end

if hasVideo
    close(vidObj);
    fprintf('  Video saved: %s\n', vidFile);
end

%% ============================================================================
%% HANKEL-LAGUERRE PROPAGATION (2 types: H1, H2)
%% ============================================================================
fprintf('\n--- Hankel-Laguerre Propagation ---\n');

l_mode = 5;
p_mode = 10;

beam_l1 = HankelLaguerre(w0, lambda, l_mode, p_mode, 1);
beam_l2 = HankelLaguerre(w0, lambda, l_mode, p_mode, 2);

field_l1 = beam_l1.opticalField(X, Y, 0) .* mask;
field_l2 = beam_l2.opticalField(X, Y, 0) .* mask;

fprintf('  Hankel-Laguerre H^{(x)}_{%d,%d}: 2 types created\n', l_mode, p_mode);

% Finer internal step for high-order modes
dz_internal = dz / 8;

% Ray bundles
bundle_l1 = RayBundle.createCircularContour(32, 0.95*R_obs, 0, R_obs, 0);
bundle_l1.ht(:) = 1;
bundle_l1 = HankelRayTracer.propagateToPlanes(bundle_l1, beam_l1, z_vec, dz_internal, 'RK4');

bundle_l2 = RayBundle.createCircularContour(32, R_obs, 0, R_obs, 0);
bundle_l2.ht(:) = 2;
bundle_l2 = HankelRayTracer.propagateToPlanes(bundle_l2, beam_l2, z_vec, dz_internal, 'RK4');

%% ============================================================================
%% VISUALIZATION LOOP: HANKEL-LAGUERRE
%% ============================================================================
vidFile2 = fullfile(scriptPath, 'HankelLaguerrePropagation.avi');
if GenerateVideo
    try
        vidObj2 = VideoWriter(vidFile2);
        vidObj2.Quality = 95;
        vidObj2.FrameRate = 15;
        open(vidObj2);
        hasVideo2 = true;
    catch
        hasVideo2 = false;
    end
else
    hasVideo2 = false;
end

figure(2);
clf;

for zi = 1:Nz+1
    subplot(1, 2, 1);
    imagesc(x_axis, y_axis, abs(field_l1).^2);
    set(gca, 'YDir', 'normal');
    colormap('hot');
    hold on;
    if zi <= size(bundle_l1.x, 3)
        rx = squeeze(bundle_l1.x(:,:,zi)) / w0;
        ry = squeeze(bundle_l1.y(:,:,zi)) / w0;
        plot(rx(:), ry(:), 'c.', 'MarkerSize', 6);
    end
    hold off;
    title(sprintf('H^{(1)}_{%d,%d}  z=%.2f z_R', l_mode, p_mode, z_vec(zi)/zr));
    xlabel('x / w_0');
    ylabel('y / w_0');

    subplot(1, 2, 2);
    field_lg = field_l1 + field_l2;
    imagesc(x_axis, y_axis, abs(field_lg).^2);
    set(gca, 'YDir', 'normal');
    colormap('hot');
    title(sprintf('LG (Normal)  z=%.2f z_R', z_vec(zi)/zr));
    xlabel('x / w_0');
    ylabel('y / w_0');

    drawnow;

    if hasVideo2
        writeVideo(vidObj2, getframe(gcf));
    end

    if zi <= Nz
        field_l1 = fftOps.propagate(field_l1, Kx, Ky, dz, lambda);
        field_l2 = fftOps.propagate(field_l2, Kx, Ky, dz, lambda);
    end
end

if hasVideo2
    close(vidObj2);
    fprintf('  Video saved: %s\n', vidFile2);
end

%% ============================================================================
%% 3D RAY TRAJECTORY VISUALIZATION
%% ============================================================================
fprintf('\n--- 3D Ray Visualization ---\n');

figure(3);
VisualizationUtils.plotRays3D(bundle_h11, 'b');
title(sprintf('Hankel-Hermite H^{(11)}_{%d,%d} Ray Trajectories', n_mode, m_mode));

figure(4);
hold on;
Nrays_l = bundle_l1.Ny * bundle_l1.Nx;
for ii = 1:Nrays_l
    [ri, ci] = ind2sub([bundle_l1.Ny, bundle_l1.Nx], ii);
    plot3(squeeze(bundle_l1.z(ri,ci,:)), squeeze(bundle_l1.x(ri,ci,:)), squeeze(bundle_l1.y(ri,ci,:)), 'r');
    plot3(squeeze(bundle_l2.z(ri,ci,:)), squeeze(bundle_l2.x(ri,ci,:)), squeeze(bundle_l2.y(ri,ci,:)), 'b');
end
hold off;
grid on;
view(3);
xlabel('z (m)');
ylabel('x (m)');
zlabel('y (m)');
title(sprintf('Hankel-Laguerre H^{(1)}(red) vs H^{(2)}(blue) — LG_{%d,%d}', l_mode, p_mode));
legend('H^{(1)}', 'H^{(2)}');

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== FFT Propagation Complete ===\n');
fprintf('  Hermite: H^{(11)}_{%d,%d} propagated over 1 z_R\n', n_mode, m_mode);
fprintf('  Laguerre: H^{(x)}_{%d,%d} propagated over 1 z_R\n', l_mode, p_mode);
fprintf('\nFigures:\n');
fprintf('  1: Hankel-Hermite propagation with rays (video)\n');
fprintf('  2: Hankel-Laguerre propagation with rays (video)\n');
fprintf('  3: 3D ray trajectories for Hankel-Hermite\n');
fprintf('  4: 3D ray trajectories comparison (H1 vs H2)\n');