# Release Cleanup and Science Communication Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Produce a cleaner public repository and release package while preserving scientific compatibility and preparing a LinkedIn communication for the optics community.

**Architecture:** Treat cleanup as a packaging and documentation problem first, not a destructive legacy removal. Internal agent/process artifacts are removed from the public surface or excluded from packages; legacy scientific compatibility remains unless tests and existing docs prove safe removal. Release packaging should use an explicit staging allowlist instead of bundling the repository root.

**Tech Stack:** MATLAB/GNU Octave, GitHub Actions, shell scripting, repository hygiene tests, Markdown documentation.

---

### Task 1: Establish cleanup baseline

**Files:**
- Reference: `.gitignore`
- Reference: `README.md`
- Reference: `docs/ADDONS_CLEANUP_READINESS.md`
- Reference: `docs/ADDONS_INVENTORY.md`
- Reference: `.github/workflows/release.yml`
- Create: `docs/release-cleanup-audit.md`

**Step 1: Generate tracked-internal artifact inventory**

Run:

```bash
git ls-files | grep -E '^(\.atl/|\.opencode/|AGENTS\.md$|plan\.md$|openspec/|.*\.asv$|.*\.mat$)' | sort
```

Expected: output includes `.atl/skill-registry.md`, `AGENTS.md`, `plan.md`, `openspec/...`, and `+paraxial/GaussianDemoInfo.mat` if still tracked.

**Step 2: Generate generated/binary artifact inventory**

Run:

```bash
find . -path ./.git -prune -o \( -name '*.asv' -o -name '*.mat' -o -name '*.png' -o -name '*.tmp' -o -name '*~' \) -print | sort
```

Expected: output identifies tracked or untracked generated/binary assets. Vendored third-party PNGs under `ParaxialBeams/Addons/panel-2.14/` are not automatically removable.

**Step 3: Write audit document**

Create `docs/release-cleanup-audit.md` with sections:

```md
# Release Cleanup Audit

## Internal/process artifacts

| Path | Current state | Decision | Rationale |
|------|---------------|----------|-----------|
| `.atl/skill-registry.md` | tracked | remove from repo/release | local agent registry with machine-specific paths |
| `AGENTS.md` | tracked | keep or move after owner decision | useful contributor guidance, not required by package |
| `plan.md` | tracked | archive or remove from release | historical Claude-facing plan |
| `openspec/` | tracked | exclude from release; keep in repo unless owner chooses archive | engineering memory, not runtime package content |

## Scientific compatibility artifacts

| Path | Decision | Rationale |
|------|----------|-----------|
| `src/` | keep | deprecated adapters still part of compatibility window |
| `legacy/compat/` | keep | compatibility gate surface |
| `examples/legacy/` | keep outside default onboarding | supports historical/research reproducibility |
| `ParaxialBeams/Addons/` | keep | existing inventory says removal requires dedicated SDD/gates |

## Packaging risk

Document that `.github/workflows/release.yml` currently builds MATLAB toolbox from `pwd`, which risks including internal process directories.
```

**Step 4: Commit audit**

```bash
git add docs/release-cleanup-audit.md
git commit -m "docs: audit release cleanup scope"
```

---

### Task 2: Add package staging allowlist

**Files:**
- Create: `tools/stage_release_package.sh`
- Modify: `.gitignore`

**Step 1: Write staging script**

Create `tools/stage_release_package.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage_dir="${1:-${root_dir}/build/release-staging}"

rm -rf "$stage_dir"
mkdir -p "$stage_dir"

copy_path() {
  local path="$1"
  if [ -e "$root_dir/$path" ]; then
    mkdir -p "$stage_dir/$(dirname "$path")"
    cp -R "$root_dir/$path" "$stage_dir/$path"
  fi
}

copy_path "+paraxial"
copy_path "ParaxialBeams"
copy_path "tests"
copy_path "examples/canonical"
copy_path "docs/ARCHITECTURE.md"
copy_path "docs/ROADMAP.md"
copy_path "docs/COMPATIBILITY_REDUCTION.md"
copy_path "README.md"
copy_path "CHANGELOG.md"
copy_path "DESCRIPTION"
copy_path "install.m"
copy_path "uninstall.m"
copy_path "setpaths.m"

if [ -f "$root_dir/LICENSE" ]; then
  copy_path "LICENSE"
fi

find "$stage_dir" -type d \( -name .git -o -name .atl -o -name .opencode -o -name openspec \) -prune -exec rm -rf {} +
find "$stage_dir" -type f \( -name '*.asv' -o -name '*~' -o -name '.DS_Store' \) -delete

echo "Release staging directory: $stage_dir"
find "$stage_dir" -maxdepth 2 -type f | sort
```

**Step 2: Make script executable**

Run:

```bash
chmod +x tools/stage_release_package.sh
```

Expected: no output.

**Step 3: Ignore staging build output**

Add this entry to `.gitignore` if absent:

```gitignore
build/
```

**Step 4: Run staging script**

Run:

```bash
./tools/stage_release_package.sh
```

Expected: `build/release-staging` exists and does not contain `.atl`, `openspec`, `AGENTS.md`, or `plan.md`.

**Step 5: Verify excluded internal artifacts**

Run:

```bash
find build/release-staging -maxdepth 3 \( -path '*/.atl*' -o -path '*/openspec*' -o -name 'AGENTS.md' -o -name 'plan.md' \) -print
```

Expected: no output.

**Step 6: Commit staging script**

```bash
git add .gitignore tools/stage_release_package.sh
git commit -m "build: add release staging allowlist"
```

---

### Task 3: Update release workflow to package staged content

**Files:**
- Modify: `.github/workflows/release.yml`

**Step 1: Update Octave package build step**

Replace the current Octave package build body with staging-based commands:

```yaml
      - name: Build .tar.gz package
        run: |
          set -o pipefail
          VERSION=${GITHUB_REF#refs/tags/v}
          ./tools/stage_release_package.sh "$PWD/build/release-staging"
          cd build/release-staging
          sed "s/__VERSION__/${VERSION}/g" DESCRIPTION > _tmp_DESCRIPTION
          mv _tmp_DESCRIPTION DESCRIPTION
          octave --no-gui --eval "pkg build DESCRIPTION"
          mv simulation_scripts-${VERSION}.tar.gz "$GITHUB_WORKSPACE/"
          ls -lh "$GITHUB_WORKSPACE/simulation_scripts-${VERSION}.tar.gz"
```

**Step 2: Update MATLAB toolbox build step**

Replace the current MATLAB toolbox build body with staging-based commands:

```yaml
      - name: Build .mltbx toolbox
        run: |
          VERSION=${GITHUB_REF#refs/tags/v}
          ./tools/stage_release_package.sh "$PWD/build/release-staging"
          matlab -batch "matlab.addons.createToolbox(fullfile(pwd, 'build', 'release-staging'), 'OutputFile', fullfile(pwd, ['simulation_scripts-${VERSION}.mltbx']), 'ProductName', 'Simulation_Scripts', 'ProductAuthor', 'Ugalde-Ontiveros J.A.', 'ProductVersion', '${VERSION}', 'ProductDescription', 'Paraxial beam propagation and wavefront analysis'); disp('Toolbox created successfully');"
          ls -lh simulation_scripts-*.mltbx
```

**Step 3: Validate workflow syntax by inspection**

Run:

```bash
grep -n "stage_release_package\|createToolbox\|pkg build" .github/workflows/release.yml
```

Expected: both package jobs call `./tools/stage_release_package.sh`; MATLAB `createToolbox` points at `build/release-staging`.

**Step 4: Run portable tests before committing**

Run:

```bash
octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

Expected: portable runner completes with status `0`.

**Step 5: Commit workflow change**

```bash
git add .github/workflows/release.yml
git commit -m "ci: package releases from staged allowlist"
```

---

### Task 4: Remove or archive obvious agent residue

**Files:**
- Delete: `.atl/skill-registry.md`
- Modify: `.gitignore`
- Optional Modify/Delete: `plan.md`
- Optional Modify/Delete: `AGENTS.md`
- Reference: `docs/release-cleanup-audit.md`

**Step 1: Remove tracked `.atl` registry**

Run:

```bash
git rm .atl/skill-registry.md
```

Expected: file staged for deletion. `.gitignore` already ignores `.atl/`, so local regenerated registries will stay untracked.

**Step 2: Decide treatment for `plan.md` and `AGENTS.md`**

Use the audit decision. Preferred minimal-risk cleanup for this release:

```bash
mkdir -p docs/internal
mkdir -p docs/archive
mv plan.md docs/archive/pre-v1-hardening-plan.md
cp AGENTS.md docs/internal/agent-repo-guidance.md
```

Then either keep `AGENTS.md` for contributor agents or remove it from root:

```bash
# If owner wants no agent metadata at root:
git rm AGENTS.md
```

Expected: `plan.md` no longer sits at repo root. `AGENTS.md` decision matches owner preference.

**Step 3: Re-run tracked internal inventory**

Run:

```bash
git ls-files | grep -E '^(\.atl/|\.opencode/|plan\.md$)' | sort
```

Expected: no output for `.atl/` or root `plan.md`.

**Step 4: Run portable tests**

Run:

```bash
octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

Expected: status `0`.

**Step 5: Commit residue cleanup**

```bash
git add .gitignore docs/archive docs/internal
git commit -m "chore: remove tracked agent residue"
```

If `AGENTS.md` remains at root, include that in the commit message body or audit doc.

---

### Task 5: Add repository/package hygiene guardrail

**Files:**
- Create: `tests/modern/test_ReleasePackageHygiene.m`
- Modify: `tests/portable_runner.m`

**Step 1: Create hygiene test**

Create `tests/modern/test_ReleasePackageHygiene.m`:

```matlab
function failures = test_ReleasePackageHygiene()
    fprintf('Running release package hygiene tests...\n');
    failures = 0;

    repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));

    forbiddenTracked = {
        fullfile('.atl', 'skill-registry.md'), ...
        fullfile('.opencode'), ...
        'plan.md'};

    [status, tracked] = system('git ls-files');
    if status ~= 0
        fprintf('  SKIP: git ls-files unavailable\n');
        return;
    end

    for i = 1:numel(forbiddenTracked)
        needle = strrep(forbiddenTracked{i}, '\\', '/');
        normalized = strrep(tracked, '\\', '/');
        if ~isempty(strfind(normalized, needle)) %#ok<STREMP>
            fprintf('  FAIL: forbidden tracked artifact %s\n', forbiddenTracked{i});
            failures = failures + 1;
        end
    end

    stagingScript = fullfile(repoRoot, 'tools', 'stage_release_package.sh');
    if ~exist(stagingScript, 'file')
        fprintf('  FAIL: missing release staging script\n');
        failures = failures + 1;
    end

    if failures == 0
        fprintf('  PASS: release package hygiene\n');
    end
end
```

**Step 2: Register test in portable runner**

Open `tests/portable_runner.m` and add `test_ReleasePackageHygiene` to the modern test list near other repository guardrail tests.

**Step 3: Run the new test**

Run:

```bash
octave --no-gui --eval "addpath('tests'); addpath('tests/modern'); failures = test_ReleasePackageHygiene(); if failures ~= 0, error('hygiene test failed'); end"
```

Expected: PASS.

**Step 4: Run full portable suite**

Run:

```bash
octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

Expected: status `0`.

**Step 5: Commit guardrail**

```bash
git add tests/modern/test_ReleasePackageHygiene.m tests/portable_runner.m
git commit -m "test: guard release package hygiene"
```

---

### Task 6: Update public documentation for the cleaned release

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Optional Modify: `docs/ROADMAP.md`

**Step 1: Update README project status**

Add a short note under `## Project Status`:

```md
The release packages are built from an explicit allowlist. Internal planning files, agent/runtime metadata, and OpenSpec process history are not included in user-facing MATLAB/Octave packages.
```

**Step 2: Add compatibility note**

Add a short paragraph near the `src/` deprecation note:

```md
Legacy adapters and research helpers remain available for compatibility and reproducibility. New work should target `+paraxial/` and `BeamFactory.create()`.
```

**Step 3: Update changelog**

Add an unreleased or v1.0.0 patch section:

```md
## [Unreleased]

### Changed
- Build release packages from an explicit allowlist to exclude internal process and agent metadata.
- Clarify canonical `+paraxial/` usage while preserving legacy compatibility surfaces.
```

**Step 4: Run docs grep check**

Run:

```bash
rg -n "\.atl|skill-registry|Claude|agent|OpenSpec|openspec" README.md CHANGELOG.md docs || true
```

Expected: any matches are intentional and confined to internal/audit docs, not onboarding sections.

**Step 5: Commit docs**

```bash
git add README.md CHANGELOG.md docs/ROADMAP.md
git commit -m "docs: document cleaned release surface"
```

---

### Task 7: Draft LinkedIn post for optics community

**Files:**
- Create: `docs/release-linkedin-post.md`

**Step 1: Create Spanish LinkedIn draft**

Create `docs/release-linkedin-post.md`:

```md
# Borrador de LinkedIn: Simulation_Scripts v1.0.0

Estoy preparando el primer release público de `Simulation_Scripts`, una librería MATLAB/GNU Octave para propagación paraxial, modos Gaussianos, Hermite-Gaussianos, Laguerre-Gaussianos, haces tipo Hankel y análisis de frente de onda.

Más que anunciar otro repositorio, quiero compartir una idea con la comunidad de óptica: necesitamos recuperar el pragmatismo de codificar en ciencia.

Durante años muchos scripts científicos crecieron como cuadernos personales: funcionan en la computadora del autor, reproducen una figura, resuelven una tesis, pero son difíciles de instalar, probar o extender. La IA no corrige eso por sí sola. Lo que sí puede hacer, si se usa con criterio, es acelerar tareas de ingeniería que muchas veces posponemos: separar APIs, escribir tests, documentar decisiones, limpiar rutas legacy y preparar paquetes que otra persona pueda ejecutar.

En este release estoy dejando `+paraxial/` como namespace canónico, `BeamFactory.create()` como entrada práctica y una suite portable para Octave/MATLAB. El código histórico no se borra por moda: se preserva cuando sostiene reproducibilidad. La limpieza se aplica donde aporta claridad sin romper ciencia.

Ese es el nuevo pragmatismo que me interesa promover: no programar para impresionar, sino para que el conocimiento óptico sea verificable, instalable y compartible.

Si trabajas en óptica, fotónica o simulación científica y tienes scripts que merecen convertirse en herramientas reutilizables, me encantaría conversar.

#Optics #Photonics #MATLAB #Octave #ScientificComputing #OpenScience #ComputationalOptics
```

**Step 2: Create optional English summary**

Append:

```md
## Optional English summary

I am preparing the first public release of `Simulation_Scripts`, a MATLAB/GNU Octave library for paraxial beam propagation and wavefront analysis. The goal is not only to share code, but to promote a pragmatic way of writing scientific software: tested APIs, reproducible examples, clear compatibility boundaries, and packages that other researchers can actually run.
```

**Step 3: Commit communication draft**

```bash
git add docs/release-linkedin-post.md
git commit -m "docs: draft optics community release post"
```

---

### Task 8: Final verification and release readiness report

**Files:**
- Create: `docs/release-readiness-v1.0.0.md`

**Step 1: Run portable suite**

Run:

```bash
octave --no-gui --eval "addpath('tests'); status = portable_runner(); if status ~= 0, error('portable_runner failed with %d failing tests', status); end"
```

Expected: status `0`.

**Step 2: Run staging verification**

Run:

```bash
./tools/stage_release_package.sh
find build/release-staging -maxdepth 3 \( -path '*/.atl*' -o -path '*/openspec*' -o -name 'AGENTS.md' -o -name 'plan.md' \) -print
```

Expected: staging command succeeds; forbidden artifact search prints nothing.

**Step 3: Check git state**

Run:

```bash
git status --short
```

Expected: no uncommitted changes except ignored `build/` output.

**Step 4: Write readiness report**

Create `docs/release-readiness-v1.0.0.md`:

```md
# v1.0.0 Release Readiness

## Verification

| Check | Command | Result |
|-------|---------|--------|
| Portable tests | `octave --no-gui --eval "addpath('tests'); status = portable_runner(); ..."` | PASS |
| Release staging | `./tools/stage_release_package.sh` | PASS |
| Internal artifact exclusion | `find build/release-staging ...` | PASS |
| Git status | `git status --short` | CLEAN |

## Release surface

The release package is staged from an explicit allowlist and excludes internal agent/process metadata. The canonical API remains `+paraxial/` plus `BeamFactory.create()`.

## Compatibility

Legacy adapters, archived examples, and addons remain in the repository where required for compatibility and reproducibility. No destructive legacy removal was performed in this cleanup.
```

**Step 5: Commit readiness report**

```bash
git add docs/release-readiness-v1.0.0.md
git commit -m "docs: record v1 release readiness"
```

---

### Task 9: Final release command checklist

**Files:**
- Reference: `CHANGELOG.md`
- Reference: `DESCRIPTION`
- Reference: `.github/workflows/release.yml`

**Step 1: Confirm version metadata**

Run:

```bash
grep -n "version=" DESCRIPTION
```

Expected: `version=1.0.0` or the intended release version.

**Step 2: Confirm release workflow exists**

Run:

```bash
grep -n "tags:\|v\*\|softprops/action-gh-release" .github/workflows/release.yml
```

Expected: workflow triggers on `v*` tags and creates a GitHub release.

**Step 3: Tag only after CI-equivalent verification passes**

Run only when ready:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Expected: GitHub Actions builds Octave `.tar.gz`, MATLAB `.mltbx`, and creates the release.
