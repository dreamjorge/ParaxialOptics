% Compatible with GNU Octave and MATLAB
% Edge-case regression tests for legacy Hankel static alias delegation.

repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(repoRoot);
setpaths();
addpath(fullfile(repoRoot, 'ParaxialBeams'));
addpath(fullfile(repoRoot, 'ParaxialBeams', 'Addons'));
addpath(fullfile(repoRoot, 'legacy', 'compat'));

fprintf('=== Hankel Alias Edge Cases Tests ===\n\n');
passed = 0;
failed = 0;

% Explicit mode gate:
%   - default: aliases required
%   - LEGACY_ALIAS_REMOVAL_MODE=1: aliases expected removed
aliasRemovalMode = strcmp(getenv('LEGACY_ALIAS_REMOVAL_MODE'), '1');

w0 = 100e-6;
lambda = 632.8e-9;
zi = 0.0;
zf = 5e-6;

% testHermiteAliasDelegationWithMixedSlopes
hpZi = HermiteParameters(zi, w0, lambda, 2, 1);
hpZf = HermiteParameters(zf, w0, lambda, 2, 1);
x = linspace(-3e-4, 3e-4, 81);
y = x;
dr = [x(2) - x(1), y(2) - y(1), zf - zi];

rayH = OpticalRay();
seedPoints = [-50e-6, 0; 20e-6, -30e-6; 15e-6, 25e-6; -10e-6, -15e-6];
for i = 1:size(seedPoints, 1)
    rayH = assignCoordinates2CartesianRay(seedPoints(i, 1), seedPoints(i, 2), zi, rayH, i, 12);
end
rayH.zxSlope = [Inf, 1e8, -1e8, 8e7];
rayH.zySlope = [Inf, -9e7, 9e7, 7e7];
rayH.xySlope = [Inf, -1.0, 1.0, -0.5];

baseH = HankelHermite.getPropagateCartesianRays(rayH, x, y, dr, hpZi, hpZf, 12);

hasHankeleHermite = (exist('HankeleHermite', 'class') == 8);
if hasHankeleHermite
    aliasH = HankeleHermite.getPropagateCartesianRays(rayH, x, y, dr, hpZi, hpZf, 12);

    okH = isequaln(baseH.xCoordinate, aliasH.xCoordinate) && ...
          isequaln(baseH.yCoordinate, aliasH.yCoordinate) && ...
          isequaln(baseH.zCoordinate, aliasH.zCoordinate) && ...
          isequaln(baseH.zxSlope, aliasH.zxSlope) && ...
          isequaln(baseH.zySlope, aliasH.zySlope) && ...
          isequaln(baseH.xySlope, aliasH.xySlope) && ...
          isequaln(baseH.hankelType, aliasH.hankelType);

    if okH
        fprintf('  PASS: Hermite alias delegation with mixed slopes\n');
        passed = passed + 1;
    else
        fprintf('  FAIL: Hermite alias delegation with mixed slopes\n');
        failed = failed + 1;
    end
elseif aliasRemovalMode
    fprintf('  PASS: Hermite alias edge-case delegation removed with alias class\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Hermite alias edge-case alias missing before removal mode\n');
    failed = failed + 1;
end

% testLaguerreAliasDelegationWithMixedRadialCases
lpZi = LaguerreParameters(zi, w0, lambda, 1, 0);
lpZf = LaguerreParameters(zf, w0, lambda, 1, 0);
r = linspace(0, 3e-4, 81);
th = linspace(-pi, pi, 81);
difr = [r(2) - r(1), th(2) - th(1), zf - zi];

rayL = CylindricalRay();
seedCartesian = [60e-6, 0; -40e-6, 10e-6; 15e-6, -35e-6; -20e-6, -25e-6];
for i = 1:size(seedCartesian, 1)
    rayL = assignCoordinates2CylindricalRay(seedCartesian(i, 1), seedCartesian(i, 2), zi, rayL, i, 2);
end
rayL.rCoordinate(2) = -abs(rayL.rCoordinate(2));
rayL.zrSlope = [Inf, 1e8, -1e8, 6e7];
rayL.zthSlope = [Inf, -8e7, 8e7, 5e7];
rayL.rthSlope = [Inf, -1.0, 1.0, -0.25];

totalRays = numel(rayL.rCoordinate);
baseL = HankelLaguerre.getPropagateCylindricalRays(rayL, totalRays, r, th, difr, lpZi, lpZf, 2);

hasHankeleLaguerre = (exist('HankeleLaguerre', 'class') == 8);
if hasHankeleLaguerre
    aliasL = HankeleLaguerre.getPropagateCylindricalRays(rayL, totalRays, r, th, difr, lpZi, lpZf, 2);

    okL = isequaln(baseL.rCoordinate, aliasL.rCoordinate) && ...
          isequaln(baseL.thetaCoordinate, aliasL.thetaCoordinate) && ...
          isequaln(baseL.zCoordinate, aliasL.zCoordinate) && ...
          isequaln(baseL.xCoordinate, aliasL.xCoordinate) && ...
          isequaln(baseL.yCoordinate, aliasL.yCoordinate) && ...
          isequaln(baseL.zrSlope, aliasL.zrSlope) && ...
          isequaln(baseL.zthSlope, aliasL.zthSlope) && ...
          isequaln(baseL.rthSlope, aliasL.rthSlope) && ...
          isequaln(baseL.hankelType, aliasL.hankelType);

    if okL
        fprintf('  PASS: Laguerre alias delegation with mixed radial cases\n');
        passed = passed + 1;
    else
        fprintf('  FAIL: Laguerre alias delegation with mixed radial cases\n');
        failed = failed + 1;
    end
elseif aliasRemovalMode
    fprintf('  PASS: Laguerre alias edge-case delegation removed with alias class\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Laguerre alias edge-case alias missing before removal mode\n');
    failed = failed + 1;
end

fprintf('\n=== Hankel Alias Edge Cases: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
