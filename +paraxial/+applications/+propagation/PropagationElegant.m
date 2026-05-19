%% PropagationElegant - Elegant Beam Propagation
%% Demonstrates propagation of Elegant Hermite-Gaussian and Elegant Laguerre-Gaussian beams.
%
% Elegant beams use the complex beam parameter q(z) in the argument of
% Hermite/Laguerre polynomials, resulting in different phase evolution
% compared to standard modes.
%
% This script shows:
%   - Creation of Elegant Hermite and Elegant Laguerre beams
%   - Analytic field computation using complex beam parameter
%   - Comparison of propagation with standard modes
%   - Phase structure visualization
%
% Compatible with GNU Octave and MATLAB
%
% References:
%   - Siegman, A. E. (1996). Defining and measuring laser beam quality. JOSA A.
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+propagation/PropagationElegant.m')"
%
% Related:
%   +paraxial/+applications/+demos/DemoElegantModes.m
%   +paraxial/+applications/+propagation/PropagationAnalytic.m

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
k  = PC.waveNumber(lambda);

fprintf('=== Elegant Beam Propagation ===\n');
fprintf('  Wavelength: %.3f nm\n', lambda*1e9);
fprintf('  Initial waist: %.1f microns\n', w0*1e6);
fprintf('  Rayleigh distance: %.4f m\n', zr);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 512;
Dx  = 2e-3;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% PROPAGATION PLANES
%% ============================================================================
Nz      = 5;
zPlanes = linspace(0, zr, Nz);

fprintf('Z-planes: %d points from 0 to z_R\n', Nz);

%% ============================================================================
%% BEAM CREATION: STANDARD VS ELEGANT
%% ============================================================================
fprintf('\n--- Beam Pairs (Standard vs Elegant) ---\n');

nMode = 2;
mMode = 1;
lMode = 2;
pMode = 0;

% Hermite-Gaussian pair
HG  = BeamFactory.create('hermite', w0, lambda, 'n', nMode, 'm', mMode);
EHG = BeamFactory.create('elegant_hermite', w0, lambda, 'n', nMode, 'm', mMode);

% Laguerre-Gaussian pair
LG  = BeamFactory.create('laguerre', w0, lambda, 'l', lMode, 'p', pMode);
ELG = BeamFactory.create('elegant_laguerre', w0, lambda, 'l', lMode, 'p', pMode);

fprintf('  Hermite-Gaussian: %s (standard) vs %s (elegant)\n', HG.beamName(), EHG.beamName());
fprintf('  Laguerre-Gaussian: %s (standard) vs %s (elegant)\n', LG.beamName(), ELG.beamName());

%% ============================================================================
%% PROPAGATION: COMPUTE FIELDS
%% ============================================================================
fprintf('\n--- Computing Fields ---\n');

fieldsHG  = cell(Nz, 1);
fieldsEHG = cell(Nz, 1);
fieldsLG  = cell(Nz, 1);
fieldsELG = cell(Nz, 1);

for iz = 1:Nz
    z = zPlanes(iz);
    fieldsHG{iz}  = HG.opticalField(X, Y, z);
    fieldsEHG{iz} = EHG.opticalField(X, Y, z);
    fieldsLG{iz}  = LG.opticalField(X, Y, z);
    fieldsELG{iz} = ELG.opticalField(X, Y, z);
end

fprintf('  All fields computed\n');

%% ============================================================================
%% VISUALIZATION: HERMITE-GAUSSIAN COMPARISON
%% ============================================================================
fprintf('\n--- Visualization ---\n');

figure(1);
clf;

for iz = 1:Nz
    z = zPlanes(iz);
    
    % Standard Hermite-Gaussian
    subplot(2, Nz, iz);
    imagesc(abs(fieldsHG{iz}).^2);
    colormap('hot');
    axis square;
    axis off;
    if iz == 1
        ylabel('Standard HG');
    end
    title(sprintf('z=%.1fz_R', z/zr));
    
    % Elegant Hermite-Gaussian
    subplot(2, Nz, iz + Nz);
    imagesc(abs(fieldsEHG{iz}).^2);
    colormap('hot');
    axis square;
    axis off;
    if iz == 1
        ylabel('Elegant HG');
    end
end

sgtitle(sprintf('Hermite-Gaussian %s: Standard vs Elegant', HG.beamName()));

%% ============================================================================
%% VISUALIZATION: LAGUERRE-GAUSSIAN COMPARISON
%% ============================================================================
figure(2);
clf;

for iz = 1:Nz
    z = zPlanes(iz);
    
    % Standard Laguerre-Gaussian
    subplot(2, Nz, iz);
    imagesc(abs(fieldsLG{iz}).^2);
    colormap('hot');
    axis square;
    axis off;
    if iz == 1
        ylabel('Standard LG');
    end
    title(sprintf('z=%.1fz_R', z/zr));
    
    % Elegant Laguerre-Gaussian
    subplot(2, Nz, iz + Nz);
    imagesc(abs(fieldsELG{iz}).^2);
    colormap('hot');
    axis square;
    axis off;
    if iz == 1
        ylabel('Elegant LG');
    end
end

sgtitle(sprintf('Laguerre-Gaussian %s: Standard vs Elegant', LG.beamName()));

%% ============================================================================
%% PHASE COMPARISON
%% ============================================================================
figure(3);
clf;

% Phase at z=0
subplot(2, 2, 1);
phaseHG0 = angle(fieldsHG{1});
imagesc(unwrap(phaseHG0, [], 1));
colormap('jet');
colorbar;
title('Standard HG Phase at z=0');
axis square;

subplot(2, 2, 2);
phaseEHG0 = angle(fieldsEHG{1});
imagesc(unwrap(phaseEHG0, [], 1));
colormap('jet');
colorbar;
title('Elegant HG Phase at z=0');
axis square;

% Phase difference at z=0
subplot(2, 2, 3);
phaseDiff0 = unwrap(unwrap(phaseHG0, [], 1) - unwrap(phaseEHG0, [], 1), [], 2);
imagesc(phaseDiff0);
colormap('jet');
colorbar;
title('Phase Difference at z=0');
axis square;

% Phase difference at z=z_R/2
subplot(2, 2, 4);
midIdx = floor(Nz/2);
phaseHGz  = angle(fieldsHG{midIdx});
phaseEHGz = angle(fieldsEHG{midIdx});
phaseDiffz = unwrap(unwrap(phaseHGz, [], 1) - unwrap(phaseEHGz, [], 1), [], 2);
imagesc(phaseDiffz);
colormap('jet');
colorbar;
title(sprintf('Phase Difference at z=%.1fz_R', zPlanes(midIdx)/zr));
axis square;

%% ============================================================================
%% INTENSITY COMPARISON (CUT LINES)
%% ============================================================================
figure(4);
clf;

cutRow = Nx/2 + 1;
x_norm = X(1,:) / w0;

% Hermite-Gaussian cross-sections
subplot(1, 2, 1);
hold on;
for iz = 1:Nz
    z = zPlanes(iz);
    plot(x_norm, abs(fieldsHG{iz}(cutRow,:)).^2, ...
         'LineWidth', 1.2, 'DisplayName', sprintf('HG z=%.1f', z/zr));
end
hold off;
xlabel('x / w_0');
ylabel('Intensity');
title('Standard HG Cross-Sections');
legend('Location', 'best');
grid on;
xlim([-3, 3]);

subplot(1, 2, 2);
hold on;
for iz = 1:Nz
    z = zPlanes(iz);
    plot(x_norm, abs(fieldsEHG{iz}(cutRow,:)).^2, ...
         'LineWidth', 1.2, 'DisplayName', sprintf('E-HG z=%.1f', z/zr));
end
hold off;
xlabel('x / w_0');
ylabel('Intensity');
title('Elegant HG Cross-Sections');
legend('Location', 'best');
grid on;
xlim([-3, 3]);

%% ============================================================================
%% AMPLITUDE RATIO ANALYSIS
%% ============================================================================
fprintf('\n--- Amplitude Ratio Analysis ---\n');

% Compute peak intensity ratio (Elegant / Standard)
ratiosHG = zeros(Nz, 1);
ratiosLG = zeros(Nz, 1);

for iz = 1:Nz
    peakHG  = max(abs(fieldsHG{iz}(:)));
    peakEHG = max(abs(fieldsEHG{iz}(:)));
    ratiosHG(iz) = peakEHG / peakHG;
    
    peakLG  = max(abs(fieldsLG{iz}(:)));
    peakELG = max(abs(fieldsELG{iz}(:)));
    ratiosLG(iz) = peakELG / peakLG;
end

fprintf('  HG peak ratio (Elegant/Standard): %.3f to %.3f\n', ...
        min(ratiosHG), max(ratiosHG));
fprintf('  LG peak ratio (Elegant/Standard): %.3f to %.3f\n', ...
        min(ratiosLG), max(ratiosLG));

figure(5);
clf;
plot(zPlanes/zr, ratiosHG, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
plot(zPlanes/zr, ratiosLG, 'r-s', 'LineWidth', 2, 'MarkerSize', 8);
hold off;
xlabel('z / z_R');
ylabel('Peak Intensity Ratio (Elegant / Standard)');
title('Elegant vs Standard Peak Intensity Ratio');
legend('Hermite-Gaussian', 'Laguerre-Gaussian');
grid on;

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Elegant Propagation Complete ===\n');
fprintf('  Hermite-Gaussian: %s vs %s\n', HG.beamName(), EHG.beamName());
fprintf('  Laguerre-Gaussian: %s vs %s\n', LG.beamName(), ELG.beamName());
fprintf('\nFigures:\n');
fprintf('  1: HG comparison (standard vs elegant)\n');
fprintf('  2: LG comparison (standard vs elegant)\n');
fprintf('  3: Phase comparison at z=0 and z=0.5z_R\n');
fprintf('  4: Cross-section comparison\n');
fprintf('  5: Peak intensity ratio over propagation\n');