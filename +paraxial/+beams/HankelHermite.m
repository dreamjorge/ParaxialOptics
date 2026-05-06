classdef HankelHermite < ParaxialBeam
    % HankelHermite - Hankel-type Hermite-Gaussian beam field
    % Compatible with GNU Octave and MATLAB
    %
    % Constructor (Phase 3 API):
    %   beam = HankelHermite(w0, lambda, n, m, hankelType)
    %
    % Usage:
    %   field = beam.opticalField(X, Y, z)    % complex field on Cartesian grid
    %   params = beam.getParameters(z)         % GaussianParameters at z
    %   name   = beam.beamName()               % e.g. 'hankel11_hermite_3_2'
    %
    % -------------------------------------------------------------------------
    % Theoretical Context
    % -------------------------------------------------------------------------
    % Hankel-Hermite beams are constructed from two independent series
    % solutions of the Hermite differential equation:
    %   HG  - standard Hermite-Gauss (even/odd parity depending on mode)
    %   NHG - complementary solution with opposite parity
    %
    % The four Hankel-Hermite types combine these independently in x and y:
    %   H^(11) = (HG_x + i*NHG_x) * (HG_y + i*NHG_y) * carrier
    %   H^(12) = (HG_x + i*NHG_x) * (HG_y - i*NHG_y) * carrier
    %   H^(21) = (HG_x - i*NHG_x) * (HG_y + i*NHG_y) * carrier
    %   H^(22) = (HG_x - i*NHG_x) * (HG_y - i*NHG_y) * carrier
    %
    % Legacy constructor (also supported):
    %   HankelHermite(x, y, hermiteParameters, hankelType)
    % Produces .OpticalField for legacy scripts.

    properties
        InitialWaist    % Beam waist at z = 0 (m)
        n               % Hermite order in x
        m               % Hermite order in y
        HankelType      % 11, 12, 21, or 22
        OpticalField    % Legacy snapshot field container
    end

    methods (Static)
        function Rays = getPropagateCartesianRays(Rays, x, y, difr, HParametersZi, HParametersZ, HankelType)
            tempdr = num2cell(difr);
            [dx, dy, dz] = deal(tempdr{:});

            totalRays = numel(Rays.xCoordinate);

            for ray_index = 1:totalRays
                xi = Rays.xCoordinate(ray_index) + (1 ./ Rays.zxSlope(ray_index)) * dz;
                yi = Rays.yCoordinate(ray_index) + (1 ./ Rays.zySlope(ray_index)) * dz;
                zi = Rays.zCoordinate(ray_index) + dz;

                Rays.xCoordinate(ray_index) = xi;
                Rays.yCoordinate(ray_index) = yi;
                Rays.zCoordinate(ray_index) = zi;
                Rays.hankelType(ray_index) = HankelType;

                HHx = HankelHermite(x, yi, HParametersZi, HankelType);
                HHy = HankelHermite(xi, y, HParametersZi, HankelType);
                HHz = HankelHermite(xi, yi, HParametersZ, HankelType);

                fx = unwrap(angle(HHx.OpticalField));
                fy = unwrap(angle(HHy.OpticalField));
                fz = unwrap(angle(HHz.OpticalField));

                [zxSlope, zySlope, xySlope] = HankelHermite.gradientCartesian(fx, fy, fz, HParametersZi.k, dx, dy, dz, xi, yi, zi);
                Rays.zxSlope(ray_index) = zxSlope;
                Rays.zySlope(ray_index) = zySlope;
                Rays.xySlope(ray_index) = xySlope;
            end
        end
    end

    methods
        function obj = HankelHermite(w0, lambda, n, m, hankelType)
            % Constructor
            % w0:         initial beam waist at z = 0 (m)
            % lambda:     wavelength (m)
            % n:          Hermite order in x (default 0)
            % m:          Hermite order in y (default 0)
            % hankelType: 11, 12, 21, or 22 (default 11)
            %
            % Legacy constructor (also supported):
            %   HankelHermite(x, y, hermiteParameters, hankelType)

            obj = obj@ParaxialBeam();

            if nargin == 0
                obj.HankelType = 11;
                obj.OpticalField = [];
                return;
            end

            % Detect legacy API: 3rd arg is a HermiteParameters object
            if nargin >= 3 && isa(n, 'HermiteParameters')
                isLegacy = true;
            else
                isLegacy = false;
            end

            if isLegacy
                % Legacy: HankelHermite(x, y, hermiteParams, hankelType)
                % The 4th legacy arg maps to 'm' in this signature.
                if nargin >= 4
                    raw_hankelType = m;
                else
                    raw_hankelType = 11;
                end
                hankelType = raw_hankelType;
            else
                if nargin < 5, hankelType = 11; end
                if nargin < 4, m = 0; end
                if nargin < 3, n = 0; end
            end

            [w0, lambda, n, m, hankelType, legacyCoords, legacyZ] = ...
                HankelHermite.parseArgs(w0, lambda, n, m, hankelType);

            if ~isempty(lambda)
                obj.Lambda = lambda;
                obj.k = 2 * pi / lambda;
            end

            obj.InitialWaist = w0;
            obj.n = n;
            obj.m = m;
            obj.HankelType = hankelType;

            if ~isempty(legacyCoords{1})
                obj.OpticalField = hankelHermiteField(legacyCoords{1}, legacyCoords{2}, ...
                    w0, lambda, n, m, legacyZ, hankelType);
            else
                obj.OpticalField = [];
            end
        end  % constructor HankelHermite
    end  % methods (constructor block)

    % -----------------------------------------------------------------
    % Private helpers
    % -----------------------------------------------------------------
    methods (Access = private)
        function field = hankelHermiteField_composed(obj, X, Y, z)
            % hankelHermiteField_composed - Compute Hankel-Hermite via beam composition.
            %
            % Uses HermiteBeam + NHermiteBeam as composition components.
            % This is the primary implementation; hankelHermiteField (module-private)
            % is retained only for legacy OpticalField snapshots.
            %
            % Hankel types:
            %   H^(11) = (HG_x + i*NHG_x) * (HG_y + i*NHG_y) * carrier
            %   H^(12) = (HG_x + i*NHG_x) * (HG_y - i*NHG_y) * carrier
            %   H^(21) = (HG_x - i*NHG_x) * (HG_y + i*NHG_y) * carrier
            %   H^(22) = (HG_x - i*NHG_x) * (HG_y - i*NHG_y) * carrier

            w0     = obj.InitialWaist;
            lambda = obj.Lambda;
            k      = obj.k;
            zr     = pi * w0^2 / lambda;
            n      = obj.n;
            m      = obj.m;
            ht     = obj.HankelType;

            w   = w0 * sqrt(1 + (z/zr)^2);
            Rc  = z  * (1 + (zr/z)^2);
            if z == 0, Rc = Inf; end
            psi = atan2(z, zr);

            % Gaussian carrier field u_0(r,z)
            r          = sqrt(X.^2 + Y.^2);
            amplitude  = (w0 ./ w) .* exp(-r.^2 ./ w.^2);
            phase_z    = -1i * k * z;
            phase_curv = 1i * k * r.^2 ./ (2 * Rc);
            phase_curv(isinf(Rc)) = 0;
            phase_gouy = -1i * psi;
            carrier    = amplitude .* exp(phase_z + phase_curv + phase_gouy);

            % Modal Gouy phase shift: (n+m)*psi
            phi_mode = (n + m) * psi;

            % Compose HG and NHG via beam instances
            hgBeam = HermiteBeam(w0, lambda, n, m);
            nhgBeam = NHermiteBeam(w0, lambda, n, m);

            HGx = hgBeam.opticalField(X, Y, z);
            NHx = nhgBeam.opticalField(X, Y, z);

            % For y, reuse same beams with swapped orders
            hgBeam_y = HermiteBeam(w0, lambda, m, n);
            nhgBeam_y = NHermiteBeam(w0, lambda, m, n);

            HGy = hgBeam_y.opticalField(X, Y, z);
            NHy = nhgBeam_y.opticalField(X, Y, z);

            % Hankel combination per type
            switch ht
                case 11
                    field = (HGx + 1i * NHx) .* (HGy + 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
                case 12
                    field = (HGx + 1i * NHx) .* (HGy - 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
                case 21
                    field = (HGx - 1i * NHx) .* (HGy + 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
                case 22
                    field = (HGx - 1i * NHx) .* (HGy - 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
                otherwise
                    error('HankelHermite:invalidType', 'Unsupported Hankel type: %d. Use 11, 12, 21, or 22.', ht);
            end
        end  % hankelHermiteField_composed
    end  % private methods

    % -----------------------------------------------------------------
    % ParaxialBeam interface
    % -----------------------------------------------------------------
    methods
        function field = opticalField(obj, X, Y, z)
            field = hankelHermiteField_composed(obj, X, Y, z);
        end

        function params = getParameters(obj, z)
            params = GaussianParameters(z, obj.InitialWaist, obj.Lambda);
        end

        function name = beamName(obj)
            name = sprintf('hankel%d_hermite_%d_%d', obj.HankelType, obj.n, obj.m);
        end
    end

    methods (Static)
        function [w0, lambda, n, m, hankelType, legacyCoords, legacyZ] = parseArgs(w0, lambda, n, m, hankelType)
            legacyCoords = {[], []};
            legacyZ = 0;

            if nargin < 1
                n = 0; m = 0; hankelType = 11;
                return;
            end

            if nargin >= 3 && isa(n, 'HermiteParameters')
                hermiteParams = n;
                legacyCoords{1} = w0;       % x coordinate
                legacyCoords{2} = lambda;   % y coordinate
                legacyZ = hermiteParams.zCoordinate;
                w0 = hermiteParams.InitialWaist;
                lambda = hermiteParams.Lambda;
                n = hermiteParams.n;
                m = hermiteParams.m;
                if nargin < 5, hankelType = 11; end
            else
                if nargin < 3, n = 0; end
                if nargin < 4, m = 0; end
                if nargin < 5, hankelType = 11; end
            end
        end
    end

    methods (Static, Access = private)
        function [zxSlope, zySlope, xySlope] = gradientCartesian(fx, fy, fz, k, dx, dy, dz, x, y, z)
            gx = gradient(fx) ./ dx;
            gy = gradient(fy) ./ dy;
            gz = gradient(fz) ./ dz + k;

            nn = size(gx, 2);
            idxZ = HankelHermite.clampIndex(floor(z / dz + 1), numel(gz));
            idxX = HankelHermite.clampIndex(nn / 2 + 1 + floor(x / dx), numel(gx));
            idxY = HankelHermite.clampIndex(nn / 2 + 1 + floor(y / dy), numel(gy));

            zxSlope = gz(idxZ) / gx(idxX);
            zySlope = gz(idxZ) / gy(idxY);
            xySlope = gx(idxX) / gy(idxY);
        end

        function idx = clampIndex(raw, maxSize)
            idx = floor(raw);
            if idx < 1
                idx = 1;
            elseif idx > maxSize
                idx = maxSize;
            end
        end
    end
end

% -------------------------------------------------------------------------
% Module-private helper (not a method — keeps the class definition clean)
% -------------------------------------------------------------------------
function field = hankelHermiteField(X, Y, w0, lambda, n, m, z, hankelType)
    % hankelHermiteField - Compute Hankel-Hermite field at depth z.
    %
    % Uses both independent series solutions [HG, NHG] of the Hermite
    % differential equation, obtained via HermiteParameters.getHermiteSolutions.

    k  = 2*pi/lambda;
    zr = pi * w0.^2 ./ lambda;

    w   = w0 .* sqrt(1 + (z./zr).^2);
    Rc  = z  .* (1 + (zr./z).^2);
    Rc(z == 0) = Inf;
    psi = atan2(z, zr);

    % Gaussian carrier field u_0(r,z)
    r          = sqrt(X.^2 + Y.^2);
    amplitude  = (w0 ./ w) .* exp(-r.^2 ./ w.^2);
    phase_z    = -1i .* k .* z;
    phase_curv = 1i .* k .* r.^2 ./ (2 .* Rc);
    phase_curv(isinf(Rc)) = 0;
    phase_gouy = -1i .* psi;
    carrier    = amplitude .* exp(phase_z + phase_curv + phase_gouy);

    % Both Hermite solutions in x and y
    [Hx, NHx] = HermiteParameters.getHermiteSolutions(n, (sqrt(2) ./ w) .* X);
    [Hy, NHy] = HermiteParameters.getHermiteSolutions(m, (sqrt(2) ./ w) .* Y);

    % Modal Gouy phase shift: (n+m)*psi
    phi_mode = (n + m) * psi;

    % Hankel combination
    switch hankelType
        case 11
            field = (Hx + 1i * NHx) .* (Hy + 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
        case 12
            field = (Hx + 1i * NHx) .* (Hy - 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
        case 21
            field = (Hx - 1i * NHx) .* (Hy + 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
        case 22
            field = (Hx - 1i * NHx) .* (Hy - 1i * NHy) .* exp(-1i * phi_mode) .* carrier;
        otherwise
            error('HankelHermite:invalidType', 'Unsupported Hankel type: %d. Use 11, 12, 21, or 22.', hankelType);
    end
end
