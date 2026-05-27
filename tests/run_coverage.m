% Compatible with GNU Octave and MATLAB
% Coverage Report - ParaxialOptics
% Calculates approximate coverage based on functions tested

fprintf('=== Coverage Report ===\n\n');

% Classes to test
classes = {
    'PhysicalConstants'
    'GridUtils'
    'FFTUtils'
    'GaussianParameters'
    'HermiteParameters'
    'LaguerreParameters'
    'GaussianBeam'
    'HermiteBeam'
    'LaguerreBeam'
    'ElegantHermiteParameters'
    'ElegantLaguerreParameters'
    'ElegantHermiteBeam'
    'ElegantLaguerreBeam'
    'AnalysisUtils'
};

% Test files
testFiles = {
    'test_PhysicalConstants.m'
    'test_GridUtils.m'
    'test_FFTUtils.m'
    'test_GaussianParameters.m'
    'test_HermiteParameters.m'
    'test_LaguerreParameters.m'
    'test_GaussianBeam.m'
    'test_HermiteBeam.m'
    'test_LaguerreBeam.m'
    'test_AnalysisUtils.m'
};

fprintf('Modules with tests: %d / %d\n\n', numel(testFiles), numel(classes));

fprintf('=== Running Tests ===\n');
scriptPath = fileparts(mfilename('fullpath'));

passed_total = 0;
failed_total = 0;

for i = 1:numel(testFiles)
    testFile = testFiles{i};
    fprintf('Running %s... ', testFile(6:end-2));
    try
        old_warning_state = warning('off', 'all');
        run(fullfile(scriptPath, testFile));
        warning(old_warning_state);
    catch ME
        fprintf('ERROR: %s\n', ME.message);
    end
end

fprintf('\n=== Summary ===\n');
fprintf('Total modules with tests: %d\n', numel(testFiles));
fprintf('Estimated coverage: %d%%\n', round(numel(testFiles) / numel(classes) * 100));

fprintf('\nNote: This is a MODULE coverage metric.\n');
fprintf('Function-level coverage would require instrumentation.\n');
