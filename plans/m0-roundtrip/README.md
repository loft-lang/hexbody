# `m0-roundtrip` — the exact model, drawn and rebuilt

**Milestone:** [`PLAN.md`](../../PLAN.md) M0 *(pre-tracker; renumber to a `loft-lang/hexbody`
issue when one exists)* · **Value:** `F` · **Effort:** `H`

## Status

**Infrastructure — it determines the block everything else is built on**, so it precedes the
mechanics spine rather than running beside it (decided 2026-07-23).

The contract is split in two: **[`../../ROUNDTRIP.md`](../../ROUNDTRIP.md)** holds only the
**settled** core — definitions, the propositions that follow from them, and the constraints
`X1`–`X50` **with trust tiers** (T1 holds `X1`, `X2`, `X19`–`X22`, `X24`–`X50`) — while
**[`DESIGN.md`](DESIGN.md)** holds everything **in flight**: proposed laws, the grammar, `fits?`,
the seam, the corpus, the method, the gates, and the open decisions.

**Progress: S0–S8 done, rungs A1–A3 closed — the round trip holds over 119 committed entries** ([`STEPS.md`](STEPS.md)). Nine gates green through `tools/run_tests.sh`:

| gate | covers |
|---|---|
| `tests/form.loft` | the 12 headings (`X1`/`X2`/`X20` re-measured to T1), `X24`/`X25`, **S3**'s turtle fill (`X33`/`X34`) and **S4**'s boundary + corner (`X35`–`X37`) |
| `tests/wall.loft` | the 24-direction wall — `X26`–`X32`, the first constraints hexbody *discovered* rather than inherited, including **two defects every other gate was green through** |
| `tests/box.loft` | the box in 12 directions, thin wall and thick wall |
| `tests/census.loft` | the census grown by level — **law F decided at levels 1–3** (`X38`, `X42`) |
| `tests/text.loft` | the canonical text — `write(read(T)) = T` byte-for-byte (`X39`) |
| `tests/surface.loft` | the wall surface by averaging — exact direction and bands, no tolerance (`X47`) |
| `tests/arc.loft` | the round tower — centre exact, radius quantised to a shell (`X49`) |
| `tests/trip.loft` | `rt_trip` — byte-for-byte over **119 committed entries** in `corpus/a1` + `a2` + `a3` (`X41`) |
| `tests/house.loft` | law **I**, 12/12 equivariant in cells *and* edges |

Three things are settled in [`DESIGN.md`](DESIGN.md):

- **§10.9 — width.** All 24 directions can be exactly straight and exactly equally wide **iff** a
  wall is a line primitive with a constant width and the cells are its rasterisation.
- **§10.12 — OD-12, resolved.** A wall marks the edges that **separate** its two sides: one
  connected chain *along* the line, not a comb of pickets across it.
- **§10.13 — S3.** The turtle fills the triangle / rhombus / hexagon the lattice holds **exactly**
  (the family `Plan` provably cannot express), each matching a predicted closed form.
- **§10.14 — S4.** The boundary is **one closed loop**, the side runs **partition** it (a corner
  edge claimed exactly once), and a band wall eats the floor an edge wall keeps. Corner parts 2
  and 4 are a **tripwire** on `SURFACE_LANDED`, enforced when the fitted surface lands.

- **§10.15 — S5.** The level-1 census: 660 proposed, law J admits 30, **3 distinct shapes, 183
  collisions, 0 unexplained — law F holds at level 1**. It found a requirement for S6: the
  canonical text must fix the starting **corner**, not just the winding.

- **§10.16 — S6.** The canonical text: `write(read(T)) = T` byte-for-byte, and the **start corner**
  fixed by the smallest `(turns, lens, h0)`. 30 spellings collapse to 10 canonical texts; what
  remains is orientation, which placement carries.

- **§10.17 — S7.** The corpus (10 committed entries) and `rt_trip`, written before `rebuild`
  exists and **asserted red**. Found `X40`: the census digest and the corpus digest answer
  different questions and must be different functions.

- **§10.18 — S8.** `rebuild`, and **the round trip closing**: `write(rebuild(draw(read(T)))) = T`
  byte-for-byte, 10/10, every entry R1 with `ρ = 0`. It is a **match, not a fit** — licensed by the
  census having decided the level finite and injective.

- **§10.19 — A2.** Length alone never collides — `draw` is injective at levels 1–3. What unequal
  sides add is **chirality**, invisible at level 1 where every form is achiral.

- **§10.20 — A3.** Side count grows cleanly (injective at 3/4/5/6 sides), but the two axes
  **multiply** and the frontier becomes **cost**: today's house needs ~1.2 M proposals, so
  enumerate-and-match cannot reach it.

**Rungs A1–A3 are closed.** The blueprint gate's concrete end-result — *a stencil's canonical text
survives `read → draw → rebuild → write` byte-identically* — holds over **119 committed entries**.

- **§10.21 — indexed recovery.** Recovery is now a single probe: **119 fills instead of 14 161**,
  law F checked once over the whole space, and the index verified to agree with the scan it
  replaces. ⚠ It fixes the *per-lookup* cost only — §10.20's claim that it would reach the house
  was **wrong** and is corrected there.

- **§10.22 — constructive recovery.** The form is read off the field, enumerating nothing: every
  admitted form is convex, so **the hull of the filled cells IS the turtle polygon**. 119/119
  entries, 0 diffs — and today's house is **R2 by enumeration, R1 with `ρ = 0` constructively**.

- **§10.23 — A4.** A reflex corner is **never** recoverable: non-convex forms violate law F (two
  forms, one field, `ρ = 0`), so no method can separate them. The fix is the **doorstep** —
  `form_admissible` = closed ∧ simple ∧ convex — not a better recovery. ⚠ This corrected §10.22's
  guidance toward tracing. **The L-shaped house is not admissible under this grammar.**

- **§10.24 — S4b.** The wall surface by averaging: direction exactly parallel to a heading
  (24/24), position an exact rational, §6.2's bands confirmed (`1/2`, `√3/2`, ratio `√3`) and the
  widening landing exactly. New: the *midpoint* band is 0 on one family and the full band on the
  other — the row stagger.

- **§10.25 — A5.** Features: a door's `t` is exact only at an edge centre `(2i+1)/2n`, every other
  value snaps silently, and `I1` holds both ways (38/0 re-materialled, 37/2 deleted).

- **§10.26 — A6.** Arcs: centre exact, radius quantised to a shell (`0, 12, 36, 48`), all integer.
  `OD-10` resolved. And the third parameter to land that way, giving **`X50` / I-QUANT**: a
  continuous parameter must be quantised to what the field distinguishes.

- **A7.** The doored tower: a door is a **material annotation on the wall's boundary edges**, and
  arc recovery consumes only the cells, so the doored tower round-trips as **one** arc at no cost
  (`X51`). The named defect — deleting fragments the wall into 3 arcs — is **unreachable through the
  door API**, and the controls have to reach around it.

- **A8 (adjacency axis).** Two stencils adjacent — *who owns the shared edge?* **Nobody**: combining
  is **"mark all, THEN cut once"** (crawler's `cut_arb`, re-measured `T2 → T1`), so the shared edge
  is interior to the union and never cut — adjacent stencils **fuse** — and the composite is
  **order-free by construction** (`X52`). The naive per-body overlay is order-dependent and invents
  a seam. Distinguishability is exactly right: authoring history is not recoverable (canonical rep,
  P1), but a *behavioural* difference is field-distinct.

- **A8 (frame seam).** The one axis with **no crawler prototype** — a **posed body against the
  world**, two frames related by a continuous pose. The pose transform is the **sole float step**;
  measured with a Pythagorean pose against an exact oracle, `ε_seam ≈ 7.1e-15` (machine ε) and
  confined to the seam, the **forbidden fix** (snapping to the lattice) moves error into the interior
  (12 cells), `κ ≥ 3` is rare at a point but higher on a sweep, and arbitration is order-free +
  fail-safe (`X53`). The two constants `DESIGN.md` §7 left OPEN are now measured.

- **A8 (overlap by nearest surface).** Gating crawler's `cut_arb` (copied into `hexway`, ungated
  until now): each boundary edge of the union is tagged with its **nearest analytic surface** — its
  collision proxy — order-free, ties to the lower id (`X54`). Two overlapping towers: 66/66 edges
  get the true nearest, a fixed rule mis-tags 31, both stamp orders agree. The collision-proxy half
  of the cut, complementing X52's material-by-source.

- **A8 (stencil against linework).** The cut **spans domains A and B** and needed nothing new — a
  tower (stencil) on a flat-topped world run (linework, `d ∈ D`): 112/112 edges take the nearest,
  the top → the world line (30/30), the rim → the arc (26/26), both build orders agree. And a world
  line **recovers exactly straight** — its edge midpoints share one `y`, so **eave_spread = 0**, the
  phase-B verify (`X55`). Control: the same ruler reads 6.75 over the curved rim.

- **Domain B's census (`rt_census_b`), and the in-between vector SETTLED.** `D` was closed by `X3`,
  so the open constant was **cost**: a three-class table — 6 at `√3` wu, 6 at `1` wu (both
  angle-exact), 12 in-between at `√39` wu = **5.408 m**, `1.1021°` off (`X56`). The census found a
  **third axis** §10.9's ladder never had — **`δ`**, whether a direction preserves the hex-vertex
  class and so links to the house angles *unconditionally*. That **reversed** the "today's vector is
  dominated" verdict, and the in-between vector was switched to **`N = 39` `(7,−2)`**: same `3.7×`
  accuracy as `N = 13`, but `N = 13` would have spent the linking. Also corrected §10.9's period
  column, which was 3× too small.

- **A8 (level separation).** The bridge guarantee, re-measured from crawler's `bridgetest`: a level
  is the topological *sheet*, and it **filters before the cut** rather than arbitrating after it, so
  different sheets never fuse, arbitrate or contend — doing work `κ` would otherwise have to
  (`X58`). One pair of stencils drawn twice with only the level changed: fused with `κ=2` at one
  sheet, two separate fields with `κ=1` across sheets. Level 0 is byte-identically free.

- **A8 (terrain).** `OD-4`'s open half: **seating writes the `height` slot and nothing else**, so a
  stencil round-trips identically on flat ground and on a slope (0 cell diffs, 0 edge diffs, the
  authored text back either way). The slope's cost is a **residual**, returned not absorbed (`1.650`
  on the slope, `0` flat), and the seat height is a **policy** that moves the residual and never the
  recovery (`X59`).

**Rungs A1–A7 and S0–S8 + S4b are closed — and A8 is COMPLETE, all six axes** (adjacency, frame
seam, nearest-surface, linework, levels, terrain), together with phase B's census.

*(Superseded: this plan was `m0-fit`, "recover the straight/arc surface from the edge strip". That
is still real, but it is the **domain B** recovery and one part of a larger contract — and "fit"
was the wrong word for an exact-invariant domain, where the construction is **recovered**, never
approximated. See [`DESIGN.md`](DESIGN.md) §11.)*

**Baseline:** [`shots/house12.png`](shots/house12.png) — the 12 orientations with walls drawn as
the raw two-direction strip (zigzag and staircase). Still the valid *before*; regenerate beside it
once recovery lands.

## Goal

`write(rebuild(draw(read(T)))) == T` — a **text diff**, with no `ε` anywhere in the comparison.

## Anchors

- **[`ROUNDTRIP.md`](../../ROUNDTRIP.md)** — authoritative on every object, map and law here.
- `SPEC` items advanced: **G2**; defended: **I-RT**, **I-TOTAL**, **I-EXACT**, **I-CLOSE**,
  **I-DOMAIN**, **I-POSE**, **I-FSEAM**, **I-ARBIT**, **K-FIT**; honoured: **L8** (metres), **L3**
  (scoped — the field is the *world's* truth; a body's is its original + pose).
- `src/housedraw.loft` (the rasterizer that already exists), `src/houseshot.loft` (the visual).
- **`../crawler` holds prototypes for much of this plan — read before building, not after.**
  Specifying from scratch what already exists is the main way to waste effort here.

  | crawler source | covers |
  |---|---|
  | `plans/5-geometry/matcher.py` | **recover straights + arcs from a traced boundary loop** — this is phase **E**, `rebuild`, already prototyped |
  | `plans/5-geometry/directions.py` | the 24-direction question: 12 natural hex directions (6 edge, 6 vertex, 30° apart), so 12 of 24 are off-axis by 15° — substantially phase **B** |
  | `plans/5-geometry/deviation.py` | per-point distance to the ideal form — the residual `ρ` |
  | `plans/5-geometry/roundness.py`, `collision_fit.py`, `road_arcs.py` | tower and road footprints by **best collision match, not best shape match** — a *different objective* than `Sep` assumes; reconcile before rung A6 |
  | `plans/5-geometry/ways.py` | a way is an exact centreline **plus offsets**, never derived from a rasterised band |
  | `plans/5-geometry/hexforms.py`, `golden/`, `out/` | the blueprint-phase test bench and its outputs |
  | `WALLS.md` | the **triangle-subdivision wall model** — the exact construction |
  | `plans/11-3d-world/BUILDING.md` §4 | the two exact overheads, `2/√3` and `3√3/4`. Ported, not re-derived |
  | `STENCILS.md`, `FORMS.md` | layered composable stencils → castles; the exact interlocking parts kit |

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

**Phase A is a ladder, not one step** ([`DESIGN.md`](DESIGN.md) §8). Each rung enumerates **exhaustively** at
its level, round-trips every form, and is a complete gated increment — so the work always has
something green, and the boundary is *discovered* rather than assumed.

**The rungs come from the scene, not the desk** ([`DESIGN.md`](DESIGN.md) §8.1). The current work — **a
landscape with houses, trees and a tower** — decides which rungs exist and in what order. That
already moved arcs from the last rung to the middle, because the scene has a tower.

| A·n | level | scene | first question it answers |
|---|---|---|---|
| **A1** ✅ | the minimal closed cycle — equilateral triangle, `len 1`, `turn 4` × 3, both heading classes | — | **yes, byte-for-byte** (`X41`) |
| **A2** ✅ | grow `len` on the same shape | — | **no — but unequal sides introduce CHIRALITY** (`X42`) |
| **A3** ✅ | grow side count — 4 (today's house), 5, 6 | **houses** | injective at every side count; **the frontier becomes COST** (`X43`) |
| **A4** ✅ | unequal sides, and non-convex — the L-shaped house | **houses** | **at every size** — non-convex forms violate law F, so the DOORSTEP refuses them (`X46`) |
| **A5** ✅ | features (doors, windows) on straight sides | **houses** | **no — already fixed**; but `t` is exact only at edge centres (`X48`) |
| **A6** ✅ | **arcs** — the round tower shell | **the tower** | centre **exact**, radius **quantised to a shell** (`X49`); the `Sep`/`X7` fork is a *policy*, not a blocker |
| **A7** ✅ | **arc + feature — the doored tower** | **the tower** | **already fixed**: a door is a material annotation the cell-based arc recovery is blind to, so it round-trips as **one** arc (`X51`); deleting fragments it into 3 arcs — the named defect, unreachable through the door API |
| **A8** ✅ | **combination** — two stencils adjacent (who owns the shared edge?), stencil against linework, stencil on terrain | **the landscape** | **adjacency + frame seam + nearest-surface + linework + levels DONE** (`X52`–`X55`, `X58`): "mark all, then cut once" (order-free, the edge fuses); the posed-body seam (`ε_seam` machine-ε & confined, `κ` counted, arbitration order-free + fail-safe); overlap by nearest surface; and the cut spanning domains A/B, with a world line recovering eave_spread 0. **Terrain** (`OD-4`) closed too — seating is orthogonal, the residual flagged (`X59`) |

A8 is the rung that matters most and the one a single-object enumeration cannot see. Do not stop
at "one complex stencil works."

**Not yet on the ladder, because the scene raised them and they are undecided:** **trees**
(OD-3 — a prop outside `𝕄*`, or field geometry needing a verb? crawler `plans/9-canopy-trees/`
and `PROPS.md` likely already answer this) and **terrain** (OD-4 — no `⟨terrain⟩` production;
crawler `plans/8-landform-morphogenesis/`).

| Phase | Effort | Verify | Status |
|---|---|---|---|
| **A** — stencil census, grown A1→A8 | M | `rt_census_a` — **reports the frontier**: largest level that round-trips + the first failing form; control fires at A1 | **A1–A7 ✅; A8 adjacency ✅ (`X52`), frame seam ✅ (`X53`), nearest-surface ✅ (`X54`), linework ✅ (`X55`), levels ✅ (`X58`), terrain ✅ (`X59`) — **A8 COMPLETE** |
| **B** — linework census: `period`, `D`, `Sep`; the straight/arc recovery | M | `rt_census_b`; `eave_spread == 0` on the recovered line | **✅ CLOSED** — `D` by `X3`, `Sep` by `X49`, recovery by `X47`/`X49`, `eave_spread 0` by `X55`, `period` by **`X56`** |
| **C** — `write` / `read`, canonical text frozen | S | `rt_canon`, `rt_project`, `rt_fits`, `rt_close` | Blocked on A, B, **OD-2** |
| **D** — `rt_trip` written **empty** (red), before `rebuild` exists | XS | needs no ground truth — only `write`/`read`/`draw`/`rebuild` + `diff` | Blocked on C |
| **E** — `rebuild` | MH | `rt_trip` green over **every** primitive kind | Blocked on D |
| **F** — damage + frames: `rt_total`, `rt_ruin`, `rt_seam`, `rt_contend` | M | `ρ = 0` on `im(draw)`, reported off it; `ε_seam`; `κ` histogram | Blocked on E |

Each gate carries a control that must fire. `rt_trip` must be **enumeration-driven** over
primitive kinds — a new primitive without `write`/`draw`/`rebuild` coverage fails the gate rather
than going silently ungated.

## Order + risks

- **A first, and it is cheap.** Finite, decidable, no new representation needed — `housedraw`
  already rasterizes. Grown by level, so every rung is a green increment rather than one long red
  run to a single verdict.
- **A collision is a result, not a failure.** The restrictions are the *output* of this plan, not
  its precondition. Defining the admitted space up front and then enumerating it would presuppose
  exactly the bounds we are trying to find ([`DESIGN.md`](DESIGN.md) §8). The bounds are not the problem —
  there is plenty of room inside them.
- **Every restriction found lands in `fits?` immediately, on the same rung.** A rung is not done
  when the collision is understood; it is done when the limit is **enforceable at the door**
  ([`DESIGN.md`](DESIGN.md) §5.2, law **C₂**). Otherwise the ladder accumulates known-but-unenforced limits and
  the editor can still author something that breaks later.
- **Each rung must also close under `Ops`**, not merely round-trip. A form that survives A5 alone
  but not `flip(A5)` is **refused at A5**, not discovered at rung A8 — that is `rt_closure`.
- **Phase A is the window where restrictions are free.** `𝕄*` grows, never shrinks (law **A₂**),
  so once texts exist in the wild, tightening `fits?` is a **breaking change** with no migration —
  nobody can re-derive geometry a person hand-placed. Run the whole ladder, A8 included, *before*
  the editor ships content. Discovering the combination limits afterwards is the expensive order.
- **Each rung keeps its fixtures forever.** `rt_extend` replays every prior fixture against the
  current grammar and demands **byte-identical** output, so a later rung that adds a verb cannot
  silently re-spell an earlier rung's texts.
- **Its output is not a throwaway probe.** `Cyc` and `period` are the **shared artifact** that
  `rt_trip` *and* the editor's `fits?` both consume (`K-FIT`: `authorable ⊆ fits?`). Building them
  twice — once for the gate, once for the editor — is the `N > 1` silent-divergence failure.
- **Risk — `ε` creep.** In an exact-invariant domain the mind reaches for a fit, a bucket, a
  smoothing. An `ε` in a round-trip comparison is a **defect signal**, never a knob: by **P4** it
  can only mean the fitting set is wider than `draw` is injective on.

## Open design questions

- **OD-2 — are roofs inside the exact round trip?** `src/hexroof.loft:493`
  `roof_match(..., tol: float)` is the `ε` **P4** forbids. Blocks phase **C** (freezing `⟨roof⟩`);
  does **not** block phase A. Options in [`DESIGN.md`](DESIGN.md) §10.
- **OD-1 — the morph.** Largely dissolved by free poses (a non-12 building is simply a free-posed
  body); the residual question is whether a *seated* building ever needs an angle outside the 12.
- **Unmeasured constants:** `ε_seam`, the `κ ≥ 3` contention rate — both due in phase **F**.

## The implementation order

[`STEPS.md`](STEPS.md) — phase A broken into **nine small safe steps** (`S0`–`S8`), each with its
file, its gate and its control. `S0`–`S2` are integer-only and convert `X1`/`X2` from inherited
claims to our own **T1**; `S3`–`S4` cross-check the new turtle path against `tests/house.loft`'s existing
27 cells / 38 edges; `S8` (`rebuild`) is the only M-sized step in the ladder.

## See also

[`STEPS.md`](STEPS.md) *(the code order)* · [`DESIGN.md`](DESIGN.md) *(the in-flight half)* · `ROUNDTRIP.md` *(settled core)* · `PLAN.md` M0 ·
`SPEC.md` · `design/FEATURES.md` · crawler `BUILDING.md` §4, `WALLS.md`, `STENCILS.md`.
