# Addons Cleanup Readiness

This document summarizes disposal/retention decisions for `ParaxialBeams/Addons/`
as a result of the deep-inventory phase. It is **not** permission to delete files
immediately — every removal requires a dedicated compatibility change with guardrail
coverage and passing tests.

---

## Keep During Compatibility Window

The following addons are referenced by legacy archive scripts, research examples,
or internal calls within the addon family itself. They must remain until the legacy
compatibility window is formally closed via a dedicated compatibility change.

| Addon | Rationale |
|-------|-----------|
| `getPropagateCylindricalRays.m` | Called by legacy archive scripts; internally calls `getCylindricalGradient`, `copyArrayRay2Ray`, `copyRay2ArrayRay`. Hankel class static API (`HankelLaguerre.getPropagateCylindricalRays`) provides modern equivalent. |
| `getCylindricalGradient.m` | Internal dependency of `getPropagateCylindricalRays.m`. Referenced in `AnalysisUtils.m` comments as matching legacy logic. |
| `assignCoordinates2CartesianRay.m` | Referenced by 20+ research/archive scripts and `OpticalRay` class comments. |
| `assignCoordinates2CylindricalRay.m` | Same as above — active use in legacy Laguerre archive scripts. |
| `copyRay2ArrayRay.m` | Referenced in `OpticalRay` comments as expected helper. Called internally by `getPropagateCylindricalRays.m`. |
| `copyArrayRay2Ray.m` | Same as above. |
| `copyRay.m` | Referenced by historical archive scripts; part of legacy copy helper family. |
| `copy2Ray.m` | Same family. Usage not proven outside legacy scripts, but kept pending investigation. |
| `copyElementRay.m` | Same family. Kept pending broader history search. |
| `copyElementsOnRay.m` | Same family. |
| `getPropagateRay.asv` | MATLAB autosave artifact. Must be removed only in a dedicated cleanup change. |

---

## Keep for Legacy Plot Reproducibility

These addons are used exclusively by `examples/legacy/` research and archive scripts
to produce published figures. Removing them would break historical reproducibility.

| Addon | Rationale |
|-------|-----------|
| `AdvancedColormap.m` | Referenced across research scripts (`MaineHermiteForThesisParameters.m`, `MainHermiteThesis.m`, generator scripts). Used for figure colormap generation. |
| `tight_subplot.m` | Same research scripts use it for multi-panel figure layout. |
| `paraxialPropagator.m` | Research scripts use for propagation loops. |
| `propagateOpticalField.m` | Same research scripts for field propagation. |
| `unwrap_phase.m` | Used by phase visualization scripts. |
| `Plots_Functions/` dir | Contains `plotOpticalField`, `plotGaussianParameters`, and ray plotting helpers for legacy examples. |

---

## License and Origin Review Required

These addons appear to be third-party vendored distributions. Before any relocation,
redistribution, or replacement decision, origin and license must be confirmed.

| Addon | Origin Clues | License Clues | Recommended Action |
|-------|--------------|---------------|-------------------|
| `export_fig-master/` | Unmodified vendored MATLAB export utility. No local attribution header. Header says "Downloaded from MathWorks File Exchange" (comment in `export_fig.m`). | Internal `license.txt` covering this tree. BSD-3 from John D'Errico. | Confirm FEX submission number and version. Decide to replace with `print`/`saveas` native alternatives or keep for legacy scripts. |
| `panel-2.14/` | Unmodified vendored panel layout utility. No attribution header. | `license.txt` applies here too (BSD-3 John D'Errico). | Consider native `uipanel` replacement for new code; keep for legacy compatibility. |
| `vline.m` | **Origin confirmed**: Brandon Kuczenski, Kensington Labs. Email: brandon_kuczenski@kensingtonlabs.com. Dated 8 November 2001. FEX utility. | No license text in file. Author email present. | **Safe for legacy use — keep as-is.** Can be replaced with native `xline()` (MATLAB R2018b+) or `vline` from FEX for new code. No copyleft risk detected. |
| `tight_subplot.m` | **Origin confirmed**: Pekka Kumpulainen, Tampere University of Technology / Automation Science and Engineering. Dated 21.5.2012. | No license text in file. Author and institution present. | **Safe for legacy use — keep as-is.** Can be replaced with native `tiledlayout`/`nexttile` (MATLAB R2019b+) for new code. No copyleft risk detected. |
| `unwrap_phase.m` | **Origin confirmed**: Muhammad F. Kasim, University of Oxford (2017). GitHub: https://github.com/mfkasim91/unwrap_phase/. Based on paper: Herráez et al., Applied Optics Vol. 41, Issue 35 (2002). | No license text in file. GitHub URL present. | **Safe for legacy use — keep as-is.** GITHUB repository is MIT-licensed per standard GitHub practice for mfkasim91/unwrap_phase. Confirm MIT on project page. Can use in new code if MIT confirmed. |
| `license.txt` | BSD-3 John D'Errico 2012. Applies to `export_fig-master/` and `panel-2.14/`. | Explicit BSD-3 — permissive. | Keep with vendored assets. |

**Action item:** No further licensing investigation needed for `vline`, `tight_subplot`, `unwrap_phase`. Origins confirmed — all safe for legacy use. `unwrap_phase.m` can be used in new code once MIT license is confirmed on GitHub.

---

## Needs Usage Investigation

These addons were flagged in prior passes and require broader history analysis
before any reclassification.

| Addon | Rationale |
|-------|-----------|
| `copyElementRay.m` | **UNREFERENCED — potential duplicate of `copy2Ray.m`**: Both copy coordinate fields. `copyElementRay.m` has identical logic to `copy2Ray.m` but uses single-index (not two-index). Both are unreferenced outside themselves. Consider consolidating or marking `removable-candidate`. |
| `copyElementsOnRay.m` | **UNREFERENCED — typo/rename candidate**: Name is structurally similar to `copyElementRay.m` (both singular/plural confusion). `copyElementsOnRay.m` also has a syntax bug: line 4 assigns to `rayObjectOuput.yCoordinate` (typo: `Ouput` not `Output`) but reads from `rayObjectInput`. Function appears dead and broken. |
| `copy2Ray.m` | **UNREFERENCED — dead code**: Zero references across the entire codebase. Function exists in Addons but nothing calls it. Classified as `removable-candidate` per REQ-3. |

---

## Potential Future Removal Candidates

The following are `removable-candidate` only after a focused compatibility change proves no active
references remain AND a guardrail test confirms no regressions.

- `paraxialPropagator.m` — after legacy examples are refactored to use `+paraxial/+propagation/+field/` equivalents (architectural migration, not simple API swap).
- `AdvancedColormap.m` — custom colormap curves have no native equivalent; migration would break thesis/paper figure output. Keep as-is.
- `vline.m`, `unwrap_phase.m`, `propagateOpticalField.m` — not used in research scripts; may be reassessed as removal candidates after the `addons-copy-helpers-removal` compatibility change.

**Removal gates:**
1. Dedicated issue or pull request created with explicit rationale.
2. Guardrail test asserts no references in `+paraxial/`, `src/`, `tests/`, or `examples/` (excluding `examples/legacy/archive/` which may retain references during transition).
3. All tests pass.
4. Legacy compatibility window formally closed.

---

## Required Follow-up Cleanup Changes

The following cleanup decisions need their own focused compatibility changes:

| Change | Scope | Status |
|-----|-------|--------|
| `addons-legacy-plot-migration` | Migrate research figure scripts from vendored helpers to native alternatives. | **COMPLETED — findings below** |
| `addons-copy-helpers-removal` | Remove dead copy helpers (`copy2Ray.m`, `copyElementRay.m`, `copyElementsOnRay.m`) after findings from this pass. | Pending — requires a dedicated compatibility change before any file deletion |

### addons-legacy-plot-migration: Investigation Findings

**Scope audited:** `examples/legacy/research/*.m` (5 scripts)
**Utilities investigated:** `AdvancedColormap`, `tight_subplot`, `vline`, `unwrap_phase`, `paraxialPropagator`, `propagateOpticalField`

**Results per utility:**

| Utility | Used in research scripts? | Migratable? | Native Alternative | Recommended Action |
|---------|--------------------------|-------------|-------------------|-------------------|
| `AdvancedColormap` | ✅ Yes (4 scripts) — custom colormap `'kgg'` | ❌ No | `colormap(parula(256))` or built-in | **Keep as-is.** Custom `'kgg'` curve has no direct native equivalent; migration risks visual regression in thesis/paper figures. |
| `tight_subplot` | ✅ Yes (1 script, 3 usages in MaineHermiteForThesisParameters.m) | ❌ No (Octave) | `tiledlayout`/`nexttile` (R2019b+ only) | **Requires follow-up compatibility change.** Not available in Octave. Do not migrate until Octave compatibility is resolved. |
| `vline` | ❌ No usage in research scripts | N/A | `xline`/`yline` (R2018b+) | Not needed in research scripts — keep as-is for legacy archive. |
| `unwrap_phase` | ❌ No usage in research scripts | N/A | `unwrap()` built-in | Not used in research scripts — keep as-is. |
| `paraxialPropagator` | ✅ Yes (4 scripts) | ❌ No | No direct native replacement — requires re-architecting to `+paraxial/+propagation/+field/` FFT propagation | **Requires follow-up compatibility change.** This is an architectural migration, not a simple API swap. |
| `propagateOpticalField` | ❌ No usage in research scripts | N/A | No direct native replacement | Not used in research scripts — keep as-is. |

**Conclusion for research scripts:** Zero migrations were applied. All research scripts depend on `AdvancedColormap` with custom curves and/or `paraxialPropagator` with no native Octave-equivalent alternatives. The utilities remain necessary for legacy plot reproducibility.

**Conclusion for vendored addons generally:** `vline`, `unwrap_phase`, and `propagateOpticalField` are not used in any research script and may be reconsidered as removal candidates in a future compatibility change after `addons-copy-helpers-removal`.

---

## Structural Invariants (do not break)

- `ParaxialBeams/Addons/` directory must not be deleted while `examples/legacy/` scripts reference its contents.
- `license.txt` must remain in place while vendored distributions (`export_fig-master/`, `panel-2.14/`) are present.
- `getPropagateRay.asv` must not be committed as a new file — existing artifact may be cleaned up in an `addons-autosave-cleanup` compatibility change.