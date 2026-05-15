function totalFailed = portable_runner()
    % Portable test runner for Octave and MATLAB
    % Runs script-based and class-based tests in the current directory.
    
    fprintf('=== Inicilizando Portable Test Runner ===\n\n');
    
    % Get test directory and repo root
    testDir = fileparts(mfilename('fullpath'));
    repoRoot = fullfile(testDir, '..');
    
    % Canonical package namespace (+paraxial/)
    % MATLAB/Octave packages are resolved by adding the parent directory.
    % Do not add internal +package folders directly.
    addpath(repoRoot);

    
    % Add utilities and legacy addons (ParaxialBeams/)
    addpath(fullfile(repoRoot, 'ParaxialBeams'));
    addpath(fullfile(repoRoot, 'ParaxialBeams', 'Addons'));
    
    % Add legacy compatibility layer
    addpath(fullfile(repoRoot, 'legacy', 'compat'));
    
    % Add test subdirectories
    addpath(fullfile(testDir, 'modern'));
    addpath(fullfile(testDir, 'edge_cases'));

    % Legacy alias removal mode:
    % Hankele* aliases were removed; legacy_compat tests assert post-removal
    % migration behavior when this flag is enabled.
    setenv('LEGACY_ALIAS_REMOVAL_MODE', '1');

    % Expected deprecation warnings from transitional src/ adapters can occur
    % in tight numerical loops (notably Hankel ray tracing). Suppress only
    % this known warning ID for the portable suite, then restore it before
    % returning so normal interactive sessions still surface deprecations.
    % Use onCleanup to guarantee restoration on ANY exit path (normal, error,
    % or keyboard interrupt). Without it, a early termination would leave
    % the deprecation warning permanently suppressed in the session.
    previousDeprecatedWarningState = warning('query', 'BeamFactory:deprecated');
    warning('off', 'BeamFactory:deprecated');
    cleanupObj = onCleanup(@() warning(previousDeprecatedWarningState.state, 'BeamFactory:deprecated'));
    
    % Canonical list of tests to run (from tests/modern/)
    testFiles = {
        'test_PhysicalConstants.m',
        'test_GridUtils.m',
        'test_FFTUtils.m',
        'test_GaussianParameters.m',
        'test_HermiteParameters.m',
        'test_LaguerreParameters.m',
        'test_ElegantHermiteParameters.m',
        'test_ElegantLaguerreParameters.m',
        'test_GaussianBeam.m',
        'test_HermiteBeam.m',
        'test_LaguerreBeam.m',
        'test_ElegantHermiteBeam.m',
        'test_ElegantLaguerreBeam.m',
        'test_HankelLaguerre.m',
        'test_HankelHermite.m',
        'test_HankelRayTracing.m',
        'test_CylindricalRay.m',
        'test_OpticalRay.m',
        'test_AnalysisUtils.m',
        'test_BeamFactory.m',
        'test_LegacyAliasGuardrail.m',
        'test_RepositoryGuardrails.m',
        'test_Propagators.m',
        'test_RayTracing.m',

        % Edge case tests (z=0, r=0, extreme parameters)
        'test_GaussianBeam_edge.m',
        'test_HankelHermite_edge.m',
        'test_HankelLaguerre_edge.m',
        'test_RayTracing_extreme.m',
        'test_Wavefront.m'
    };

    % --- Deprecated compatibility paths (src/) ---
    % Legacy library structure — kept only for edge cases and transition period.
    % Do not add for new development or onboarding.
    % Port compatible: use strfind instead of contains for Octave/MATLAB
    legacySrcNeeded = false;
    for i = 1:numel(testFiles)
        tf = testFiles{i};
        if ~isempty(strfind(tf, '_edge')) || ~isempty(strfind(tf, 'HankelRayTracing'))
            legacySrcNeeded = true;
            break;
        end
    end
    if legacySrcNeeded
        addpath(fullfile(repoRoot, 'src', 'beams'));
        addpath(fullfile(repoRoot, 'src', 'parameters'));
        addpath(fullfile(repoRoot, 'src', 'computation'));
        addpath(fullfile(repoRoot, 'src', 'propagation', 'field'));
        addpath(fullfile(repoRoot, 'src', 'propagation', 'rays'));
        addpath(fullfile(repoRoot, 'src', 'visualization'));
        fprintf('  [WARN] Paths legacy src/ activos SOLO para compatibilidad/transición.\n');
    end
    
    totalPassed = 0;
    totalFailed = 0;
    
    for i = 1:numel(testFiles)
        testFile = testFiles{i};
        [~, testName, ext] = fileparts(testFile);
        
        fprintf('Ejecutando: %s\n', testFile);
        
        try
            % Check if it's a class or a script
            % In Octave/MATLAB, we can check exist()
            status = exist(testName, 'class');
            
            if status == 8 % It's a class
                [passed, failed] = run_class_test(testName);
            else % Assume script
                run(testFile);
                passed = 1; % Assume pass if no error
                failed = 0;
            end
            
            totalPassed = totalPassed + passed;
            totalFailed = totalFailed + failed;
            
        catch ME
            fprintf('  [ERROR] Fallo crítico en %s: %s\n', testName, ME.message);
            totalFailed = totalFailed + 1;
        end
        fprintf('\n');
    end
    
    fprintf('=== Resumen Final ===\n');
    fprintf('Tests Pasados: %d\n', totalPassed);
    fprintf('Tests Fallados: %d\n', totalFailed);
    
    if totalFailed > 0
        fprintf('ESTADO: FALLO\n');
        % exit(1); % Uncomment if running from CLI only
else
        fprintf('ESTADO: ÉXITO\n');
        % exit(0);
    end
end

function [passed, failed] = run_class_test(className)
    passed = 0;
    failed = 0;
    
    try
        testObj = feval(className);
        
        allMethods = methods(testObj);
        testMethods = allMethods(strncmp(allMethods, 'test', 4));
        
        % Mock testCase interface
        mockTestCase.verifyEqual = @(a, b, varargin) assert_equal(a, b, varargin{:});
        mockTestCase.verifyGreaterThan = @(a, b, varargin) assert_greater(a, b, varargin{:});
        mockTestCase.verifySize = @(a, b, varargin) assert_size(a, b, varargin{:});
        
        for i = 1:numel(testMethods)
            methodName = testMethods{i};
            fprintf('  Metodo: %s... ', methodName);
            try
                feval(methodName, testObj, mockTestCase);
                fprintf('PASÓ\n');
                passed = passed + 1;
            catch ME
                fprintf('FALLÓ (%s)\n', ME.message);
                failed = failed + 1;
            end
        end
    catch ME
        fprintf('  [ERROR] No se pudo instanciar o procesar %s: %s\n', className, ME.message);
        failed = 1;
    end
end

% Simple assertion helpers
function assert_equal(a, b, varargin)
    tol = 1e-10;
    % Simple tolerance extraction if present
    for i=1:length(varargin)
        if ischar(varargin{i}) && (strcmp(varargin{i}, 'RelTol') || strcmp(varargin{i}, 'AbsTol'))
            tol = varargin{i+1};
        end
    end
    
    if ischar(a) && ischar(b)
        if ~strcmp(a, b), error('Assertion failed: %s != %s', a, b); end
    elseif isnumeric(a) && isnumeric(b)
        if any(size(a) ~= size(b))
            error('Assertion failed: size mismatch. Actual [%s], Expected [%s]', ...
                num2str(size(a)), num2str(size(b)));
        end
        diffs = abs(a(:) - b(:));
        if any(diffs > tol)
            [maxDiff, idx] = max(diffs);
            error('Assertion failed: value mismatch. Max diff: %g at index %d. Actual: %g, Expected: %g, Tol: %g', ...
                maxDiff, idx, a(idx), b(idx), tol);
        end
    else
        error('Assertion failed: types do not match');
    end
end

function assert_greater(a, b, varargin)
    if ~(a > b), error('Assertion failed: %f not greater than %f', a, b); end
end

function assert_size(a, expectedSize, varargin)
    if any(size(a) ~= expectedSize), error('Assertion failed: size mismatch'); end
end
