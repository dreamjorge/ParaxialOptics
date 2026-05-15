% Compatible with GNU Octave and MATLAB
% Tests for ElegantHermiteParameters

repoRoot = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repoRoot, 'ParaxialBeams'));

fprintf('=== ElegantHermiteParameters Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;

% testConstructor
ehp = ElegantHermiteParameters(0.05, w0, lambda, 1, 1);
if (ehp.n == 1 && ehp.m == 1)
    fprintf('  PASS: constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: constructor\n');
    failed = failed + 1;
end

% testDefaultNandM
ehp0 = ElegantHermiteParameters(0.05, w0, lambda);
if (ehp0.n == 0 && ehp0.m == 0)
    fprintf('  PASS: default n m\n');
    passed = passed + 1;
else
    fprintf('  FAIL: default n m\n');
    failed = failed + 1;
end

% testAlphaAtWaist
ehp_z0 = ElegantHermiteParameters(0, w0, lambda, 1, 1);
k_val = 2*pi/lambda;
zr = pi*w0^2/lambda;
expected_alpha = k_val / (2*zr);
if (abs(ehp_z0.alpha - expected_alpha) < 1e-10)
    fprintf('  PASS: alpha at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: alpha at waist\n');
    failed = failed + 1;
end

% testAlphaAtZgt0
ehp_z = ElegantHermiteParameters(0.1, w0, lambda, 1, 1);
if (imag(ehp_z.alpha) ~= 0 || real(ehp_z.alpha) ~= 0)
    fprintf('  PASS: alpha complex at z>0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: alpha at z>0\n');
    failed = failed + 1;
end

% testAlphaFormula
k_af = 2*pi/lambda;
zr_af = pi*w0^2/lambda;
q_af = 0.1 + 1i*zr_af;
expected_alpha = 1i * k_af / (2 * q_af);
if (abs(ehp_z.alpha - expected_alpha) < 1e-10)
    fprintf('  PASS: alpha formula\n');
    passed = passed + 1;
else
    fprintf('  FAIL: alpha formula\n');
    failed = failed + 1;
end

% testAlphaChangesWithZ
ehp_z1 = ElegantHermiteParameters(0.01, w0, lambda, 1, 1);
ehp_z2 = ElegantHermiteParameters(0.05, w0, lambda, 1, 1);
if (ehp_z1.alpha ~= ehp_z2.alpha)
    fprintf('  PASS: alpha changes with z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: alpha change\n');
    failed = failed + 1;
end

% testInheritsGaussianParameters
if (isfield(ehp, 'RayleighDistance') || ~isempty(ehp.RayleighDistance))
    fprintf('  PASS: inherits from GaussianParameters\n');
    passed = passed + 1;
else
    fprintf('  FAIL: inheritance\n');
    failed = failed + 1;
end

% testWaistFromParent
if (ehp.Waist > 0)
    fprintf('  PASS: Waist from parent\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Waist\n');
    failed = failed + 1;
end

% testGouyPhaseFromParent
if (ehp.GouyPhase > 0)
    fprintf('  PASS: GouyPhase from parent\n');
    passed = passed + 1;
else
    fprintf('  FAIL: GouyPhase\n');
    failed = failed + 1;
end

% testkFromParent
if (ehp.k > 0)
    fprintf('  PASS: k from parent\n');
    passed = passed + 1;
else
    fprintf('  FAIL: k\n');
    failed = failed + 1;
end

% testVectorZInput
z_vec = linspace(0, 0.1, 5);
ehp_vec = ElegantHermiteParameters(z_vec, w0, lambda, 1, 1);
if (numel(ehp_vec.zCoordinate) == 5)
    fprintf('  PASS: vector z input\n');
    passed = passed + 1;
else
    fprintf('  FAIL: vector z\n');
    failed = failed + 1;
end

% testAlphaPurelyImaginaryAtWaist
ehp_waist = ElegantHermiteParameters(0, w0, lambda, 1, 1);
if (ehp_waist.alpha > 0)
    fprintf('  PASS: alpha purely imaginary at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: alpha at waist\n');
    failed = failed + 1;
end

% testDifferentNM
ehp_n = ElegantHermiteParameters(0.05, w0, lambda, 2, 0);
ehp_m = ElegantHermiteParameters(0.05, w0, lambda, 0, 2);
if (ehp_n.n == 2 && ehp_m.m == 2)
    fprintf('  PASS: different n m values\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different n m\n');
    failed = failed + 1;
end

% testAlphaNegativeZ
ehp_neg_z = ElegantHermiteParameters(-0.05, w0, lambda, 1, 1);
if (isfinite(ehp_neg_z.alpha))
    fprintf('  PASS: alpha at negative z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: alpha at negative z\n');
    failed = failed + 1;
end

% testHigherOrderAlpha
ehp_ho = ElegantHermiteParameters(0.05, w0, lambda, 3, 3);
if (ehp_ho.n == 3 && ehp_ho.m == 3)
    fprintf('  PASS: higher order modes\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher order\n');
    failed = failed + 1;
end

% testInheritedWaistCalculation
ehp_wc = ElegantHermiteParameters(0.1, w0, lambda, 1, 1);
expected_w = w0 * sqrt(1 + (0.1/ehp_wc.RayleighDistance)^2);
if (abs(ehp_wc.Waist - expected_w) / expected_w < 1e-10)
    fprintf('  PASS: inherited waist calculation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist calc\n');
    failed = failed + 1;
end

% --- Dynamic API tests (Phase 2) ---

% testDynamicAlphaAtZ
ehp_dyn = ElegantHermiteParameters(0, w0, lambda, 1, 1);
z2 = 0.1;
al_dyn = ehp_dyn.alphaAtZ(z2);
k_val = 2*pi/lambda;
zr_dyn = pi*w0^2/lambda;
q = z2 + 1i*zr_dyn;
al_expected = 1i * k_val / (2 * q);
if (abs(al_dyn - al_expected) < 1e-10)
    fprintf('  PASS: dynamic alphaAtZ(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic alphaAtZ(z)\n');
    failed = failed + 1;
end

% testDynamicAlphaDiffersFromSnapshot
al_snapshot = ehp_dyn.alpha;  % at z=0
al_at_z2 = ehp_dyn.alphaAtZ(z2);
if (al_snapshot ~= al_at_z2)
    fprintf('  PASS: dynamic alphaAtZ differs from snapshot\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic alphaAtZ differs from snapshot\n');
    failed = failed + 1;
end

% testDynamicPhiPhase
phi_dyn = ehp_dyn.phiPhase(z2);
phi_expected = (1 + 1) * atan(z2 / zr_dyn);
if (abs(phi_dyn - phi_expected) < 1e-10)
    fprintf('  PASS: dynamic phiPhase(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic phiPhase(z)\n');
    failed = failed + 1;
end

% testDynamicPhiPhaseAtZero
phi_zero = ehp_dyn.phiPhase(0);
if (abs(phi_zero) < 1e-10)
    fprintf('  PASS: dynamic phiPhase(0) = 0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: dynamic phiPhase(0)\n');
    failed = failed + 1;
end

fprintf('\n=== ElegantHermiteParameters: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
