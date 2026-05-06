classdef HermiteComputation
    % HermiteComputation - Static computation utilities for Hermite polynomials
    % Compatible with GNU Octave and MATLAB
    %
    % Purpose:
    %   Provides pure, stateless static methods for Hermite polynomial evaluation.
    %   This class owns the canonical implementations; parameter classes delegate here.
    %
    % Usage:
    %   [HG, NHG] = HermiteComputation.hermiteSolutions(nu, x)
    %
    % Notes:
    %   The hermiteSolutions algorithm computes two independent series solutions
    %   (HG, NHG) of the Hermite differential equation. These are used by
    %   Hankel-Hermite beam constructions in research scripts.

    methods (Static)

        function [HG, NHG] = hermiteSolutions(nu, x)
            % hermiteSolutions - Legacy-compatible Hermite pair (HG, NHG).
            %
            % Computes two independent series solutions of the Hermite differential
            % equation, used historically for Hankel-Hermite combinations.
            %
            % Input:
            %   nu  - order parameter (used as floor(nu + nu/2) internally)
            %   x   - evaluation point(s), scalar or vector
            %
            % Output:
            %   HG   - "standard" Hermite function
            %   NHG  - "normalized" Hermite function (orthogonal partner)
            %
            % Example:
            %   [HG, NHG] = HermiteComputation.hermiteSolutions(2, linspace(-1,1,11))

            an = 1;
            bn = 1;

            fpar = 1;
            fimpar = x;

            n = floor(nu + nu / 2);
            for k = 0:n
                an = an .* (2 * ((2 * k) - nu)) ./ (((2 * k) + 1) * ((2 * k) + 2));
                fpar = fpar + an .* (x).^(2 * k + 2);

                bn = bn .* (2 * ((2 * k + 1) - nu)) ./ (((2 * k + 1) + 1) * ((2 * k + 1) + 2));
                fimpar = fimpar + bn .* (x).^(2 * k + 3);
            end

            norma = sqrt(2 * nu + 1);

            if mod(nu, 2) ~= 0
                fimpar = norma .* fimpar;
                HG = fimpar;
                NHG = fpar;
            else
                fimpar = norma .* fimpar;
                NHG = fimpar;
                HG = fpar;
            end
        end

        function NHG = hermiteSecondSolution(n, x)
            % hermiteSecondSolution - Second independent Hermite solution (NHG).
            %
            % Returns the normalized partner of the standard Hermite polynomial H_n.
            % NHG is orthogonal to H_n and is given by the companion solution of
            % the Hermite differential equation.
            %
            % Input:
            %   n  - Hermite order (integer)
            %   x  - evaluation point(s), scalar or vector
            %
            % Output:
            %   NHG - second independent Hermite solution (normalized partner)
            %
            % Example:
            %   NHG = HermiteComputation.hermiteSecondSolution(2, linspace(-2,2,11))

            % Delegate to hermiteSolutions and return only NHG
            [~, NHG] = HermiteComputation.hermiteSolutions(n, x);
        end

    end
end
