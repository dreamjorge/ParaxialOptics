% Compatible with GNU Octave and MATLAB
% Legacy compatibility tests for Hankel Hermite/Laguerre wrappers.

repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(repoRoot);
setpaths();
addpath(fullfile(repoRoot, 'ParaxialBeams'));
addpath(fullfile(repoRoot, 'legacy', 'compat'));

fprintf('=== Hankel Compatibility Tests ===\n\n');
passed = 0;
failed = 0;

% Explicit mode gate:
%   - default (LEGACY_ALIAS_REMOVAL_MODE unset/0): aliases MUST exist
%   - post-removal mode (LEGACY_ALIAS_REMOVAL_MODE=1): aliases MUST be absent
aliasRemovalMode = strcmp(getenv('LEGACY_ALIAS_REMOVAL_MODE'), '1');

w0 = 100e-6;
lambda = 632.8e-9;
z = 0.01;

% testHermiteLegacySolutions
[h0, nh0] = HermiteParameters.getHermiteSolutions(2, linspace(-1, 1, 11));
if (~isempty(h0) && ~isempty(nh0) && numel(h0) == 11 && numel(nh0) == 11)
    fprintf('  PASS: HermiteParameters.getHermiteSolutions\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HermiteParameters.getHermiteSolutions\n');
    failed = failed + 1;
end

% testHankelHermiteConstructor
hp = HermiteParameters(z, w0, lambda, 1, 1);
x = linspace(-3e-4, 3e-4, 51);
y = 1e-5;
hh11 = HankelHermite(x, y, hp, 11);
if (~isempty(hh11.OpticalField) && numel(hh11.OpticalField) == numel(x))
    fprintf('  PASS: HankelHermite constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HankelHermite constructor\n');
    failed = failed + 1;
end

% testHankeleHermiteAlias
hasHankeleHermite = (exist('HankeleHermite', 'class') == 8);
if hasHankeleHermite
    hhe11 = HankeleHermite(x, y, hp, 11);
    if (max(abs(hhe11.OpticalField - hh11.OpticalField)) < 1e-12)
        fprintf('  PASS: HankeleHermite alias\n');
        passed = passed + 1;
    else
        fprintf('  FAIL: HankeleHermite alias\n');
        failed = failed + 1;
    end
elseif aliasRemovalMode
    % Post-removal behavior: alias should be unavailable.
    try
        HankeleHermite(x, y, hp, 11); %#ok<UNRCH>
        fprintf('  FAIL: HankeleHermite removed alias should not resolve\n');
        failed = failed + 1;
    catch
        fprintf('  PASS: HankeleHermite alias removed behavior\n');
        passed = passed + 1;
    end
else
    fprintf('  FAIL: HankeleHermite alias missing before removal mode\n');
    failed = failed + 1;
end

% testHankelLaguerreLegacyConstructor
lp = LaguerreParameters(z, w0, lambda, 1, 0);
r = linspace(0, 3e-4, 51);
th = pi / 4;
hl1 = HankelLaguerre(r, th, lp, 1);
if (~isempty(hl1.OpticalFieldLaguerre) && numel(hl1.OpticalFieldLaguerre) == numel(r))
    fprintf('  PASS: HankelLaguerre legacy constructor\n');
    passed = passed + 1;
else
    fprintf('  FAIL: HankelLaguerre legacy constructor\n');
    failed = failed + 1;
end

% testHankeleLaguerreAlias
hasHankeleLaguerre = (exist('HankeleLaguerre', 'class') == 8);
if hasHankeleLaguerre
    hle1 = HankeleLaguerre(r, th, lp, 1);
    if (max(abs(hle1.OpticalFieldLaguerre - hl1.OpticalFieldLaguerre)) < 1e-12)
        fprintf('  PASS: HankeleLaguerre alias\n');
        passed = passed + 1;
    else
        fprintf('  FAIL: HankeleLaguerre alias\n');
        failed = failed + 1;
    end
elseif aliasRemovalMode
    % Post-removal behavior: alias should be unavailable.
    try
        HankeleLaguerre(r, th, lp, 1); %#ok<UNRCH>
        fprintf('  FAIL: HankeleLaguerre removed alias should not resolve\n');
        failed = failed + 1;
    catch
        fprintf('  PASS: HankeleLaguerre alias removed behavior\n');
        passed = passed + 1;
    end
else
    fprintf('  FAIL: HankeleLaguerre alias missing before removal mode\n');
    failed = failed + 1;
end

% testLegacyAliasStaticMethodsExposed
hasAliasStatic = hasHankeleHermite && hasHankeleLaguerre;
if hasAliasStatic
    if (ismethod('HankeleHermite', 'getPropagateCartesianRays') && ismethod('HankeleLaguerre', 'getPropagateCylindricalRays'))
        fprintf('  PASS: legacy alias static methods exposed\n');
        passed = passed + 1;
    else
        fprintf('  FAIL: legacy alias static methods exposed\n');
        failed = failed + 1;
    end
elseif aliasRemovalMode
    fprintf('  PASS: legacy alias static methods removed with alias classes\n');
    passed = passed + 1;
else
    fprintf('  FAIL: legacy alias static methods missing before removal mode\n');
    failed = failed + 1;
end

fprintf('\n=== Hankel Compatibility: %d/%d passed ===\n', passed, passed + failed);

if failed ~= 0
    error('Tests failed: %d/%d', failed, passed + failed);
end
