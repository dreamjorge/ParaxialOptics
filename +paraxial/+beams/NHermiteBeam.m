classdef NHermiteBeam < ParaxialBeam
    % NHermiteBeam - Second Hermite-Gaussian beam (NHG solution)
    % Compatible with GNU Octave and MATLAB
    %
    % Constructor (Phase 3 API):
    %   beam = NHermiteBeam(w0, lambda, n, m)
    %
    % Usage:
    %   field = beam.opticalField(X, Y, z)    % complex field on Cartesian grid
    %   params = beam.getParameters(z)         % GaussianParameters at z
    %   name   = beam.beamName()               % e.g. 'nhermite_3_2'
    %
    % Mathematical definition (second Hermite-Gaussian, NHG_{nm}):
    %
    %   u_{nm}(x,y,z) = NH_n(sqrt(2)*x/w) * NH_m(sqrt(2)*y/w)
    %                   * u_0(r,z) * exp(i*(n+m)*psi(z))
    %
    % where:
    %   NH_n, NH_m - second Hermite solution (normalized partner, orthogonal to H_n)
    %   w = w(z)    - beam waist at z
    %   u_0(r,z)    - fundamental Gaussian carrier field
    %   psi(z)      - Gouy phase = arctan(z / z_R)
    %
    % The second Hermite solution NHG is computed via
    %   HermiteComputation.hermiteSecondSolution(n, x).
    %
    % The coordinate system is Cartesian (x, y). The class stores only the
    % physical parameters w0, lambda, n, m — no grid or stored field.
    %
    % Reference: Hermite differential equation — second independent solution.

    properties
        InitialWaist    % Beam waist at z = 0 (m)
        n               % Hermite order in x
        m               % Hermite order in y
        OpticalField    % Legacy snapshot field compatibility
    end

    methods
        function obj = NHermiteBeam(arg1, arg2, varargin)
            % Constructor
            % Modern API:
            %   NHermiteBeam(w0, lambda, n, m)
            %
            % Legacy-compatible API:
            %   NHermiteBeam(X, Y, hermiteParams)

            % Call superclass constructor first (MATLAB requirement)
            obj = obj@ParaxialBeam();

            % Determine parameters from input using static helper
            [w0, lambda, n, m, legacyCoords, legacyZ] = ...
                NHermiteBeam.parseArgs(arg1, arg2, varargin{:});

            % Initialize parent class state
            if ~isempty(lambda)
                obj.Lambda = lambda;
                obj.k = 2 * pi / lambda;
            end

            % Initialize subclass state
            obj.InitialWaist = w0;
            obj.n = n;
            obj.m = m;

            if ~isempty(legacyCoords{1})
                obj.OpticalField = obj.computeField(legacyCoords{1}, legacyCoords{2}, legacyZ);
            else
                obj.OpticalField = [];
            end
        end

        % -----------------------------------------------------------------
        % ParaxialBeam interface
        % -----------------------------------------------------------------

        function field = opticalField(obj, X, Y, z)
            % opticalField - Complex optical field on Cartesian grid (X,Y) at depth z.
            field = obj.computeField(X, Y, z);
        end

        function params = getParameters(obj, z)
            % getParameters - GaussianParameters evaluated at axial position z.
            params = GaussianParameters(z, obj.InitialWaist, obj.Lambda);
        end

        function name = beamName(obj)
            % beamName - Returns identifier string, e.g. 'nhermite_3_2'.
            name = sprintf('nhermite_%d_%d', obj.n, obj.m);
        end
    end

    methods (Static)
        function [w0, lambda, n, m, legacyCoords, legacyZ] = parseArgs(arg1, arg2, varargin)
            % Static helper to parse constructor arguments
            w0 = [];
            lambda = [];
            n = 0;
            m = 0;
            legacyCoords = {[], []};
            legacyZ = 0;

            if nargin < 2
                return;
            end

            if nargin == 3 && isa(varargin{1}, 'HermiteParameters')
                % Legacy: NHermiteBeam(X, Y, hermiteParams)
                params = varargin{1};
                lambda = params.Lambda;
                w0 = params.InitialWaist;
                n = params.n;
                m = params.m;
                legacyCoords{1} = arg1;
                legacyCoords{2} = arg2;
                legacyZ = params.zCoordinate;

            elseif nargin >= 2
                % Modern: NHermiteBeam(w0, lambda, n, m)
                w0 = arg1;
                lambda = arg2;
                if numel(varargin) >= 2
                    n = varargin{1};
                    m = varargin{2};
                end
            end
        end
    end

    % -----------------------------------------------------------------
    % Private helpers
    % -----------------------------------------------------------------
    methods (Access = private)
        function field = computeField(obj, X, Y, z)
            % Compute NHG_{nm} field at Cartesian grid (X,Y) and depth z.
            %
            % Uses the second independent Hermite solution (NHG) via
            % HermiteComputation.hermiteSecondSolution, which returns the
            % normalized partner orthogonal to the standard H_n polynomial.
            w0     = obj.InitialWaist;
            lambda = obj.Lambda;
            k      = obj.k;
            zr     = pi * w0^2 / lambda;

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

            % Second Hermite solution scaling: sqrt(2)*coord/w
            % Uses hermiteSecondSolution which returns NHG (normalized partner)
            NHn = HermiteComputation.hermiteSecondSolution(obj.n, sqrt(2) * X ./ w);
            NHm = HermiteComputation.hermiteSecondSolution(obj.m, sqrt(2) * Y ./ w);

            % Modal Gouy phase shift: (n+m)*psi
            phi_mode = (obj.n + obj.m) * psi;

            field = NHn .* NHm .* exp(-1i * phi_mode) .* carrier;
        end
    end
end