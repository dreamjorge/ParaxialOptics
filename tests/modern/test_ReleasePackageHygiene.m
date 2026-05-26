function failures = test_ReleasePackageHygiene()
    fprintf('Running release package hygiene tests...\n');
    failures = 0;

    repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));

    forbiddenTracked = {
        fullfile('.atl', 'skill-registry.md'), ...
        fullfile('.opencode'), ...
        'plan.md', ...
        'AGENTS.md'};

    command = sprintf('git -C "%s" ls-files', repoRoot);
    [status, tracked] = system(command);
    if status ~= 0
        fprintf('  SKIP: git ls-files unavailable\n');
        return;
    end

    normalized = strrep(tracked, '\\', '/');
    trackedFiles = strsplit(strtrim(normalized), '\n');
    for i = 1:numel(forbiddenTracked)
        needle = strrep(forbiddenTracked{i}, '\\', '/');
        found = false;
        for j = 1:numel(trackedFiles)
            trackedFile = trackedFiles{j};
            if strcmp(trackedFile, needle) || strncmp(trackedFile, [needle '/'], length(needle) + 1)
                found = true;
                break;
            end
        end
        if found
            fprintf('  FAIL: forbidden tracked artifact %s\n', forbiddenTracked{i});
            failures = failures + 1;
        end
    end

    stagingScript = fullfile(repoRoot, 'tools', 'stage_release_package.sh');
    if ~exist(stagingScript, 'file')
        fprintf('  FAIL: missing release staging script\n');
        failures = failures + 1;
    end

    rootPlan = fullfile(repoRoot, 'plan.md');
    archivedPlan = fullfile(repoRoot, 'docs', 'archive', 'pre-v1-hardening-plan.md');
    if exist(rootPlan, 'file')
        fprintf('  FAIL: historical plan remains at repository root\n');
        failures = failures + 1;
    elseif ~exist(archivedPlan, 'file')
        fprintf('  FAIL: historical plan was not archived\n');
        failures = failures + 1;
    end

    if failures == 0
        fprintf('  PASS: release package hygiene\n');
    end
end
