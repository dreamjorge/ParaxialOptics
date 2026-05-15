% Compatible with GNU Octave and MATLAB
% Runs only legacy compatibility suites.

scriptPath = fileparts(mfilename('fullpath'));
testRoot = fileparts(scriptPath);
repoRoot = fileparts(testRoot);

addpath(repoRoot);
setpaths();
addpath(scriptPath);

% Post-removal legacy mode:
% Hankele* aliases were removed from legacy/compat, so this runner must
% validate migration behavior with alias-removal expectations enabled.
setenv('LEGACY_ALIAS_REMOVAL_MODE', '1');

legacySuites = {
    fullfile(scriptPath, 'test_HankelCompatibility.m')
    fullfile(scriptPath, 'test_LegacyBeamConstructors.m')
    fullfile(scriptPath, 'test_HankelAliasStaticDelegation.m')
    fullfile(scriptPath, 'test_HankelAliasEdgeCases.m')
};

fprintf('=== Legacy Compatibility Runner ===\n\n');

failed = 0;
for i = 1:numel(legacySuites)
    suitePath = legacySuites{i};
    [~, suiteName] = fileparts(suitePath);
    fprintf('Running: %s\n', suiteName);
    try
        run(suitePath);
    catch ME
        fprintf('  FAIL: %s (%s)\n', suiteName, ME.message);
        failed = failed + 1;
    end
    fprintf('\n');
end

if failed ~= 0
    error('Legacy compatibility runner failed: %d suite(s).', failed);
end

fprintf('Legacy compatibility runner passed.\n');
