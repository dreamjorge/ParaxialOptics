classdef ElegantNHermiteBeam < ParaxialBeam
    % ElegantNHermiteBeam - Second Elegant Hermite-Gaussian beam (NHG solution)
    % Compatible with GNU Octave and MATLAB
    %
    % Constructor (Phase 3 API):
    %   beam = ElegantNHermiteBeam(w0, lambda, n, m)
    %
    % Usage:
    %   field = beam.opticalField(X, Y, z)    % complex field on Cartesian grid
    %   params = beam.getParameters(z)         % GaussianParameters at z
    %   name   = beam.beamName()               % e.g. 'elegant_nhermite_2_0'
    %
    % Mathematical differences from standard ElegantHermiteBeam:
    %
    %   Elegant HG:  H_n(sqrt(alpha)*x)   -- standard Hermite polynomial
    %   Elegant NHG: NH_n(sqrt(alpha)*x)  -- second Hermite solution (normalized)
    %
    % where alpha(z) = i*k / (2*q(z)), q(z) = z + i*z_R (complex beam parameter).
    %
    % Full field definition (elegant second Hermite-Gaussian, ENHG_{nm}):
    %
    %   u_{nm}(x,y,z) = NH_n(sqrt(alpha)*x) * NH_m(sqrt(alpha)*y)
    %                   * u_0(r,z) * exp(i*(n+m)*psi(z))
    %
    % Physical consequence: because alpha is complex, the second Hermite
    % solution evaluated at complex arguments produces amplitude AND phase
    % modulation simultaneously — the elegant variant of the second solution.
    %
    % Reference: Siegman, "Lasers", University Science Books (1986), Ch. 17;
    %            Siegman, J. Opt. Soc. Am. A 13, 952 (1996).

    properties
        InitialWaist    % Beam waist at z = 0 (m)
        n               % Hermite order in x
        m               % Hermite order in y
        OpticalField    % Legacy snapshot field compatibility
    end

    methods
        function obj = ElegantNHermiteBeam(arg1, arg2, varargin)
            % Constructor
            % Modern API:
            %   ElegantNHermiteBeam(w0, lambda, n, m)
            %
            % Legacy-compatible API:
            %   ElegantNHermiteBeam(X, Y, hermiteParams)

            % Call superclass constructor first (MATLAB requirement)
            obj = obj@ParaxialBeam();

            % Determine parameters from input using static helper
            [w0, lambda, n, m, legacyCoords, legacyZ] = ...
                paraxial.beams.ElegantNHermiteBeam.parseArgs(arg1, arg2, varargin{:});

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
            field = obj.computeField(X, Y, z);
        end

        function params = getParameters(obj, z)
            params = GaussianParameters(z, obj.InitialWaist, obj.Lambda);
        end

        function name = beamName(obj)
            name = sprintf('elegant_nhermite_%d_%d', obj.n, obj.m);
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

            if nargin == 3 && (isa(varargin{1}, 'ElegantHermiteParameters') || isa(varargin{1}, 'HermiteParameters'))
                % Legacy: ElegantNHermiteBeam(X, Y, hermiteParams)
                params = varargin{1};
                lambda = params.Lambda;
                w0 = params.InitialWaist;
                n = params.n;
                m = params.m;
                legacyCoords{1} = arg1;
                legacyCoords{2} = arg2;
                legacyZ = params.zCoordinate;

            elseif nargin >= 2
                % Modern: ElegantNHermiteBeam(w0, lambda, n, m)
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
            % Compute ENHG_{nm} field at Cartesian grid (X,Y) and depth z.
            %
            % Uses the second independent Hermite solution (NHG) evaluated
            % at complex argument sqrt_alpha * coord, via
            % HermiteComputation.hermiteSecondSolution.
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

            % Complex beam parameter: alpha(z) = i*k / (2*q(z))
            q          = z + 1i * zr;
            alpha      = 1i * k / (2 * q);
            sqrt_alpha = sqrt(alpha);

            % Second Hermite solution at complex argument
            NHn = HermiteComputation.hermiteSecondSolution(obj.n, sqrt_alpha .* X);
            NHm = HermiteComputation.hermiteSecondSolution(obj.m, sqrt_alpha .* Y);

            % Modal Gouy phase shift: (n+m)*psi
            phi_mode = (obj.n + obj.m) * psi;

            field = NHn .* NHm .* exp(-1i * phi_mode) .* carrier;
        end
    end
end