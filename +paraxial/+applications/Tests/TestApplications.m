%% TestApplications - Quick verification script for +applications
%% Tests basic functionality of all application categories.
%
% Usage:
%   octave --no-gui --eval "run('+paraxial/+applications/Tests/TestApplications.m')"

scriptPath = fileparts(mfilename('fullpath'));
repoRoot   = fullfile(scriptPath, '..', '..', '..', '..');
addpath(repoRoot);
setpaths();

fprintf('=== Testing +paraxial/+applications Suite ===\n\n');

passed = 0;
failed = 0;

%% Test 1: DemoGaussian
fprintf('Test 1: Demo Gaussian beam... ');
try
    w0 = 100e-6;
    lambda = 632.8e-9;
    GB = BeamFactory.create('gaussian', w0, lambda);
    simGrid = GridUtils(128, 128, 1e-3, 1e-3);
    [X, Y] = simGrid.create2DGrid();
    field = GB.opticalField(X, Y, 0);
    assert(~isempty(field));
    fprintf('OK\n');
    passed = passed + 1;
catch err
    fprintf('FAILED: %s\n', err.message);
    failed = failed + 1;
end

%% Test 2: DemoHermiteLaguerre
fprintf('Test 2: Hermite/Laguerre modes... ');
try
    hb = BeamFactory.create('hermite', w0, lambda, 'n', 1, 'm', 1);
    lb = BeamFactory.create('laguerre', w0, lambda, 'l', 1, 'p', 0);
    fprintf('OK\n');
    passed = passed + 1;
catch err
    fprintf('FAILED: %s\n', err.message);
    failed = failed + 1;
end

%% Test 3: DemoElegantModes
fprintf('Test 3: Elegant modes... ');
try
    eh = BeamFactory.create('elegant_hermite', w0, lambda, 'n', 1, 'm', 1);
    el = BeamFactory.create('elegant_laguerre', w0, lambda, 'l', 1, 'p', 0);
    fprintf('OK\n');
    passed = passed + 1;
catch err
    fprintf('FAILED: %s\n', err.message);
    failed = failed + 1;
end

%% Test 4: PropagationAnalytic
fprintf('Test 4: Analytic propagation... ');
try
    GB = BeamFactory.create('gaussian', w0, lambda);
    for z = [0, 0.01, 0.05]
        field = GB.opticalField(X, Y, z);
        assert(~isempty(field));
    end
    fprintf('OK\n');
    passed = passed + 1;
catch err
    fprintf('FAILED: %s\n', err.message);
    failed = failed + 1;
end

%% Test 5: WavefrontAnalysis
fprintf('Test 5: Wavefront analysis... ');
try
    GB = BeamFactory.create('gaussian', w0, lambda);
    E = GB.opticalField(X, Y, 0);
    wf = Wavefront(E, lambda, simGrid);
    coeffs = wf.fitZernike(10);
    assert(length(coeffs) == 10);
    fprintf('OK\n');
    passed = passed + 1;
catch err
    fprintf('FAILED: %s\n', err.message);
    failed = failed + 1;
end

%% Results
fprintf('\n=== Results ===\n');
fprintf('Passed: %d/5\n', passed);
fprintf('Failed: %d/5\n', failed);

if failed > 0
    error('Some tests failed');
end

fprintf('\nAll tests passed!\n');

%% Helper
function assert(cond)
    if ~cond
        error('Assertion failed');
    end
end