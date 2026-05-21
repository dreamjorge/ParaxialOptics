# ParaxialBeams Addons Inventory

This inventory classifies `ParaxialBeams/Addons/` before any cleanup, migration, or removal decision. Cleanup-only work MUST NOT delete addon files solely because usage is unclear.

## Classification Key

| Classification | Meaning |
|----------------|---------|
| `runtime-required` | Used by current source/tests or legacy compatibility behavior. |
| `plotting-only` | Used for figures, visualization, examples, or research scripts. |
| `vendored-third-party` | Likely external helper; preserve until origin/license is confirmed. |
| `removable-candidate` | No current evidence of use; requires follow-up SDD before deletion. |
| `needs-investigation` | Usage/origin unclear; do not remove. |

## Top-level Addons

| Path | Classification | Evidence / Rationale | Follow-up |
|------|----------------|----------------------|-----------|
| `ParaxialBeams/Addons/getPropagateCylindricalRays.m` | `runtime-required` | Legacy archive scripts reference the standalone function; modern Hankel implementations retain equivalent static APIs. | Keep until legacy ray APIs are retired. |
| `ParaxialBeams/Addons/getCylindricalGradient.m` | `runtime-required` | Called by `getPropagateCylindricalRays.m`; `AnalysisUtils` documents matching this legacy logic. | Keep with ray compatibility code. |
| `ParaxialBeams/Addons/assignCoordinates2CartesianRay.m` | `runtime-required` | Referenced by legacy research/archive scripts and by ray class comments as expected helper shape. | Keep during legacy ray compatibility. |
| `ParaxialBeams/Addons/assignCoordinates2CylindricalRay.m` | `runtime-required` | Referenced by legacy Laguerre archive scripts for cylindrical ray initialization. | Keep during legacy ray compatibility. |
| `ParaxialBeams/Addons/copyRay.m` | `runtime-required` | Legacy ray copying helper family used by historical scripts and compatibility APIs. | Investigate consolidation with class methods later. |
| `ParaxialBeams/Addons/copy2Ray.m` | `needs-investigation` | Part of legacy copy helper family; exact external usage not proven in this pass. | Search broader history before removal. |
| `ParaxialBeams/Addons/copyElementRay.m` | `needs-investigation` | Part of legacy copy helper family; exact external usage not proven in this pass. | Search broader history before removal. |
| `ParaxialBeams/Addons/copyElementsOnRay.m` | `needs-investigation` | Part of legacy copy helper family; exact external usage not proven in this pass. | Search broader history before removal. |
| `ParaxialBeams/Addons/copyRay2ArrayRay.m` | `runtime-required` | Referenced by `OpticalRay` comments as an expected legacy helper. | Keep during ray compatibility. |
| `ParaxialBeams/Addons/copyArrayRay2Ray.m` | `runtime-required` | Referenced by `OpticalRay` comments as an expected legacy helper. | Keep during ray compatibility. |
| `ParaxialBeams/Addons/paraxialPropagator.m` | `plotting-only` | Used by legacy archive/research propagation scripts. | Keep with legacy examples until replacement examples exist. |
| `ParaxialBeams/Addons/propagateOpticalField.m` | `plotting-only` | Used by legacy archive scripts for field propagation loops. | Keep with legacy examples until replacement examples exist. |
| `ParaxialBeams/Addons/AdvancedColormap.m` | `plotting-only` | Used by legacy archive/generator/research figure scripts. | Preserve for reproducible historical plots. |
| `ParaxialBeams/Addons/tight_subplot.m` | `vendored-third-party` | Common external MATLAB helper name; used by legacy plotting scripts. | Confirm origin/license before migration. |
| `ParaxialBeams/Addons/unwrap_phase.m` | `plotting-only` | Used by legacy plotting/phase visualization scripts. | Keep with visualization helpers. |
| `ParaxialBeams/Addons/vline.m` | `vendored-third-party` | Common plotting helper name; direct usage not proven in this pass. | Confirm origin/license and usage before removal. |
| `ParaxialBeams/Addons/getPropagateRay.asv` | `needs-investigation` | MATLAB autosave artifact present at top level; no usage proven in this pass. | Inspect history before deciding whether to remove in a dedicated cleanup change. |
| `ParaxialBeams/Addons/license.txt` | `vendored-third-party` | Top-level addon license file likely applies to vendored helper assets. | Preserve until vendored origin/license review is complete. |

## Subdirectories

| Path | Classification | Evidence / Rationale | Follow-up |
|------|----------------|----------------------|-----------|
| `ParaxialBeams/Addons/export_fig-master/` | `vendored-third-party` | Vendored MATLAB export helper distribution; top-level directory must be tracked before migration/removal decisions. | Confirm origin/version/license and decide whether to keep, replace, or archive in a dedicated change. |
| `ParaxialBeams/Addons/panel-2.14/` | `vendored-third-party` | Vendored MATLAB panel layout helper distribution; top-level directory must be tracked before migration/removal decisions. | Confirm origin/version/license and decide whether to keep, replace, or archive in a dedicated change. |
| `ParaxialBeams/Addons/Plots_Functions/` | `plotting-only` | Contains plotting helpers such as `plotOpticalField`, `plotGaussianParameters`, ray plotting, and circle/square drawing utilities for legacy examples/research figures. | Keep as legacy plotting surface; consider moving to a documented visualization namespace in a dedicated change. |

## Policy

- `removable-candidate` and `needs-investigation` entries MUST remain present until a follow-up SDD change proves they can be removed safely.
- Runtime and plotting classifications are descriptive, not a promise that the API is modern.
- Vendored-third-party entries need origin/license review before relocation or redistribution decisions.
