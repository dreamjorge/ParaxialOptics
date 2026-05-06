classdef XLaguerreBeam < ParaxialBeam
    % XLaguerreBeam - Second Laguerre-Gaussian beam (XLG solution)
    % Compatible with GNU Octave and MATLAB
    %
    % Constructor (Phase 3 API):
    %   beam = XLaguerreBeam(w0, lambda, l, p)
    %
    % Usage:
    %   field = beam.opticalField(X, Y, z)    % complex field on Cartesian grid
    %   params = beam.getParameters(z)         % GaussianParameters at z
    %   name   = beam.beamName()               % e.g. 'xlaguerre_2_1'
    %
    % Mathematical definition (second Laguerre-Gaussian, XLG_{lp}):
    %
    %   u_{lp}(r,theta,z) = (sqrt(2)*r/w)^|l| * Y_p^|l|(2*r^2/w^2)
    %                       * u_0(r,z) * exp(i*l*theta) * exp(i*(|l|+2p)*psi(z))
    %
    % where:
    %   Y_p^|l|  - second independent solution of the associated Laguerre DE
    %             (logarithmic + digamma series, via xAssociatedLaguerre)
    %   w = w(z) - beam waist at z
    %   u_0(r,z) - fundamental Gaussian carrier field
    %   psi(z)   - Gouy phase = arctan(z / z_R)
    %
    % The second Laguerre solution uses PolynomialUtils.xAssociatedLaguerre
    % with the same inner/outer truncation regularization as HankelLaguerre
    % to suppress log(0) singularities at r=0 and divergent tails at large r.
    %
    % The class accepts Cartesian (X, Y) in opticalField and converts to polar
    % internally. The class stores only w0, lambda, l, p — no grid or field.
    %
    % Reference: Papi, "Hankel beams", Structured Light, Elsevier 2023.

    properties
        InitialWaist    % Beam waist at z = 0 (m)
        l               % Topological charge (azimuthal index)
        p               % Radial order
        OpticalField    % Legacy snapshot field compatibility
    end

    methods
        function obj = XLaguerreBeam(arg1, arg2, varargin)
            % Constructor
            % Modern API:
            %   XLaguerreBeam(w0, lambda, l, p)
            %
            % Legacy-compatible API:
            %   XLaguerreBeam(R, Theta, laguerreParams)

            % Call superclass constructor first (MATLAB requirement)
            obj = obj@ParaxialBeam();

            % Determine parameters from input using static helper
            [w0, lambda, l, p, legacyCoords, legacyZ] = ...
                XLaguerreBeam.parseArgs(arg1, arg2, varargin{:});

            % Initialize parent class state
            if ~isempty(lambda)
                obj.Lambda = lambda;
                obj.k = 2 * pi / lambda;
            end

            % Initialize subclass state
            obj.InitialWaist = w0;
            obj.l = l;
            obj.p = p;

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
            %
            % Converts Cartesian to polar internally, then evaluates the XLG field.
            [TH, R] = cart2pol(X, Y);
            field   = obj.computeField(R, TH, z);
        end

        function params = getParameters(obj, z)
            % getParameters - GaussianParameters evaluated at axial position z.
            params = GaussianParameters(z, obj.InitialWaist, obj.Lambda);
        end

        function name = beamName(obj)
            % beamName - Returns identifier string, e.g. 'xlaguerre_2_1'.
            name = sprintf('xlaguerre_%d_%d', obj.l, obj.p);
        end
    end

    methods (Static)
        function [w0, lambda, l, p, legacyCoords, legacyZ] = parseArgs(arg1, arg2, varargin)
            % Static helper to parse constructor arguments
            w0 = [];
            lambda = [];
            l = 0;
            p = 0;
            legacyCoords = {[], []};
            legacyZ = 0;

            if nargin < 2
                return;
            end

            if nargin == 3 && isa(varargin{1}, 'LaguerreParameters')
                % Legacy: XLaguerreBeam(R, Theta, laguerreParams)
                params = varargin{1};
                lambda = params.Lambda;
                w0 = params.InitialWaist;
                l = params.l;
                p = params.p;
                legacyCoords{1} = arg1;
                legacyCoords{2} = arg2;
                legacyZ = params.zCoordinate;

            elseif nargin >= 2
                % Modern: XLaguerreBeam(w0, lambda, l, p)
                w0 = arg1;
                lambda = arg2;
                if numel(varargin) >= 2
                    l = varargin{1};
                    p = varargin{2};
                end
            end
        end
    end

    % -----------------------------------------------------------------
    % Private helpers
    % -----------------------------------------------------------------
    methods (Access = private)
        function field = computeField(obj, r, theta, z)
            % Compute XLG_{lp} field from polar grids (r, theta) and depth z.
            %
            % Uses xAssociatedLaguerre (second associated Laguerre solution)
            % with inner/outer truncation regularization to suppress
            % log(0) singularities at r=0 and divergent tails at large r.
            w0     = obj.InitialWaist;
            lambda = obj.Lambda;
            k      = obj.k;
            l      = obj.l;
            p      = obj.p;
            zr     = pi * w0^2 / lambda;

            w   = w0 * sqrt(1 + (z/zr)^2);
            Rc  = z  * (1 + (zr/z)^2);
            if z == 0, Rc = Inf; end
            psi = atan2(z, zr);

            % Gaussian carrier field u_0(r,z)
            amplitude  = (w0 ./ w) .* exp(-r.^2 ./ w.^2);
            phase_z    = -1i * k * z;
            phase_curv = 1i * k * r.^2 ./ (2 * Rc);
            phase_curv(isinf(Rc)) = 0;
            phase_gouy = -1i * psi;
            carrier    = amplitude .* exp(phase_z + phase_curv + phase_gouy);

            % Radial amplitude: (sqrt(2)*r/w)^|l|
            amp = (sqrt(2) * r ./ w).^abs(l);

            % Modal Gouy phase shift: (|l|+2p)*psi
            phi_mode = (abs(l) + 2*p) * psi;

            % Argument for radial polynomials
            arg = 2 * r.^2 ./ w.^2;

            % --- XLG field (second solution) ---
            % Normalization factor matching HankelLaguerre
            m = abs(l);
            xNorm = (-1)^(p+1) ./ ((p + (m+1)/2).^(m/2));

            % Avoid log(0) singularities in xAssociatedLaguerre series evaluation.
            arg_safe = max(arg, 1e-12);
            XLpl = xNorm .* PolynomialUtils.xAssociatedLaguerre(p, m, arg_safe);
            XLpl(~isfinite(XLpl)) = 0;

            % Outer truncation: suppress XLG at large r (divergent tail)
            outer_trunc = exp(-(r ./ (w0 .* sqrt(2*p + abs(l) + 1))).^50);

            % Inner regularization: suppress XLG singularity at r->0.
            % For l=0, no inner cutoff (keeps XLG behavior at axis).
            % For |l|>0, apply empirical inner regularizer.
            if m == 0
                inner_reg = ones(size(r));
            else
                % Empirical fit: r_cross ≈ w * (|l|+2p+1)^(-0.35)
                r_cross = w .* (abs(l) + 2*p + 1).^(-0.35);
                r_cut   = 0.5 .* r_cross;
                r_safe  = max(r, eps);
                inner_reg = exp(-(r_cut ./ r_safe).^6);
            end

            XLG_field = inner_reg .* outer_trunc .* amp .* XLpl ...
                        .* exp(1i * l * theta) .* exp(-1i * phi_mode) .* carrier;
            XLG_field(~isfinite(XLG_field)) = 0;

            field = XLG_field;
        end
    end
end