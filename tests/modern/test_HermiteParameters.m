% Compatible with GNU Octave and MATLAB
% Tests for HermiteParameters

repoRoot = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repoRoot, 'ParaxialBeams'));

fprintf('=== HermiteParameters Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;
z = 0.05;

% testConstructor
hp = HermiteParameters(z, w0, lambda, 1, 1);
if (hp.n == 1 && hp.m == 1)
    fprintf('  PASS: constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: constructor\n');
    failed = failed + 1;
end

% testDefaultNandM
hp0 = HermiteParameters(z, w0, lambda);
if (hp0.n == 0 && hp0.m == 0)
    fprintf('  PASS: default n m\n');
    passed = passed + 1;
else
    fprintf('  FAIL: default n m\n');
    failed = failed + 1;
end

% testHermiteWaistX
hp1 = HermiteParameters(z, w0, lambda, 2, 0);
expected_wx = hp1.Waist * sqrt(2 + 1);
if (abs(hp1.HermiteWaistX - expected_wx) / expected_wx < 1e-10)
    fprintf('  PASS: HermiteWaistX\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HermiteWaistX\n');
    failed = failed + 1;
end

% testHermiteWaistY
expected_wy = hp1.Waist * sqrt(0 + 1);
if (abs(hp1.HermiteWaistY - expected_wy) / expected_wy < 1e-10)
    fprintf('  PASS: HermiteWaistY\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HermiteWaistY\n');
    failed = failed + 1;
end

% testHermiteWaist
hp2 = HermiteParameters(z, w0, lambda, 2, 3);
expected_w = hp2.Waist * sqrt(2 + 3 + 1);
if (abs(hp2.HermiteWaist - expected_w) / expected_w < 1e-10)
    fprintf('  PASS: HermiteWaist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HermiteWaist\n');
    failed = failed + 1;
end

% testPhiPhase
zr = hp2.RayleighDistance;
expected_phi = (2 + 3) * atan(z/zr);
if (abs(hp2.PhiPhase - expected_phi) < 1e-10)
    fprintf('  PASS: PhiPhase\n');
    passed = passed + 1;
else
    fprintf('  FAIL: PhiPhase\n');
    failed = failed + 1;
end

% testPhiPhaseZeroAtWaist
hp_z0 = HermiteParameters(0, w0, lambda, 1, 1);
if (abs(hp_z0.PhiPhase) < 1e-10)
    fprintf('  PASS: PhiPhase zero at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: PhiPhase at waist\n');
    failed = failed + 1;
end

% testStaticGetWaistOneDirection
zr_s = pi*w0^2/lambda;
wH_s = HermiteParameters.getWaistOneDirection(0.05, w0, zr_s, 1);
if (wH_s > 0)
    fprintf('  PASS: static getWaistOneDirection\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getWaistOneDirection\n');
    failed = failed + 1;
end

% testStaticGetWaist
wH2_s = HermiteParameters.getWaist(0.05, w0, zr_s, 1, 2);
if (wH2_s > 0)
    fprintf('  PASS: static getWaist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getWaist\n');
    failed = failed + 1;
end

% testWaistIncreasesWithZ
hp_z1 = HermiteParameters(0.01, w0, lambda, 1, 1);
hp_z2 = HermiteParameters(0.1, w0, lambda, 1, 1);
if (hp_z2.HermiteWaist > hp_z1.HermiteWaist)
    fprintf('  PASS: waist grows with z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist grows with z\n');
    failed = failed + 1;
end

% testHigherOrdersLargerWaist
hp_12 = HermiteParameters(z, w0, lambda, 1, 2);
hp_34 = HermiteParameters(z, w0, lambda, 3, 4);
if (hp_34.HermiteWaist > hp_12.HermiteWaist)
    fprintf('  PASS: higher orders larger waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher orders\n');
    failed = failed + 1;
end

% testWavelengthProperty
if (hp.Wavelength == lambda)
    fprintf('  PASS: Wavelength stored\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Wavelength\n');
    failed = failed + 1;
end

% testVectorZInput
z_vec = linspace(0, 0.1, 5);
hp_vec = HermiteParameters(z_vec, w0, lambda, 1, 1);
if (numel(hp_vec.zCoordinate) == 5)
    fprintf('  PASS: vector z input\n');
    passed = passed + 1;
else
    fprintf('  FAIL: vector z\n');
    failed = failed + 1;
end

% testStaticGetWaistOneDirectionAtWaist
wH_at_waist = HermiteParameters.getWaistOneDirection(0, w0, zr_s, 1);
expected_at_waist = w0 * sqrt(2);
if (abs(wH_at_waist - expected_at_waist) / expected_at_waist < 1e-10)
    fprintf('  PASS: static getWaistOneDirection at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getWaistOneDirection at waist\n');
    failed = failed + 1;
end

% testStaticGetWaistAtWaist
wH2_at_waist = HermiteParameters.getWaist(0, w0, zr_s, 1, 1);
expected_w2 = w0 * sqrt(3);
if (abs(wH2_at_waist - expected_w2) / expected_w2 < 1e-10)
    fprintf('  PASS: static getWaist at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getWaist at waist\n');
    failed = failed + 1;
end

% testInheritedProperties
hp_inherit = HermiteParameters(z, w0, lambda, 1, 1);
if (hp_inherit.k > 0 && hp_inherit.RayleighDistance > 0 && hp_inherit.Waist > 0)
    fprintf('  PASS: inherited properties\n');
    passed = passed + 1;
else
    fprintf('  FAIL: inherited properties\n');
    failed = failed + 1;
end

% testDifferentNandM
hp_n1 = HermiteParameters(z, w0, lambda, 3, 0);
hp_m1 = HermiteParameters(z, w0, lambda, 0, 3);
if (hp_n1.HermiteWaistX == hp_m1.HermiteWaistY && hp_n1.n == 3 && hp_m1.m == 3)
    fprintf('  PASS: different n m values\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different n m\n');
    failed = failed + 1;
end

% testPhiPhaseScalesWithOrder
hp_11 = HermiteParameters(z, w0, lambda, 1, 1);
hp_22 = HermiteParameters(z, w0, lambda, 2, 2);
if (hp_22.PhiPhase > hp_11.PhiPhase)
    fprintf('  PASS: PhiPhase scales with order\n');
    passed = passed + 1;
else
    fprintf('  FAIL: PhiPhase scaling\n');
    failed = failed + 1;
end

% testHigherNProducesLargerWaistX
hp_n0 = HermiteParameters(z, w0, lambda, 0, 0);
hp_n2 = HermiteParameters(z, w0, lambda, 2, 0);
if (hp_n2.HermiteWaistX > hp_n0.HermiteWaistX)
    fprintf('  PASS: higher n produces larger WaistX\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher n waistX\n');
    failed = failed + 1;
end

% --- Dynamic API tests (Phase 2) ---

% testDynamicPhiPhase
hp_dyn = HermiteParameters(0, w0, lambda, 2, 3);
z2 = 0.1;
zr_dyn = hp_dyn.RayleighDistance;
phi_dyn = hp_dyn.phiPhase(z2);
phi_expected = (2 + 3) * atan(z2 / zr_dyn);
if (abs(phi_dyn - phi_expected) < 1e-10)
    fprintf('  PASS: dynamic phiPhase(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic phiPhase(z)\n');
    failed = failed + 1;
end

% testDynamicPhiPhaseAtZero
phi_zero = hp_dyn.phiPhase(0);
if (abs(phi_zero) < 1e-10)
    fprintf('  PASS: dynamic phiPhase(0) = 0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic phiPhase(0)\n');
    failed = failed + 1;
end

% testDynamicHermiteWaist
w_dyn2 = hp_dyn.hermiteWaist(z2);
w_g = hp_dyn.waist(z2);
w_expected2 = w_g * sqrt(2 + 3 + 1);
if (abs(w_dyn2 - w_expected2) / w_expected2 < 1e-10)
    fprintf('  PASS: dynamic hermiteWaist(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic hermiteWaist(z)\n');
    failed = failed + 1;
end

% testDynamicHermiteWaistX
hp_x = HermiteParameters(0, w0, lambda, 3, 0);
wx_dyn = hp_x.hermiteWaistX(z2);
wx_expected = hp_x.waist(z2) * sqrt(3 + 1);
if (abs(wx_dyn - wx_expected) / wx_expected < 1e-10)
    fprintf('  PASS: dynamic hermiteWaistX(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic hermiteWaistX(z)\n');
    failed = failed + 1;
end

% testDynamicHermiteWaistY
wy_dyn = hp_x.hermiteWaistY(z2);
wy_expected = hp_x.waist(z2) * sqrt(0 + 1);
if (abs(wy_dyn - wy_expected) / wy_expected < 1e-10)
    fprintf('  PASS: dynamic hermiteWaistY(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic hermiteWaistY(z)\n');
    failed = failed + 1;
end

% testHermiteComputationDelegation
x_test = linspace(-1, 1, 11);
[HG_shim, NHG_shim] = HermiteParameters.getHermiteSolutions(2, x_test);
[HG_direct, NHG_direct] = HermiteComputation.hermiteSolutions(2, x_test);
if (max(abs(HG_shim - HG_direct)) < 1e-12 && max(abs(NHG_shim - NHG_direct)) < 1e-12)
    fprintf('  PASS: HermiteParameters.getHermiteSolutions delegates to HermiteComputation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HermiteParameters.getHermiteSolutions shim mismatch\n');
    failed = failed + 1;
end

fprintf('\n=== HermiteParameters: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
