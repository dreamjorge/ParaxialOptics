%% Canonical Example: Hankel Beam Propagation with Ray Tracing
%% Demonstrates unified propagation for both Hermite and Laguerre Hankel beams.
%
% This script shows:
%   1. Beam creation via modern API (BeamFactory / direct constructors)
%   2. FFT field propagation (angular spectrum, step-by-step)
%   3. Hankel ray tracing via HankelRayTracePropagator
%   4. Combined visualization: intensity + ray overlay per z-step
%   5. Video generation (MATLAB only, Octave skips gracefully)

scriptPath = fileparts(mfilename('fullpath'));
repoRoot = fullfile(scriptPath, '..', '..');
addpath(repoRoot);
setpaths();

GenerateVideo = true;

%% Physical parameters (SI units: meters)
w0     = 100e-6;
lambda = 632.8e-9;
k      = 2*pi / lambda;
zr     = pi * w0^2 / lambda;

%% Grid setup
Nx = 512;
Dx = 15 * w0;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y]   = simGrid.create2DGrid();
[Kx, Ky] = simGrid.createFreqGrid();
fftOps   = FFTUtils();

%% Propagation parameters
Dz    = zr;
Nz    = 64;
dz    = Dz / Nz;
z_vec = (0:Nz) * dz;

%% Obstruction setup (Optional disk in the center)
R_obs = 0.6 * w0; % Obstruction radius
mask = (sqrt((X-0.95*R_obs).^2 + (Y).^2) > R_obs);
fprintf('Adding circular obstruction (R = %.1f w0)\n', R_obs/w0);

%% ===================================================================
%%  SECTION 1: Hankel-Hermite Propagation (4 types: 11, 12, 21, 22)
%% ===================================================================
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

% Ray tracing for all 4 Hankel types
% Seed rays on the obstruction contour instead of a generic grid.
bundle_h11 = RayBundle.createCircularContour(32, R_obs, 0, R_obs, 0);
bundle_h11.ht(:) = 11;
% Keep ray samples aligned with fixed field z-planes (z_vec), even if
% internal integration step changes in the future.
bundle_h11 = HankelRayTracer.propagateToPlanes(bundle_h11, beam_h11, z_vec, dz, 'RK4');

% Video setup
vidFile = fullfile(scriptPath, 'HankelHermitePropagation.avi');
if GenerateVideo
    try
        vidObj = VideoWriter(vidFile);
        vidObj.Quality   = 95;
        vidObj.FrameRate = 15;
        open(vidObj);
        hasVideo = true;
    catch
        hasVideo = false;
        fprintf('VideoWriter not available (Octave?). Skipping video.\n');
    end
else
    hasVideo = false;
end

fig1 = figure('Position', [100 100 1200 500]);
x_axis = X(1,:) / w0;
y_axis = Y(:,1) / w0;

for zi = 1:Nz+1
    % 2x2 subplot: one panel per Hankel type
    subplot(1,2,1);
    imagesc(x_axis, y_axis, abs(field_h11).^2);
    set(gca, 'YDir', 'normal');
    colormap(hot);
    hold on;
    % Overlay rays at this z-step
    if zi <= size(bundle_h11.x, 3)
        rx = squeeze(bundle_h11.x(:,:,zi)) / w0;
        ry = squeeze(bundle_h11.y(:,:,zi)) / w0;
        plot(rx(:), ry(:), 'c.', 'MarkerSize', 6);
    end
    hold off;
    title(sprintf('H^{(11)}_{%d,%d}  z=%.2f z_R', n_mode, m_mode, z_vec(zi)/zr));
    xlabel('x / w_0'); ylabel('y / w_0');

    subplot(1,2,2);
    % Coherent sum gives the "normal" (Gaussian-derivative) beam
    field_total = field_h11 + field_h12 + field_h21 + field_h22;
    imagesc(x_axis, y_axis, abs(field_total).^2);
    set(gca, 'YDir', 'normal');
    colormap(hot);
    title(sprintf('Gaussian (Coherent Sum)  z=%.2f z_R', z_vec(zi)/zr));
    xlabel('x / w_0'); ylabel('y / w_0');

    drawnow;

    if hasVideo
        writeVideo(vidObj, getframe(fig1));
    end

    % Propagate fields one step via FFT
    if zi <= Nz
        field_h11 = fftOps.propagate(field_h11, Kx, Ky, dz, lambda);
        field_h12 = fftOps.propagate(field_h12, Kx, Ky, dz, lambda);
        field_h21 = fftOps.propagate(field_h21, Kx, Ky, dz, lambda);
        field_h22 = fftOps.propagate(field_h22, Kx, Ky, dz, lambda);
    end
end

if hasVideo
    close(vidObj);
    fprintf('Hermite video saved: %s\n', vidFile);
end

%% ===================================================================
%%  SECTION 2: Hankel-Laguerre Propagation (2 types: H1, H2)
%% ===================================================================
l_mode = 5;
p_mode = 10;

beam_l1 = HankelLaguerre(w0, lambda, l_mode, p_mode, 1);
beam_l2 = HankelLaguerre(w0, lambda, l_mode, p_mode, 2);

field_l1 = beam_l1.opticalField(X, Y, 0) .* mask;
field_l2 = beam_l2.opticalField(X, Y, 0) .* mask;

% Finer internal step for high-order modes: the phase structure of
% LG_{l,p} has (p+1) radial rings and l azimuthal nodes, so the
% eikonal gradient changes on a shorter scale than for low-order beams.
dz_internal = dz / 8;

% Ray tracing for H^(1) — seeded on the obstruction contour
bundle_l1 = RayBundle.createCircularContour(32, 0.95*R_obs, 0, R_obs, 0);
bundle_l1.ht(:) = 1;
bundle_l1 = HankelRayTracer.propagateToPlanes(bundle_l1, beam_l1, z_vec, dz_internal, 'RK4');

bundle_l2 = RayBundle.createCircularContour(32, R_obs, 0, R_obs, 0);
bundle_l2.ht(:) = 2;
bundle_l2 = HankelRayTracer.propagateToPlanes(bundle_l2, beam_l2, z_vec, dz_internal, 'RK4');

vidFile2 = fullfile(scriptPath, 'HankelLaguerrePropagation.avi');
if GenerateVideo
    try
        vidObj2 = VideoWriter(vidFile2);
        vidObj2.Quality   = 95;
        vidObj2.FrameRate = 15;
        open(vidObj2);
        hasVideo2 = true;
    catch
        hasVideo2 = false;
    end
else
    hasVideo2 = false;
end

fig2 = figure('Position', [100 100 1200 500]);

for zi = 1:Nz+1
    subplot(1,2,1);
    imagesc(x_axis, y_axis, abs(field_l1).^2);
    set(gca, 'YDir', 'normal');
    colormap(hot);
    hold on;
    if zi <= size(bundle_l1.x, 3)
        rx = squeeze(bundle_l1.x(:,:,zi)) / w0;
        ry = squeeze(bundle_l1.y(:,:,zi)) / w0;
        plot(rx(:), ry(:), 'c.', 'MarkerSize', 6);
    end
    hold off;
    title(sprintf('H^{(1)}_{%d,%d}  z=%.2f z_R', l_mode, p_mode, z_vec(zi)/zr));
    xlabel('x / w_0'); ylabel('y / w_0');

    subplot(1,2,2);
    % Coherent sum gives the Laguerre-Gauss (Normal) beam
    field_lg = field_l1 + field_l2;
    imagesc(x_axis, y_axis, abs(field_lg).^2);
    set(gca, 'YDir', 'normal');
    colormap(hot);
    title(sprintf('Laguerre-Gauss (Normal)  z=%.2f z_R', z_vec(zi)/zr));
    xlabel('x / w_0'); ylabel('y / w_0');

    drawnow;

    if hasVideo2
        writeVideo(vidObj2, getframe(fig2));
    end

    if zi <= Nz
        field_l1 = fftOps.propagate(field_l1, Kx, Ky, dz, lambda);
        field_l2 = fftOps.propagate(field_l2, Kx, Ky, dz, lambda);
    end
end

if hasVideo2
    close(vidObj2);
    fprintf('Laguerre video saved: %s\n', vidFile2);
end

%% ===================================================================
%%  SECTION 3: Final 3D Ray Visualization
%% ===================================================================
fprintf('\n=== Propagation complete ===\n');
fprintf('Hermite HankelHermite(%d,%d): 4 types propagated over %.2f zR\n', n_mode, m_mode, Dz/zr);
fprintf('Laguerre HankelLaguerre(%d,%d): 2 types propagated over %.2f zR\n', l_mode, p_mode, Dz/zr);

VisualizationUtils.plotRays3D(bundle_h11, 'b');
title(sprintf('Hankel-Hermite H^{(11)}_{%d,%d} Ray Trajectories', n_mode, m_mode));

figure;
hold on;
Nrays_l = bundle_l1.Ny * bundle_l1.Nx;
for ii = 1:Nrays_l
    [ri, ci] = ind2sub([bundle_l1.Ny, bundle_l1.Nx], ii);
    plot3(squeeze(bundle_l1.z(ri,ci,:)), squeeze(bundle_l1.x(ri,ci,:)), squeeze(bundle_l1.y(ri,ci,:)), 'r');
    plot3(squeeze(bundle_l2.z(ri,ci,:)), squeeze(bundle_l2.x(ri,ci,:)), squeeze(bundle_l2.y(ri,ci,:)), 'b');
end
hold off;
grid on; view(3);
xlabel('z (m)'); ylabel('x (m)'); zlabel('y (m)');
title(sprintf('Hankel-Laguerre H^{(1)}(red) vs H^{(2)}(blue) — LG_{%d,%d}', l_mode, p_mode));
legend('H^{(1)}', 'H^{(2)}');
