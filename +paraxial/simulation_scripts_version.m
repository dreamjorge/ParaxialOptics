function ver = simulation_scripts_version()
    % simulation_scripts_version - Get ParaxialOptics version
    %
    % Usage:
    %   ver = paraxial.simulation_scripts_version()
    %
    % Output:
    %   ver - version string from Git tag (e.g. 'v1.0.0'), package
    %        DESCRIPTION metadata, or '0.0.0-unknown' if unavailable.

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
