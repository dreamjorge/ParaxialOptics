%% Legacy: Main Elegant Hermite Simulation (Thesis Version Refactored)
% Refactored to use the new classdef architecture
% Ugalde-Ontiveros J.A.

clear all;
addpath(fullfile('ParaxialBeams'));
addpath(fullfile('ParaxialBeams', 'Addons'));

%% Beam indices (Hermite-Gaussian modes)
nu = 12;
mu = 11;

%% Physical parameters
InitialWaist = 100e-6; % meters
Wavelength   = 0.6328e-6; % HeNe

%% Initialize Parameters
HPz0 = ElegantHermiteParameters(0, InitialWaist, Wavelength, nu, mu);
zr = HPz0.RayleighDistance;
k = HPz0.k;

%% Grid and Sampling
Dz = zr;  
Nz = 2^7;
Nx = 2^10;

% Use GridUtils to handle coordinates
grid = GridUtils(Nx, Nx, 0, 0, Nz, Dz);
% Approximate window size based on beam spread
maxW = PhysicalConstants.waistAtZ(InitialWaist, Dz, Wavelength, zr);
grid.Dx = 1.1 * maxW * sqrt(max(nu, mu)); % Heuristic for higher order modes
grid.Dy = grid.Dx;

[X, Y] = grid.create2DGrid();
[Kx, Ky] = grid.createFreqGrid();

%% Generate Elegant Hermite Beam at z=0
EHB = ElegantHermiteBeam(X, Y, HPz0);
g0 = EHB.OpticalField;

%% Visualization at z=0
figure(1);
imagesc(X/InitialWaist, Y/InitialWaist, abs(g0).^2);
colormap('hot'); axis square;
xlabel('$x/w_o$','Interpreter','latex');
ylabel('$y/w_o$','Interpreter','latex');
title(sprintf('Elegant Hermite (%d,%d) at z=0', nu, mu));

%% Propagation (using FFTUtils)
fftOps = FFTUtils(true, true);
zPlanes = linspace(0, Dz, Nz);
dz = Dz/Nz;

% Initialize propagator (Transfer Function)
H = fftOps.transferFunction(Kx, Ky, dz, Wavelength);

fprintf('Propagating field...\n');
g = g0;
for iz = 1:Nz
    % Propagate one step
    G = fftOps.fft2(g);
    g = fftOps.ifft2(G .* H);
    
    if mod(iz, 32) == 0
        fprintf('  Step %d/%d\n', iz, Nz);
    end
end

%% Final Result
figure(2);
imagesc(X/InitialWaist, Y/InitialWaist, abs(g).^2);
colormap('hot'); axis square;
title(sprintf('Elegant Hermite at z=%g zR', Dz/zr));