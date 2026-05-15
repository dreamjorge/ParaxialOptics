% Compatible with GNU Octave and MATLAB
% Legacy alias static delegation tests for Hankel propagation methods.

repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(repoRoot);
setpaths();
addpath(fullfile(repoRoot, 'ParaxialBeams'));
addpath(fullfile(repoRoot, 'ParaxialBeams', 'Addons'));
addpath(fullfile(repoRoot, 'legacy', 'compat'));

fprintf('=== Hankel Alias Static Delegation Tests ===\n\n');
passed = 0;
failed = 0;

% Explicit mode gate:
%   - default: aliases required
%   - LEGACY_ALIAS_REMOVAL_MODE=1: aliases expected removed
aliasRemovalMode = strcmp(getenv('LEGACY_ALIAS_REMOVAL_MODE'), '1');

w0 = 100e-6;
lambda = 632.8e-9;
zi = 0.0;
zf = 0.01;

% testHankeleHermiteStaticDelegatesExactly
hpZi = HermiteParameters(zi, w0, lambda, 1, 1);
hpZf = HermiteParameters(zf, w0, lambda, 1, 1);
x = linspace(-3e-4, 3e-4, 51);
y = x;
dr = [x(2) - x(1), y(2) - y(1), zf - zi];

rayH = OpticalRay();
seedPoints = [-40e-6, -20e-6; 20e-6, 15e-6; 35e-6, -25e-6; -10e-6, 30e-6];
for i = 1:size(seedPoints, 1)
    rayH = assignCoordinates2CartesianRay(seedPoints(i, 1), seedPoints(i, 2), zi, rayH, i, 11);
end
rayH.zxSlope(:) = 1e8;
rayH.zySlope(:) = 1e8;
rayH.xySlope(:) = 1.0;

baseH = HankelHermite.getPropagateCartesianRays(rayH, x, y, dr, hpZi, hpZf, 11);

hasHankeleHermite = (exist('HankeleHermite', 'class') == 8);
if hasHankeleHermite
    aliasH = HankeleHermite.getPropagateCartesianRays(rayH, x, y, dr, hpZi, hpZf, 11);

    okH = isequaln(baseH.xCoordinate, aliasH.xCoordinate) && ...
          isequaln(baseH.yCoordinate, aliasH.yCoordinate) && ...
          isequaln(baseH.zCoordinate, aliasH.zCoordinate) && ...
          isequaln(baseH.zxSlope, aliasH.zxSlope) && ...
          isequaln(baseH.zySlope, aliasH.zySlope) && ...
          isequaln(baseH.xySlope, aliasH.xySlope) && ...
          isequaln(baseH.hankelType, aliasH.hankelType);

    if okH
        fprintf('  PASS: HankeleHermite.getPropagateCartesianRays delegates to base\n');
        passed = passed + 1;
    else
        fprintf('  FAIL: HankeleHermite.getPropagateCartesianRays delegates to base\n');
        failed = failed + 1;
    end
elseif aliasRemovalMode
    fprintf('  PASS: HankeleHermite static delegation removed with alias class\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HankeleHermite static delegation alias missing before removal mode\n');
    failed = failed + 1;
end

% testHankeleLaguerreStaticDelegatesExactly
lpZi = LaguerreParameters(zi, w0, lambda, 1, 0);
lpZf = LaguerreParameters(zf, w0, lambda, 1, 0);
r = linspace(0, 3e-4, 51);
th = linspace(-pi, pi, 51);
difr = [r(2) - r(1), th(2) - th(1), zf - zi];
totalRays = 4;

rayL = CylindricalRay();
seedCartesian = [50e-6, 0; -25e-6, 35e-6; -40e-6, -10e-6; 15e-6, -30e-6];
for i = 1:size(seedCartesian, 1)
    rayL = assignCoordinates2CylindricalRay(seedCartesian(i, 1), seedCartesian(i, 2), zi, rayL, i, 2);
end
rayL.rCoordinate(1) = -abs(rayL.rCoordinate(1));
rayL.zrSlope(:) = 1e8;
rayL.zthSlope(:) = 1e8;
rayL.rthSlope(:) = 1.0;

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
        fprintf('  PASS: HankeleLaguerre.getPropagateCylindricalRays delegates to base\n');
        passed = passed + 1;
    else
        fprintf('  FAIL: HankeleLaguerre.getPropagateCylindricalRays delegates to base\n');
        failed = failed + 1;
    end
elseif aliasRemovalMode
    fprintf('  PASS: HankeleLaguerre static delegation removed with alias class\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HankeleLaguerre static delegation alias missing before removal mode\n');
    failed = failed + 1;
end

fprintf('\n=== Hankel Alias Static Delegation: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
