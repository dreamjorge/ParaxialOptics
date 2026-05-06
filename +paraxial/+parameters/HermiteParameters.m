classdef HermiteParameters < GaussianParameters
    % HermiteParameters - Parameters for Hermite-Gaussian beams
    % Inherits from GaussianParameters and adds Hermite-specific properties.
    %
    % Mode indices:
    %   n  - order in x (horizontal)
    %   m  - order in y (vertical)
    %
    % Dynamic API (Phase 2, preferred for propagators):
    %   phi = params.phiPhase(z)      -- modal Gouy shift (n+m)*psi(z)
    %   w   = params.hermiteWaist(z)  -- combined spot size w(z)*sqrt(n+m+1)
    %   wx  = params.hermiteWaistX(z) -- x spot size      w(z)*sqrt(n+1)
    %   wy  = params.hermiteWaistY(z) -- y spot size      w(z)*sqrt(m+1)
    %
    % Snapshot API (original, preserved):
    %   params.PhiPhase        -- at stored zCoordinate
    %   params.HermiteWaist    -- at stored zCoordinate
    %   params.HermiteWaistX   -- at stored zCoordinate
    %   params.HermiteWaistY   -- at stored zCoordinate

    properties
        n   % Order in x
        m   % Order in y
    end

    properties (Dependent)
        HermiteWaistX
        HermiteWaistY
        HermiteWaist
        PhiPhase        % Modal Gouy phase shift: (n+m)*psi(z) at stored z
    end

    methods
        function obj = HermiteParameters(z, w0, lambda, n, m)
            % Constructor
            % z:      propagation distance (snapshot)
            % w0:     initial beam waist (m)
            % lambda: wavelength (m)
            % n, m:   Hermite mode orders (default 0)

            if nargin < 3
                error('Usage: params = HermiteParameters(z, w0, lambda, n, m)');
            end

            obj@GaussianParameters(z, w0, lambda);

            if nargin >= 5
                obj.n = n;
                obj.m = m;
            else
                obj.n = 0;
                obj.m = 0;
            end
        end

        % -----------------------------------------------------------------
        % Dynamic evaluation methods (Phase 2 API)
        % -----------------------------------------------------------------

        function phi = phiPhase(obj, z)
            % phiPhase  Modal Gouy phase shift (n+m)*psi(z) at arbitrary z.
            %
            % This is the additional Gouy phase accumulated by mode HG_{nm}
            % relative to the fundamental Gaussian mode. At z = 0 it is zero.
            phi = (obj.n + obj.m) .* obj.gouyPhase(z);
        end

        function w = hermiteWaist(obj, z)
            % hermiteWaist  Combined HG spot size w(z)*sqrt(n+m+1) at arbitrary z.
            w = obj.waist(z) .* sqrt(obj.n + obj.m + 1);
        end

        function wx = hermiteWaistX(obj, z)
            % hermiteWaistX  HG spot size in x: w(z)*sqrt(n+1) at arbitrary z.
            wx = obj.waist(z) .* sqrt(obj.n + 1);
        end

        function wy = hermiteWaistY(obj, z)
            % hermiteWaistY  HG spot size in y: w(z)*sqrt(m+1) at arbitrary z.
            wy = obj.waist(z) .* sqrt(obj.m + 1);
        end

        % -----------------------------------------------------------------
        % Snapshot Dependent property getters (original API, preserved)
        % -----------------------------------------------------------------

        function phi = get.PhiPhase(obj)
            % Total phase shift (n+m)*psi at the stored zCoordinate.
            phi = (obj.n + obj.m) .* obj.GouyPhase;
        end

        function wH = get.HermiteWaistX(obj)
            % Standard Hermite spot size in X: w(z)*sqrt(n+1).
            wH = obj.Waist .* sqrt(obj.n + 1);
        end

        function wH = get.HermiteWaistY(obj)
            wH = obj.Waist .* sqrt(obj.m + 1);
        end

        function wH = get.HermiteWaist(obj)
            % Combined spot size (RMSE): w(z)*sqrt(n+m+1).
            wH = obj.Waist .* sqrt(obj.n + obj.m + 1);
        end
    end

    methods (Static)
        function wH = getWaistOneDirection(z, w0, zr, n)
            % Static: one-dimensional Hermite waist at z.
            w  = w0 * sqrt(1 + (z/zr).^2);
            wH = w * sqrt(n + 1);
        end

        function wH = getWaist(z, w0, zr, n, m)
            % Static: two-dimensional Hermite waist at z.
            w  = w0 * sqrt(1 + (z/zr).^2);
            wH = w * sqrt(n + m + 1);
        end

        function [HG, NHG] = getHermiteSolutions(n, x)
            % getHermiteSolutions - Legacy-compatible Hermite pair (HG, NHG).
            %
            % DEPRECATED (since Phase 3):
            %   Use HermiteComputation.hermiteSolutions(n, x) directly.
            %
            % This entrypoint is preserved for backward compatibility with
            % research scripts that build Hankel-Hermite combinations from
            % the two independent series solutions of the Hermite differential
            % equation. Prefer using HermiteBeam + NHermiteBeam composition.
            %
            % Parameters:
            %   n  - Hermite order
            %   x  - scaled coordinate: sqrt(2)*coord/w
            %
            % Returns:
            %   HG  - standard Hermite polynomial H_n(x)
            %   NHG - second independent solution (normalized partner)
            %
            % See also: HermiteComputation.hermiteSolutions,
            %           HermiteComputation.hermiteSecondSolution
            [HG, NHG] = HermiteComputation.hermiteSolutions(n, x);
        end
    end
end
