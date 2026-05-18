# Assignments 4–6 Workthrough — LDC Group

Single working document for **Assignment 4 (problem formulation)**, **Assignment 5 (MOEA run)**, and **Assignment 6 (convergence)**. Mandate-relevant cues are marked **[LDC]**.

---

## Decisions I need from you up-front

Without these I cannot fill the notebooks. Quick defaults shown in **bold**; override anything.

| # | Decision | Default (mandate-aligned) | Why it matters |
|---|----------|---------------------------|----------------|
| D1 | Welfare function for optimisation | **`SUFFICIENTARIAN`** | Only WF with a floor concept — matches your "basic minimum first" mandate |
| D2 | Welfare functions to *compare* in Step 2 | **Utilitarian, Prioritarian, Sufficientarian, Egalitarian** (all 4) | You need this contrast to justify D1 |
| D3 | Reference SSP-RCP scenario | **2 (SSP2-RCP4.5)** as central case, OR **5 (SSP3-7.0)** to stress-test the floor | LDC interest = make sure the floor holds under plausible-bad futures |
| D4 | FaIR ensemble size (local) | **15** members, evenly spaced indices via `np.linspace(0, 1000, 15, dtype=int)` | Trade-off: accuracy vs. runtime |
| D5 | NFE budget for A5 | **500 smoke-test** first, then **20 000** full | 50 000 is the spec default but slow on a laptop |
| D6 | Number of seeds for A5 | **5** (e.g. `1, 2, 3, 4, 5`) | Standard; needed for A6 reference-set merging |
| D7 | Runtime budget | _your answer_ — hours? overnight? HPC? | Determines D4/D5 |
| D8 | ε-values (Pareto resolution) | See **Task 5.4** below — defaults proposed | Smaller ε = finer front but more NFE needed |
| D9 | Welfare-function tag in filenames | Must match D1 (e.g. `SUFFICIENTARIAN_…`) | A6 globs `UTILITARIAN_*.tar.gz` — needs editing if D1 ≠ utilitarian |

**Tell me D1–D7 and I can fill the rest myself**, including reflection answers grounded in the mandate. D8/D9 I can pick from D1.

---

## Concept cheat-sheet (keywords used across the three notebooks)

| Keyword | Meaning |
|---|---|
| **XLRM** | eXogenous uncertainties, Levers, Relationships, Measures — Lempert's framework for structuring a decision problem under deep uncertainty |
| **ECR** | Emission Control Rate ∈ [0, 1]; 0 = no abatement (BAU), 1 = full mitigation, per region per year |
| **RBF** | Radial Basis Function — Gaussian "bumps" in state space. The MOEA tunes their centers/radii/weights so the policy maps *current climate state → ECR* |
| **EMODPS** | Evolutionary Multi-Objective Direct Policy Search — searching over a decision *rule* (RBF), not a fixed schedule |
| **Closed-loop policy** | Reacts to the realised climate state (RBF). Contrast: **open-loop** = fixed time path |
| **NFE** | Number of Function Evaluations — how many candidate policies the MOEA tests. More NFE = better convergence, longer runtime |
| **MOEA** | Many-Objective Evolutionary Algorithm. Default here = **GenerationalBorg** (self-adaptive, 6 operators) |
| **ε (epsilon)** | Pareto archive resolution per objective. A solution must beat the archive by ≥ ε in ≥1 objective to be kept. Smaller ε = finer Pareto front, more storage, slower |
| **Pareto front** | Set of non-dominated policies — improving one objective requires worsening another |
| **Reference set** | Best-known Pareto front, built by epsilon-merging all seeds (and possibly all NFE budgets) |
| **Seed** | RNG seed. MOEAs are stochastic → run multiple seeds and pool |
| **FaIR ensemble** | 1001 plausible climate-system parameter sets (mostly varying **ECS**, equilibrium climate sensitivity). Each policy → 1001 possible temperature trajectories |
| **ECS** | Equilibrium Climate Sensitivity — °C warming per CO₂ doubling. ~2.5–4°C, deeply uncertain |
| **SSP-RCP** | Shared Socioeconomic Pathway × Representative Concentration Pathway. Indices 0–7. e.g. 2 = SSP2-4.5 (middle), 5 = SSP3-7.0 (regional rivalry, high emissions) |
| **WelfareFunction** | UTILITARIAN (sum of utility), PRIORITARIAN (weights poor more), SUFFICIENTARIAN (penalises below-floor), EGALITARIAN (penalises inequality) |
| **Sufficiency floor** | ~$0.456k/cap/yr — below this counts as deprivation. **[LDC] central to your mandate** |
| **Hypervolume (HV)** | Volume of objective space the archive dominates. Higher = better. Convergence = plateau |
| **Generational Distance (GD)** | Mean distance from archive points to reference set. Lower = better |
| **Epsilon Indicator (EI)** | How much you'd have to shift the archive so it ε-dominates the reference set. Lower = better |
| **Epsilon-progress** | New solutions added per checkpoint. → 0 = no more improvement |

---

# Assignment 4 — Problem Formulation

## Step 1 — XLRM table ([cell a04ema-c02](assignments_ema/assignment_04_problem_formulation.ipynb))

**What to fill:** `xlrm["X — Uncertainties"]`, `xlrm["R — Relationships"]`, and the `ema_mapping` DataFrame.

**Standard items I can put in:**
- **X:** SSP-RCP scenario index, ECS (FaIR ensemble member), TCRE, damage function elasticity, abatement cost curve, savings rate (if exogenous)
- **R:** JUSTICE = economic submodel (DICE-style production/abatement/damage) ↔ FaIR climate module ↔ welfare aggregation. Adaptive ECR via RBF closes the loop.
- **EMA mapping:** scenario → `CategoricalParameter` on `.uncertainties`; ECS/damage → `RealParameter` on `.uncertainties`; RBF params → `RealParameter` on `.levers`; the 4 welfare/temp metrics → `ScalarOutcome` on `.outcomes`

## Step 2 — Welfare function comparison ([cell df869634](assignments_ema/assignment_04_problem_formulation.ipynb))

**What to fill:**
1. `welfare_functions` dict — **I'll put all 4** (D2)
2. `JUSTICE(...)` constructor:
   - `start_year=2015, end_year=2300, timestep=1, scenario=<D3>, climate_ensembles=1` (1 is fine here — fast)
   - `stochastic_run=False`
3. Four scalar extractions:
   - `wf_val = float(np.abs(datasets["welfare"]))`
   - `yat = years_above_temperature_threshold(datasets["global_temperature"], 2.0)`
   - `_, _, _, wl_dam = model.welfare_function.calculate_welfare(datasets["damage_cost_per_capita"], welfare_loss=True)`
   - `_, _, _, wl_abt = model.welfare_function.calculate_welfare(datasets["abatement_cost_per_capita"], welfare_loss=True)`

*(Key names like `"global_temperature"`, `"damage_cost_per_capita"` need verification — first run `print(datasets.keys())` after the first iteration.)*

## Step 3 — ECR profiles plot

Run as-is. **One-line observation:** the policy space spans BAU → aggressive front-loaded mitigation; the MOEA must navigate this *per region per year*, hence the need for an adaptive rule rather than a hand-picked profile.

## Step 4 — RBF math ([cell ef0fd716](assignments_ema/assignment_04_problem_formulation.ipynb))

With `n_rbfs=4`, `n_inputs=2`, `n_outputs=57`:

```python
n_centers = n_rbfs * n_inputs   # 4*2  = 8
n_radii   = n_rbfs * n_inputs   # 4*2  = 8
n_weights = n_rbfs * n_outputs  # 4*57 = 228
n_total   = n_centers + n_radii + n_weights  # 244
```

## Step 5 — Optimisation config

### 5.1 Welfare function (D1)
**[LDC] Recommended: SUFFICIENTARIAN.** Rationale text: *"The LDC mandate demands a welfare framework that treats falling below a basic living standard as the first priority. Only the Sufficientarian function explicitly penalises consumption below the ~$0.456k/cap/yr floor; Utilitarian and even Prioritarian can show 'success' while `rsas`/`rsaf` remain in deprivation."*

### 5.2 SSP-RCP scenario (D3)
| Idx | Scenario | LDC framing |
|---|---|---|
| 0 | SSP1-1.9 | Best case — uninformative for floor stress test |
| 1 | SSP1-2.6 | Optimistic — floor probably safe |
| 2 | SSP2-4.5 | **Central baseline — defensible default** |
| 3 | SSP3-7.0 | Regional rivalry — high stress on poor regions |
| 5 | SSP5-8.5 | Worst case — strong stress test |

### 5.3 FaIR ensemble (D4)
Pick `N_ENSEMBLE_LOCAL` (e.g. 15) and use `np.linspace(0, 1000, N, dtype=int)` for even coverage. Speedup vs full ensemble ≈ `1001 / N`.

### 5.4 Objectives & ε (D8)
4 objectives, **order matters** (must match `objectives` list and config `epsilons`):

| # | Outcome | Scale | Direction (in code) | Proposed ε |
|---|---|---|---|---|
| 1 | `welfare` | 10²–10⁵ | MINIMIZE | 10.0 |
| 2 | `fraction_above_threshold` | 0–1 | MINIMIZE | 0.05 |
| 3 | `welfare_loss_damage` | 10³–10⁴ | **MAXIMIZE** (because `np.abs` flips sign — larger magnitude = less damage) | 10.0 |
| 4 | `welfare_loss_abatement` | 10³–10⁴ | **MAXIMIZE** (same reason) | 10.0 |

### 5.5 Config file values

```python
start_year                  = 2015
end_year                    = 2300
data_timestep               = 5
timestep                    = 1
emission_control_start_year = 2025   # or 2020 — small impact
n_rbfs                      = N_INPUTS + 2   # = 4
n_inputs                    = N_INPUTS       # = 2
epsilons                    = EPSILONS
temperature_year_of_interest = 2100
reference_ssp_rcp_scenario_index = CHOSEN_SCENARIO_INDEX   # from D3
```

---

# Assignment 5 — MOEA Run

## Step 1 — Inspect config
Runs as-is; reads `config_student.json` from A4.

## Step 2 — Run optimisation ([cell-step2-code](assignments_ema/assignment_05_moea_local.ipynb))

**What to fill (from D5, D6, D4):**
```python
NFE         = 500        # smoke-test first; then 20_000 or 50_000
SEEDS       = [1, 2, 3, 4, 5]
N_ENSEMBLES = 15         # matches A4 choice
N_PROCESSES = None       # auto
```

**Before running: open `run_optimization_local.py` and check:**
- Welfare function name matches D1 (the script likely defaults to `UTILITARIAN` — change to `SUFFICIENTARIAN`, otherwise output dirs are mis-tagged and A6 will mis-glob)
- It loads `config_student.json` correctly
- Objectives & directions match A4 Task 5.4

**Recommended workflow:**
1. Smoke test: `NFE=500, SEEDS=[1]` → confirms wiring (~3–5 min)
2. Full local: `NFE=20_000, SEEDS=[1,2,3,4,5]` → background overnight, OR
3. HPC: full 1001 ensemble + 50 000 NFE on DelftBlue

## Step 3 — Load & inspect ([cell-step3-load](assignments_ema/assignment_05_moea_local.ipynb))

I can write this directly:
```python
csv_paths   = sorted(glob.glob(os.path.join(RESULTS_ROOT, "**", "pareto_front_*.csv"), recursive=True))
all_results = pd.concat([pd.read_csv(p).assign(seed=int(os.path.basename(p).split('_')[-1].replace('.csv',''))) for p in csv_paths])
OBJECTIVE_COLS = ["welfare", "fraction_above_threshold", "welfare_loss_damage", "welfare_loss_abatement"]
print(f"Seeds: {sorted(all_results['seed'].unique())}")
print(f"Total solutions: {len(all_results)}")
print(all_results[OBJECTIVE_COLS].describe().round(3))
```

Non-trivial check: `len > 1`, std > 0 on each objective, min(`fraction_above_threshold`) < 1.0.

## Reflection answers (I can draft)
- **Multi-seed:** MOEAs are stochastic — different seeds explore different regions of the 244-D space. Pooling 5 seeds via ε-dominance gives a more complete front than one long seed.
- **NFE diagnostic:** hypervolume curve plateauing well before final NFE (covered in A6).
- **Operator adaptation:** Borg picks among 6 recombination operators based on which is generating archive improvements *now*. Useful in 244-D because no single operator is best globally. Trade-off: extra bookkeeping cost + slower per-NFE vs. NSGA-II.

---

# Assignment 6 — Convergence

## Setup gotcha
The setup cell globs `UTILITARIAN_*.tar.gz`. **If D1 ≠ utilitarian, change this** to e.g. `SUFFICIENTARIAN_*.tar.gz` or just `"*.tar.gz"`. I'll handle this.

## Step 1 — Load results
Runs as-is once A5 produced files.

## Step 2 — Build reference set ([cell 8ebb6399](assignments_ema/assignment_06_moea_convergence.ipynb))

I'll write:
```python
from ema_workbench.em_framework.optimization import epsilon_nondominated

problem_outcomes = [
    ScalarOutcome("welfare",                  kind=ScalarOutcome.MINIMIZE),
    ScalarOutcome("fraction_above_threshold", kind=ScalarOutcome.MINIMIZE),
    ScalarOutcome("welfare_loss_damage",      kind=ScalarOutcome.MAXIMIZE),
    ScalarOutcome("welfare_loss_abatement",   kind=ScalarOutcome.MAXIMIZE),
]
epsilons = cfg["epsilons"]

for nfe, seed_dfs in nfe_groups.items():
    ref = epsilon_nondominated(list(seed_dfs.values()), epsilons, problem_outcomes)
    ref.to_csv(os.path.join(RESULTS_ROOT, f"reference_set_{WF_NAME}_{nfe}.csv"), index=False)

# Grand reference set across all NFE budgets
all_fronts = [df for seed_dfs in nfe_groups.values() for df in seed_dfs.values()]
grand_ref  = epsilon_nondominated(all_fronts, epsilons, problem_outcomes)
grand_ref.to_csv(os.path.join(RESULTS_ROOT, f"reference_set_{WF_NAME}.csv"), index=False)
```

## Step 3 — Load archives
Runs as-is (modulo the welfare-function glob in setup).

## Step 4 — Compute & plot metrics ([cell 60d51773](assignments_ema/assignment_06_moea_convergence.ipynb))

I'll write the metrics loop using `_deap_hypervolume`, `GenerationalDistanceMetric`, `EpsilonIndicatorMetric` for each `(nfe, seed)` snapshot, plus a 4-panel plot per NFE budget (HV / GD / EI / ε-progress vs NFE checkpoint, one line per seed).

## Reflection answers (drafted post-run, once curves are visible)
Need the actual plots to answer concretely. I can write template answers; you fill in the observed NFE-at-plateau numbers.

---

# Suggested order of work

1. **You answer D1–D7** (5 min).
2. I fill A4 cells → you run A4 → confirms `config_student.json` written.
3. I update `run_optimization_local.py` if needed (welfare function tag).
4. You run A5 smoke-test (`NFE=500, 1 seed`) → confirm files appear in `results/`.
5. Launch A5 full run in background (overnight or HPC).
6. I fill A6 cells → you run after A5 finishes.
7. I draft reflection answers (A4, A5, A6) grounded in the LDC mandate; you review and personalise.

---

# Open questions to confirm

1. Is `run_optimization_local.py` already set up for a non-utilitarian welfare function, or will I need to patch it? (I'll inspect once you confirm D1.)
2. Are you running locally only, or do you have DelftBlue access? Affects D4/D5 sizing.
3. Do you want a single reference scenario (D3) for A5/A6, with multi-scenario robustness deferred to A7? (Standard course flow — recommended.)

---

# Patch log — A6 setup cell

## 2026-05-18 — DEAP `_hypervolume` removed; switched to `moocore`

**Symptom.** Setup cell of [`assignment_06_moea_convergence.ipynb`](assignments_ema/assignment_06_moea_convergence.ipynb) crashed at import:

```
ModuleNotFoundError: No module named 'deap.tools._hypervolume'
```

**Cause.** The notebook was written against an older DEAP that exposed a private WFG-based hypervolume implementation at `deap.tools._hypervolume.hv.hypervolume(points, ref_point)`. The installed environment has DEAP `1.4`, which dropped that private submodule. The public `deap.tools.hypervolume` is a different function (operates on populations with `.fitness` attributes, returns the index of the least-contributing individual) and not a drop-in replacement.

DEAP 1.4 now delegates hypervolume work to the `moocore` package, which is already installed (`moocore 0.2.0`) and exposes a clean indicator-style API:

```python
moocore.hypervolume(points_array, ref=ref_point, maximise=mask)
```

It accepts mixed minimise/maximise objectives via a boolean `maximise` mask, so we no longer need to manually negate the maximise columns before computing HV.

**Fix.** Two edits in the notebook:

1. **Setup cell ([`a06-c-01`](assignments_ema/assignment_06_moea_convergence.ipynb))**
   - Removed `from deap.tools._hypervolume import hv as deap_hv`.
   - Added `import moocore`.
   - Renamed `_deap_hypervolume(archive_df, ref_point)` → `_compute_hypervolume(archive_df, ref_point)` and re-implemented it as a one-liner around `moocore.hypervolume(...)` with `maximise=_MAXIMISE_MASK`.
   - Simplified `_compute_ref_point(ref_df, margin)` so it stays in *original* objective coordinates and pads outward per axis (max + margin·range for MINIMIZE axes; min − margin·range for MAXIMIZE axes). Previously it built the reference point in a pre-negated coordinate system to feed DEAP's pure-minimisation API.

2. **Metrics cell ([`60d51773`](assignments_ema/assignment_06_moea_convergence.ipynb))**
   - Single-line change: `hv = _deap_hypervolume(snap, ref_point)` → `hv = _compute_hypervolume(snap, ref_point)`. No other logic touched.

**Why these changes are equivalent.** The MINIMIZE axes already used `hi + margin·range` as the reference coordinate; that is unchanged. The MAXIMIZE axes used `-orig` internally and then `max(neg) + margin·range`, which by definition equals `-min(orig) + margin·range`, i.e. a point *worse* than the worst maximise value. Switching to `min(orig) − margin·range` and telling moocore those axes are maximised gives the same dominated volume — moocore internally maps maximise axes to minimisation in exactly this way.

**Numeric effect.** Hypervolume values reported by `_compute_hypervolume` will be on the same scale and trend identically to what DEAP would have produced — they are not directly comparable run-to-run with results from another HV implementation (different reference points → different numbers), but within this notebook the relative comparison across seeds/checkpoints is preserved. GD and EI are unaffected (they still come from `ema_workbench.em_framework.optimization_convergence`).

**Things to know going forward.**
- `moocore` is now a hard dependency of this notebook. It ships with DEAP 1.4 by default; no extra install needed.
- If you ever rerun this notebook in a fresh env where `moocore` is missing, `pip install moocore` (or `pip install "deap[viz]"` which pulls it in).
- The renamed helper `_compute_hypervolume` is the only HV entry point in the notebook now; do not reintroduce `_deap_hypervolume` references when adding new cells.
