%% Legacy: Generate Lateral View of Hermite-Gaussian Beams with Rays
% Refactored version using classdef architecture
% original scripts by: dreamjorge

addpath(fullfile('ParaxialBeams'))

%% Parameters
InitialWaist = 100e-6;
Wavelength = 632.8e-9;
zr = PhysicalConstants.rayleighDistance(InitialWaist, Wavelength);

% Plotting parameters
Nz = 200;
Dz = 0.5 * zr;
Nx = 512;
Dx = 1.2 * 2 * InitialWaist;

grid = GridUtils(Nx, Nx, Dx, Dx, Nz, Dz);
[X, Y] = grid.create2DGrid();
zPlanes = linspace(0, Dz, Nz);

%% Initialize Data Handling
% Usually these matrices are computed via FFT propagation.
% Wo = field_3d_matrix; 

fprintf('Ready for lateral view generation.\n');
fprintf('Use AnalysisUtils.gradientRZ for ray slope analysis.\n');

%% Helper Function for Lateral Plot
function plotLateralField(zSub, xSub, FieldSlice, PC, name)
    figure('Name', name);
    pcolor(zSub/PC.RayleighDistance, xSub/PC.InitialWaist, abs(FieldSlice).^2);
    shading interp;
    colormap('hot');
    xlabel('$z/z_R$','Interpreter','latex','FontSize',14);
    ylabel('$r/w_o$','Interpreter','latex','FontSize',14);
    title(name);
end

%% Example: Process a slice
% If Wo is your 3D field:
% sliceX = squeeze(Wo(Nx/2, :, :));
% plotLateralField(zPlanes, grid.x, sliceX, struct('RayleighDistance', zr, 'InitialWaist', InitialWaist), 'HG Lateral View');

% Note: Ray trajectories (ray11, etc.) should be plotted on top using:
% hold on;
% plot(z_ray/zr, x_ray/w0, 'r--');
% hold off;