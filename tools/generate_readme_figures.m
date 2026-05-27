function generate_readme_figures()
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(repoRoot);
    addpath(fullfile(repoRoot, 'ParaxialBeams'));

    outDir = fullfile(repoRoot, 'docs', 'assets');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    try
        graphics_toolkit('gnuplot');
    catch
        % MATLAB or Octave installations without gnuplot can still use the
        % default toolkit.
    end
    set(0, 'defaultfigurevisible', 'off');

    n = 220;
    span = 4.0e-4;
    x = linspace(-span, span, n);
    y = linspace(-span, span, n);
    [X, Y] = meshgrid(x, y);

    gaussian = BeamFactory.create('gaussian', 1.0e-4, 632.8e-9);
    field = gaussian.opticalField(X, Y, 0);
    intensity = abs(field).^2;

    fig = figure('visible', 'off', 'position', [100, 100, 720, 560]);
    imagesc(x * 1e6, y * 1e6, intensity);
    axis image;
    applyReadableColormap('parula');
    cb = colorbar;
    ylabel(cb, 'Normalized intensity |E|^2 [a.u.]');
    xlabel('x [um]');
    ylabel('y [um]');
    title('Gaussian beam intensity at waist');
    print(fig, fullfile(outDir, 'gaussian_beam_intensity.png'), '-dpng', '-r160');
    close(fig);

    hermite = BeamFactory.create('hermite', 1.0e-4, 632.8e-9, 'n', 2, 'm', 1);
    laguerre = BeamFactory.create('laguerre', 1.0e-4, 632.8e-9, 'l', 1, 'p', 1);
    Ih = abs(hermite.opticalField(X, Y, 0)).^2;
    Il = abs(laguerre.opticalField(X, Y, 0)).^2;

    fig = figure('visible', 'off', 'position', [100, 100, 1100, 440]);
    subplot(1, 2, 1);
    imagesc(x * 1e6, y * 1e6, Ih);
    axis image;
    xlabel('x [um]');
    ylabel('y [um]');
    cb = colorbar;
    ylabel(cb, 'Normalized intensity |E|^2 [a.u.]');
    title('Hermite-Gaussian HG_{2,1}');
    subplot(1, 2, 2);
    imagesc(x * 1e6, y * 1e6, Il);
    axis image;
    xlabel('x [um]');
    ylabel('y [um]');
    cb = colorbar;
    ylabel(cb, 'Normalized intensity |E|^2 [a.u.]');
    title('Laguerre-Gaussian LG_{1,1}');
    applyReadableColormap('parula');
    print(fig, fullfile(outDir, 'hermite_laguerre_modes.png'), '-dpng', '-r160');
    close(fig);

    z = 0.05;
    phaseField = gaussian.opticalField(X, Y, z);
    phaseMap = angle(phaseField);
    fig = figure('visible', 'off', 'position', [100, 100, 720, 560]);
    imagesc(x * 1e6, y * 1e6, phaseMap);
    axis image;
    colormap(hsv(256));
    cb = colorbar;
    ylabel(cb, 'Phase [rad]');
    xlabel('x [um]');
    ylabel('y [um]');
    title('Gaussian wavefront phase after propagation');
    print(fig, fullfile(outDir, 'wavefront_phase.png'), '-dpng', '-r160');
    close(fig);

    fprintf('README figures written to %s\n', outDir);
end

function applyReadableColormap(name)
    try
        cmap = feval(name, 256);
    catch
        cmap = jet(256);
    end
    colormap(cmap);
end

generate_readme_figures();
