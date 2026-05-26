# Release Cleanup Audit

This audit separates release hygiene from destructive compatibility cleanup. The goal is a clean user-facing MATLAB/Octave package without removing scientific compatibility surfaces that still support migration, reproducibility, or historical research scripts.

## Internal/process artifacts

| Path | Current state | Decision | Rationale |
|------|---------------|----------|-----------|
| `.atl/skill-registry.md` | tracked | remove from repo/release | Local agent registry with machine-specific paths and tool metadata. It is not part of the scientific package. |
| `.atl/` | ignored, partially tracked through registry | keep ignored | Runtime state may exist locally, but should not be versioned or packaged. |
| `.opencode/` | ignored | keep ignored | Local AI/tooling runtime state. |
| `AGENTS.md` | tracked | keep in repo for now; exclude from release | Useful contributor guidance for agent-assisted maintenance, but not needed by package users. |
| `plan.md` | tracked | archive or remove from release | Historical Claude-facing plan. It should not remain part of the default public/package surface. |
| `openspec/` | tracked | exclude from release; keep in repo unless owner chooses later archive | Engineering memory and SDD history. Useful for maintainers, not runtime/package content. |

## Generated and binary artifacts

| Path | Current state | Decision | Rationale |
|------|---------------|----------|-----------|
| `+paraxial/GaussianDemoInfo.mat` | tracked | keep pending inspection; include only if required by demos/tests | MATLAB data file. It may be legitimate example data, but binary package inclusion should remain intentional. |
| `ParaxialBeams/Addons/panel-2.14/**/*.png` | vendored assets | keep with addon | Documentation/demo images belong to a vendored third-party helper. Existing addon policy requires dedicated review before removal. |
| `*.asv` | ignored | do not package | MATLAB autosave files are generated artifacts. Existing addon docs mention `getPropagateRay.asv` as cleanup candidate under dedicated change. |

## Scientific compatibility artifacts

| Path | Decision | Rationale |
|------|----------|-----------|
| `src/` | keep | Deprecated adapters remain part of the compatibility window. Removal would be a breaking migration. |
| `legacy/compat/` | keep | Compatibility gate surface used by tests and migration policy. |
| `examples/legacy/` | keep outside default onboarding | Historical and research scripts support reproducibility. They should not be presented as the modern entrypoint. |
| `ParaxialBeams/Addons/` | keep | `docs/ADDONS_INVENTORY.md` and `docs/ADDONS_CLEANUP_READINESS.md` state that removal requires dedicated SDD/gates. |

## Packaging risk

`.github/workflows/release.yml` currently builds the MATLAB toolbox from `pwd`. Building from the repository root risks including internal process directories such as `openspec/`, `.atl/`, root planning documents, and contributor-only metadata.

Release packaging should use an explicit staging allowlist. The staged package should include runtime code, tests, canonical examples, public docs, metadata, and install scripts while excluding internal process artifacts.

## Verification commands used

```bash
git ls-files | grep -E '^(\.atl/|\.opencode/|AGENTS\.md$|plan\.md$|openspec/|.*\.asv$|.*\.mat$)' | sort
find . -path ./.git -prune -o \( -name '*.asv' -o -name '*.mat' -o -name '*.png' -o -name '*.tmp' -o -name '*~' \) -print | sort
```
