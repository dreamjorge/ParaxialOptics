% Extended test suite for ParaxialOptics
% Run with: matlab -batch "runtests('tests/')"

%% PhysicalConstants tests
classdef TestPhysicalConstants < matlab.unittest.TestCase
    methods (Test)
        function testWaveNumber(testCase)
            lambda = 632.8e-9;
            k = PhysicalConstants.waveNumber(lambda);
            expected = 2*pi / lambda;
            testCase.verifyEqual(k, expected, 'AbsTol', 1e-5);
        end
        
        function testRayleighDistance(testCase)
            w0 = 100e-6;
            lambda = 632.8e-9;
            zr = PhysicalConstants.rayleighDistance(w0, lambda);
            expected = pi * w0^2 / lambda;
            testCase.verifyEqual(zr, expected, 'RelTol', 1e-5);
        end
        
        function testWaistAtZ(testCase)
            w0 = 100e-6;
            z = 0.05;
            lambda = 632.8e-9;
            zr = PhysicalConstants.rayleighDistance(w0, lambda);
            w = PhysicalConstants.waistAtZ(w0, z, lambda, zr);
            expected = w0 * sqrt(1 + (z/zr)^2);
            testCase.verifyEqual(w, expected, 'RelTol', 1e-5);
        end
        
        function testWaistAtZEqualsW0AtOrigin(testCase)
            w0 = 100e-6;
            lambda = 632.8e-9;
            w = PhysicalConstants.waistAtZ(w0, 0, lambda);
            testCase.verifyEqual(w, w0, 'RelTol', 1e-5);
        end
        
        function testWaistAtZAutoComputeZr(testCase)
            w0 = 100e-6;
            z = 0.05;
            lambda = 632.8e-9;
            w = PhysicalConstants.waistAtZ(w0, z, lambda);
            zr = PhysicalConstants.rayleighDistance(w0, lambda);
            expected = w0 * sqrt(1 + (z/zr)^2);
            testCase.verifyEqual(w, expected, 'RelTol', 1e-5);
        end
        
        function testRadiusOfCurvature(testCase)
            z = 0.1;
            zr = 0.05;
            R = PhysicalConstants.radiusOfCurvature(z, zr);
            expected = z * (1 + (zr/z)^2);
            testCase.verifyEqual(R, expected, 'RelTol', 1e-5);
        end
        
        function testGouyPhase(testCase)
            z = 0.05;
            zr = 0.1;
            gouy = PhysicalConstants.gouyPhase(z, zr);
            expected = atan(z/zr);
            testCase.verifyEqual(gouy, expected, 'AbsTol', 1e-10);
        end
        
        function testGouyPhaseZeroAtOrigin(testCase)
            zr = 0.1;
            gouy = PhysicalConstants.gouyPhase(0, zr);
            testCase.verifyEqual(gouy, 0, 'AbsTol', 1e-10);
        end
        
        function testWaveNumberArrayInput(testCase)
            lambda = [532e-9, 632.8e-9, 1064e-9];
            k = PhysicalConstants.waveNumber(lambda);
            expected = 2*pi ./ lambda;
            testCase.verifyEqual(k, expected, 'RelTol', 1e-5);
        end
        
        function testFundamentalConstants(testCase)
            % Just verify they return positive values
            testCase.verifyGreaterThan(PhysicalConstants.speed_of_light, 0);
            testCase.verifyGreaterThan(PhysicalConstants.planck, 0);
            testCase.verifyGreaterThan(PhysicalConstants.planck_reduced, 0);
            testCase.verifyGreaterThan(PhysicalConstants.vacuum_permittivity, 0);
            testCase.verifyGreaterThan(PhysicalConstants.vacuum_permeability, 0);
        end
    end
end

%% GridUtils tests
classdef TestGridUtils < matlab.unittest.TestCase
    methods (Test)
        function testCreate2DGridSize(testCase)
            Nx = 256; Ny = 128;
            Dx = 1e-3; Dy = 0.5e-3;
            grid = GridUtils(Nx, Ny, Dx, Dy);
            [X, Y] = grid.create2DGrid();
            testCase.verifySize(X, [Ny, Nx]);
            testCase.verifySize(Y, [Ny, Nx]);
        end
        
        function testCreate2DGridValues(testCase)
            Nx = 256; Dx = 1e-3;
            grid = GridUtils(Nx, Nx, Dx, Dx);
            [X, Y] = grid.create2DGrid();
            dx = Dx / Nx;
            testCase.verifyEqual(X(Nx/2+1, Nx/2+1), 0, 'AbsTol', 1e-10);
            testCase.verifyEqual(Y(Nx/2+1, Nx/2+1), 0, 'AbsTol', 1e-10);
        end
        
        function testCreate2DGridNonSquare(testCase)
            Nx = 128; Ny = 64;
            Dx = 1e-3; Dy = 0.5e-3;
            grid = GridUtils(Nx, Ny, Dx, Dy);
            [X, Y] = grid.create2DGrid();
            dx = Dx / Nx;
            dy = Dy / Ny;
            % Edge values should differ
            testCase.verifyGreaterThan(max(abs(X(:))), max(abs(Y(:)))+dx/2);
        end
        
        function testCreateFreqGridSize(testCase)
            Nx = 256; Ny = 128;
            Dx = 1e-3; Dy = 0.5e-3;
            grid = GridUtils(Nx, Ny, Dx, Dy);
            [Kx, Ky] = grid.createFreqGrid();
            testCase.verifySize(Kx, [Ny, Nx]);
            testCase.verifySize(Ky, [Ny, Nx]);
        end
        
        function testCreateFreqGridCenterZero(testCase)
            Nx = 256; Dx = 1e-3;
            grid = GridUtils(Nx, Nx, Dx, Dx);
            [Kx, ~] = grid.createFreqGrid();
            testCase.verifyEqual(Kx(Nx/2+1, Nx/2+1), 0, 'AbsTol', 1e-10);
        end
        
        function testCreate3DGridSize(testCase)
            Nx = 64; Ny = 64; Nz = 32;
            Dx = 1e-3; Dy = 1e-3; Dz = 1e-2;
            grid = GridUtils(Nx, Ny, Dx, Dy, Nz, Dz);
            [X, Y, Z] = grid.create3DGrid();
            testCase.verifySize(X, [Ny, Nx, Nz]);
            testCase.verifySize(Y, [Ny, Nx, Nz]);
            testCase.verifySize(Z, [Ny, Nx, Nz]);
        end
        
        function testStaticMeshgrid2D(testCase)
            [X, Y] = GridUtils.meshgrid2D(128, 1e-3);
            testCase.verifySize(X, [128, 128]);
            testCase.verifySize(Y, [128, 128]);
        end
        
        function testStaticFreqGrid(testCase)
            [Kx, Ky] = GridUtils.freqGrid(128, 1e-3);
            testCase.verifySize(Kx, [128, 128]);
        end
        
        function testStaticPolarGrid(testCase)
            [r, theta] = GridUtils.polarGrid(128, 1e-3);
            testCase.verifySize(r, [128, 128]);
            testCase.verifySize(theta, [128, 128]);
            testCase.verifyEqual(r(1,64), 0, 'AbsTol', 1e-10); % center
        end
    end
end

%% FFTUtils tests
classdef TestFFTUtils < matlab.unittest.TestCase
    methods (Test)
        function testFFTRoundtrip(testCase)
            fftOps = FFTUtils(true, true);
            [X, Y] = meshgrid(linspace(-1,1,64), linspace(-1,1,64));
            R = sqrt(X.^2 + Y.^2);
            g = exp(-R.^2);
            g_rec = fftOps.ifft2(fftOps.fft2(g));
            testCase.verifyEqual(g, g_rec, 'AbsTol', 1e-10);
        end
        
        function testFFTNormalized(testCase)
            fftOps = FFTUtils(true, true);
            g = rand(64, 64);
            G = fftOps.fft2(g);
            sum_g = sum(abs(g).^2, 'all');
            sum_G = sum(abs(G).^2, 'all') / numel(g);
            testCase.verifyEqual(sum_g, sum_G, 'RelTol', 1e-10);
        end
        
        function testTransferFunctionAtZero(testCase)
            fftOps = FFTUtils();
            [Kx, Ky] = meshgrid(linspace(-1e6,1e6,32));
            H = fftOps.transferFunction(Kx, Ky, 0, 632.8e-9);
            testCase.verifyEqual(H, ones(32), 'AbsTol', 1e-10);
        end
        
        function testTransferFunctionPhase(testCase)
            fftOps = FFTUtils();
            kx = 0; ky = 0;
            z = 0.1;
            lambda = 632.8e-9;
            H = fftOps.transferFunction(kx, ky, z, lambda);
            % For kx=ky=0, H = exp(i*k*z)
            k = 2*pi/lambda;
            expected = exp(1i*k*z);
            testCase.verifyEqual(H, expected, 'AbsTol', 1e-10);
        end
        
        function testTransferFunctionParaxial(testCase)
            fftOps = FFTUtils();
            kx = 1e4; ky = 0;
            z = 0.1;
            lambda = 632.8e-9;
            k = 2*pi/lambda;
            H = fftOps.transferFunction(kx, ky, z, lambda);
            % Para approximation: H ≈ exp(i*k*z - i*(kx^2+ky^2)*z/(2*k))
            kz_para = k*z - (kx^2 + ky^2)*z/(2*k);
            expected = exp(1i*kz_para);
            testCase.verifyEqual(H, expected, 'RelTol', 1e-3);
        end
        
        function testFFTN(testCase)
            fftOps = FFTUtils(true, true);
            g = rand(16, 16, 4);
            g_rec = fftOps.ifftn(fftn(g));
            testCase.verifyEqual(g, g_rec, 'AbsTol', 1e-10);
        end
        
        function testPropagateRoundtrip(testCase)
            fftOps = FFTUtils();
            [X, Y] = meshgrid(linspace(-1,1,32));
            R = sqrt(X.^2 + Y.^2);
            g = exp(-R.^2);
            g_rec = fftOps.propagate(g, zeros(32), zeros(32), 0, 632.8e-9);
            testCase.verifyEqual(g, g_rec, 'AbsTol', 1e-10);
        end
        
        function testStaticFFT2Centered(testCase)
            g = rand(32, 32);
            G = FFTUtils.fft2_centered(g);
            testCase.verifySize(G, [32, 32]);
        end
        
        function testStaticFFT2Std(testCase)
            g = rand(32, 32);
            G = FFTUtils.fft2_std(g);
            testCase.verifySize(G, [32, 32]);
        end
    end
end

%% GaussianParameters tests
classdef TestGaussianParameters < matlab.unittest.TestCase
    methods (Test)
        function testRayleighDistance(testCase)
            z = 0;
            w0 = 100e-6;
            lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            expected_zr = pi * w0^2 / lambda;
            testCase.verifyEqual(params.RayleighDistance, expected_zr, 'RelTol', 1e-5);
        end
        
        function testWaistAtOriginEqualsInitial(testCase)
            z = 0;
            w0 = 100e-6;
            lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            testCase.verifyEqual(params.Waist, w0, 'RelTol', 1e-5);
        end
        
        function testWaveNumber(testCase)
            z = 0; w0 = 100e-6; lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            expected_k = 2*pi / lambda;
            testCase.verifyEqual(params.k, expected_k, 'RelTol', 1e-5);
        end
        
        function testVectorZCoordinate(testCase)
            z = linspace(0, 0.1, 10);
            w0 = 100e-6;
            lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            testCase.verifyEqual(numel(params.zCoordinate), 10);
        end
        
        function testWaistIncreasesWithZ(testCase)
            z1 = 0; z2 = 0.1;
            w0 = 100e-6; lambda = 632.8e-9;
            params1 = GaussianParameters(z1, w0, lambda);
            params2 = GaussianParameters(z2, w0, lambda);
            testCase.verifyGreaterThan(params2.Waist, params1.Waist);
        end
        
        function testGouyPhase(testCase)
            z = 0.05; w0 = 100e-6; lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            zr = params.RayleighDistance;
            expected_gouy = atan(z/zr);
            testCase.verifyEqual(params.GouyPhase, expected_gouy, 'AbsTol', 1e-10);
        end
        
        function testGouyPhaseZeroAtWaist(testCase)
            z = 0; w0 = 100e-6; lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            testCase.verifyEqual(params.GouyPhase, 0, 'AbsTol', 1e-10);
        end
        
        function testRadiusOfCurvature(testCase)
            z = 0.1; w0 = 100e-6; lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            zr = params.RayleighDistance;
            expected_R = z * (1 + (zr/z)^2);
            testCase.verifyEqual(params.Radius, expected_R, 'RelTol', 1e-5);
        end
        
        function testDivergenceAngle(testCase)
            z = 0; w0 = 100e-6; lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            zr = params.RayleighDistance;
            expected_theta = atan(w0/zr);
            testCase.verifyEqual(params.DivergenceAngle, expected_theta, 'RelTol', 1e-5);
        end
        
        function testAmplitude(testCase)
            z = 0; w0 = 100e-6; lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            testCase.verifyEqual(params.Amplitude, 1/params.Waist, 'RelTol', 1e-5);
        end
        
        function testToString(testCase)
            z = 0; w0 = 100e-6; lambda = 632.8e-9;
            params = GaussianParameters(z, w0, lambda);
            str = params.toString();
            testCase.verifySubstring(str, 'GaussianParameters');
            testCase.verifySubstring(str, 'zCoordinate');
        end
        
        function testIsEqual(testCase)
            z = 0; w0 = 100e-6; lambda = 632.8e-9;
            params1 = GaussianParameters(z, w0, lambda);
            params2 = GaussianParameters(z, w0, lambda);
            testCase.verifyTrue(params1.isEqual(params2));
        end
        
        function testIsEqualFalse(testCase)
            params1 = GaussianParameters(0, 100e-6, 632.8e-9);
            params2 = GaussianParameters(0.1, 100e-6, 632.8e-9);
            testCase.verifyFalse(params1.isEqual(params2));
        end
    end
end

%% Integration tests
classdef TestIntegration < matlab.unittest.TestCase
    methods (Test)
        function testPhysicalConstantsGridUtilsIntegration(testCase)
            w0 = 100e-6; lambda = 632.8e-9;
            zr = PhysicalConstants.rayleighDistance(w0, lambda);
            Dz = zr;
            Nx = 256; Nz = 64;
            
            maxWaist = PhysicalConstants.waistAtZ(w0, Dz, lambda, zr);
            grid = GridUtils(Nx, Nx, 1.2*2*maxWaist, 1.2*2*maxWaist, Nz, Dz);
            
            [X, Y] = grid.create2DGrid();
            testCase.verifySize(X, [Nx, Nx]);
        end
        
        function testGridUtilsFFTUtilsIntegration(testCase)
            Nx = 128; Dx = 1e-3;
            grid = GridUtils(Nx, Nx, Dx, Dx);
            [X, Y] = grid.create2DGrid();
            [Kx, Ky] = grid.createFreqGrid();
            
            R = sqrt(X.^2 + Y.^2);
            g = exp(-R.^2 / (Dx/4)^2);
            
            fftOps = FFTUtils(true, true);
            G = fftOps.fft2(g);
            testCase.verifySize(G, [Nx, Nx]);
            
            H = fftOps.transferFunction(Kx, Ky, 0.01, 632.8e-9);
            testCase.verifySize(H, [Nx, Nx]);
        end
        
        function testGaussianParametersPropagation(testCase)
            w0 = 100e-6; lambda = 632.8e-9;
            zr = pi * w0^2 / lambda;
            
            z_positions = linspace(0, zr, 10);
            params = GaussianParameters(z_positions, w0, lambda);
            
            % Waist should increase monotonically
            waists = zeros(1, length(z_positions));
            for i = 1:length(z_positions)
                waists(i) = GaussianParameters.getWaist(z_positions(i), w0, zr);
            end
            
            for i = 2:length(waists)
                testCase.verifyGreaterThan(waists(i), waists(i-1));
            end
        end
    end
end
