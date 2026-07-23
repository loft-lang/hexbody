# `m0-fit` — the wall fit

**Milestone:** [`PLAN.md`](../../PLAN.md) M0 *(pre-tracker; renumber to a `loft-lang/hexbody`
issue when one exists)* · **Value:** `F` · **Effort:** `M`

## Status

The drawing routines ship — `housedraw` + `housetest`, floor/walls/openings/roof equivariant at
all 12 orientations, gate green. But a wall is still drawn as its raw **two-direction edge
strip** — the zigzag (sides perpendicular to a lattice line) and staircase (sides along one).
This plan recovers the straight/arc **surface** the strip approximates, so a wall renders as one
flat quad and features have a straight surface to sit on. It is the recurring dependency named
across the design docs — nothing visual is right until it lands.

**Baseline:** [`shots/house12.png`](shots/house12.png) — the 12 orientations with walls drawn as
the raw strip. This is the *before*; regenerate it after the fit to show the straightened walls
beside it.

## Goal

Any wall renders as its analytic surface, not its strip.

## Anchors

- [`design/FEATURES.md`](../../design/FEATURES.md) — the surface the features sit on (this fit is
  its §7 gap #1, the load-bearing one).
- Source design: crawler `plans/11-3d-world/BUILDING.md` §4 (*"the wall run is longer than the
  wall"* — the two exact overheads, 2/√3 and 3√3/4). Being ported, not re-derived.
- `src/housedraw.loft` (the strip), `src/houseshot.loft` (the visual).

## Blueprint gate (exact-invariant — geometry)

- **Concrete end-result:** a 15° wall → **one** straight quad; the fitted line coincides with the
  analytic wall line the strip approximates.
- **Invariant:** the fit is the exact straight/arc surface the strip discretises — `eave_spread`
  on the fitted line is `0`, and reading the wall top at the strip instead wanders ±0.43 m (the
  control).
- **Medium:** the engine itself — the primitives exist (`housedraw`, the strip), so the cheapest
  medium is the real gate + `houseshot` for the visual, not a separate model.
- **SPEC items** ([`../../SPEC.md`](../../SPEC.md)): advances **G2**; defends **I8** (eave level
  on the fitted line) and **I1** (the analytic surface features sit on); honours **L8** (metres).

## Phases

| Phase | Effort | Verify | Status |
|---|---|---|---|
| **A** — straight-wall fit (recover the line from the 2/3-direction strip) | S | `make test` (`eave_spread == 0`, control fires) + `make shot` (`shots/` straightens) | Open |
| **B** — arc fit (the curved-wall generalisation) | M | `make test` (arc parity) | Blocked on A |

Each gate carries a control that must fire.

## See also

`PLAN.md` M0 · `design/FEATURES.md` · crawler `BUILDING.md` §4.
