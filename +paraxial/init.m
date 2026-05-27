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
    %   ver = paraxial.simulation_scripts_version()
    %
    % Output:
    %   ver - version string from Git tag, package DESCRIPTION metadata,
    %        or '0.0.0-unknown' if unavailable.

    [status, result] = system('git describe --tags --match "v*" --always');
    if status == 0
        ver = strtrim(result);
        return;
    end

    descriptionPath = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'DESCRIPTION');
    if exist(descriptionPath, 'file')
        content = fileread(descriptionPath);
        token = regexp(content, '(?m)^Version:\s*([^\r\n]+)', 'tokens', 'once');
        if ~isempty(token)
            ver = ['v' strtrim(token{1})];
            return;
        end
    end

    ver = '0.0.0-unknown';
end