%% Canonical Example: Gaussian Beam Propagation
%% This script demonstrates the recommended workflow for beam simulation.
% Gaussian Beam propagation using new utility classes
% Ugalde-Ontiveros J.A.
%
% This version uses:
%   - PhysicalConstants for physical parameter calculations
%   - GridUtils for grid generation
%   - FFTUtils for normalized FFT operations

%% Add paths
scriptPath = fileparts(mfilename('fullpath'));
repoRoot = fullfile(scriptPath, '..', '..');
addpath(repoRoot);
setpaths();
addpath(fullfile(repoRoot, 'ParaxialBeams', 'Addons', 'export_fig-master'));
addpath(fullfile(repoRoot, 'ParaxialBeams', 'Addons', 'panel-2.14'));
addpath(fullfile(repoRoot, 'ParaxialBeams', 'Addons', 'Plots_Functions'));

%% Physical parameters [microns -> meters]
InitialWaist = 100e-6;      % 100 microns
Wavelength  = 632.8e-9;    % HeNe laser (632.8 nm)

%% Calculate derived parameters using PhysicalConstants
PC = PhysicalConstants;
k = PC.waveNumber(Wavelength);
zr = PC.rayleighDistance(InitialWaist, Wavelength);

fprintf('Physical Parameters:\n');
fprintf('  Wavelength: %g nm\n', Wavelength*1e9);
fprintf('  InitialWaist: %g um\n', InitialWaist*1e6);
fprintf('  Rayleigh distance: %g m\n', zr);
fprintf('  Wave number k: %g 1/m\n', k);

%% Create grid using GridUtils
Nx = 2^10;
Dz = 2*zr;
Nz = 2^8;

% Create grid instance
grid = GridUtils(Nx, Nx, 1, 1, Nz, Dz);

% Estimate optimal window size
maxWaist = PC.waistAtZ(InitialWaist, Dz, Wavelength, zr);
grid.Dx = 1.2 * 2 * maxWaist;
grid.Dy = grid.Dx;
grid.dx = grid.Dx / Nx;
grid.dy = grid.Dy / Nx;

% Get grid arrays
[X, Y] = grid.create2DGrid();
[Kx, Ky] = grid.createFreqGrid();

fprintf('\nGrid Parameters:\n');
fprintf('  Nx = %d, Nz = %d\n', Nx, Nz);
fprintf('  Dx = %g m, Dz = %g m\n', grid.Dx, grid.Dz);
fprintf('  dx = %g m\n', grid.dx);

%% FFT utilities
fftOps = FFTUtils(true, true);  % normalize=true, shift=true

% Colormap for visualization
mapgreen = AdvancedColormap('kgg',256,[0 100 255]/255);

%% Gaussian Beam at z = 0 (modern API)
GB = BeamFactory.create('gaussian', InitialWaist, Wavelength);
GaussianBeamParameters = GB.getParameters(0);
field0 = GB.opticalField(X, Y, 0);

% Plot field
figure(1)
plotOpticalField(X(1,:), Y(:,1), abs(field0).^2, mapgreen, 'x (m)', 'y (m)');
plotCircle(0, 0, GaussianBeamParameters.InitialWaist, 'w', 1.5);

%% Compare old vs new FFT approach
% Old way (scattered in codebase):
%   G = fftshift(fft2(ifftshift(g)));
%   g = fftshift(ifft2(ifftshift(G)));

% New way (consistent):
%   G = fftOps.fft2(g);
%   g = fftOps.ifft2(G);

%% Example: Propagate beam using angular spectrum
% Create initial field
g0 = field0;

% Propagate to multiple z planes
zPlanes = linspace(0, Dz, Nz);
fields = zeros(Nx, Nx, Nz);

for iz = 1:Nz
    z = zPlanes(iz);
    
    % Compute transfer function
    H = fftOps.transferFunction(Kx, Ky, z, Wavelength);
    
    % Propagate
    G = fftOps.fft2(g0);
    gProp = fftOps.ifft2(G .* H);
    fields(:, :, iz) = gProp;
end

fprintf('\nPropagation complete: %d z-planes computed\n', Nz);

%% Export parameters info
info = struct('InitialWaist', InitialWaist, ...
              'Wavelength', Wavelength, ...
              'RayleighDistance', zr, ...
              'Nx', Nx, 'Nz', Nz, ...
              'Dx', grid.Dx, 'Dz', Dz);
          
save('GaussianSimulationInfo.mat', 'info');
fprintf('\nInfo saved to GaussianSimulationInfo.mat\n');
