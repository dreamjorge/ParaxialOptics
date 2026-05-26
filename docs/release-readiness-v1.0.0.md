# v1.0.0 Release Readiness

## Verification

| Check | Command | Result |
|-------|---------|--------|
| Portable tests | `octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"` | PASS |
| Release staging | `./tools/stage_release_package.sh` | PASS |
| Internal artifact exclusion | `find build/release-staging -maxdepth 3 \( -path '*/.atl*' -o -path '*/openspec*' -o -name 'AGENTS.md' -o -name 'plan.md' \) -print` | PASS |
| Git status | `git status --short` | CLEAN |

## Release surface

The release package is staged from an explicit allowlist and excludes internal agent/process metadata. The canonical API remains `+paraxial/` plus `BeamFactory.create()`.

## Compatibility

Legacy adapters, archived examples, and addons remain in the repository where required for compatibility and reproducibility. No destructive legacy removal was performed in this cleanup.
