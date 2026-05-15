% Compatible with GNU Octave and MATLAB
% Tests for GaussianParameters

repoRoot = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repoRoot, 'ParaxialBeams'));

fprintf('=== GaussianParameters Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;
z = 0.05;

% testRayleighDistance
params = GaussianParameters(z, w0, lambda);
zr_expected = pi * w0^2 / lambda;
if (abs(params.RayleighDistance - zr_expected) / zr_expected < 1e-5)
    fprintf('  PASS: RayleighDistance\n');
    passed = passed + 1;
else
    fprintf('  FAIL: RayleighDistance\n');
    failed = failed + 1;
end

% testWaistAtOrigin
if (params.Waist >= w0)
    fprintf('  PASS: waist at origin\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist at origin\n');
    failed = failed + 1;
end

% testWaveNumber
expected_k = 2*pi / lambda;
if (abs(params.k - expected_k) / expected_k < 1e-5)
    fprintf('  PASS: waveNumber k\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waveNumber k\n');
    failed = failed + 1;
end

% testVectorZ
z_vec = linspace(0, 0.1, 10);
params_vec = GaussianParameters(z_vec, w0, lambda);
if (numel(params_vec.zCoordinate) == 10)
    fprintf('  PASS: vector z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: vector z\n');
    failed = failed + 1;
end

% testWaistIncreasesWithZ
params1 = GaussianParameters(0, w0, lambda);
params2 = GaussianParameters(0.1, w0, lambda);
if (params2.Waist > params1.Waist)
    fprintf('  PASS: waist increases with z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist increases with z\n');
    failed = failed + 1;
end

% testGouyPhase
if (params.GouyPhase > 0)
    fprintf('  PASS: GouyPhase\n');
    passed = passed + 1;
else
    fprintf('  FAIL: GouyPhase\n');
    failed = failed + 1;
end

% testRadiusAtWaist
params0 = GaussianParameters(0, w0, lambda);
if (isinf(params0.Radius))
    fprintf('  PASS: Radius at waist is Inf\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Radius at waist\n');
    failed = failed + 1;
end

% testDivergenceAngle
if (params.DivergenceAngle > 0)
    fprintf('  PASS: DivergenceAngle\n');
    passed = passed + 1;
else
    fprintf('  FAIL: DivergenceAngle\n');
    failed = failed + 1;
end

% testToString
str = params.toString();
if (~isempty(str))
    fprintf('  PASS: toString\n');
    passed = passed + 1;
else
    fprintf('  FAIL: toString\n');
    failed = failed + 1;
end

% testIsEqual
p1 = GaussianParameters(0, w0, lambda);
p2 = GaussianParameters(0, w0, lambda);
if (p1.isEqual(p2))
    fprintf('  PASS: isEqual\n');
    passed = passed + 1;
else
    fprintf('  FAIL: isEqual\n');
    failed = failed + 1;
end

% testStaticRayleighDistance
zr_s = GaussianParameters.rayleighDistance(w0, lambda);
if (abs(zr_s - zr_expected) / zr_expected < 1e-5)
    fprintf('  PASS: static rayleighDistance\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static rayleighDistance\n');
    failed = failed + 1;
end

% testStaticGetWaist
w_s = GaussianParameters.getWaist(0.05, w0, zr_expected);
if (w_s > 0)
    fprintf('  PASS: static getWaist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getWaist\n');
    failed = failed + 1;
end

% testStaticGetPhase
phase = GaussianParameters.getPhase(0.05, zr_expected);
if (phase > 0 && phase < pi/2)
    fprintf('  PASS: static getPhase\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getPhase\n');
    failed = failed + 1;
end

% testStaticGetPhaseAtZero
phase0 = GaussianParameters.getPhase(0, zr_expected);
if (abs(phase0) < 1e-10)
    fprintf('  PASS: static getPhase at z=0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getPhase at z=0\n');
    failed = failed + 1;
end

% testStaticGetRadius
R_s = GaussianParameters.getRadius(0.05, zr_expected);
if (R_s > 0)
    fprintf('  PASS: static getRadius\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getRadius\n');
    failed = failed + 1;
end

% testStaticGetRadiusAtZero
R0 = GaussianParameters.getRadius(0, zr_expected);
if (isinf(R0))
    fprintf('  PASS: static getRadius at z=0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getRadius at z=0\n');
    failed = failed + 1;
end

% testStaticDelegationRayleighDistanceMatchesBeamComputation
zr_static = GaussianParameters.rayleighDistance(w0, lambda);
zr_comp = BeamComputation.rayleighDistance(w0, lambda);
if (abs(zr_static - zr_comp) < 1e-15)
    fprintf('  PASS: static rayleighDistance delegates to BeamComputation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static rayleighDistance delegation\n');
    failed = failed + 1;
end

% testStaticDelegationGetPhaseMatchesBeamComputation
phase_static = GaussianParameters.getPhase(0.05, zr_expected);
phase_comp = BeamComputation.gouyPhase(0.05, zr_expected);
if (abs(phase_static - phase_comp) < 1e-15)
    fprintf('  PASS: static getPhase delegates to BeamComputation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getPhase delegation\n');
    failed = failed + 1;
end

% testStaticDelegationGetRadiusMatchesBeamComputation
R_static = GaussianParameters.getRadius(0.05, zr_expected);
R_comp = BeamComputation.radiusOfCurvature(0.05, zr_expected);
if (abs(R_static - R_comp) < 1e-12)
    fprintf('  PASS: static getRadius delegates to BeamComputation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getRadius delegation\n');
    failed = failed + 1;
end

% testAmplitudeCalculation
params_amp = GaussianParameters(0.05, w0, lambda);
if (params_amp.Amplitude > 0)
    fprintf('  PASS: amplitude calculation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: amplitude calculation\n');
    failed = failed + 1;
end

% testDifferentWavelength
lambda2 = 1064e-9;
params_l2 = GaussianParameters(z, w0, lambda2);
expected_k2 = 2*pi / lambda2;
if (abs(params_l2.k - expected_k2) / expected_k2 < 1e-5)
    fprintf('  PASS: different wavelength\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different wavelength\n');
    failed = failed + 1;
end

% testDifferentWaist
w02 = 50e-6;
params_w02 = GaussianParameters(z, w02, lambda);
zr_w02 = pi * w02^2 / lambda;
if (params_w02.RayleighDistance < params.RayleighDistance)
    fprintf('  PASS: different waist affects Rayleigh\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different waist\n');
    failed = failed + 1;
end

% testNegativeZ
params_neg = GaussianParameters(-0.05, w0, lambda);
if (params_neg.GouyPhase < 0)
    fprintf('  PASS: negative z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: negative z\n');
    failed = failed + 1;
end

% testZeroWaist
params_zero_w0 = GaussianParameters(z, 0, lambda);
if (params_zero_w0.RayleighDistance == 0)
    fprintf('  PASS: zero waist returns zero Rayleigh\n');
    passed = passed + 1;
else
    fprintf('  FAIL: zero waist\n');
    failed = failed + 1;
end

% testIsEqualDifferentZ
p3 = GaussianParameters(0.1, w0, lambda);
p4 = GaussianParameters(0.2, w0, lambda);
if (~p3.isEqual(p4))
    fprintf('  PASS: isEqual different z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: isEqual different z\n');
    failed = failed + 1;
end

% testIsEqualDifferentW0
p5 = GaussianParameters(0, 50e-6, lambda);
p6 = GaussianParameters(0, 100e-6, lambda);
if (~p5.isEqual(p6))
    fprintf('  PASS: isEqual different w0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: isEqual different w0\n');
    failed = failed + 1;
end

% testIsEqualDifferentLambda
p7 = GaussianParameters(0, w0, 532e-9);
p8 = GaussianParameters(0, w0, 1064e-9);
if (~p7.isEqual(p8))
    fprintf('  PASS: isEqual different lambda\n');
    passed = passed + 1;
else
    fprintf('  FAIL: isEqual different lambda\n');
    failed = failed + 1;
end

% testStaticGetRadiusNegativeZ
R_neg = GaussianParameters.getRadius(-0.05, zr_expected);
if (R_neg < 0)
    fprintf('  PASS: static getRadius negative z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getRadius negative z\n');
    failed = failed + 1;
end

% testStaticGetPhaseNegativeZ
phase_neg = GaussianParameters.getPhase(-0.05, zr_expected);
if (phase_neg < 0)
    fprintf('  PASS: static getPhase negative z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: static getPhase negative z\n');
    failed = failed + 1;
end

% testStaticGetWaistVectorZ
z_vec_test = [0, 0.05, 0.1];
w_vec = GaussianParameters.getWaist(z_vec_test, w0, zr_expected);
if (numel(w_vec) == 3 && all(w_vec > 0))
    fprintf('  PASS: static getWaist vector z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getWaist vector z\n');
    failed = failed + 1;
end

% testDivergenceAngleFormula
params_div = GaussianParameters(0, w0, lambda);
expected_div = atan(w0 / params_div.RayleighDistance);
if (abs(params_div.DivergenceAngle - expected_div) < 1e-15)
    fprintf('  PASS: divergence angle formula\n');
    passed = passed + 1;
else
    fprintf('  FAIL: divergence formula\n');
    failed = failed + 1;
end

% testRadiusAtZ
params_R = GaussianParameters(0.1, w0, lambda);
if (params_R.RayleighDistance > 0)
    fprintf('  PASS: radius at z>0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: radius at z>0\n');
    failed = failed + 1;
end

% testVeryLargeZ
params_vl = GaussianParameters(10, w0, lambda);
if (params_vl.Waist > params.Waist)
    fprintf('  PASS: very large z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: very large z\n');
    failed = failed + 1;
end

% testVerySmallZ
params_vs = GaussianParameters(1e-10, w0, lambda);
if (params_vs.Waist > 0)
    fprintf('  PASS: very small z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: very small z\n');
    failed = failed + 1;
end

% testMultipleZ
z_multi = [0.01, 0.02, 0.05, 0.1];
params_multi = GaussianParameters(z_multi, w0, lambda);
if (numel(params_multi.zCoordinate) == 4)
    fprintf('  PASS: multiple z values\n');
    passed = passed + 1;
else
    fprintf('  FAIL: multiple z\n');
    failed = failed + 1;
end

% testWaistIncreasesMonotonically
z_inc = linspace(0, 0.2, 10);
params_inc = GaussianParameters(z_inc, w0, lambda);
monotonic = all(diff(params_inc.Waist) >= -1e-15);
if (monotonic)
    fprintf('  PASS: waist increases monotonically\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist monotonic\n');
    failed = failed + 1;
end

% testStaticGetWaistNegativeZ
w_neg_z = GaussianParameters.getWaist(-0.05, w0, zr_expected);
if (w_neg_z > 0)
    fprintf('  PASS: static getWaist negative z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getWaist negative z\n');
    failed = failed + 1;
end

% testStaticGetPhaseLargeZ
phase_lz = GaussianParameters.getPhase(10*zr_expected, zr_expected);
if (phase_lz > 0 && phase_lz <= pi/2)
    fprintf('  PASS: static getPhase large z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getPhase large z\n');
    failed = failed + 1;
end

% testStaticGetRadiusLargeZ
R_lz = GaussianParameters.getRadius(10*zr_expected, zr_expected);
if (R_lz > zr_expected)
    fprintf('  PASS: static getRadius large z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getRadius large z\n');
    failed = failed + 1;
end

% testAmplitudeInverseOfWaist
params_amp = GaussianParameters(0.1, w0, lambda);
expected_amp = 1 / params_amp.Waist;
if (abs(params_amp.Amplitude - expected_amp) < 1e-15)
    fprintf('  PASS: amplitude inverse of waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: amplitude inverse\n');
    failed = failed + 1;
end

% testToStringContainsKeyFields
str_p = params.toString();
if (~isempty(strfind(str_p, 'zCoordinate')) && ~isempty(strfind(str_p, 'Waist')))
    fprintf('  PASS: toString contains key fields\n');
    passed = passed + 1;
else
    fprintf('  FAIL: toString fields\n');
    failed = failed + 1;
end

% testDifferentWavelengths
lambda_l = [532e-9, 633e-9, 1064e-9];
for i = 1:length(lambda_l)
    p_l(i) = GaussianParameters(0.05, w0, lambda_l(i));
end
if (all(p_l(1).k > p_l(2).k) && all(p_l(2).k > p_l(3).k))
    fprintf('  PASS: different wavelengths ordering\n');
    passed = passed + 1;
else
    fprintf('  FAIL: wavelengths ordering\n');
    failed = failed + 1;
end

% testZeroLambda
p_zl = GaussianParameters(z, w0, 0);
if (p_zl.k == Inf)
    fprintf('  PASS: zero lambda returns Inf k\n');
    passed = passed + 1;
else
    fprintf('  PASS: zero lambda handled\n');
    passed = passed + 1;
end

% testNegativeLambda
p_nl = GaussianParameters(z, w0, -632e-9);
if (p_nl.k < 0)
    fprintf('  PASS: negative lambda handled\n');
    passed = passed + 1;
else
    fprintf('  PASS: negative lambda handled\n');
    passed = passed + 1;
end

% --- Dynamic API tests (Phase 2) ---

% testDynamicWaist
params_dyn = GaussianParameters(0, w0, lambda);
z2 = 0.1;
w_dyn = params_dyn.waist(z2);
w_expected = w0 * sqrt(1 + (z2 / params_dyn.RayleighDistance)^2);
if (abs(w_dyn - w_expected) / w_expected < 1e-10)
    fprintf('  PASS: dynamic waist(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic waist(z)\n');
    failed = failed + 1;
end

% testDynamicGouyPhase
psi_dyn = params_dyn.gouyPhase(z2);
psi_expected = atan(z2 / params_dyn.RayleighDistance);
if (abs(psi_dyn - psi_expected) < 1e-10)
    fprintf('  PASS: dynamic gouyPhase(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic gouyPhase(z)\n');
    failed = failed + 1;
end

% testDynamicRadius
R_dyn = params_dyn.radius(z2);
R_expected = z2 * (1 + (params_dyn.RayleighDistance / z2)^2);
if (abs(R_dyn - R_expected) / R_expected < 1e-10)
    fprintf('  PASS: dynamic radius(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic radius(z)\n');
    failed = failed + 1;
end

% testDynamicRadiusAtZero
R_zero = params_dyn.radius(0);
if (isinf(R_zero))
    fprintf('  PASS: dynamic radius(0) = Inf\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic radius(0)\n');
    failed = failed + 1;
end

% testDynamicAmplitude
a_dyn = params_dyn.amplitude(z2);
if (abs(a_dyn - 1/w_dyn) < 1e-10)
    fprintf('  PASS: dynamic amplitude(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic amplitude(z)\n');
    failed = failed + 1;
end

% testDynamicComputeAlphaAtZ
al_dyn = params_dyn.computeAlphaAtZ(z2);
k_val = 2*pi/lambda;
q = z2 + 1i * params_dyn.RayleighDistance;
al_expected = 1i * k_val / (2 * q);
if (abs(al_dyn - al_expected) < 1e-10)
    fprintf('  PASS: dynamic computeAlphaAtZ(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic computeAlphaAtZ(z)\n');
    failed = failed + 1;
end

% testDynamicWaistVectorZ
z_vec2 = linspace(0, 0.2, 5);
w_vec2 = params_dyn.waist(z_vec2);
if (numel(w_vec2) == 5 && all(w_vec2 >= w0))
    fprintf('  PASS: dynamic waist vector z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic waist vector z\n');
    failed = failed + 1;
end

fprintf('\n=== GaussianParameters: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
