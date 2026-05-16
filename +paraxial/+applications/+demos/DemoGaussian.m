%% DemoGaussian - Canonical Gaussian Beam Demonstration
%% Demonstrates the recommended workflow for Gaussian beam simulation.
%
% This demo shows:
%   - Physical parameter calculations using PhysicalConstants
%   - Grid generation using GridUtils
%   - FFT-based angular spectrum propagation using FFTUtils
%   - Modern beam construction via BeamFactory
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   Run this script from the repository root:
%     octave --no-gui --eval "run('+paraxial/+applications/+demos/DemoGaussian.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoHermiteLaguerre.m
%   +paraxial/+applications/+propagation/PropagationFFT.m
%   +paraxial/+applications/+analysis/WavefrontAnalysis.m

scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..');
addpath(repoRoot);
setpaths();

%% ============================================================================
%% PHYSICAL PARAMETERS (SI units)
%% ============================================================================
w0     = 100e-6;          % Initial waist: 100 microns
lambda = 632.8e-9;       % HeNe laser wavelength: 632.8 nm

PC = PhysicalConstants;
k  = PC.waveNumber(lambda);
zr = PC.rayleighDistance(w0, lambda);

fprintf('=== Gaussian Beam Parameters ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);
fprintf('  Rayleigh distance: %.4f m\n', zr);
fprintf('  Wave number k: %.2e 1/m\n', k);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 2^10;              % Grid resolution (power of 2 for FFT)
Dz  = 2 * zr;            % Propagation window: 2 * zR
Nz  = 2^8;               % Number of z-planes

simGrid = GridUtils(Nx, Nx, 1, 1, Nz, Dz);
maxWaist = PC.waistAtZ(w0, Dz, lambda, zr);
grid.Dx  = 1.2 * 2 * maxWaist;
grid.Dy  = grid.Dx;
grid.dx  = grid.Dx / Nx;
grid.dy  = grid.Dy / Nx;

[X, Y]   = grid.create2DGrid();
[Kx, Ky] = simGrid.createFreqGrid();
fftOps   = FFTUtils(true, true);  % normalize=true, shift=true

fprintf('\n=== Grid Parameters ===\n');
fprintf('  Nx = %d, Nz = %d\n', Nx, Nz);
fprintf('  Window size: %.4f m\n', grid.Dx);
fprintf('  Resolution: %.2e m\n', grid.dx);

%% ============================================================================
%% BEAM CREATION AND VISUALIZATION
%% ============================================================================
mapgreen = AdvancedColormap('kgg', 256, [0 100 255]/255);

% Create Gaussian beam using BeamFactory (modern API)
GB = BeamFactory.create('gaussian', w0, lambda);
field0 = GB.opticalField(X, Y, 0);

% Get beam parameters at z=0
params0 = GB.getParameters(0);

figure(1);
clf;
plotOpticalField(X(1,:), Y(:,1), abs(field0).^2, mapgreen, 'x (m)', 'y (m)');
hold on;
plotCircle(0, 0, params0.InitialWaist, 'w', 1.5);
title(sprintf('Gaussian Beam |z=0, w_0=%.1f \\mum', w0*1e6));
hold off;

%% ============================================================================
%% ANGULAR SPECTRUM PROPAGATION
%% ============================================================================
fprintf('\n=== Propagation ===\n');
zPlanes = linspace(0, Dz, Nz);
fields  = zeros(Nx, Nx, Nz);

for iz = 1:Nz
    z    = zPlanes(iz);
    H    = fftOps.transferFunction(Kx, Ky, z, lambda);
    G    = fftOps.fft2(field0);
    fields(:, :, iz) = fftOps.ifft2(G .* H);
    
    if mod(iz, 50) == 0
        fprintf('  z = %.2f m (%.1f z_R), plane %d/%d\n', z, z/zr, iz, Nz);
    end
end

fprintf('  Propagation complete: %d z-planes computed\n', Nz);

%% ============================================================================
%% LATERAL VIEW VISUALIZATION
%% ============================================================================
figure(2);
clf;
imagesc(zPlanes/zr, X(1,:)/w0, squeeze(abs(fields(Nx/2+1, :, :))).^2);
set(gca, 'YDir', 'normal');
colormap(mapgreen);
hold on;
plot(zPlanes/zr, 0.5 * ones(size(zPlanes)), 'w--', 'LineWidth', 1.5);
plot(zPlanes/zr, -0.5 * ones(size(zPlanes)), 'w--', 'LineWidth', 1.5);
hold off;
xlabel('z / z_R');
ylabel('x / w_0');
title('Gaussian Beam Lateral View (x-cut at y=0)');

%% ============================================================================
%% SAVE PARAMETERS
%% ============================================================================
info = struct('InitialWaist', w0, ...
              'Wavelength', lambda, ...
              'RayleighDistance', zr, ...
              'Nx', Nx, ...
              'Nz', Nz, ...
              'Dx', grid.Dx, ...
              'Dz', Dz);

outputFile = fullfile(scriptPath, '..', '..', 'GaussianDemoInfo.mat');
save(outputFile, 'info');
fprintf('\nParameters saved to: %s\n', outputFile);

fprintf('\n=== Demo Complete ===\n');
fprintf('Figures:\n');
fprintf('  1: Gaussian beam intensity at z=0\n');
fprintf('  2: Lateral view showing beam divergence\n');