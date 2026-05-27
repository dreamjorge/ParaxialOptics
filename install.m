function install()
    % install - Install ParaxialOptics package
    %
    % This script is called automatically by:
    %   Octave: pkg install simulation_scripts-*.tar.gz
    %   MATLAB: matlab.addons.install('simulation_scripts.mltbx')
    %
    % Or manually:
    %   octave --eval "install"
    %   matlab >> run install.m

    scriptPath = fileparts(mfilename('fullpath'));

    % Get version string via Git directly (avoids needing +paraxial on path)
    [status, result] = system('git describe --tags --match "v*" --always');
    if status == 0
        ver = strtrim(result);
    else
        ver = '0.0.0-unknown';
    end

    % Add main repo root (covers +paraxial/, ParaxialBeams/, src/, examples/, etc.)
    addpath(scriptPath);

    % Add all +paraxial/ namespace subpackages
    paraxialRoot = fullfile(scriptPath, '+paraxial');
    if exist(paraxialRoot, 'dir')
        addpath(paraxialRoot);
        subfolders = {...
            '+beams', ...
            '+parameters', ...
            '+computation', ...
            '+propagation', ...
            '+propagation/+field', ...
            '+propagation/+rays', ...
            '+visualization'};
        for i = 1:numel(subfolders)
            subPath = fullfile(paraxialRoot, subfolders{i});
            if exist(subPath, 'dir')
                addpath(subPath);
            end
        end
    end

    fprintf('[ParaxialOptics] v%s installed successfully.\n', ver);
    fprintf('  Type "help simulation_scripts_version" for version info.\n');
    fprintf('  See README.md for usage examples.\n');
end