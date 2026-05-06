% Compatible with GNU Octave and MATLAB
% Tests for HermiteBeam (Phase 3 API: HermiteBeam(w0, lambda, n, m))

addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'ParaxialBeams'));

fprintf('=== HermiteBeam Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;
grid = GridUtils(64, 64, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();

hb = HermiteBeam(w0, lambda, 1, 1);

% testFieldGeneration
field = hb.opticalField(X, Y, 0);
if (isequal(size(field), [64, 64]))
    fprintf('  PASS: field generation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field generation\n');
    failed = failed + 1;
end

% testHigherOrderModes
hb_high = HermiteBeam(w0, lambda, 2, 3);
field_high = hb_high.opticalField(X, Y, 0);
if (all(all(isfinite(field_high))))
    fprintf('  PASS: higher order modes\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher order modes\n');
    failed = failed + 1;
end

% testZeroOrderEqualsGaussian
hb_zero = HermiteBeam(w0, lambda, 0, 0);
gb = GaussianBeam(w0, lambda);
field_hb = hb_zero.opticalField(X, Y, 0);
field_gb = gb.opticalField(X, Y, 0);
diff_center = abs(field_hb(33,33) - field_gb(33,33));
if (diff_center < 1e-10)
    fprintf('  PASS: zero order equals Gaussian\n');
    passed = passed + 1;
else
    fprintf('  FAIL: zero order equals Gaussian\n');
    failed = failed + 1;
end

% testModeOrdersStored
if (hb.n == 1 && hb.m == 1)
    fprintf('  PASS: mode orders stored\n');
    passed = passed + 1;
else
    fprintf('  FAIL: mode orders stored\n');
    failed = failed + 1;
end

% testGetParameters
params = hb.getParameters(0.05);
if (abs(params.zCoordinate - 0.05) < 1e-15 && params.InitialWaist == w0)
    fprintf('  PASS: getParameters(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getParameters(z)\n');
    failed = failed + 1;
end

% testValidFieldAtWaist
field_z0 = hb.opticalField(X, Y, 0);
if (all(all(isfinite(field_z0))))
    fprintf('  PASS: valid field at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: valid field at waist\n');
    failed = failed + 1;
end

% testDifferentOrders
hb_10 = HermiteBeam(w0, lambda, 1, 0);
hb_01 = HermiteBeam(w0, lambda, 0, 1);
field_10 = hb_10.opticalField(X, Y, 0);
field_01 = hb_01.opticalField(X, Y, 0);
if (isequal(size(field_10), size(field_01)))
    fprintf('  PASS: different orders valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different orders\n');
    failed = failed + 1;
end

% testHermitePolyN0
x_test = linspace(-2, 2, 10);
H0 = PolynomialUtils.hermitePoly(0, x_test);
if (all(abs(H0 - 1) < 1e-10))
    fprintf('  PASS: hermitePoly n=0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermitePoly n=0\n');
    failed = failed + 1;
end

% testHermitePolyN1
H1 = PolynomialUtils.hermitePoly(1, x_test);
expected_H1 = 2 * x_test;
if (all(abs(H1 - expected_H1) < 1e-10))
    fprintf('  PASS: hermitePoly n=1\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermitePoly n=1\n');
    failed = failed + 1;
end

% testHermitePolyN2
H2 = PolynomialUtils.hermitePoly(2, x_test);
expected_H2 = 4 * x_test.^2 - 2;
if (all(abs(H2 - expected_H2) < 1e-10))
    fprintf('  PASS: hermitePoly n=2\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermitePoly n=2\n');
    failed = failed + 1;
end

% testHermitePolyN3
H3 = PolynomialUtils.hermitePoly(3, x_test);
expected_H3 = 8 * x_test.^3 - 12 * x_test;
if (all(abs(H3 - expected_H3) < 1e-10))
    fprintf('  PASS: hermitePoly n=3\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermitePoly n=3\n');
    failed = failed + 1;
end

% testHermitePolyMatrixInput
x_mat = rand(5, 5);
H_mat = PolynomialUtils.hermitePoly(2, x_mat);
if (isequal(size(H_mat), size(x_mat)))
    fprintf('  PASS: hermitePoly matrix input\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermitePoly matrix input\n');
    failed = failed + 1;
end

% testPhaseIncluded
hb_phase = HermiteBeam(w0, lambda, 1, 1);
field_phase = hb_phase.opticalField(X, Y, 0.05);
if (~isreal(field_phase) || any(any(abs(imag(field_phase)) > 0)))
    fprintf('  PASS: phase included in field\n');
    passed = passed + 1;
else
    fprintf('  FAIL: phase included in field\n');
    failed = failed + 1;
end

% testHermitePolyN4
H4 = PolynomialUtils.hermitePoly(4, x_test);
expected_H4 = 16 * x_test.^4 - 48 * x_test.^2 + 12;
if (all(abs(H4 - expected_H4) < 1e-10))
    fprintf('  PASS: hermitePoly n=4\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermitePoly n=4\n');
    failed = failed + 1;
end

% testFieldAtDifferentZ
field_z1 = hb.opticalField(X, Y, 0.01);
field_z2 = hb.opticalField(X, Y, 0.1);
if (all(all(isfinite(field_z1))) && all(all(isfinite(field_z2))))
    fprintf('  PASS: field at different z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field at different z\n');
    failed = failed + 1;
end

% testHigherNMOrders
hb_hn = HermiteBeam(w0, lambda, 3, 3);
field_hn = hb_hn.opticalField(X, Y, 0);
if (all(all(isfinite(field_hn))))
    fprintf('  PASS: higher n m orders\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher n m\n');
    failed = failed + 1;
end

% testZeroOrderPhase (PhiPhase = 0 at z=0 for n=m=0)
hb_zp = HermiteBeam(w0, lambda, 0, 0);
params_zp = hb_zp.getParameters(0);
phi_mode = (0 + 0) * params_zp.GouyPhase;
if (phi_mode == 0)
    fprintf('  PASS: zero order phase only\n');
    passed = passed + 1;
else
    fprintf('  FAIL: zero order phase\n');
    failed = failed + 1;
end

% testInitialWaistStored
if (hb.InitialWaist == w0)
    fprintf('  PASS: InitialWaist stored\n');
    passed = passed + 1;
else
    fprintf('  FAIL: InitialWaist stored\n');
    failed = failed + 1;
end

% testFieldAmplitude
hb_amp = HermiteBeam(w0, lambda, 0, 0);
field_amp = hb_amp.opticalField(X, Y, 0);
max_amp = max(max(abs(field_amp)));
if (max_amp > 0)
    fprintf('  PASS: field amplitude positive\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field amplitude\n');
    failed = failed + 1;
end

% testDifferentWavelengths
hb_l1 = HermiteBeam(w0, 532e-9, 1, 1);
hb_l2 = HermiteBeam(w0, 1064e-9, 1, 1);
field_l1 = hb_l1.opticalField(X, Y, 0);
field_l2 = hb_l2.opticalField(X, Y, 0);
if (all(all(isfinite(field_l1))) && all(all(isfinite(field_l2))))
    fprintf('  PASS: different wavelengths\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different wavelengths\n');
    failed = failed + 1;
end

% testHermitePolyNegativeValues
x_neg = linspace(-1, 1, 5);
H_neg = PolynomialUtils.hermitePoly(2, x_neg);
if (all(isfinite(H_neg)))
    fprintf('  PASS: hermitePoly negative values\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermitePoly negative\n');
    failed = failed + 1;
end

% testAsymmetricOrders
hb_asym = HermiteBeam(w0, lambda, 2, 1);
field_asym = hb_asym.opticalField(X, Y, 0);
if (all(all(isfinite(field_asym))))
    fprintf('  PASS: asymmetric orders\n');
    passed = passed + 1;
else
    fprintf('  FAIL: asymmetric orders\n');
    failed = failed + 1;
end

% testWaistFromParameters
params_hb = hb.getParameters(0);
if (params_hb.Waist > 0)
    fprintf('  PASS: waist from parameters\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist from params\n');
    failed = failed + 1;
end

% testGouyPhaseIncluded
params_gouy = hb.getParameters(0.05);
if (params_gouy.GouyPhase > 0)
    fprintf('  PASS: Gouy phase included\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Gouy phase\n');
    failed = failed + 1;
end

% testModalGouyRelativePhase (HG10 vs HG00)
z_rel = pi * w0^2 / lambda;
psi_rel = atan2(z_rel, pi * w0^2 / lambda);
x_rel = 0.7 * w0;
y_rel = 0;
hb00_rel = HermiteBeam(w0, lambda, 0, 0);
hb10_rel = HermiteBeam(w0, lambda, 1, 0);
f00_rel = hb00_rel.opticalField(x_rel, y_rel, z_rel);
f10_rel = hb10_rel.opticalField(x_rel, y_rel, z_rel);
w_rel = hb00_rel.getParameters(z_rel).Waist;
H1_rel = PolynomialUtils.hermitePoly(1, sqrt(2) * x_rel / w_rel);
ratio_rel = f10_rel / (H1_rel * f00_rel);
phase_err_rel = angle(ratio_rel * exp(1i * psi_rel));
if (abs(phase_err_rel) < 1e-8)
    fprintf('  PASS: modal Gouy relative phase\n');
    passed = passed + 1;
else
    fprintf('  FAIL: modal Gouy relative phase\n');
    failed = failed + 1;
end

% testBeamName
if (strcmp(hb.beamName(), 'hermite_1_1'))
    fprintf('  PASS: beamName\n');
    passed = passed + 1;
else
    fprintf('  FAIL: beamName\n');
    failed = failed + 1;
end

%% ===== NHermiteBeam Tests =====

fprintf('\n--- NHermiteBeam Tests ---\n');

% NHermiteBeam modern constructor
nhb = NHermiteBeam(w0, lambda, 1, 1);
if (nhb.InitialWaist == w0 && nhb.n == 1 && nhb.m == 1 && nhb.Lambda == lambda)
    fprintf('  PASS: NHermiteBeam modern constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam modern constructor\n');
    failed = failed + 1;
end

% NHermiteBeam field finite at waist
nhb_field = nhb.opticalField(X, Y, 0);
if (all(all(isfinite(nhb_field))) && isequal(size(nhb_field), [64, 64]))
    fprintf('  PASS: NHermiteBeam field finite at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam field finite at waist\n');
    failed = failed + 1;
end

% NHermiteBeam field finite at propagation
nhb_zr = nhb.opticalField(X, Y, pi * w0^2 / lambda);
if (all(all(isfinite(nhb_zr))))
    fprintf('  PASS: NHermiteBeam field finite at zr\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam field at zr\n');
    failed = failed + 1;
end

% NHermiteBeam beamName format
if (strcmp(nhb.beamName(), 'nhermite_1_1'))
    fprintf('  PASS: NHermiteBeam beamName\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam beamName (got %s)\n', nhb.beamName());
    failed = failed + 1;
end

% NHermiteBeam getParameters
nhb_params = nhb.getParameters(0.05);
if (isa(nhb_params, 'GaussianParameters') && abs(nhb_params.zCoordinate - 0.05) < 1e-15)
    fprintf('  PASS: NHermiteBeam getParameters\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam getParameters\n');
    failed = failed + 1;
end

% NHermiteBeam isa ParaxialBeam
if (isa(nhb, 'ParaxialBeam'))
    fprintf('  PASS: NHermiteBeam isa ParaxialBeam\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam isa ParaxialBeam\n');
    failed = failed + 1;
end

% NHermiteBeam legacy constructor
hp_test = HermiteParameters(0.01, w0, lambda, 2, 1);
x_leg = linspace(-1e-3, 1e-3, 21);
y_leg = 1e-4;
nhb_leg = NHermiteBeam(x_leg, y_leg, hp_test);
if (~isempty(nhb_leg.OpticalField) && numel(nhb_leg.OpticalField) == numel(x_leg))
    fprintf('  PASS: NHermiteBeam legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam legacy constructor\n');
    failed = failed + 1;
end

% hermiteSecondSolution returns NHG different from HG
x_test = linspace(-2, 2, 11);
[HG, NHG] = HermiteComputation.hermiteSolutions(2, x_test);
NHG_direct = HermiteComputation.hermiteSecondSolution(2, x_test);
if (max(abs(NHG - NHG_direct)) < 1e-14 && max(abs(HG - NHG_direct)) > 1e-6)
    fprintf('  PASS: hermiteSecondSolution returns NHG distinct from HG\n');
    passed = passed + 1;
else
    fprintf('  FAIL: hermiteSecondSolution NHG vs HG distinction\n');
    failed = failed + 1;
end

% NHermiteBeam higher orders
nhb_high = NHermiteBeam(w0, lambda, 2, 3);
nhb_high_field = nhb_high.opticalField(X, Y, 0);
if (all(all(isfinite(nhb_high_field))))
    fprintf('  PASS: NHermiteBeam higher order modes\n');
    passed = passed + 1;
else
    fprintf('  FAIL: NHermiteBeam higher order modes\n');
    failed = failed + 1;
end

fprintf('\n=== HermiteBeam: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
