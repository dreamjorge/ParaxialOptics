% Compatible with GNU Octave and MATLAB
% Legacy constructor compatibility tests for modern beam classes.

repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(repoRoot);
setpaths();

fprintf('=== Legacy Beam Constructor Compatibility Tests ===\n\n');
passed = 0;
failed = 0;

w0 = 100e-6;
lambda = 632.8e-9;
z = 0.01;

x = linspace(-3e-4, 3e-4, 41);
[X, Y] = meshgrid(x, x);
[TH, R] = cart2pol(X, Y);

% testGaussianLegacyLineConstructor
gp = GaussianParameters(z, w0, lambda);
gb_line = GaussianBeam(x, gp);
ref_line = GaussianBeam(w0, lambda).opticalField(x, zeros(size(x)), z);
if (numel(gb_line.OpticalField) == numel(x) && max(abs(gb_line.OpticalField(:) - ref_line(:))) < 1e-12)
    fprintf('  PASS: GaussianBeam legacy line constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: GaussianBeam legacy line constructor\n');
    failed = failed + 1;
end

% testGaussianLegacyGridConstructor
gb_grid = GaussianBeam(X, Y, gp);
ref_grid = GaussianBeam(w0, lambda).opticalField(X, Y, z);
if (isequal(size(gb_grid.OpticalField), size(X)) && max(abs(gb_grid.OpticalField(:) - ref_grid(:))) < 1e-12)
    fprintf('  PASS: GaussianBeam legacy grid constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: GaussianBeam legacy grid constructor\n');
    failed = failed + 1;
end

% testHermiteLegacyConstructor
hp = HermiteParameters(z, w0, lambda, 2, 1);
hb_legacy = HermiteBeam(X, Y, hp);
hb_modern = HermiteBeam(w0, lambda, 2, 1);
ref_h = hb_modern.opticalField(X, Y, z);
if (isequal(size(hb_legacy.OpticalField), size(X)) && max(abs(hb_legacy.OpticalField(:) - ref_h(:))) < 1e-12)
    fprintf('  PASS: HermiteBeam legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HermiteBeam legacy constructor\n');
    failed = failed + 1;
end

% testLaguerreLegacyConstructor
lp = LaguerreParameters(z, w0, lambda, 1, 0);
lb_legacy = LaguerreBeam(R, TH, lp);
lb_modern = LaguerreBeam(w0, lambda, 1, 0);
ref_l = lb_modern.opticalField(X, Y, z);
if (isequal(size(lb_legacy.OpticalField), size(R)) && max(abs(lb_legacy.OpticalField(:) - ref_l(:))) < 1e-12)
    fprintf('  PASS: LaguerreBeam legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: LaguerreBeam legacy constructor\n');
    failed = failed + 1;
end

% testElegantHermiteLegacyConstructor
ehp = ElegantHermiteParameters(z, w0, lambda, 1, 1);
ehb_legacy = ElegantHermiteBeam(X, Y, ehp);
ehb_modern = ElegantHermiteBeam(w0, lambda, 1, 1);
ref_eh = ehb_modern.opticalField(X, Y, z);
if (isequal(size(ehb_legacy.OpticalField), size(X)) && max(abs(ehb_legacy.OpticalField(:) - ref_eh(:))) < 1e-12)
    fprintf('  PASS: ElegantHermiteBeam legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: ElegantHermiteBeam legacy constructor\n');
    failed = failed + 1;
end

% testElegantLaguerreLegacyConstructor
elp = ElegantLaguerreParameters(z, w0, lambda, 1, 0);
elb_legacy = ElegantLaguerreBeam(R, TH, elp);
elb_modern = ElegantLaguerreBeam(w0, lambda, 1, 0);
ref_el = elb_modern.opticalField(X, Y, z);
if (isequal(size(elb_legacy.OpticalField), size(R)) && max(abs(elb_legacy.OpticalField(:) - ref_el(:))) < 1e-12)
    fprintf('  PASS: ElegantLaguerreBeam legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: ElegantLaguerreBeam legacy constructor\n');
    failed = failed + 1;
end

fprintf('\n=== Legacy Constructor Compatibility: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
