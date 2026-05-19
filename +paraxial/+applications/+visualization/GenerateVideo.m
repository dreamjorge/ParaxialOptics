%% GenerateVideo - Beam Propagation Video Generation
%% Generates AVI/MP4 videos of beam propagation with optional ray overlay.
%
% This script shows:
%   - Video generation from propagation sequences
%   - Frame-by-frame animation with beam intensity
%   - Optional ray trajectory overlay
%   - Configurable frame rate and quality
%
% Compatible with GNU Octave and MATLAB
% Note: Octave uses avifile/addframe; MATLAB uses VideoWriter
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/+visualization/GenerateVideo.m')"
%
% Related:
%   +paraxial/+applications/+propagation/PropagationFFT.m
%   +paraxial/+applications/+visualization/GenerateSlices3D.m

scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..');
addpath(repoRoot);
setpaths();

%% ============================================================================
%% CONFIGURATION
%% ============================================================================

% Video settings
VideoFormat = 'AVI';      % 'AVI' or 'MP4' (platform-dependent)
FrameRate   = 15;          % Frames per second
Quality     = 95;          % Video quality (0-100)
ShowRays    = true;        % Overlay ray trajectories
ShowMetrics = true;        % Display beam metrics on frame

% Beam parameters
w0     = 100e-6;          % Initial waist: 100 microns
lambda = 632.8e-9;       % HeNe laser wavelength: 632.8 nm

PC = PhysicalConstants;
zr = PC.rayleighDistance(w0, lambda);

fprintf('=== Video Generation ===\n');
fprintf('  Format: %s, Frame rate: %d fps, Quality: %d%%\n', ...
        VideoFormat, FrameRate, Quality);
fprintf('  Wavelength: %.3f nm, Initial waist: %.1f microns\n', lambda*1e9, w0*1e6);

%% ============================================================================
%% GRID SETUP
%% ============================================================================
Nx  = 256;               % Reduced for faster video generation
Dx  = 3 * w0;
simGrid = GridUtils(Nx, Nx, Dx, Dx);
[X, Y] = simGrid.create2DGrid();
[Kx, Ky] = simGrid.createFreqGrid();
fftOps = FFTUtils();

fprintf('\nGrid: %d x %d points, window %.3f mm\n', Nx, Nx, Dx*1e3);

%% ============================================================================
%% PROPAGATION PARAMETERS
%% ============================================================================
Dz    = zr;
Nz    = 64;               % Number of frames
dz    = Dz / Nz;
z_vec = (0:Nz) * dz;

fprintf('  Frames: %d (Dz = %.4f m)\n', Nz, Dz);

%% ============================================================================
%% BEAM SELECTION
%% ============================================================================
fprintf('\n--- Beam Selection ---\n');

beamType = 'gaussian';  % Options: 'gaussian', 'hermite', 'laguerre', 'hankel'

switch beamType
    case 'gaussian'
        beam = BeamFactory.create('gaussian', w0, lambda);
        beamName = 'Gaussian';
    case 'hermite'
        beam = BeamFactory.create('hermite', w0, lambda, 'n', 2, 'm', 1);
        beamName = 'HG_{2,1}';
    case 'laguerre'
        beam = BeamFactory.create('laguerre', w0, lambda, 'l', 2, 'p', 0);
        beamName = 'LG_{2,0}';
    case 'hankel'
        beam = BeamFactory.create('hankel', w0, lambda, 'l', 3, 'p', 5, 'type', 1);
        beamName = 'Hankel LG_{3,5}';
    otherwise
        error('Unknown beam type: %s', beamType);
end

fprintf('  Beam: %s\n', beamName);

% Create ray bundle if requested
if ShowRays
    fprintf('  Creating ray bundle... ');
    bundle = RayBundle.createCircularContour(12, w0, 0, w0, 0);
    bundle = RayTracer.propagateToPlanes(bundle, beam, z_vec, dz, 'RK4');
    fprintf('done (%d rays)\n', bundle.Ny * bundle.Nx);
end

%% ============================================================================
%% VIDEO SETUP
%% ============================================================================
fprintf('\n--- Video Setup ---\n');

% Determine video writer
if isunix() && ~ismac()
    % Likely Linux with ffmpeg
    outputFile = fullfile(scriptPath, [beamName, '_Propagation.mp4']);
else
    % Windows or macOS
    outputFile = fullfile(scriptPath, [beamName, '_Propagation.avi']);
end

% Check platform and create appropriate video object
try
    if exist('VideoWriter', 'file') == 2
        % MATLAB
        if strcmp(VideoFormat, 'MP4')
            vidObj = VideoWriter(outputFile, 'MPEG-4');
        else
            vidObj = VideoWriter(outputFile);
        end
        vidObj.Quality = Quality;
        vidObj.FrameRate = FrameRate;
        open(vidObj);
        hasVideo = true;
        platform = 'MATLAB';
    else
        % Octave fallback: use avifile
        error('fallback');
    end
catch
    % Octave or older MATLAB
    try
        vidObj = avifile(outputFile);
        vidObj.fps = FrameRate;
        vidObj.quality = Quality;
        hasVideo = true;
        platform = 'Octave';
    catch
        hasVideo = false;
        platform = 'None';
        fprintf('  Warning: Video generation not available on this platform\n');
    end
end

if hasVideo
    fprintf('  Video writer initialized: %s\n', platform);
    fprintf('  Output: %s\n', outputFile);
end

%% ============================================================================
%% FRAME GENERATION LOOP
%% ============================================================================
fprintf('\n--- Generating Frames ---\n');

% Colormap
mapBeam = 'hot';  % Or use: AdvancedColormap('kgg', 256, [0 100 255]/255)

% Create figure for frame capture
fig = figure(1);
fig.Position = [100, 100, 800, 600];
fig.NumberTitle = 'off';
fig.MenuBar = 'none';

% Initial field
field = beam.opticalField(X, Y, 0);

% Normalize intensity for consistent display
I_max = max(abs(field(:)).^2);

% Progress tracking
framesGenerated = 0;
t_start = tic;

for zi = 1:Nz
    z = z_vec(zi);
    
    % Compute intensity
    I = abs(field).^2;
    
    % Plot intensity field
    clf;
    imagesc(X(1,:)/w0, Y(:,1)/w0, I/I_max);
    colormap(mapBeam);
    caxis([0, 1]);
    axis square;
    set(gca, 'YDir', 'normal');
    hold on;
    
    % Overlay rays if requested
    if ShowRays && zi <= size(bundle.x, 3)
        rx = squeeze(bundle.x(:,:,zi)) / w0;
        ry = squeeze(bundle.y(:,:,zi)) / w0;
        plot(rx(:), ry(:), 'c.', 'MarkerSize', 4);
    end
    
    % Add metrics text
    if ShowMetrics
        params = beam.getParameters(z);
        textStr = sprintf('z = %.2f z_R\nw = %.2f um\nR = %.2f m', ...
                           z/zr, params.Waist*1e6, params.radius(z));
        text(0.02, 0.98, textStr, ...
             'Units', 'normalized', ...
             'VerticalAlignment', 'top', ...
             'FontSize', 10, ...
             'Color', 'w', ...
             'BackgroundColor', 'k');
    end
    
    hold off;
    title(sprintf('%s Propagation: z = %.2f z_R', beamName, z/zr));
    xlabel('x / w_0');
    ylabel('y / w_0');
    
    drawnow;
    
    % Write frame
    if hasVideo
        if strcmp(platform, 'Octave')
            vidObj = addframe(vidObj, fig);
        else
            writeVideo(vidObj, getframe(fig));
        end
    end
    
    framesGenerated = framesGenerated + 1;
    
    % Progress update every 10 frames
    if mod(zi, 10) == 0
        elapsed = toc(t_start);
        fps = framesGenerated / elapsed;
        remaining = (Nz - zi) / fps;
        fprintf('  Frame %d/%d (%.0f%%) - %.1f fps, ~%.0f s remaining\n', ...
                zi, Nz, zi/Nz*100, fps, remaining);
    end
    
    % Propagate to next plane (except on last frame)
    if zi < Nz
        field = fftOps.propagate(field, Kx, Ky, dz, lambda);
    end
end

fprintf('  %d frames generated in %.1f seconds\n', framesGenerated, toc(t_start));

%% ============================================================================
%% FINALIZE VIDEO
%% ============================================================================
if hasVideo
    fprintf('\n--- Finalizing Video ---\n');
    
    if strcmp(platform, 'Octave')
        vidObj = close(vidObj);
    else
        close(vidObj);
    end
    
    % Verify file was created
    if exist(outputFile, 'file') == 2
        fileInfo = dir(outputFile);
        fprintf('  Video saved: %s (%.2f MB)\n', outputFile, fileInfo.bytes/1e6);
    else
        fprintf('  Warning: Video file not found after close\n');
    end
end

%% ============================================================================
%% SUMMARY
%% ============================================================================
fprintf('\n=== Video Generation Complete ===\n');
fprintf('  Beam: %s\n', beamName);
fprintf('  Frames: %d\n', framesGenerated);
fprintf('  Format: %s\n', VideoFormat);
if hasVideo
    fprintf('  Output: %s\n', outputFile);
end

close(fig);