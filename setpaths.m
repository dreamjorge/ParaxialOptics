function setpaths()
    % setpaths - Initialize path for ParaxialOptics
    % Call this function before using the library, or add the
    % individual directories to your path.
    %
    % DUAL-PATH SUPPORT:
    % This function adds both the legacy 'src/' paths and the modern
    % '+paraxial/' package paths. Users can choose which to use.
    %
    % Legacy structure (src/):
    %   addpath('src/beams');
    %   addpath('src/parameters');
    %   ...
    %
    % Modern package (+paraxial/):
    %   addpath(repoRoot);  % package parent enables 'import paraxial.*'
    %   import paraxial.beams.GaussianBeam
    %
    % Utilities (ParaxialBeams/):
    %   addpath('ParaxialBeams');
    %   addpath('ParaxialBeams/Addons');

    scriptPath = fileparts(mfilename('fullpath'));

    %% Modern package (+paraxial/):
    % Recomendada para desarrollo, onboarding y uso actual.
    addpath(scriptPath); % +paraxial parent (namespace canonical)
    % Add package subdirectories for Octave compatibility
    addpath(fullfile(scriptPath, '+paraxial', '+beams'));
    addpath(fullfile(scriptPath, '+paraxial', '+parameters'));
    addpath(fullfile(scriptPath, '+paraxial', '+computation'));
    addpath(fullfile(scriptPath, '+paraxial', '+propagation', '+field'));
    addpath(fullfile(scriptPath, '+paraxial', '+propagation', '+rays'));
    addpath(fullfile(scriptPath, '+paraxial', '+visualization'));
    % Utilities
    addIfDir(fullfile(scriptPath, 'ParaxialBeams'));
    addIfDir(fullfile(scriptPath, 'ParaxialBeams', 'Addons'));
    addIfDir(fullfile(scriptPath, 'ParaxialBeams', 'Addons', 'Plots_Functions'));

    %% Legacy compatibility aliases
    addIfDir(fullfile(scriptPath, 'legacy', 'compat'));

    %% Tests
    addIfDir(fullfile(scriptPath, 'tests'));

    %% Legacy library structure (src/) — USO RESTRINGIDO
    % Solo necesario para correr scripts heredados o en sesiones de migración.
    % No es necesario para el uso moderno ni para el onboarding/documentación.
    % Para compatibilidad temporal, descomentar el bloque siguiente únicamente si es requerido:
    % addpath(fullfile(scriptPath, 'src', 'beams'));
    % addpath(fullfile(scriptPath, 'src', 'parameters'));
    % addpath(fullfile(scriptPath, 'src', 'computation'));
    % addpath(fullfile(scriptPath, 'src', 'propagation', 'field'));
    % addpath(fullfile(scriptPath, 'src', 'propagation', 'rays'));
    % addpath(fullfile(scriptPath, 'src', 'visualization'));

    fprintf('Path configurado para ParaxialOptics (solo +paraxial/). Legacy src/ solo habilitar si es estrictamente necesario.\n');
end

function addIfDir(pathName)
    if exist(pathName, 'dir')
        addpath(pathName);
    end
end
