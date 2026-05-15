% Compatible with GNU Octave and MATLAB
% Tests for BeamComputation - stateless formula utilities
%
% These tests verify that the computation layer produces numerically
% correct results matching the physical formulas for Gaussian beams.


fprintf('=== BeamComputation Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;
z = 0.05;
zr = pi * w0^2 / lambda;

% =====================================================================
% Core formula tests
% =====================================================================

% testRayleighDistance
zr_computed = BeamComputation.rayleighDistance(w0, lambda);
zr_expected = pi * w0^2 / lambda;
if (abs(zr_computed - zr_expected) / zr_expected < 1e-10)
    fprintf('  PASS: rayleighDistance formula\n');
    passed = passed + 1;
else
    fprintf('  FAIL: rayleighDistance formula (got %g, expected %g)\n', zr_computed, zr_expected);
    failed = failed + 1;
end

% testWaveNumber
k_computed = BeamComputation.waveNumber(lambda);
k_expected = 2 * pi / lambda;
if (abs(k_computed - k_expected) / k_expected < 1e-10)
    fprintf('  PASS: waveNumber formula\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waveNumber formula (got %g, expected %g)\n', k_computed, k_expected);
    failed = failed + 1;
end

% testWaistAtOrigin
w_z0 = BeamComputation.waist(w0, 0, lambda, zr);
if (abs(w_z0 - w0) / w0 < 1e-12)
    fprintf('  PASS: waist at origin w(0)=w0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist at origin (got %g, expected %g)\n', w_z0, w0);
    failed = failed + 1;
end

% testWaistAtRayleigh
w_zr = BeamComputation.waist(w0, zr, lambda, zr);
expected_at_zr = w0 * sqrt(2);
if (abs(w_zr - expected_at_zr) / expected_at_zr < 1e-10)
    fprintf('  PASS: waist at Rayleigh w(zR)=w0*sqrt(2)\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist at Rayleigh (got %g, expected %g)\n', w_zr, expected_at_zr);
    failed = failed + 1;
end

% testWaistIncreasesWithZ
w_half_zr = BeamComputation.waist(w0, zr/2, lambda, zr);
w_full_zr = BeamComputation.waist(w0, zr, lambda, zr);
if (w_full_zr > w_half_zr)
    fprintf('  PASS: waist increases with z\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist does not increase with z\n');
    failed = failed + 1;
end

% testGouyPhaseAtOrigin
psi_z0 = BeamComputation.gouyPhase(0, zr);
if (abs(psi_z0) < 1e-15)
    fprintf('  PASS: Gouy phase at origin is zero\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Gouy phase at origin (got %g, expected 0)\n', psi_z0);
    failed = failed + 1;
end

% testGouyPhasePositiveForPositiveZ
psi_pos = BeamComputation.gouyPhase(z, zr);
if (psi_pos > 0 && psi_pos < pi/2)
    fprintf('  PASS: Gouy phase positive for z>0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Gouy phase for z>0 (got %g)\n', psi_pos);
    failed = failed + 1;
end

% testGouyPhaseNegativeForNegativeZ
psi_neg = BeamComputation.gouyPhase(-z, zr);
if (psi_neg < 0 && psi_neg > -pi/2)
    fprintf('  PASS: Gouy phase negative for z<0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Gouy phase for z<0 (got %g)\n', psi_neg);
    failed = failed + 1;
end

% testRadiusOfCurvatureAtOrigin
R_z0 = BeamComputation.radiusOfCurvature(0, zr);
if (isinf(R_z0))
    fprintf('  PASS: radius of curvature at origin is Inf\n');
    passed = passed + 1;
else
    fprintf('  FAIL: radius of curvature at origin (got %g, expected Inf)\n', R_z0);
    failed = failed + 1;
end

% testRadiusOfCurvaturePositiveForZNotZero
R_pos = BeamComputation.radiusOfCurvature(z, zr);
if (R_pos > 0)
    fprintf('  PASS: radius of curvature positive for z>0\n');
    passed = passed + 1;
else
    fprintf('  FAIL: radius of curvature for z>0 (got %g)\n', R_pos);
    failed = failed + 1;
end

% testComplexBeamParameter (q = z + i*zR)
k = BeamComputation.waveNumber(lambda);
q = BeamComputation.complexBeamParameter(z, zr, k);
q_expected = z + 1i * zr;
if (abs(q - q_expected) < 1e-10)
    fprintf('  PASS: complex beam parameter q = z + i*zR\n');
    passed = passed + 1;
else
    fprintf('  FAIL: complex beam parameter q (got %g%+gi, expected %g%+gi)\n', ...
        real(q), imag(q), real(q_expected), imag(q_expected));
    failed = failed + 1;
end

% testComplexAlpha (alpha = i*k/(2*q))
alpha = BeamComputation.complexAlpha(z, zr, k);
q_val = z + 1i * zr;
alpha_expected = 1i * k / (2 * q_val);
if (abs(alpha - alpha_expected) < 1e-6)
    fprintf('  PASS: complex alpha formula\n');
    passed = passed + 1;
else
    fprintf('  FAIL: complex alpha (got %g%+gi, expected %g%+gi)\n', ...
        real(alpha), imag(alpha), real(alpha_expected), imag(alpha_expected));
    failed = failed + 1;
end

% =====================================================================
% Vectorized inputs
% =====================================================================

% testWaistVectorized
z_vec = linspace(0, 0.1, 10);
w_vec = BeamComputation.waist(w0, z_vec, lambda, zr);
if (numel(w_vec) == 10 && all(w_vec >= w0))
    fprintf('  PASS: waist vectorized over z array\n');
    passed = passed + 1;
else
    fprintf('  FAIL: waist vectorized (size %d, expected 10)\n', numel(w_vec));
    failed = failed + 1;
end

% testGouyPhaseVectorized
psi_vec = BeamComputation.gouyPhase(z_vec, zr);
if (numel(psi_vec) == 10 && all(psi_vec >= 0))
    fprintf('  PASS: gouyPhase vectorized over z array\n');
    passed = passed + 1;
else
    fprintf('  FAIL: gouyPhase vectorized (size %d, expected 10)\n', numel(psi_vec));
    failed = failed + 1;
end

% =====================================================================
% Summary
% =====================================================================

fprintf('\n=== BeamComputation Summary ===\n');
fprintf('Tests Pasados: %d\n', passed);
fprintf('Tests Fallados: %d\n', failed);

if failed > 0
    fprintf('ESTADO: FALLO\n');
else
    fprintf('ESTADO: EXITO\n');
end
