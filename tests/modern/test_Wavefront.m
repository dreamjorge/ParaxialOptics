% test_Wavefront - Wavefront class tests
% Compatible with GNU Octave and MATLAB
%
% Run with: octave --no-gui --eval "run('tests/test_Wavefront.m')"
% Or: matlab -batch "run('tests/test_Wavefront.m')"

testDir = fileparts(mfilename('fullpath'));
repoRoot = fullfile(testDir, '..', '..');

% Canonical package namespace (+paraxial/) is resolved by adding its parent.
addpath(repoRoot);


% Utilities and legacy addons.
addpath(fullfile(repoRoot, 'ParaxialBeams'));
addpath(fullfile(repoRoot, 'ParaxialBeams', 'Addons'));

fprintf('=== Wavefront Test Suite ===\n\n');

% Test 1: Basic constructor
fprintf('Test 1: Constructor\n');
E = ones(256, 256) + 1i*ones(256, 256);
lambda = 632.8e-9;
wf = Wavefront(E, lambda);
assert(~isempty(wf.Field), 'Field should be stored');
assert(wf.Lambda == lambda, 'Lambda should be stored');
assert(wf.Nx == 256, 'Nx should be 256');
assert(wf.Ny == 256, 'Ny should be 256');
fprintf('  PASS: Constructor works\n\n');

% Test 2: Get Intensity
fprintf('Test 2: getIntensity\n');
I = wf.getIntensity();
assert(size(I,1) == 256 && size(I,2) == 256, 'Intensity size mismatch');
is_non_neg = all(I(:) >= 0);
assert(is_non_neg, 'Intensity should be non-negative');
fprintf('  PASS: getIntensity returns |E|^2\n\n');

% Test 3: Get Phase
fprintf('Test 3: getPhase\n');
phi = wf.getPhase();
assert(size(phi,1) == 256 && size(phi,2) == 256, 'Phase size mismatch');
in_range = all(phi(:) >= -pi - 1e-10 & phi(:) <= pi + 1e-10);
assert(in_range, 'Phase should be in [-pi, pi]');
fprintf('  PASS: getPhase returns wrapped phase\n\n');

% Test 4: Zernike Z1 = 1 (Piston)
fprintf('Test 4: Zernike Z1 (Piston)\n');
rho = 0.5 * ones(10, 10);
theta = zeros(10, 10);
Z1 = ZernikeUtils.zernike(1, rho, theta);
z1_ok = all(abs(Z1(:) - 1) < 1e-10);
assert(z1_ok, 'Z1 should be 1');
fprintf('  PASS: Z1 = 1 (Piston)\n\n');

% Test 5: Zernike Z2 (Tilt X) formula
fprintf('Test 5: Zernike Z2 (Tilt X)\n');
rho = ones(10, 10);
theta = zeros(10, 10);  % cos(0) = 1
Z2 = ZernikeUtils.zernike(2, rho, theta);
expected = 2 * 1 * 1;  % 2*rho*cos(theta) = 2*1*1
z2_ok = all(abs(Z2(:) - expected) < 1e-10);
assert(z2_ok, 'Z2 should be 2');
fprintf('  PASS: Z2 = 2*rho*cos(theta)\n\n');

% Test 6: Zernike Z4 (Defocus) formula
fprintf('Test 6: Zernike Z4 (Defocus)\n');
rho = ones(10, 10);
theta = zeros(10, 10);
Z4 = ZernikeUtils.zernike(4, rho, theta);
expected = sqrt(3) * (2*1 - 1);  % sqrt(3)*(2*rho^2 - 1)
z4_ok = all(abs(Z4(:) - expected) < 1e-10);
assert(z4_ok, 'Z4 should be sqrt(3)');
fprintf('  PASS: Z4 = sqrt(3)*(2*rho^2 - 1)\n\n');

% Test 7: Zernike name lookup
fprintf('Test 7: Zernike names\n');
assert(strcmp(ZernikeUtils.zernikeName(1), 'Piston'), 'Z1 name');
assert(strcmp(ZernikeUtils.zernikeName(2), 'Tilt X'), 'Z2 name');
assert(strcmp(ZernikeUtils.zernikeName(4), 'Defocus'), 'Z4 name');
fprintf('  PASS: Zernike names correct\n\n');

% Test 8: Gaussian beam at waist (planar wavefront)
fprintf('Test 8: Gaussian beam at waist - planar wavefront\n');
beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);
grid = GridUtils(256, 256, 1e-3, 1e-3);
[X, Y] = grid.create2DGrid();
E = beam.opticalField(X, Y, 0);  % z=0: planar wavefront
wf_gauss = Wavefront(E, 632.8e-9, grid);
coeffs = wf_gauss.fitZernike(36);
% At waist (z=0), wavefront should be nearly flat (all coefficients small)
% Piston term should be ~0 for ideal planar wavefront at reference
all_small = all(abs(coeffs) < 0.5);
assert(all_small, 'All Zernike terms should be small for planar wavefront');
fprintf('  PASS: Gaussian at waist gives nearly planar wavefront\n\n');

% Test 9: Round-trip fit -> reconstruct
fprintf('Test 9: Round-trip fit/reconstruct residual\n');
% Create test grid
Nx = 50; Ny = 50;
dx = 1e-3/Nx; dy = 1e-3/Ny;
[X, Y] = meshgrid((-Nx/2:Nx/2-1)*dx, (-Ny/2:Ny/2-1)*dy);
maxR = min(1e-3/2, 1e-3/2);
rho_test = min(1, sqrt(X.^2 + Y.^2) / maxR);  % normalized to <= 1
theta_test = atan2(Y, X);

% Generate synthetic phase with known coefficients
test_coeffs = zeros(36, 1);
test_coeffs(4) = 0.5;  % Defocus only
test_coeffs(7) = 0.3;  % Coma X
phi_test = ZernikeUtils.zernikeMatrix(rho_test, theta_test, 36) * test_coeffs;
phi_test = reshape(phi_test, Ny, Nx);

wf_test = Wavefront(exp(1i * phi_test), 632.8e-9);
% Use same grid for the wavefront
wf_test.dx = dx; wf_test.dy = dy;
wf_test.Dx = 1e-3; wf_test.Dy = 1e-3;

residual = wf_test.zernikeResidual(36);
assert(residual < 0.1, sprintf('Residual should be small, got %e', residual));
fprintf('  PASS: Round-trip residual < 0.1\n\n');

% Test 10: RMS and PV calculations
fprintf('Test 10: RMS and PV calculations\n');
phi_flat = zeros(256, 256);
phi_flat(:) = 0.5;
wf_flat = Wavefront(exp(1i * phi_flat), 632.8e-9);
rms = wf_flat.computeRMS();
pv = wf_flat.computePV();
assert(abs(rms - 0.5) < 1e-10, sprintf('RMS should be 0.5, got %f', rms));
assert(abs(pv) < 1e-10, sprintf('PV should be 0 for constant phase, got %f', pv));
fprintf('  PASS: RMS and PV correct for constant phase\n\n');

% Test 11: Strehl calculation
fprintf('Test 11: Strehl calculation\n');
sigma = 0.1;  % phase RMS in radians (flat phase = 0.1 rad)
phi_flat = zeros(256, 256) + sigma;
wf_strehl = Wavefront(exp(1i * phi_flat), 632.8e-9);
strehl = wf_strehl.computeStrehl();
% Maréchal: Strehl ~ exp(-sigma^2) where sigma is phase RMS in radians
expected_strehl = exp(-sigma^2);
assert(abs(strehl - expected_strehl) < 1e-10, ...
    sprintf('Strehl should be ~%.3f, got %.3f', expected_strehl, strehl));
fprintf('  PASS: Strehl approx exp(-sigma^2) where sigma is phase RMS in rad\n\n');

fprintf('=== All Tests Passed ===\n');
