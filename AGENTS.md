# AGENTS.md

High-signal repo guidance for future agent sessions. Prefer executable sources of truth (`tests/portable_runner.m`, workflows, `setpaths.m`) over stale prose.

## Project shape

- MATLAB/GNU Octave library for paraxial beam propagation and wavefront analysis.
- Runtime baseline: GNU Octave 11.1.0+ and MATLAB R2020b+.
- Canonical namespace for new code: `+paraxial/`.
- Deprecated/transitional surface: `src/` adapters. Do not expand new implementation work there unless maintaining compatibility.
- Preferred high-level beam construction API: `BeamFactory.create()` in `ParaxialBeams/BeamFactory.m`.
- Public `BeamFactory.supportedTypes()` names are:
  `gaussian`, `hermite`, `laguerre`, `elegant_hermite`, `elegant_laguerre`, `hankel`, `hankel_hermite`, `nhermite`, `xlaguerre`, `elegant_nhermite`, `elegant_xlaguerre`.

## Path setup gotchas

- For dev/test setup, prefer `setpaths()` from repo root.
- Package folders are resolved by adding their parent directory. `setpaths.m` intentionally adds the repo root for `+paraxial/`; do not add internal `+package` folders directly in new dev/test code unless an existing installer workflow specifically requires it.
- Directly running `tests/modern/test_RepositoryGuardrails.m` needs `ParaxialBeams/` on the path; the test now adds it itself.

## Test commands

- Full portable Octave suite:
  ```powershell
  octave --no-gui --eval "run('tests/test_all.m')"
  ```
- CI-style Octave runner:
  ```powershell
  octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
  ```
- CI-style MATLAB runner:
  ```powershell
  matlab -batch "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
  ```
- Direct repository guardrail:
  ```powershell
  octave-cli --no-gui --eval "run('tests/modern/test_RepositoryGuardrails.m')"
  ```

## CI and release

- GitHub Actions is the canonical CI system.
- `tests/portable_runner.m` is the canonical non-interactive runner; `tests/test_all.m` is a wrapper for humans/portable invocation.
- No standard lint/typecheck tool is configured for this MATLAB/Octave repo.
- Release workflow triggers on tags matching `v*` and builds Octave `.tar.gz` plus MATLAB `.mltbx` artifacts.

## Change workflow

- Keep physics/numerical changes isolated and explicitly justified.
- When changing canonical/deprecated API behavior, update guardrails/docs together so `README.md`, `docs/ARCHITECTURE.md`, `tests/README.md`, and `tests/modern/test_RepositoryGuardrails.m` stay aligned.
- SDD/OpenSpec artifacts live under `openspec/changes/`; archived changes live under `openspec/changes/archive/`.
- Do not build package artifacts unless explicitly requested.
