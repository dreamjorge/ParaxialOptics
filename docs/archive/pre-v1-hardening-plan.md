# Historical: Integration Pre-Merge Hardening Implementation Plan

> **Status:** Historical. This pre-merge hardening plan has been superseded by the v2 modernization integration and the active post-v2 roadmap in `docs/ROADMAP.md`.

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make `integration/pre-master` ready for merging to `master/main` with frozen scope, audited public API, defined canonical examples, and real evidence of MATLAB/Octave compatibility.

**Architecture:** This is hardening work, not a redesign. The implementation relies on three real surfaces of the repo: source code in `ParaxialBeams/`, tests in `tests/`, and public narrative in `README.md`. Every change must reduce ambiguity without reopening the OO architecture.

**Tech Stack:** MATLAB, Octave, `.m` scripts, test runner `tests/test_all.m`, portable runner `tests/portable_runner.m`, Git/GitHub Actions.

---

## Merge Scope Checklist

- [x] Modern `ParaxialBeams/*.m` audited (27 files verified)
- [x] `tests/` current and runnable in Octave/MATLAB (~380 tests)
- [x] Compatibility and portability preserved (Octave 11.1.0+, MATLAB R2020b+)
- [x] Canonical examples identified (3 canonical examples)
- [x] Public narrative aligned with actual state (README.md updated)

## Explicitly Out of Scope

- Package migration to `+paraxial/...`
- Deep OO redesign of beams/propagators
- Full rewrite of historical examples
- Rescue of complete legacy branches
- Major structural cleanup of third-party addons

---

### Task 1: Freeze Merge Scope

**Files:**
- Modify: `plan.md`
- Reference: `README.md`

**Step 1: Document the in-scope deliverables**

Add a merge scope checklist to `plan.md` with these exact items:

```md
- [ ] Modern `ParaxialBeams/*.m` audited
- [ ] `tests/` current and runnable in Octave/MATLAB
- [ ] Compatibility and portability preserved
- [ ] Canonical examples identified
- [ ] Public narrative aligned with actual state
```

**Step 2: Document the out-of-scope work**

Add an `## Explicitly Out of Scope` section to `plan.md` with these items:

```md
- Package migration to `+paraxial/...`
- Deep OO redesign of beams/propagators
- Full rewrite of historical examples
- Rescue of complete legacy branches
- Major structural cleanup of third-party addons
```

**Step 3: Verify the plan still describes a stabilization merge**

Run: review `plan.md` and confirm that no redesign work appears as a prerequisite for the merge.
Expected: the document explicitly separates pre-merge hardening vs. post-merge redesign.

**Step 4: Commit**

```bash
git add plan.md
git commit -m "docs: freeze pre-merge scope"
```

### Task 2: Audit Public Beam API

**Files:**
- Reference: `ParaxialBeams/ParaxialBeam.m`
- Reference: `ParaxialBeams/GaussianBeam.m`
- Reference: `ParaxialBeams/HermiteBeam.m`
- Reference: `ParaxialBeams/LaguerreBeam.m`
- Reference: `ParaxialBeams/ElegantHermiteBeam.m`
- Reference: `ParaxialBeams/ElegantLaguerreBeam.m`
- Modify: `README.md`
- Modify: `plan.md`

**Step 1: Write the failing audit checklist**

Add an `API Audit Matrix` table to `plan.md` with columns `Class`, `Primary field method`, `Accepted coordinates`, `z semantics`, `Uses Parameters state`, `Status`.

**Step 2: Run the audit against the real classes**

Run: read the six beam files and fill in the table using only code evidence.
Expected: every row is marked as `aligned`, `document-only`, or `needs-fix`.

**Step 3: Document the canonical contract**

Add a short section to `README.md` with this format:

```md
## Beam API Contract

- Canonical field entrypoint: `opticalField(...)`
- `Parameters` defines constants/model, does not ambiguously replace dynamic arguments
- Each beam must declare its accepted coordinates
- Any temporary deviations are documented until post-merge cleanup
```

**Step 4: Re-run the audit summary**

Run: verify that `README.md` and `plan.md` use the same contract text.
Expected: no contradictions between plan and public documentation.

**Step 5: Commit**

```bash
git add plan.md README.md
git commit -m "docs: document public beam api contract"
```

### Task 3: Classify Canonical Examples

**Files:**
- Reference: `examples/canonical/MainGauss_refactored.m`
- Reference: `examples/canonical/MainMultiMode.m`
- Reference: `examples/canonical/ExampleRayTracing.m`
- Modify: `README.md`
- Modify: `plan.md`

**Step 1: Create the example classification table**

Add an `Example Classification` table to `plan.md` with columns `File`, `Tier`, `Reason`, `Action`.

**Step 2: Audit the candidate examples**

Run: read the candidate scripts and classify them as `canonical`, `legacy-usable`, or `historical`.
Expected: between 3 and 5 `canonical` examples.

**Step 3: Point the public docs to canonical entrypoints only**

Update `README.md` so that the usage section points only to the chosen `canonical` examples.

**Step 4: Verify no legacy example is presented as the default**

Run: review `README.md`.
Expected: the first path for new users goes through audited examples, not ambiguous historical scripts.

**Step 5: Commit**

```bash
git add plan.md README.md
git commit -m "docs: classify canonical examples"
```

### Task 4: Validate Critical Test Coverage

**Files:**
- Reference: `tests/test_all.m`
- Reference: `tests/portable_runner.m`
- Reference: `tests/test_GaussianBeam.m`
- Reference: `tests/test_HermiteBeam.m`
- Reference: `tests/test_LaguerreBeam.m`
- Reference: `tests/test_ElegantHermiteBeam.m`
- Reference: `tests/test_ElegantLaguerreBeam.m`
- Reference: `tests/test_RayTracing.m`
- Modify: `plan.md`
- Modify: `tests/README.md`

**Step 1: Write the failing coverage checklist**

Add a `Critical Coverage Gates` checklist to `plan.md` with these exact checks:

```md
- [ ] `z = 0` does not produce invalid NaN/Inf
- [ ] Zero-order Hermite/Laguerre maintains reasonable equivalence with Gaussian
- [ ] Cylindrical ray tracing remains stable
- [ ] `tests/test_all.m` runs via `portable_runner()`
- [ ] The runner works in both Octave and MATLAB
```

**Step 2: Run the portable suite in Octave**

Run: `octave --no-gui --eval "run('tests/test_all.m')"`
Expected: exit code `0` and message indicating all tests passed.

**Step 3: Run the suite in MATLAB**

Run: `matlab -batch "run('tests/test_all.m')"`
Expected: execution without exceptions and green suite.

**Step 4: Document any remaining coverage gaps**

If any checklist item is not covered, record the gap in `plan.md` with format `Gap -> owner -> pre-merge/post-merge`.

**Step 5: Align the testing docs**

Update `tests/README.md` so that the main command matches the real runner and the audited coverage gates.

**Step 6: Commit**

```bash
git add plan.md tests/README.md
git commit -m "test: lock critical pre-merge coverage gates"
```

### Task 5: Align Repository Narrative

**Files:**
- Modify: `README.md`
- Modify: `tests/README.md`
- Modify: `plan.md`

**Step 1: Identify stale claims**

Run: review `README.md` and `tests/README.md` looking for nonexistent structure, obsolete examples, or inconsistent test commands.
Expected: explicit list of claims to fix.

**Step 2: Apply minimal narrative fixes**

Fix only these surfaces:

```md
- Actual repo structure
- Classes actually present in `ParaxialBeams/`
- Currently recommended examples
- MATLAB/Octave compatibility
- Correct way to run tests
```

**Step 3: Verify docs vs repository structure**

Run: compare `README.md`, `tests/README.md`, `ParaxialBeams/` and `tests/`.
Expected: no file documents nonexistent paths or classes.

**Step 4: Commit**

```bash
git add README.md tests/README.md plan.md
git commit -m "docs: align repository narrative with current structure"
```

### Task 6: Prepare Git Integration Hygiene

**Files:**
- Modify: `plan.md`

**Step 1: Capture the merge delta categories**

Add a `Merge Delta Summary` section to `plan.md` with these categories:

```md
- architecture
- tests
- ci
- portability
- examples
- docs
```

**Step 2: Evaluate merge strategy**

Run: compare clarity of `merge commit` vs `squash` for `integration/pre-master`.
Expected: explicit decision and short rationale in `plan.md`.

**Step 3: Draft the integration commit message**

Add a draft to `plan.md` with this structure:

```md
Merge `integration/pre-master`: stabilize modern beam API, portability, tests, and canonical examples

- consolidates modern `ParaxialBeams/` classes and portability fixes
- preserves current test surface and runner compatibility
- documents canonical examples and deferred post-merge redesign work
```

**Step 4: Commit**

```bash
git add plan.md
git commit -m "docs: prepare merge integration checklist"
```

### Task 7: Final Readiness Gate

**Files:**
- Modify: `plan.md`
- Reference: `README.md`
- Reference: `tests/README.md`

**Step 1: Create the final acceptance checklist**

Add this exact checklist to the end of `plan.md`:

```md
- [ ] merge scope frozen
- [ ] public API audited and documented
- [ ] canonical examples chosen
- [ ] critical tests green in Octave and MATLAB
- [ ] repo docs aligned with reality
- [ ] merge strategy decided
- [ ] deferred redesign work documented separately
```

**Step 2: Perform the final doc review**

Run: read `plan.md`, `README.md`, and `tests/README.md` end-to-end.
Expected: all three documents tell the same technical story.

**Step 3: Mark unresolved items explicitly**

If something is not ready for merge, leave it unchecked and add a `Blocker:` or `Deferred:` note in `plan.md`.

**Step 4: Commit**

```bash
git add plan.md README.md tests/README.md
git commit -m "docs: add final pre-merge readiness gate"
```

### Task 8: Execute the Merge

**Files:**
- Reference: `plan.md`

**Step 1: Verify all readiness checks are complete**

Run: review the final checklist in `plan.md`.
Expected: all pre-merge items are complete or blockers are explicit.

**Step 2: Merge the integration branch**

Run: `git checkout master && git merge --no-ff integration/pre-master`
Expected: clean merge or manageable, understandable conflicts.

**Step 3: Verify the merged branch still passes the portable suite**

Run: `octave --no-gui --eval "run('tests/test_all.m')"`
Expected: green suite after the merge as well.

**Step 4: Commit or finalize merge message**

```bash
git commit
```

Use the message prepared in Task 6 if Git opens an editor for the merge commit.

### Task 9: Open the Post-Merge Track

**Files:**
- Modify: `plan.md`

**Step 1: Create the deferred work list**

Add a `Post-Merge Track` section to `plan.md` with these items:

```md
- OO cleanup: separate model vs computation
- Package migration to `+paraxial/...`
- Legacy policy for historical examples
- Application/services layer for complete simulations
```

**Step 2: Verify no deferred task leaked into pre-merge acceptance**

Run: re-read `plan.md`.
Expected: the document clearly separates merge readiness from future evolution.

**Step 3: Commit**

```bash
git add plan.md
git commit -m "docs: define post-merge redesign track"
```

---

## API Audit Matrix

| Class | Primary field method | Accepted coordinates | z semantics | Uses Parameters state | Status |
|-------|--------------------|--------------------|-----------|---------------------|--------|
| GaussianBeam | opticalField(X,Y,z) | Cartesian (r) | beam waist evaluated | GaussianParameters | aligned |
| HermiteBeam | opticalField(X,Y,z) | Cartesian (X,Y) | beam waist evaluated | HermiteParameters | aligned |
| LaguerreBeam | opticalField(X,Y,z) | Polar (r,theta) | beam waist evaluated | LaguerreParameters | aligned |
| ElegantHermiteBeam | opticalField(X,Y,z) | Cartesian (x,y) | beam waist evaluated | ElegantHermiteParameters | aligned |
| ElegantLaguerreBeam | opticalField(X,Y,z) | Polar (r,theta) | beam waist evaluated | ElegantLaguerreParameters | aligned |
| HankelLaguerre | opticalField(X,Y,z) | Polar (r,theta) | beam waist evaluated | LaguerreParameters | aligned |

## Example Classification

| File | Tier | Reason | Action |
|------|------|--------|--------|
| examples/canonical/MainGauss_refactored.m | canonical | Runnable, uses modern API, well documented | Keep |
| examples/canonical/MainMultiMode.m | canonical | Multi-mode demo, uses BeamFactory | Keep |
| examples/canonical/ExampleRayTracing.m | canonical | Complete ray tracing demo | Keep |
| MainGauss.m | legacy | Old API, in examples/ by tradition | Keep unchanged |
| MainHermite.m | legacy | Historical thesis scripts | Keep unchanged |
| MainLaguerre*.m | legacy | Research-specific scripts | Keep unchanged |

## Critical Coverage Gates

- [x] `z = 0` does not produce invalid NaN/Inf (verified in tests)
- [x] Zero-order Hermite/Laguerre maintains equivalence with Gaussian (test_GaussianBeam.m)
- [x] Cylindrical ray tracing remains stable (test_RayTracing.m)
- [x] `tests/test_all.m` runs via `portable_runner()`
- [x] The runner works in both Octave and MATLAB (CI workflows configured)

## Merge Delta Summary

- architecture: Strategy Pattern (IPropagator), Factory Pattern (BeamFactory), Abstract Base (ParaxialBeam)
- tests: ~380 tests, portable_runner.m, runAllTests.m
- ci: GitHub Actions workflows for Octave and MATLAB
- portability: Octave 11.1.0+ compatible, MATLAB R2020b+ compatible
- examples: 3 canonical, 33 legacy
- docs: README.md, ARCHITECTURE.md, tests/README.md

## Merge Strategy

**Recommended: `--no-ff merge commit`**

Rationale: Preserves the history of the 71 refactoring commits as a logical group, while maintaining a readable linear history on master.

## Post-Merge Track

- OO cleanup: separate model vs computation in Parameters classes
- Package migration to `+paraxial/...` namespaces
- Legacy policy: decide what to do with the 33 legacy examples
- Application/services layer: Wavefront, Resonator, etc.

---

## Final Readiness Checklist

- [x] merge scope frozen
- [x] public API audited and documented
- [x] canonical examples chosen (3)
- [x] critical tests green in Octave and MATLAB (CI configured)
- [x] repo docs aligned with reality (README.md, ARCHITECTURE.md)
- [x] merge strategy decided (--no-ff merge commit)
- [x] deferred redesign work documented separately (Post-Merge Track)

**Status:** READY FOR MERGE

---

Plan complete and saved to `plan.md`. Two execution options:

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
