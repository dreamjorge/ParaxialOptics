% Compatible with GNU Octave and MATLAB
% Tests for LaguerreBeam (Phase 3 API: LaguerreBeam(w0, lambda, l, p))

addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'ParaxialBeams'));

fprintf('=== LaguerreBeam Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;
grid = GridUtils(64, 64, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();

lb = LaguerreBeam(w0, lambda, 1, 0);

% testFieldGeneration
field = lb.opticalField(X, Y, 0);
if (isequal(size(field), [64, 64]))
    fprintf('  PASS: field generation\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field generation\n');
    failed = failed + 1;
end

% testHigherOrderModes
lb_high = LaguerreBeam(w0, lambda, 2, 1);
field_high = lb_high.opticalField(X, Y, 0);
if (all(all(isfinite(field_high))))
    fprintf('  PASS: higher order modes\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher order modes\n');
    failed = failed + 1;
end

% testModeIndicesStored
if (lb.l == 1 && lb.p == 0)
    fprintf('  PASS: mode indices stored\n');
    passed = passed + 1;
else
    fprintf('  FAIL: mode indices stored\n');
    failed = failed + 1;
end

% testGetParameters
params = lb.getParameters(0.1);
if (abs(params.zCoordinate - 0.1) < 1e-15 && params.InitialWaist == w0)
    fprintf('  PASS: getParameters(z)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: getParameters(z)\n');
    failed = failed + 1;
end

% testValidFieldAtWaist
field_z0 = lb.opticalField(X, Y, 0);
if (all(all(isfinite(field_z0))))
    fprintf('  PASS: valid field at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: valid field at waist\n');
    failed = failed + 1;
end

% testDifferentLandP
lb_10 = LaguerreBeam(w0, lambda, 1, 0);
lb_01 = LaguerreBeam(w0, lambda, 0, 1);
field_10 = lb_10.opticalField(X, Y, 0);
field_01 = lb_01.opticalField(X, Y, 0);
if (isequal(size(field_10), size(field_01)))
    fprintf('  PASS: different l p valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different l p\n');
    failed = failed + 1;
end

% testL0P0Valid
lb_00 = LaguerreBeam(w0, lambda, 0, 0);
field_00 = lb_00.opticalField(X, Y, 0);
if (isequal(size(field_00), [64, 64]))
    fprintf('  PASS: l=0 p=0 valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: l=0 p=0\n');
    failed = failed + 1;
end

% testNegativeL
lb_neg = LaguerreBeam(w0, lambda, -1, 0);
field_neg = lb_neg.opticalField(X, Y, 0);
if (all(all(isfinite(field_neg))))
    fprintf('  PASS: negative l valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: negative l\n');
    failed = failed + 1;
end

% testHigherP
lb_p2 = LaguerreBeam(w0, lambda, 0, 2);
field_p2 = lb_p2.opticalField(X, Y, 0);
if (all(all(isfinite(field_p2))))
    fprintf('  PASS: higher p order valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher p order\n');
    failed = failed + 1;
end

% testPhaseVariation
field_prop = lb.opticalField(X, Y, 0.05);
params_prop = lb.getParameters(0.05);
if (params_prop.GouyPhase ~= 0)
    fprintf('  PASS: phase variation included\n');
    passed = passed + 1;
else
    fprintf('  FAIL: phase variation\n');
    failed = failed + 1;
end

% testAzimuthalPhase
[Theta, ~] = cart2pol(X, Y);
field_az = lb.opticalField(X, Y, 0);
theta_sample = Theta(32, 32);
phase_at_theta = angle(field_az(32,32));
if (abs(phase_at_theta - 1*theta_sample) < pi)
    fprintf('  PASS: azimuthal phase contribution\n');
    passed = passed + 1;
else
    fprintf('  FAIL: azimuthal phase\n');
    failed = failed + 1;
end

% testAtPropagation
field_p = lb.opticalField(X, Y, 0.1);
if (all(all(isfinite(field_p))))
    fprintf('  PASS: field at propagation valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field at propagation\n');
    failed = failed + 1;
end

% testCombinedLandP
lb_comb = LaguerreBeam(w0, lambda, 2, 3);
field_comb = lb_comb.opticalField(X, Y, 0);
if (all(all(isfinite(field_comb))))
    fprintf('  PASS: combined l p valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: combined l p\n');
    failed = failed + 1;
end

% testFieldAmplitude
lb_amp = LaguerreBeam(w0, lambda, 0, 0);
field_amp = lb_amp.opticalField(X, Y, 0);
max_amp = max(max(abs(field_amp)));
if (max_amp > 0)
    fprintf('  PASS: field amplitude positive\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field amplitude\n');
    failed = failed + 1;
end

% testWaistFromParameters
params_lb = lb.getParameters(0);
if (params_lb.Waist > 0)
    fprintf('  PASS: waist from parameters\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist from params\n');
    failed = failed + 1;
end

% testLaguerreWaistFormula
lp_dyn = LaguerreParameters(0, w0, lambda, 1, 0);
if (lp_dyn.LaguerreWaist > 0)
    fprintf('  PASS: Laguerre waist valid\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Laguerre waist\n');
    failed = failed + 1;
end

% testDifferentWavelengths
lb_l1 = LaguerreBeam(w0, 532e-9, 1, 0);
lb_l2 = LaguerreBeam(w0, 1064e-9, 1, 0);
f_l1  = lb_l1.opticalField(X, Y, 0);
f_l2  = lb_l2.opticalField(X, Y, 0);
if (all(all(isfinite(f_l1))) && all(all(isfinite(f_l2))))
    fprintf('  PASS: different wavelengths\n');
    passed = passed + 1;
else
    fprintf('  FAIL: different wavelengths\n');
    failed = failed + 1;
end

% testInitialWaistStored
if (lb.InitialWaist == w0)
    fprintf('  PASS: InitialWaist stored\n');
    passed = passed + 1;
else
    fprintf('  FAIL: InitialWaist stored\n');
    failed = failed + 1;
end

% testFieldAtDifferentZ
f_z1 = lb.opticalField(X, Y, 0.01);
f_z2 = lb.opticalField(X, Y, 0.1);
if (all(all(isfinite(f_z1))) && all(all(isfinite(f_z2))))
    fprintf('  PASS: field at different z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: field at different z\n');
    failed = failed + 1;
end

% testNegativeLWithP
lb_negp = LaguerreBeam(w0, lambda, -2, 1);
field_negp = lb_negp.opticalField(X, Y, 0);
if (all(all(isfinite(field_negp))))
    fprintf('  PASS: negative l with p\n');
    passed = passed + 1;
else
    fprintf('  FAIL: negative l with p\n');
    failed = failed + 1;
end

% testPhiPhaseAtWaist
lp_pw = LaguerreParameters(0, w0, lambda, 1, 1);
if (abs(lp_pw.PhiPhase) < 1e-10)
    fprintf('  PASS: PhiPhase at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: PhiPhase at waist\n');
    failed = failed + 1;
end

% testHigherLLargerWaist
lp_l1 = LaguerreParameters(0, w0, lambda, 1, 0);
lp_l2 = LaguerreParameters(0, w0, lambda, 2, 0);
if (lp_l2.LaguerreWaist > lp_l1.LaguerreWaist)
    fprintf('  PASS: higher l larger waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: higher l waist\n');
    failed = failed + 1;
end

% testModalGouyRelativePhase (LG10 vs LG00)
z_rel = pi * w0^2 / lambda;
psi_rel = atan2(z_rel, pi * w0^2 / lambda);
x_rel = 0.7 * w0;
y_rel = 0;
r_rel = abs(x_rel);
lg00_rel = LaguerreBeam(w0, lambda, 0, 0);
lg10_rel = LaguerreBeam(w0, lambda, 1, 0);
f00_rel = lg00_rel.opticalField(x_rel, y_rel, z_rel);
f10_rel = lg10_rel.opticalField(x_rel, y_rel, z_rel);
w_rel = lg00_rel.getParameters(z_rel).Waist;
amp_rel = sqrt(2) * r_rel / w_rel;
ratio_rel = f10_rel / (amp_rel * f00_rel);
phase_err_rel = angle(ratio_rel * exp(1i * psi_rel));
if (abs(phase_err_rel) < 1e-8)
    fprintf('  PASS: modal Gouy relative phase\n');
    passed = passed + 1;
else
    fprintf('  FAIL: modal Gouy relative phase\n');
    failed = failed + 1;
end

% testBeamName
if (strcmp(lb.beamName(), 'laguerre_1_0'))
    fprintf('  PASS: beamName\n');
    passed = passed + 1;
else
    fprintf('  FAIL: beamName\n');
    failed = failed + 1;
end

%% ===== XLaguerreBeam Tests =====

fprintf('\n--- XLaguerreBeam Tests ---\n');

% XLaguerreBeam modern constructor
xlb = XLaguerreBeam(w0, lambda, 1, 0);
if (xlb.InitialWaist == w0 && xlb.l == 1 && xlb.p == 0 && xlb.Lambda == lambda)
    fprintf('  PASS: XLaguerreBeam modern constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam modern constructor\n');
    failed = failed + 1;
end

% XLaguerreBeam field finite at waist
xlb_field = xlb.opticalField(X, Y, 0);
if (all(all(isfinite(xlb_field))) && isequal(size(xlb_field), [64, 64]))
    fprintf('  PASS: XLaguerreBeam field finite at waist\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam field finite at waist\n');
    failed = failed + 1;
end

% XLaguerreBeam field finite at propagation
xlb_zr = xlb.opticalField(X, Y, pi * w0^2 / lambda);
if (all(all(isfinite(xlb_zr))))
    fprintf('  PASS: XLaguerreBeam field finite at zr\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam field at zr\n');
    failed = failed + 1;
end

% XLaguerreBeam beamName format
if (strcmp(xlb.beamName(), 'xlaguerre_1_0'))
    fprintf('  PASS: XLaguerreBeam beamName\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam beamName (got %s)\n', xlb.beamName());
    failed = failed + 1;
end

% XLaguerreBeam getParameters
xlb_params = xlb.getParameters(0.05);
if (isa(xlb_params, 'GaussianParameters') && abs(xlb_params.zCoordinate - 0.05) < 1e-15)
    fprintf('  PASS: XLaguerreBeam getParameters\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam getParameters\n');
    failed = failed + 1;
end

% XLaguerreBeam isa ParaxialBeam
if (isa(xlb, 'ParaxialBeam'))
    fprintf('  PASS: XLaguerreBeam isa ParaxialBeam\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam isa ParaxialBeam\n');
    failed = failed + 1;
end

% XLaguerreBeam legacy constructor
lp_test = LaguerreParameters(0.01, w0, lambda, 2, 1);
r_leg = linspace(0, 5e-3, 21)';
theta_leg = zeros(21, 1);
xlb_leg = XLaguerreBeam(r_leg, theta_leg, lp_test);
if (~isempty(xlb_leg.OpticalField) && numel(xlb_leg.OpticalField) == numel(r_leg))
    fprintf('  PASS: XLaguerreBeam legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam legacy constructor\n');
    failed = failed + 1;
end

% XLaguerreBeam higher orders
xlb_high = XLaguerreBeam(w0, lambda, 2, 1);
xlb_high_field = xlb_high.opticalField(X, Y, 0);
if (all(all(isfinite(xlb_high_field))))
    fprintf('  PASS: XLaguerreBeam higher order modes\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam higher order modes\n');
    failed = failed + 1;
end

% XLaguerreBeam l=0 p=0 at axis (no inner regularization for l=0)
xlb_l0 = XLaguerreBeam(w0, lambda, 0, 0);
[TH_ax, R_ax] = cart2pol(X, Y);
R_center = R_ax(32, 32);  % r near 0
field_axis = xlb_l0.opticalField(X, Y, 0);
if (all(all(isfinite(field_axis))) && abs(field_axis(32,32)) > 0)
    fprintf('  PASS: XLaguerreBeam l=0 at axis finite and non-zero\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam l=0 at axis\n');
    failed = failed + 1;
end

% XLaguerreBeam l>0 inner regularization
xlb_vortex = XLaguerreBeam(w0, lambda, 2, 0);
field_vortex = xlb_vortex.opticalField(X, Y, 0);
if (all(all(isfinite(field_vortex))))
    fprintf('  PASS: XLaguerreBeam l>0 finite with inner regularization\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam l>0 regularization\n');
    failed = failed + 1;
end

% XLaguerreBeam different l and p combinations
xlb_10 = XLaguerreBeam(w0, lambda, 1, 0);
xlb_01 = XLaguerreBeam(w0, lambda, 0, 1);
field_10 = xlb_10.opticalField(X, Y, 0);
field_01 = xlb_01.opticalField(X, Y, 0);
if (isequal(size(field_10), size(field_01)) && ~isequaln(field_10, field_01))
    fprintf('  PASS: XLaguerreBeam different l p combinations distinct\n');
    passed = passed + 1;
else
    fprintf('  FAIL: XLaguerreBeam different l p\n');
    failed = failed + 1;
end

fprintf('\n=== LaguerreBeam: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
