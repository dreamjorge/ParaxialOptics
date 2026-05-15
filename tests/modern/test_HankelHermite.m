% Compatible with GNU Octave and MATLAB
% Tests for HankelHermite (Phase 3 API: HankelHermite(w0, lambda, n, m, hankelType))

repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(repoRoot);
setpaths();

fprintf('=== HankelHermite Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 1e-3;
lambda = 632e-9;
grid = GridUtils(64, 64, 4e-3, 4e-3);
[X, Y] = grid.create2DGrid();

% testConstructorType11
HH11 = HankelHermite(w0, lambda, 1, 1, 11);
field11 = HH11.opticalField(X, Y, 0);
if (~isempty(field11) && isequal(size(field11), [64, 64]))
    fprintf('  PASS: constructor hankelType=11\n');
    passed = passed + 1;
else
    fprintf('  FAIL: constructor hankelType=11\n');
    failed = failed + 1;
end

% testConstructorType12
HH12 = HankelHermite(w0, lambda, 1, 1, 12);
field12 = HH12.opticalField(X, Y, 0);
if (~isempty(field12) && isequal(size(field12), [64, 64]))
    fprintf('  PASS: constructor hankelType=12\n');
    passed = passed + 1;
else
    fprintf('  FAIL: constructor hankelType=12\n');
    failed = failed + 1;
end

% testConstructorType21
HH21 = HankelHermite(w0, lambda, 1, 1, 21);
field21 = HH21.opticalField(X, Y, 0);
if (~isempty(field21) && isequal(size(field21), [64, 64]))
    fprintf('  PASS: constructor hankelType=21\n');
    passed = passed + 1;
else
    fprintf('  FAIL: constructor hankelType=21\n');
    failed = failed + 1;
end

% testConstructorType22
HH22 = HankelHermite(w0, lambda, 1, 1, 22);
field22 = HH22.opticalField(X, Y, 0);
if (~isempty(field22) && isequal(size(field22), [64, 64]))
    fprintf('  PASS: constructor hankelType=22\n');
    passed = passed + 1;
else
    fprintf('  FAIL: constructor hankelType=22\n');
    failed = failed + 1;
end

% testConstructorDefault
HH_def = HankelHermite(w0, lambda, 1, 1);
if (HH_def.HankelType == 11)
    fprintf('  PASS: default hankelType=11\n');
    passed = passed + 1;
else
    fprintf('  FAIL: default hankelType\n');
    failed = failed + 1;
end

% testPropertiesStored
if (HH11.n == 1 && HH11.m == 1 && HH11.HankelType == 11 && HH11.InitialWaist == w0)
    fprintf('  PASS: properties stored\n');
    passed = passed + 1;
else
    fprintf('  FAIL: properties stored\n');
    failed = failed + 1;
end

% testIsParaxialBeam
if isa(HH11, 'ParaxialBeam')
    fprintf('  PASS: isa ParaxialBeam\n');
    passed = passed + 1;
else
    fprintf('  FAIL: isa ParaxialBeam\n');
    failed = failed + 1;
end

% testGetParameters
params = HH11.getParameters(0.1);
if (abs(params.zCoordinate - 0.1) < 1e-15 && params.InitialWaist == w0)
    fprintf('  PASS: getParameters\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getParameters\n');
    failed = failed + 1;
end

% testBeamName
if strcmp(HH11.beamName(), 'hankel11_hermite_1_1')
    fprintf('  PASS: beamName\n');
    passed = passed + 1;
else
    fprintf('  FAIL: beamName (got %s)\n', HH11.beamName());
    failed = failed + 1;
end

% testFieldFiniteAtWaist
if all(all(isfinite(field11))) && all(all(isfinite(field22)))
    fprintf('  PASS: finite at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: finite at waist\n');
    failed = failed + 1;
end

% testFieldFiniteAtPropagation
fp11 = HH11.opticalField(X, Y, 0.1);
fp22 = HH22.opticalField(X, Y, 0.1);
if all(all(isfinite(fp11))) && all(all(isfinite(fp22)))
    fprintf('  PASS: finite at propagation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: finite at propagation\n');
    failed = failed + 1;
end

% testFieldAmplitudePositive
if max(max(abs(field11))) > 0
    fprintf('  PASS: field amplitude positive\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field amplitude\n');
    failed = failed + 1;
end

% testHigherModes
HH_high = HankelHermite(w0, lambda, 3, 2, 11);
f_high = HH_high.opticalField(X, Y, 0);
if all(all(isfinite(f_high)))
    fprintf('  PASS: higher modes (3,2)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher modes\n');
    failed = failed + 1;
end

% testZeroModes
HH_00 = HankelHermite(w0, lambda, 0, 0, 11);
f_00 = HH_00.opticalField(X, Y, 0);
if all(all(isfinite(f_00)))
    fprintf('  PASS: zero modes (0,0)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: zero modes\n');
    failed = failed + 1;
end

% testDifferentWavelengths
HH_532 = HankelHermite(w0, 532e-9, 1, 1, 11);
HH_1064 = HankelHermite(w0, 1064e-9, 1, 1, 11);
if all(all(isfinite(HH_532.opticalField(X, Y, 0)))) && all(all(isfinite(HH_1064.opticalField(X, Y, 0))))
    fprintf('  PASS: different wavelengths\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different wavelengths\n');
    failed = failed + 1;
end

% testFourTypesDistinct
if max(max(abs(field11 - field12))) > 1e-15 && max(max(abs(field11 - field22))) > 1e-15
    fprintf('  PASS: four types are distinct\n');
    passed = passed + 1;
else
    fprintf('  FAIL: types not distinct\n');
    failed = failed + 1;
end

% testBeamFactory
beam_f = BeamFactory.create('hankel_hermite', w0, lambda, 'n', 2, 'm', 1, 'type', 12);
if (isa(beam_f, 'HankelHermite') || isa(beam_f, 'paraxial.beams.HankelHermite')) && beam_f.HankelType == 12 && beam_f.n == 2 && beam_f.m == 1
    fprintf('  PASS: BeamFactory create\n');
    passed = passed + 1;
else
    fprintf('  FAIL: BeamFactory create\n');
    failed = failed + 1;
end

% testLegacyConstructor
hp = HermiteParameters(0.01, w0, lambda, 2, 1);
x = linspace(-3e-3, 3e-3, 51);
y = 1e-4;
hh_legacy = HankelHermite(x, y, hp, 11);
if ~isempty(hh_legacy.OpticalField) && numel(hh_legacy.OpticalField) == numel(x)
    fprintf('  PASS: legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: legacy constructor\n');
    failed = failed + 1;
end

fprintf('\n=== HankelHermite: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
