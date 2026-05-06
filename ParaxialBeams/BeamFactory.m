classdef BeamFactory
    % BeamFactory - Factory for creating any ParaxialBeam by name
    % Compatible with GNU Octave and MATLAB
    %
    % Usage:
    %   beam = BeamFactory.create(type, w0, lambda)
    %   beam = BeamFactory.create(type, w0, lambda, Name, Value, ...)
    %
    % Supported types and their optional parameters:
    %
    %   'gaussian'          — GaussianBeam(w0, lambda)
    %   'hermite'           — HermiteBeam(w0, lambda, n, m)
    %                         Name-Value: 'n' (default 0), 'm' (default 0)
    %   'laguerre'          — LaguerreBeam(w0, lambda, l, p)
    %                         Name-Value: 'l' (default 0), 'p' (default 0)
    %   'elegant_hermite'   — ElegantHermiteBeam(w0, lambda, n, m)
    %                         Name-Value: 'n' (default 0), 'm' (default 0)
    %   'elegant_laguerre'  — ElegantLaguerreBeam(w0, lambda, l, p)
    %                         Name-Value: 'l' (default 0), 'p' (default 0)
    %   'hankel'            — HankelLaguerre(w0, lambda, l, p, hankelType)
    %                         Name-Value: 'l' (default 0), 'p' (default 0),
    %                                     'type' (default 1, values: 1 or 2)
    %   'hankel_hermite'    — HankelHermite(w0, lambda, n, m, hankelType)
    %                         Name-Value: 'n' (default 0), 'm' (default 0),
    %                                     'type' (default 11, values: 11, 12, 21, 22)
    %
    % Examples:
    %   beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);
    %   beam = BeamFactory.create('hermite', 100e-6, 632.8e-9, 'n', 2, 'm', 1);
    %   beam = BeamFactory.create('laguerre', 100e-6, 632.8e-9, 'l', 1, 'p', 0);
    %   beam = BeamFactory.create('hankel', 100e-6, 632.8e-9, 'l', 2, 'type', 1);
    %   beam = BeamFactory.create('hankel_hermite', 100e-6, 632.8e-9, 'n', 1, 'm', 1, 'type', 11);
    %
    % Extensibility:
    %   To add a new beam type, add a case to the switch in BeamFactory.create().
    %   No changes to propagators, tests, or calling code required.

    methods (Static)
        function beam = create(type, w0, lambda, varargin)
            % create - Instantiate a ParaxialBeam by name.
            %
            % Resolves beam class via Strangler Fig pattern:
            %   1. Try +paraxial/ (canonical) namespace first
            %   2. Fall back to src/ with deprecation warning
            %
            % Parameters:
            %   type   (char):   beam type identifier (see class header)
            %   w0     (scalar): beam waist at z = 0 (m)
            %   lambda (scalar): wavelength (m)
            %   varargin:        Name-Value pairs for mode indices
            %
            % Returns:
            %   beam (ParaxialBeam subclass)

            % Parse optional Name-Value pairs
            n     = BeamFactory.getOpt(varargin, 'n',    0);
            m     = BeamFactory.getOpt(varargin, 'm',    0);
            l     = BeamFactory.getOpt(varargin, 'l',    0);
            p     = BeamFactory.getOpt(varargin, 'p',    0);
            htype = BeamFactory.getOpt(varargin, 'type', 1);

            % Resolve class location (canonical vs legacy)
            [className, canonical, legacy, htype_out] = BeamFactory.resolveClass(type, n, m, l, p, htype);

            % Build positional constructor args (NOT name-value pairs)
            % Use htype_out (normalized) instead of htype for hankel_hermite
            constructorArgs = BeamFactory.buildConstructorArgs(type, w0, lambda, n, m, l, p, htype_out);

            % Try +paraxial/ first (canonical)
            if BeamFactory.classExists(canonical)
                beam = feval(canonical, constructorArgs{:});

            % Fallback to src/ with deprecation warning
            elseif exist(legacy, 'file')
                warning('BeamFactory:deprecatedSrc', ...
                    ['src/beams/%s is deprecated. ' ...
                     'Use BeamFactory.create(''%s'', ...) or %s directly.'], ...
                    className, type, canonical);
                beam = feval(className, constructorArgs{:});

            else
                error('BeamFactory:classNotFound', ...
                    'Neither +paraxial nor src/ version of %s found.', className);
            end
        end

        function types = supportedTypes()
            % supportedTypes - Return cell array of all supported type names.
            types = {'gaussian', 'hermite', 'laguerre', ...
                     'elegant_hermite', 'elegant_laguerre', ...
                     'hankel', 'hankel_hermite', ...
                     'nhermite', 'xlaguerre', ...
                     'elegant_nhermite', 'elegant_xlaguerre'};
        end
    end

    % -----------------------------------------------------------------
    % Class resolution (Strangler Fig routing)
    % -----------------------------------------------------------------
    methods (Static)
        function [className, canonical, legacy, htype_out] = resolveClass(type, n, m, l, p, htype)
            % resolveClass - Map beam type to canonical and legacy class paths.
            %
            % Returns:
            %   className  (char):  plain class name for feval
            %   canonical (char):   +paraxial/ package.class path
            %   legacy    (char):   src/beams/ClassName.m path
            %   htype_out (scalar): normalized hankel type (for hankel_hermite)

            if nargin < 2, n = 0; end
            if nargin < 3, m = 0; end
            if nargin < 4, l = 0; end
            if nargin < 5, p = 0; end
            if nargin < 6, htype = 1; end

            htype_out = htype;  % default: no change

            switch lower(type)
                case 'gaussian'
                    className = 'GaussianBeam';
                    canonical = 'paraxial.beams.GaussianBeam';
                    legacy = 'src/beams/GaussianBeam.m';

                case 'hermite'
                    className = 'HermiteBeam';
                    canonical = 'paraxial.beams.HermiteBeam';
                    legacy = 'src/beams/HermiteBeam.m';

                case 'laguerre'
                    className = 'LaguerreBeam';
                    canonical = 'paraxial.beams.LaguerreBeam';
                    legacy = 'src/beams/LaguerreBeam.m';

                case {'elegant_hermite', 'eleganth', 'elegant_hg'}
                    className = 'ElegantHermiteBeam';
                    canonical = 'paraxial.beams.ElegantHermiteBeam';
                    legacy = 'src/beams/ElegantHermiteBeam.m';

                case {'elegant_laguerre', 'elegantl', 'elegant_lg'}
                    className = 'ElegantLaguerreBeam';
                    canonical = 'paraxial.beams.ElegantLaguerreBeam';
                    legacy = 'src/beams/ElegantLaguerreBeam.m';

                case {'hankel', 'hankel_laguerre'}
                    className = 'HankelLaguerre';
                    canonical = 'paraxial.beams.HankelLaguerre';
                    legacy = 'src/beams/HankelLaguerre.m';

                case {'hankel_hermite', 'hankelh'}
                    if htype < 10, htype_out = 11; end
                    className = 'HankelHermite';
                    canonical = 'paraxial.beams.HankelHermite';
                    legacy = 'src/beams/HankelHermite.m';

                case {'nhermite', 'nherm'}
                    className = 'NHermiteBeam';
                    canonical = 'paraxial.beams.NHermiteBeam';
                    legacy = 'src/beams/NHermiteBeam.m';

                case {'xlaguerre', 'xlg'}
                    className = 'XLaguerreBeam';
                    canonical = 'paraxial.beams.XLaguerreBeam';
                    legacy = 'src/beams/XLaguerreBeam.m';

                case {'elegant_nhermite', 'elegant_nherm'}
                    className = 'ElegantNHermiteBeam';
                    canonical = 'paraxial.beams.ElegantNHermiteBeam';
                    legacy = 'src/beams/ElegantNHermiteBeam.m';

                case {'elegant_xlaguerre', 'elegant_xlg'}
                    className = 'ElegantXLaguerreBeam';
                    canonical = 'paraxial.beams.ElegantXLaguerreBeam';
                    legacy = 'src/beams/ElegantXLaguerreBeam.m';

                otherwise
                    error('BeamFactory:unknownType', ...
                        'Unknown beam type "%s". Supported: gaussian, hermite, laguerre, elegant_hermite, elegant_laguerre, hankel, hankel_hermite, nhermite, xlaguerre, elegant_nhermite, elegant_xlaguerre.', ...
                        type);
            end
        end

        function exists = classExists(className)
            % classExists - Check if a class is available on the path.
            %
            % Uses which() to locate the class — if it resolves to +paraxial/
            % directory, it's the canonical version. Otherwise checks plain class.
            %
            % Note: exist('package.class', 'class') does not work in Octave
            % for +package directories, so we use which() instead.
            resolved = which(className);
            if isempty(resolved)
                exists = false;
            else
                % Class found — check if it's from +paraxial/ (canonical)
                exists = ~isempty(strfind(resolved, '+paraxial'));
            end
        end
    end

    % -----------------------------------------------------------------
    % Private helpers
    % -----------------------------------------------------------------
    methods (Static, Access = private)
        function val = getOpt(args, key, default)
            % getOpt - Extract value for 'key' from Name-Value list args.
            val = default;
            for i = 1:2:numel(args)-1
                if strcmpi(args{i}, key)
                    val = args{i+1};
                    return
                end
            end
        end

        function args = buildConstructorArgs(type, w0, lambda, n, m, l, p, htype)
            % buildConstructorArgs - Build positional args for beam constructor.
            %
            % Beam constructors expect positional args, NOT name-value pairs.
            % This helper maps beam type to the correct constructor signature.
            %
            % Constructor signatures:
            %   gaussian          -> (w0, lambda)
            %   hermite          -> (w0, lambda, n, m)
            %   laguerre         -> (w0, lambda, l, p)
            %   elegant_hermite  -> (w0, lambda, n, m)
            %   elegant_laguerre -> (w0, lambda, l, p)
            %   hankel           -> (w0, lambda, l, p, htype)
            %   hankel_hermite  -> (w0, lambda, n, m, htype)

            switch lower(type)
                case 'gaussian'
                    args = {w0, lambda};

                case {'hermite', 'elegant_hermite', 'nhermite', 'elegant_nhermite'}
                    args = {w0, lambda, n, m};

                case {'laguerre', 'elegant_laguerre', 'xlaguerre', 'elegant_xlaguerre'}
                    args = {w0, lambda, l, p};

                case {'hankel', 'hankel_laguerre'}
                    args = {w0, lambda, l, p, htype};

                case {'hankel_hermite', 'hankelh'}
                    args = {w0, lambda, n, m, htype};

                otherwise
                    error('BeamFactory:unknownType', ...
                        'Unknown beam type "%s".', type);
            end
        end
    end
end
