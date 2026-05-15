% Compatible with GNU Octave and MATLAB
% Tests for BeamFactory

repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(repoRoot);
setpaths();

fprintf('=== BeamFactory Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;
grid = GridUtils(64, 64, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();

% testCreateGaussian
beam = BeamFactory.create('gaussian', w0, lambda);
if (isa(beam, 'GaussianBeam') || isa(beam, 'paraxial.beams.GaussianBeam'))
    fprintf('  PASS: create gaussian\n');
    passed = passed + 1;
else
    fprintf('  FAIL: create gaussian\n');
    failed = failed + 1;
end

% testCreateHermite
beam = BeamFactory.create('hermite', w0, lambda, 'n', 1, 'm', 2);
if ((isa(beam, 'HermiteBeam') || isa(beam, 'paraxial.beams.HermiteBeam')) && beam.n == 1 && beam.m == 2)
    fprintf('  PASS: create hermite\n');
    passed = passed + 1;
else
    fprintf('  FAIL: create hermite\n');
    failed = failed + 1;
end

% testCreateLaguerre
beam = BeamFactory.create('laguerre', w0, lambda, 'l', 2, 'p', 1);
if ((isa(beam, 'LaguerreBeam') || isa(beam, 'paraxial.beams.LaguerreBeam')) && beam.l == 2 && beam.p == 1)
    fprintf('  PASS: create laguerre\n');
    passed = passed + 1;
else
    fprintf('  FAIL: create laguerre\n');
    failed = failed + 1;
end

% testCreateElegantHermite
beam = BeamFactory.create('elegant_hermite', w0, lambda, 'n', 2, 'm', 0);
if ((isa(beam, 'ElegantHermiteBeam') || isa(beam, 'paraxial.beams.ElegantHermiteBeam')) && beam.n == 2 && beam.m == 0)
    fprintf('  PASS: create elegant_hermite\n');
    passed = passed + 1;
else
    fprintf('  FAIL: create elegant_hermite\n');
    failed = failed + 1;
end

% testCreateElegantLaguerre
beam = BeamFactory.create('elegant_laguerre', w0, lambda, 'l', 1, 'p', 0);
if ((isa(beam, 'ElegantLaguerreBeam') || isa(beam, 'paraxial.beams.ElegantLaguerreBeam')) && beam.l == 1 && beam.p == 0)
    fprintf('  PASS: create elegant_laguerre\n');
    passed = passed + 1;
else
    fprintf('  FAIL: create elegant_laguerre\n');
    failed = failed + 1;
end

% testCreateHankel
beam = BeamFactory.create('hankel', w0, lambda, 'l', 1, 'p', 0, 'type', 2);
if ((isa(beam, 'HankelLaguerre') || isa(beam, 'paraxial.beams.HankelLaguerre')) && beam.HankelType == 2)
    fprintf('  PASS: create hankel\n');
    passed = passed + 1;
else
    fprintf('  FAIL: create hankel\n');
    failed = failed + 1;
end

% testDefaultsGaussian
beam = BeamFactory.create('gaussian', w0, lambda);
if (beam.InitialWaist == w0 && beam.Lambda == lambda)
    fprintf('  PASS: defaults gaussian\n');
    passed = passed + 1;
else
    fprintf('  FAIL: defaults gaussian\n');
    failed = failed + 1;
end

% testDefaultsHermite (n=0, m=0)
beam = BeamFactory.create('hermite', w0, lambda);
if (beam.n == 0 && beam.m == 0)
    fprintf('  PASS: defaults hermite n m\n');
    passed = passed + 1;
else
    fprintf('  FAIL: defaults hermite n m\n');
    failed = failed + 1;
end

% testDefaultsLaguerre (l=0, p=0)
beam = BeamFactory.create('laguerre', w0, lambda);
if (beam.l == 0 && beam.p == 0)
    fprintf('  PASS: defaults laguerre l p\n');
    passed = passed + 1;
else
    fprintf('  FAIL: defaults laguerre l p\n');
    failed = failed + 1;
end

% testDefaultsHankel (type=1)
beam = BeamFactory.create('hankel', w0, lambda);
if (beam.HankelType == 1)
    fprintf('  PASS: defaults hankel type\n');
    passed = passed + 1;
else
    fprintf('  FAIL: defaults hankel type\n');
    failed = failed + 1;
end

% testAllBeamsImplementInterface
types = BeamFactory.supportedTypes();
all_ok = true;
for i = 1:numel(types)
    b = BeamFactory.create(types{i}, w0, lambda);
    f = b.opticalField(X, Y, 0);
    if ~(all(all(isfinite(f))) && size(f, 1) == 64)
        all_ok = false;
    end
end
if all_ok
    fprintf('  PASS: all types implement opticalField\n');
    passed = passed + 1;
else
    fprintf('  FAIL: some type fails opticalField\n');
    failed = failed + 1;
end

% testAllBeamsHaveBeamName
types = BeamFactory.supportedTypes();
all_ok = true;
for i = 1:numel(types)
    b = BeamFactory.create(types{i}, w0, lambda);
    n_str = b.beamName();
    if isempty(n_str)
        all_ok = false;
    end
end
if all_ok
    fprintf('  PASS: all types implement beamName\n');
    passed = passed + 1;
else
    fprintf('  FAIL: some type fails beamName\n');
    failed = failed + 1;
end

% testAllBeamsHaveGetParameters
types = BeamFactory.supportedTypes();
all_ok = true;
for i = 1:numel(types)
    b = BeamFactory.create(types{i}, w0, lambda);
    p = b.getParameters(0.1);
    if ~(p.InitialWaist > 0)
        all_ok = false;
    end
end
if all_ok
    fprintf('  PASS: all types implement getParameters\n');
    passed = passed + 1;
else
    fprintf('  FAIL: some type fails getParameters\n');
    failed = failed + 1;
end

% testUnknownTypeErrors
try
    BeamFactory.create('bessel', w0, lambda);
    fprintf('  FAIL: unknown type should error\n');
    failed = failed + 1;
catch
    fprintf('  PASS: unknown type errors correctly\n');
    passed = passed + 1;
end

% testCaseInsensitive
beam = BeamFactory.create('GAUSSIAN', w0, lambda);
if isa(beam, 'GaussianBeam') || isa(beam, 'paraxial.beams.GaussianBeam')
    fprintf('  PASS: case insensitive\n');
    passed = passed + 1;
else
    fprintf('  FAIL: case insensitive\n');
    failed = failed + 1;
end

% testSupportedTypes
types = BeamFactory.supportedTypes();
if (numel(types) == 11)
    fprintf('  PASS: supportedTypes count\n');
    passed = passed + 1;
else
    fprintf('  FAIL: supportedTypes count\n');
    failed = failed + 1;
end

% testHermiteIsParaxialBeam
beam = BeamFactory.create('hermite', w0, lambda, 'n', 1, 'm', 1);
if isa(beam, 'ParaxialBeam') || isa(beam, 'paraxial.beams.ParaxialBeam')
    fprintf('  PASS: all beams are ParaxialBeam\n');
    passed = passed + 1;
else
    fprintf('  FAIL: beam not ParaxialBeam\n');
    failed = failed + 1;
end

fprintf('\n=== BeamFactory: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
