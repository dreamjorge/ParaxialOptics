function ver = simulation_scripts_version()
    % simulation_scripts_version - Get ParaxialOptics version
    %
    % Usage:
    %   ver = simulation_scripts_version()
    %
    % Output:
    %   ver - version string from Git tag (e.g. 'v2.0.0' or 'v2.0.0-3-gabc1234'
    %        if the commit is not an exact tag), '0.0.0-unknown' if Git is unavailable
    %
    % Note:
    %   This function is also available as a local function inside +paraxial/init.m
    %   for package-internal use. Both implementations return the same version.

    [status, result] = system('git describe --tags --match "v*" --always');
    if status == 0
        ver = strtrim(result);
    else
        ver = '0.0.0-unknown';
    end
end