function init()
    % init - Initialize +paraxial package with convenient imports
    %
    % Usage:
    %   paraxial.init()  % Call once at start of session
    %
    % This adds all +paraxial/ subdirectories to the path and optionally
    % imports commonly used classes.
    %
    % Note: In MATLAB/Octave, adding +paraxial/ to path automatically
    % makes all subpackages accessible via import paraxial.* or
    % import paraxial.beams.* etc.

    scriptPath = fileparts(mfilename('fullpath'));

    % Add main package directory
    addpath(scriptPath);

    % Add all subpackages
    addpath(fullfile(scriptPath, '+beams'));
    addpath(fullfile(scriptPath, '+parameters'));
    addpath(fullfile(scriptPath, '+computation'));
    addpath(fullfile(scriptPath, '+propagation'));
    addpath(fullfile(scriptPath, '+propagation', '+field'));
    addpath(fullfile(scriptPath, '+propagation', '+rays'));
    addpath(fullfile(scriptPath, '+visualization'));

    fprintf('[+paraxial] Package initialized\n');
end

function ver = simulation_scripts_version()
    % simulation_scripts_version - Get ParaxialOptics version
    %
    % Usage:
    %   ver = simulation_scripts_version()
    %
    % Output:
    %   ver - version string from Git tag (e.g. 'v2.0.0' or 'v2.0.0-3-gabc1234'
    %        if the commit is not an exact tag), '0.0.0-unknown' if Git is unavailable

    [status, result] = system('git describe --tags --match "v*" --always');
    if status == 0
        ver = strtrim(result);
    else
        ver = '0.0.0-unknown';
    end
end