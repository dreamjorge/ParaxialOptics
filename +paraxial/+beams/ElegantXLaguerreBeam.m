classdef ElegantXLaguerreBeam < ParaxialBeam
    % ElegantXLaguerreBeam - Second Elegant Laguerre-Gaussian beam (XLG solution)
    % Compatible with GNU Octave and MATLAB
    %
    % Constructor (Phase 3 API):
    %   beam = ElegantXLaguerreBeam(w0, lambda, l, p)
    %
    % Usage:
    %   field = beam.opticalField(X, Y, z)    % complex field on Cartesian grid
    %   params = beam.getParameters(z)         % GaussianParameters at z
    %   name   = beam.beamName()               % e.g. 'elegant_xlaguerre_2_1'
    %
    % Mathematical differences from standard ElegantLaguerreBeam:
    %
    %   Elegant LG:  L_p^|l|(alpha*r^2)    -- standard associated Laguerre polynomial
    %   Elegant XLG: Y_p^|l|(alpha*r^2)    -- second associated Laguerre solution
    %
    % where alpha(z) = i*k / (2*q(z)), q(z) = z + i*z_R (complex beam parameter).
    %
    % Full field definition (elegant second Laguerre-Gaussian, EXLG_{lp}):
    %
    %   u_{lp}(r,theta,z) = (sqrt(alpha)*r)^|l| * Y_p^|l|(alpha*r^2)
    %                       * u_0(r,z) * exp(i*l*theta) * exp(i*(|l|+2p)*psi(z))
    %
    % where Y_p^|l| is the second independent solution of the associated
    % Laguerre differential equation, computed via PolynomialUtils.xAssociatedLaguerre.
    %
    % The second solution has different radial structure, producing genuinely
    % different wavefront curvature compared to standard ElegantLaguerreBeam.
    %
    % Inner/outer truncation regularization is applied to suppress log(0)
    % singularities at r=0 and divergent tails at large r, matching the
    % regularization used in HankelLaguerre and XLaguerreBeam.
    %
    % The class accepts Cartesian (X, Y) in opticalField and converts to polar
    % internally. Stores only w0, lambda, l, p — no grid or field.
    %
    % Reference: Siegman, "Lasers", University Science Books (1986), Ch. 17;
    %            Papi, "Hankel beams", Structured Light, Elsevier 2023.

    properties
        InitialWaist    % Beam waist at z = 0 (m)
        l               % Topological charge (azimuthal index)
        p               % Radial order
        OpticalField    % Legacy snapshot field compatibility
    end

    methods
        function obj = ElegantXLaguerreBeam(arg1, arg2, varargin)
            % Constructor
            % Modern API:
            %   ElegantXLaguerreBeam(w0, lambda, l, p)
            %
            % Legacy-compatible API:
            %   ElegantXLaguerreBeam(R, Theta, laguerreParams)

            % Call superclass constructor first (MATLAB requirement)
            obj = obj@ParaxialBeam();

            % Determine parameters from input using static helper
            [w0, lambda, l, p, legacyCoords, legacyZ] = ...
                ElegantXLaguerreBeam.parseArgs(arg1, arg2, varargin{:});

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
            [TH, R] = cart2pol(X, Y);
            field   = obj.computeField(R, TH, z);
        end

        function params = getParameters(obj, z)
            params = GaussianParameters(z, obj.InitialWaist, obj.Lambda);
        end

        function name = beamName(obj)
            name = sprintf('elegant_xlaguerre_%d_%d', obj.l, obj.p);
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

            if nargin == 3 && (isa(varargin{1}, 'ElegantLaguerreParameters') || isa(varargin{1}, 'LaguerreParameters'))
                % Legacy: ElegantXLaguerreBeam(R, Theta, laguerreParams)
                params = varargin{1};
                lambda = params.Lambda;
                w0 = params.InitialWaist;
                l = params.l;
                p = params.p;
                legacyCoords{1} = arg1;
                legacyCoords{2} = arg2;
                legacyZ = params.zCoordinate;

            elseif nargin >= 2
                % Modern: ElegantXLaguerreBeam(w0, lambda, l, p)
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
            % Compute EXLG_{lp} field from polar grids (r, theta) and depth z.
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

            % Complex beam parameter: alpha(z) = i*k / (2*q(z))
            q          = z + 1i * zr;
            alpha_val  = 1i * k / (2 * q);

            % Radial amplitude: (sqrt(alpha)*r)^|l|
            m = abs(l);
            amp = (sqrt(alpha_val) .* r).^m;

            % Modal Gouy phase shift: (|l|+2p)*psi
            phi_mode = (m + 2*p) * psi;

            % --- XLG field (second solution) ---
            % Normalization factor matching HankelLaguerre/XLaguerreBeam
            xNorm = (-1)^(p+1) ./ ((p + (m+1)/2).^(m/2));

            % Polynomial argument: alpha*r^2 (complex)
            % Avoid log(0) singularities in xAssociatedLaguerre series evaluation.
            arg = alpha_val .* r.^2;
            arg_safe = max(abs(arg), 1e-12);
            XLpl = xNorm .* PolynomialUtils.xAssociatedLaguerre(p, m, arg_safe);
            XLpl(~isfinite(XLpl)) = 0;

            % Outer truncation: suppress XLG at large r (divergent tail)
            outer_trunc = exp(-(abs(r) ./ (w0 .* sqrt(2*p + m + 1))).^50);

            % Inner regularization: suppress XLG singularity at r->0.
            % For l=0 (m=0), no inner cutoff (keeps XLG behavior at axis).
            % For |l|>0, apply empirical inner regularizer.
            if m == 0
                inner_reg = ones(size(r));
            else
                % Empirical fit: r_cross ≈ w * (|l|+2p+1)^(-0.35)
                r_cross = w .* (m + 2*p + 1).^(-0.35);
                r_cut   = 0.5 .* r_cross;
                r_safe  = max(abs(r), eps);
                inner_reg = exp(-(r_cut ./ r_safe).^6);
            end

            EXLG_field = inner_reg .* outer_trunc .* amp .* XLpl ...
                         .* exp(1i * l * theta) .* exp(-1i * phi_mode) .* carrier;
            EXLG_field(~isfinite(EXLG_field)) = 0;

            field = EXLG_field;
        end
    end
end