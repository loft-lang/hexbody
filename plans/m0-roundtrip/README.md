# `m0-roundtrip` — the exact model, drawn and rebuilt

**Milestone:** [`PLAN.md`](../../PLAN.md) M0 *(pre-tracker; renumber to a `loft-lang/hexbody`
issue when one exists)* · **Value:** `F` · **Effort:** `H`

## Status

**Infrastructure — it determines the block everything else is built on**, so it precedes the
mechanics spine rather than running beside it (decided 2026-07-23).

The formal contract exists: **[`ROUNDTRIP.md`](../../ROUNDTRIP.md)** — objects, maps, laws
**A–K₂**. No code yet. Of its twelve gates exactly one is green: `rt_orient` (law **I**) —
`housetest`, 12/12 equivariant in cells *and* edges.

*(Superseded: this plan was `m0-fit`, "recover the straight/arc surface from the edge strip". That
is still real, but it is the **domain B** recovery and one part of a larger contract — and "fit"
was the wrong word for an exact-invariant domain, where the construction is **recovered**, never
approximated. See `ROUNDTRIP` §11.2.)*

**Baseline:** [`shots/house12.png`](shots/house12.png) — the 12 orientations with walls drawn as
the raw two-direction strip (zigzag and staircase). Still the valid *before*; regenerate beside it
once recovery lands.

## Goal

`write(rebuild(draw(read(T)))) == T` — a **text diff**, with no `ε` anywhere in the comparison.

## Anchors

- **[`ROUNDTRIP.md`](../../ROUNDTRIP.md)** — authoritative on every object, map and law here.
- `SPEC` items advanced: **G2**; defended: **I-RT**, **I-TOTAL**, **I-EXACT**, **I-CLOSE**,
  **I-DOMAIN**, **I-POSE**, **I-SEAM**, **I-ARBIT**, **K-FIT**; honoured: **L8** (metres), **L3**
  (scoped — the field is the *world's* truth; a body's is its original + pose).
- `src/housedraw.loft` (the rasterizer that already exists), `src/houseshot.loft` (the visual).
- Domain B source design: crawler `plans/11-3d-world/BUILDING.md` §4 — the two exact overheads,
  `2/√3` and `3√3/4`. Ported, not re-derived.

## Blueprint gate (exact-invariant — geometry, round trip)

- **Concrete end-result:** a stencil's canonical text survives `read → draw → rebuild → write`
  **byte-identically**; a wall renders as its analytic surface, not its strip.
- **Invariant:** `draw` and `rebuild` are mutual pseudo-inverses on the fitting set
  (`ROUNDTRIP` laws **D** + **E₂**). The fitting set is not axiomatised — it *is* `im(rebuild)`.
- **Control:** a non-fitting model bypassing `snap` → the diff fires. For phase A: remove a
  corner's turn from the match key → collisions appear.
- **Medium:** the engine itself. The primitives exist (`housedraw` rasterizes today), so the
  cheapest medium is the real gate, not a separate model.
- **Why exhaustive, not sampled:** with `|H₁₂| = 12` and bounded side counts and lengths, the
  admitted stencil space is **finite** — so law **F** is *decided* in phase A, not estimated.

## Phases

| Phase | Effort | Verify | Status |
|---|---|---|---|
| **A** — stencil census: enumerate `Cyc` exhaustively, count collisions | S | `rt_census_a` — collisions **must be 0**; control fires | **Open — next** |
| **B** — linework census: `period`, `D`, `Sep`; the straight/arc recovery | M | `rt_census_b`; `eave_spread == 0` on the recovered line | Blocked on A |
| **C** — `write` / `read`, canonical text frozen | S | `rt_canon`, `rt_project`, `rt_fits`, `rt_close` | Blocked on A, B, **OD-2** |
| **D** — `rt_trip` written **empty** (red), before `rebuild` exists | XS | needs no ground truth — only `write`/`read`/`draw`/`rebuild` + `diff` | Blocked on C |
| **E** — `rebuild` | MH | `rt_trip` green over **every** primitive kind | Blocked on D |
| **F** — damage + frames: `rt_total`, `rt_ruin`, `rt_seam`, `rt_contend` | M | `ρ = 0` on `im(draw)`, reported off it; `ε_seam`; `κ` histogram | Blocked on E |

Each gate carries a control that must fire. `rt_trip` must be **enumeration-driven** over
primitive kinds — a new primitive without `write`/`draw`/`rebuild` coverage fails the gate rather
than going silently ungated.

## Order + risks

- **A first, and it is cheap.** Finite, decidable, no new representation needed. It either closes
  at 0 or hands back the exact colliding pair — an answer either way.
- **Its output is not a throwaway probe.** `Cyc` and `period` are the **shared artifact** that
  `rt_trip` *and* the editor's `fits?` both consume (`K-FIT`: `authorable ⊆ fits?`). Building them
  twice — once for the gate, once for the editor — is the `N > 1` silent-divergence failure.
- **Risk — `ε` creep.** In an exact-invariant domain the mind reaches for a fit, a bucket, a
  smoothing. An `ε` in a round-trip comparison is a **defect signal**, never a knob: by **P4** it
  can only mean the fitting set is wider than `draw` is injective on.

## Open design questions

- **OD-2 — are roofs inside the exact round trip?** `src/hexroof.loft:493`
  `roof_match(..., tol: float)` is the `ε` **P4** forbids. Blocks phase **C** (freezing `⟨roof⟩`);
  does **not** block phase A. Options in `ROUNDTRIP` §11.1.
- **OD-1 — the morph.** Largely dissolved by free poses (a non-12 building is simply a free-posed
  body); the residual question is whether a *seated* building ever needs an angle outside the 12.
- **Unmeasured constants:** `ε_seam`, the `κ ≥ 3` contention rate — both due in phase **F**.

## See also

`ROUNDTRIP.md` · `PLAN.md` M0 · `SPEC.md` · `design/FEATURES.md` · crawler `BUILDING.md` §4.
