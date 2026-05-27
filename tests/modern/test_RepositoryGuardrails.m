% Guardrail: keep repository cleanup and canonical API documentation aligned

repoRoot = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repoRoot, 'ParaxialBeams'));

fprintf('=== Repository Guardrail Tests ===\n\n');
passed = 0;
failed = 0;

% -------------------------------------------------------------------------
% Local tooling and CI hygiene
% -------------------------------------------------------------------------
gitignorePath = fullfile(repoRoot, '.gitignore');
circleCiPath = fullfile(repoRoot, '.circleci', 'config.yml');
if exist(gitignorePath, 'file')
    gitignoreContent = fileread(gitignorePath);
else
    gitignoreContent = '';
end

if ~isempty(strfind(gitignoreContent, '.opencode/'))
    fprintf('  PASS: .opencode/ is ignored as local tooling\n');
    passed = passed + 1;
else
    fprintf('  FAIL: .opencode/ is not listed in .gitignore\n');
    failed = failed + 1;
end

if ~exist(circleCiPath, 'file')
    fprintf('  PASS: stale CircleCI config is absent\n');
    passed = passed + 1;
else
    fprintf('  FAIL: stale CircleCI config still exists at %s\n', circleCiPath);
    failed = failed + 1;
end

% -------------------------------------------------------------------------
% Documentation invariants
% -------------------------------------------------------------------------
readmePath = fullfile(repoRoot, 'README.md');
roadmapPath = fullfile(repoRoot, 'docs', 'ROADMAP.md');
addonsInventoryPath = fullfile(repoRoot, 'docs', 'ADDONS_INVENTORY.md');
compatReductionPath = fullfile(repoRoot, 'docs', 'COMPATIBILITY_REDUCTION.md');
portableRunnerPath = fullfile(repoRoot, 'tests', 'portable_runner.m');
wavefrontTestPath = fullfile(repoRoot, 'tests', 'modern', 'test_Wavefront.m');
addonsDir = fullfile(repoRoot, 'ParaxialBeams', 'Addons');
if exist(readmePath, 'file')
    readmeContent = fileread(readmePath);
else
    readmeContent = '';
end
if exist(roadmapPath, 'file')
    roadmapContent = fileread(roadmapPath);
else
    roadmapContent = '';
end
if exist(addonsInventoryPath, 'file')
    addonsInventoryContent = fileread(addonsInventoryPath);
else
    addonsInventoryContent = '';
end
if exist(compatReductionPath, 'file')
    compatReductionContent = fileread(compatReductionPath);
else
    compatReductionContent = '';
end
if exist(portableRunnerPath, 'file')
    portableRunnerContent = fileread(portableRunnerPath);
else
    portableRunnerContent = '';
end
if exist(wavefrontTestPath, 'file')
    wavefrontTestContent = fileread(wavefrontTestPath);
else
    wavefrontTestContent = '';
end

if ~isempty(strfind(readmeContent, 'GitHub Actions is the canonical CI system'))
    fprintf('  PASS: README documents GitHub Actions as canonical CI\n');
    passed = passed + 1;
else
    fprintf('  FAIL: README does not document GitHub Actions as canonical CI\n');
    failed = failed + 1;
end

if ~isempty(strfind(readmeContent, '+paraxial/')) && ~isempty(strfind(readmeContent, 'deprecated'))
    fprintf('  PASS: README documents canonical +paraxial/ and deprecated src/ surfaces\n');
    passed = passed + 1;
else
    fprintf('  FAIL: README canonical/deprecated namespace documentation is incomplete\n');
    failed = failed + 1;
end

if ~exist(fullfile(repoRoot, '.atl', 'skill-registry.md'), 'file')
    fprintf('  PASS: local skill registry is not part of repository surface\n');
    passed = passed + 1;
else
    fprintf('  FAIL: local skill registry is still present in repository surface\n');
    failed = failed + 1;
end

% -------------------------------------------------------------------------
% Runner path policy and roadmap governance
% -------------------------------------------------------------------------
if ~isempty(strfind(portableRunnerContent, 'Canonical package namespace')) && ...
   ~isempty(strfind(portableRunnerContent, "addpath(repoRoot)")) && ...
   isempty(strfind(portableRunnerContent, 'Add modern library paths (src/)'))
    fprintf('  PASS: portable runner documents canonical package parent path policy\n');
    passed = passed + 1;
else
    fprintf('  FAIL: portable runner path policy is stale or ambiguous\n');
    failed = failed + 1;
end

if ~isempty(strfind(portableRunnerContent, 'Deprecated compatibility paths (src/)'))
    fprintf('  PASS: portable runner labels src/ paths as deprecated compatibility\n');
    passed = passed + 1;
else
    fprintf('  FAIL: portable runner does not label src/ paths as deprecated compatibility\n');
    failed = failed + 1;
end

% onCleanup guarantees restoration on ANY exit (normal, error, interrupt).
% The cleanup anonymous function holds the restoration call inline.
if ~isempty(strfind(portableRunnerContent, "warning('off', 'BeamFactory:deprecated')")) && ...
   ~isempty(strfind(portableRunnerContent, 'cleanupObj = onCleanup(@() warning(previousDeprecatedWarningState.state, '))
    fprintf('  PASS: portable runner suppresses expected deprecated-adapter warning storm\n');
    passed = passed + 1;
else
    fprintf('  FAIL: portable runner does not suppress/restore expected deprecated-adapter warnings\n');
    failed = failed + 1;
end

staleWavefrontRoot = ~isempty(strfind(wavefrontTestContent, "repoRoot = fullfile(testDir, '..');"));
addsProjectPaths = ~isempty(strfind(wavefrontTestContent, "addpath(fullfile(repoRoot, 'src'")) || ...
                   ~isempty(strfind(wavefrontTestContent, "addpath(fullfile(repoRoot, 'ParaxialBeams'"));
usesRepoRootParent = ~isempty(strfind(wavefrontTestContent, "repoRoot = fullfile(testDir, '..', '..');")) && ...
                     ~isempty(strfind(wavefrontTestContent, 'addpath(repoRoot)'));

if ~staleWavefrontRoot && ~addsProjectPaths && usesRepoRootParent
    fprintf('  PASS: Wavefront direct test uses repo-root package parent path setup\n');
    passed = passed + 1;
elseif ~staleWavefrontRoot && usesRepoRootParent
    fprintf('  PASS: Wavefront direct test uses repo-root package parent path setup\n');
    passed = passed + 1;
else
    fprintf('  FAIL: Wavefront direct test has stale repo-root path setup\n');
    failed = failed + 1;
end

if ~isempty(strfind(roadmapContent, 'Completed Cleanup Baseline')) && ...
   ~isempty(strfind(roadmapContent, 'No removal of `src/` without a dedicated migration SDD')) && ...
   ~isempty(strfind(roadmapContent, 'Keep `docs/` focused on public architecture'))
    fprintf('  PASS: roadmap owns active modernization next steps\n');
    passed = passed + 1;
else
    fprintf('  FAIL: roadmap governance for active modernization next steps is incomplete\n');
    failed = failed + 1;
end

if ~isempty(strfind(addonsInventoryContent, 'runtime-required')) && ...
   ~isempty(strfind(addonsInventoryContent, 'plotting-only')) && ...
   ~isempty(strfind(addonsInventoryContent, 'needs-investigation')) && ...
   ~isempty(strfind(addonsInventoryContent, 'Plots_Functions'))
    fprintf('  PASS: addons inventory classifies legacy addon surfaces\n');
    passed = passed + 1;
else
    fprintf('  FAIL: addons inventory is missing required classifications\n');
    failed = failed + 1;
end

addonEntries = dir(addonsDir);
missingAddonEntries = {};
for i = 1:numel(addonEntries)
    entryName = addonEntries(i).name;
    if strcmp(entryName, '.') || strcmp(entryName, '..')
        continue;
    end

    inventoryEntry = ['ParaxialBeams/Addons/' entryName];
    if addonEntries(i).isdir
        inventoryEntry = [inventoryEntry '/'];
    end

    if isempty(strfind(addonsInventoryContent, inventoryEntry))
        missingAddonEntries{end+1} = inventoryEntry; %#ok<AGROW>
    end
end

if isempty(missingAddonEntries)
    fprintf('  PASS: addons inventory lists every top-level addon entry\n');
    passed = passed + 1;
else
    fprintf('  FAIL: addons inventory is missing top-level addon entries\n');
    for i = 1:numel(missingAddonEntries)
        fprintf('    - %s\n', missingAddonEntries{i});
    end
    failed = failed + 1;
end

if ~isempty(strfind(compatReductionContent, 'Cleanup-only changes MUST NOT remove `src/`')) && ...
   ~isempty(strfind(compatReductionContent, 'tests/legacy_compat/')) && ...
   ~isempty(strfind(compatReductionContent, 'Dedicated SDD change'))
    fprintf('  PASS: compatibility reduction plan defines src/ migration gates\n');
    passed = passed + 1;
else
    fprintf('  FAIL: compatibility reduction plan is missing src/ migration gates\n');
    failed = failed + 1;
end

% -------------------------------------------------------------------------
% Canonical examples must not regress to direct src/beams usage
% -------------------------------------------------------------------------
canonicalDir = fullfile(repoRoot, 'examples', 'canonical');
exampleFiles = dir(fullfile(canonicalDir, '*.m'));
exampleViolations = {};

for i = 1:numel(exampleFiles)
    filePath = fullfile(canonicalDir, exampleFiles(i).name);
    content = fileread(filePath);

    if ~isempty(strfind(content, "addpath('src/beams')")) || ...
       ~isempty(strfind(content, 'addpath("src/beams")'))
        exampleViolations{end+1} = filePath; %#ok<AGROW>
    end
end

if isempty(exampleViolations)
    fprintf('  PASS: canonical examples avoid direct src/beams path usage\n');
    passed = passed + 1;
else
    fprintf('  FAIL: canonical examples use direct src/beams paths\n');
    for i = 1:numel(exampleViolations)
        fprintf('    - %s\n', exampleViolations{i});
    end
    failed = failed + 1;
end

% -------------------------------------------------------------------------
% BeamFactory supported registry stays explicit
% -------------------------------------------------------------------------
expectedTypes = {'gaussian', 'hermite', 'laguerre', ...
                 'elegant_hermite', 'elegant_laguerre', ...
                 'hankel', 'hankel_hermite'};
supportedTypes = BeamFactory.supportedTypes();
missingTypes = {};

for i = 1:numel(expectedTypes)
    if ~any(strcmp(supportedTypes, expectedTypes{i}))
        missingTypes{end+1} = expectedTypes{i}; %#ok<AGROW>
    end
end

if isempty(missingTypes)
    fprintf('  PASS: BeamFactory supported type registry contains expected public names\n');
    passed = passed + 1;
else
    fprintf('  FAIL: BeamFactory supported type registry is missing expected names\n');
    for i = 1:numel(missingTypes)
        fprintf('    - %s\n', missingTypes{i});
    end
    failed = failed + 1;
end

fprintf('\n=== Repository Guardrails: %d/%d passed ===\n', passed, passed + failed);

% -------------------------------------------------------------------------
% No autosave artifacts in ParaxialBeams/Addons/ (recursive scan)
% -------------------------------------------------------------------------
addonsDir = fullfile(repoRoot, 'ParaxialBeams', 'Addons');
% Recursively scan all subdirectories within Addons to catch nested autosave files
allEntries = dir(fullfile(addonsDir, '**', '*.asv'));
asvFiles = {allEntries.name};

if isempty(asvFiles)
    fprintf('  PASS: no .asv autosave artifacts in ParaxialBeams/Addons/\n');
    passed = passed + 1;
else
    fprintf('  FAIL: .asv autosave artifacts found in ParaxialBeams/Addons/:\n');
    for i = 1:numel(asvFiles)
        fprintf('    - %s\n', asvFiles{i});
    end
    failed = failed + 1;
end

% -------------------------------------------------------------------------
% Addons cleanup readiness gates
% -------------------------------------------------------------------------
readinessPath = fullfile(repoRoot, 'docs', 'ADDONS_CLEANUP_READINESS.md');
if exist(readinessPath, 'file')
    readinessContent = fileread(readinessPath);
else
    readinessContent = '';
end

if ~isempty(strfind(readinessContent, 'License and Origin Review Required')) && ...
   ~isempty(strfind(readinessContent, 'Required Follow-up SDDs')) && ...
   ~isempty(strfind(readinessContent, 'Keep During Compatibility Window'))
    fprintf('  PASS: addons cleanup readiness defines review gates\n');
    passed = passed + 1;
else
    fprintf('  FAIL: addons cleanup readiness is missing review gates\n');
    failed = failed + 1;
end

if failed ~= 0
    error('Repository guardrails failed: %d violation group(s).', failed);
end
