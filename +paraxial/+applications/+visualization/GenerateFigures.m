%% GenerateFigures - Generate Publication-Quality Figures
%% Consolidates generation of paper-ready figures from beam simulations.
%
% This script shows:
%   - Automated figure generation for multiple beam modes
%   - Consistent styling and layout
%   - Multi-panel figure creation
%   - Export to multiple formats (PNG, PDF, EPS)
%
% Compatible with GNU Octave and MATLAB
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+visualization/GenerateFigures.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoGaussian.m
%   +paraxial/+applications/+visualization/GenerateSlices3D.m

scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..');
addpath(repoRoot);
setpaths();

%% ============================================================================
%% CONFIGURATION
%% ============================================================================

% Export settings
ExportFormat = {'png', 'pdf'};  % Cell array of formats
DPI = 300;                        % Resolution for raster formats
TransparentBG = true;            % Transparent background for PNG

% Figure styling
FontSize = 12;
LineWidth = 1.5;
MarkerSize = 8;
ColorMap = 'hot';

% Beam parameters
w0     = 100e-6;          % Initial waist: 100 microns
lambda = 632.8e-9;       % HeNe laser wavelength: 632.8 nm

PC = PhysicalConstants;
zr = PC.rayleighDistance(w0, lambda);

fprintf('=== Figure Generation ===\n');
fprintf('  Formats: %s\n', strjoin(ExportFormat, ', '));
fprintf('  DPI: %d\n', DPI);
fprintf('  Colormap: %s\n', ColorMap);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 512;
Dx  = 2 * w0;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% BEAM MODES TO GENERATE
%% ============================================================================
fprintf('\n--- Beam Modes ---\n');

modes = {
    {'gaussian', 0, 0}, ...
    {'hermite',  1, 0}, ...
    {'hermite',  2, 1}, ...
    {'laguerre', 1, 0}, ...
    {'laguerre', 2, 0} ...
};

%% ============================================================================
%% HELPER FUNCTION: APPLY STYLE
%% ============================================================================
    function applyStyle(ax)
        % Apply consistent styling to axes
        set(ax, 'FontSize', FontSize, ...
                'FontWeight', 'bold', ...
                'Box', 'on', ...
                'LineWidth', LineWidth);
        xlabel(ax, 'x / w_0');
        ylabel(ax, 'y / w_0');
    end

%% ============================================================================
%% FIGURE 1: BEAM INTENSITY AT Z=0
%% ============================================================================
fprintf('\n--- Figure 1: Beam Intensities at z=0 ---\n');

nModes = length(modes);
nCols = min(nModes, 4);
nRows = ceil(nModes / nCols);

figure(1);
clf;

for i = 1:nModes
    modeName = modes{i}{1};
    n = modes{i}{2};
    m = modes{i}{3};
    
    % Create beam
    if strcmp(modeName, 'gaussian')
        beam = BeamFactory.create('gaussian', w0, lambda);
        nameStr = 'Gaussian';
    elseif strcmp(modeName, 'hermite')
        beam = BeamFactory.create('hermite', w0, lambda, 'n', n, 'm', m);
        nameStr = sprintf('HG_{%d,%d}', n, m);
    else
        beam = BeamFactory.create('laguerre', w0, lambda, 'l', n, 'p', m);
        nameStr = sprintf('LG_{%d,%d}', n, m);
    end
    
    % Compute field
    E = beam.opticalField(X, Y, 0);
    I = abs(E).^2;
    
    % Plot
    subplot(nRows, nCols, i);
    imagesc(X(1,:)/w0, Y(:,1)/w0, I);
    colormap(ColorMap);
    axis square;
    axis off;
    title(nameStr, 'FontSize', FontSize);
    colorbar;
    
    fprintf('  %s: max intensity = %.4f\n', nameStr, max(I(:)));
end

sgtitle('Beam Intensities at z = 0', 'FontSize', FontSize+2);

% Export
baseName = 'Figure1_BeamIntensities';
exportFig(figure(1), baseName, ExportFormat, DPI, TransparentBG);
fprintf('  Saved: %s.*\n', baseName);

%% ============================================================================
%% FIGURE 2: PROPAGATION SEQUENCE
%% ============================================================================
fprintf('\n--- Figure 2: Propagation Sequence (Gaussian) ---\n');

beam = BeamFactory.create('gaussian', w0, lambda);
[Kx, Ky] = simGrid.createFreqGrid();
fftOps = FFTUtils();

zPlanes = [0, zr/4, zr/2, 3*zr/4, zr];
Nz = length(zPlanes);

figure(2);
clf;

field = beam.opticalField(X, Y, 0);

for iz = 1:Nz
    z = zPlanes(iz);
    
    subplot(1, Nz, iz);
    imagesc(X(1,:)/w0, Y(:,1)/w0, abs(field).^2);
    colormap(ColorMap);
    axis square;
    axis off;
    title(sprintf('z = %.1f z_R', z/zr), 'FontSize', FontSize);
    colorbar;
    
    if iz < Nz
        field = fftOps.propagate(field, Kx, Ky, zPlanes(iz+1) - z, lambda);
    end
end

sgtitle('Gaussian Beam Propagation', 'FontSize', FontSize+2);

% Export
baseName = 'Figure2_GaussianPropagation';
exportFig(figure(2), baseName, ExportFormat, DPI, TransparentBG);
fprintf('  Saved: %s.*\n', baseName);

%% ============================================================================
%% FIGURE 3: CROSS-SECTION COMPARISON
%% ============================================================================
fprintf('\n--- Figure 3: Cross-Section Comparison ---\n');

figure(3);
clf;

cutRow = Nx/2 + 1;
x_norm = X(1,:) / w0;

nCols = 2;
nRows = ceil(nModes / nCols);

for i = 1:nModes
    modeName = modes{i}{1};
    n = modes{i}{2};
    m = modes{i}{3};
    
    % Create beam
    if strcmp(modeName, 'gaussian')
        beam = BeamFactory.create('gaussian', w0, lambda);
        nameStr = 'Gaussian';
    elseif strcmp(modeName, 'hermite')
        beam = BeamFactory.create('hermite', w0, lambda, 'n', n, 'm', m);
        nameStr = sprintf('HG_{%d,%d}', n, m);
    else
        beam = BeamFactory.create('laguerre', w0, lambda, 'l', n, 'p', m);
        nameStr = sprintf('LG_{%d,%d}', n, m);
    end
    
    % Compute field
    E = beam.opticalField(X, Y, 0);
    I = abs(E(cutRow, :)).^2;
    
    % Plot cross-section
    subplot(nRows, nCols, i);
    plot(x_norm, I, 'b-', 'LineWidth', LineWidth);
    hold on;
    % Mark waist positions
    params = beam.getParameters(0);
    % Add zero line
    plot(x_norm, zeros(size(x_norm)), 'k--', 'LineWidth', 0.5);
    hold off;
    xlabel('x / w_0');
    ylabel('Intensity');
    title(nameStr);
    grid on;
    xlim([-3, 3]);
    set(gca, 'FontSize', FontSize - 2);
end

sgtitle('Cross-Sections at z = 0', 'FontSize', FontSize+2);

% Export
baseName = 'Figure3_CrossSections';
exportFig(figure(3), baseName, ExportFormat, DPI, TransparentBG);
fprintf('  Saved: %s.*\n', baseName);

%% ============================================================================
%% FIGURE 4: PHASE STRUCTURE
%% ============================================================================
fprintf('\n--- Figure 4: Phase Structure ---\n');

figure(4);
clf;

% Gaussian phase at z=0 (should be flat/planar)
subplot(1, 2, 1);
beamG = BeamFactory.create('gaussian', w0, lambda);
E_G = beamG.opticalField(X, Y, 0);
phase_G = angle(E_G);
imagesc(X(1,:)/w0, Y(:,1)/w0, phase_G);
colormap('jet');
colorbar;
axis square;
title('Gaussian Phase at z=0');
xlabel('x / w_0');
ylabel('y / w_0');
set(gca, 'FontSize', FontSize);

% Hermite-Gaussian phase (complex due to mode structure)
subplot(1, 2, 2);
beamHG = BeamFactory.create('hermite', w0, lambda, 'n', 2, 'm', 1);
E_HG = beamHG.opticalField(X, Y, 0);
phase_HG = angle(E_HG);
imagesc(X(1,:)/w0, Y(:,1)/w0, phase_HG);
colormap('jet');
colorbar;
axis square;
title(sprintf('HG_{2,1} Phase at z=0'));
xlabel('x / w_0');
ylabel('y / w_0');
set(gca, 'FontSize', FontSize);

sgtitle('Phase Structure Comparison', 'FontSize', FontSize+2);

% Export
baseName = 'Figure4_PhaseStructure';
exportFig(figure(4), baseName, ExportFormat, DPI, TransparentBG);
fprintf('  Saved: %s.*\n', baseName);

%% ============================================================================
%% FIGURE 5: MULTI-MODE OVERVIEW
%% ============================================================================
fprintf('\n--- Figure 5: Multi-Mode Overview ---\n');

figure(5);
clf;

% Create 3x3 grid showing different modes and their propagation
nGridRows = 3;
nGridCols = 3;

for i = 1:min(9, nModes)
    modeName = modes{i}{1};
    n = modes{i}{2};
    m = modes{i}{3};
    
    % Create beam
    if strcmp(modeName, 'gaussian')
        beam = BeamFactory.create('gaussian', w0, lambda);
        nameStr = 'Gaussian';
    elseif strcmp(modeName, 'hermite')
        beam = BeamFactory.create('hermite', w0, lambda, 'n', n, 'm', m);
        nameStr = sprintf('HG_{%d,%d}', n, m);
    else
        beam = BeamFactory.create('laguerre', w0, lambda, 'l', n, 'p', m);
        nameStr = sprintf('LG_{%d,%d}', n, m);
    end
    
    % Plot at z=0
    subplot(nGridRows, nGridCols, i);
    E = beam.opticalField(X, Y, 0);
    I = abs(E).^2;
    imagesc(X(1,:)/w0, Y(:,1)/w0, I);
    colormap(ColorMap);
    axis square;
    axis off;
    title(nameStr, 'FontSize', FontSize);
    
    % Add waist contour
    hold on;
    params = beam.getParameters(0);
    th = linspace(0, 2*pi, 64);
    % Could add waist circle here if needed
    hold off;
end

sgtitle('Multi-Mode Beam Overview', 'FontSize', FontSize+2);

% Export
baseName = 'Figure5_MultiModeOverview';
exportFig(figure(5), baseName, ExportFormat, DPI, TransparentBG);
fprintf('  Saved: %s.*\n', baseName);

%% ============================================================================
%% HELPER FUNCTION: EXPORT FIGURE
%% ============================================================================
    function exportFig(hFig, baseName, formats, dpi, transparent)
        % Export figure to multiple formats
        
        for i = 1:length(formats)
            fmt = formats{i};
            
            switch fmt
                case 'png'
                    if transparent
                        export_fig(hFig, baseName, '-png', '-transparent', ...
                                   sprintf('-r%d', dpi));
                    else
                        export_fig(hFig, baseName, '-png', ...
                                   sprintf('-r%d', dpi));
                    end
                case 'pdf'
                    export_fig(hFig, baseName, '-pdf', '-transparent');
                case 'eps'
                    export_fig(hFig, baseName, '-eps', '-transparent');
                otherwise
                    warning('Unknown format: %s', fmt);
            end
        end
    end

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Figure Generation Complete ===\n');
fprintf('  Figures generated: 5\n');
fprintf('  Formats: %s\n', strjoin(ExportFormat, ', '));
fprintf('  DPI: %d\n', DPI);
fprintf('\nFiles saved in: %s\n', scriptPath);
fprintf('  Figure1_BeamIntensities.*\n');
fprintf('  Figure2_GaussianPropagation.*\n');
fprintf('  Figure3_CrossSections.*\n');
fprintf('  Figure4_PhaseStructure.*\n');
fprintf('  Figure5_MultiModeOverview.*\n');