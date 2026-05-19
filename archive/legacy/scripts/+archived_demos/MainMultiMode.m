%% Canonical Example: Multi-Mode Beam Demonstration
%% This script demonstrates multi-mode Hermite and Laguerre beams.
% Using refactored class architecture
% Ugalde-Ontiveros J.A.

scriptPath = fileparts(mfilename('fullpath'));
repoRoot = fullfile(scriptPath, '..', '..');
addpath(repoRoot);
setpaths();

%% Parameters
w0 = 100e-6;
lambda = 632.8e-9;
z = 0.5; % Propagate to 0.5m

%% Grid
Nx = 512;
Dx = 1.5e-3;
grid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = grid.create2DGrid();

%% Hermite-Gaussian (1,1)
fprintf('Calculating Hermite-Gaussian (1,1)...\n');
hb = BeamFactory.create('hermite', w0, lambda, 'n', 1, 'm', 1);
fieldHG = hb.opticalField(X, Y, z);

%% Laguerre-Gaussian (0,1)
fprintf('Calculating Laguerre-Gaussian (0,1)...\n');
lb = BeamFactory.create('laguerre', w0, lambda, 'l', 1, 'p', 0); % l=1, p=0
fieldLG = lb.opticalField(X, Y, z);

%% Visualization
figure(1);
subplot(1,2,1);
imagesc(abs(fieldHG).^2);
colormap('hot'); axis square; title('HG (1,1) Intensity');

subplot(1,2,2);
imagesc(abs(fieldLG).^2);
colormap('hot'); axis square; title('LG (0,1) Intensity');

fprintf('Done.\n');
