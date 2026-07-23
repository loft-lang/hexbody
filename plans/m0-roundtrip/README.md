# `m0-roundtrip` — the exact model, drawn and rebuilt

**Milestone:** [`PLAN.md`](../../PLAN.md) M0 *(pre-tracker; renumber to a `loft-lang/hexbody`
issue when one exists)* · **Value:** `F` · **Effort:** `H`

## Status

**Infrastructure — it determines the block everything else is built on**, so it precedes the
mechanics spine rather than running beside it (decided 2026-07-23).

The contract is split in two: **[`../../ROUNDTRIP.md`](../../ROUNDTRIP.md)** holds only the
**settled** core — definitions, the propositions that follow from them, and the inherited
constraints `X1`–`X31` **with trust tiers** (T1 holds `X1`, `X2`, `X19`–`X22`, `X24`–`X31`) — while
**[`DESIGN.md`](DESIGN.md)** holds everything **in flight**: proposed laws, the grammar, `fits?`,
the seam, the corpus, the method, the gates, and the open decisions.

**Progress: S0, S1, S2b done** ([`STEPS.md`](STEPS.md)). Three gates green, all through
`tools/run_tests.sh`: `tests/house.loft` (law **I**, 12/12 in cells *and* edges),
`tests/form.loft` (re-measured **`X1`**/**`X2`**/**`X20`** to **T1**, added **`X24`**/**`X25`**),
and `tests/wall.loft` (**`X26`**–**`X31`** — the first constraints hexbody *discovered* rather
than inherited, including **two defects every other gate was green through**).

The width question is settled in [`DESIGN.md`](DESIGN.md) §10.9: all 24 directions can be exactly
straight and exactly equally wide **iff** a wall is a line primitive with a constant width and the
cells are its rasterisation. **OD-12** — *which edges IS a wall* — is **resolved** (§10.12): a wall
marks the edges that **separate** its two sides, one connected chain along the line, not a comb of
pickets across it. Next is **S3** (`Plan`→cells). `rebuild`, the census and the corpus do not exist
yet.

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
| **A1** | the minimal closed cycle — equilateral triangle, `len 1`, `turn 4` × 3, both heading classes | — | does *anything* round-trip? |
| **A2** | grow `len` on the same shape | — | does length alone ever collide? |
| **A3** | grow side count — 4 (today's house), 5, 6 | **houses** | — |
| **A4** | unequal sides, and non-convex — the L-shaped house | **houses** | where does a reflex corner stop being recoverable? |
| **A5** | features (doors, windows) on straight sides | **houses** | does the `surf`-slot collision bite here? |
| **A6** | **arcs** — the round tower shell | **the tower** | `Sep`; and crawler's objective is **collision match**, not shape match — reconcile first |
| **A7** | **arc + feature — the doored tower** | **the tower** | the **named defect**: a wall with a door fitting **3 arcs instead of 1** (`design/FEATURES.md` §3) — a law **D** failure with prior art |
| **A8** | **combination** — two stencils adjacent (who owns the shared edge?), stencil against linework, stencil on terrain | **the landscape** | **where things that work alone stop working together** |

A8 is the rung that matters most and the one a single-object enumeration cannot see. Do not stop
at "one complex stencil works."

**Not yet on the ladder, because the scene raised them and they are undecided:** **trees**
(OD-3 — a prop outside `𝕄*`, or field geometry needing a verb? crawler `plans/9-canopy-trees/`
and `PROPS.md` likely already answer this) and **terrain** (OD-4 — no `⟨terrain⟩` production;
crawler `plans/8-landform-morphogenesis/`).

| Phase | Effort | Verify | Status |
|---|---|---|---|
| **A** — stencil census, grown A1→A8 | M | `rt_census_a` — **reports the frontier**: largest level that round-trips + the first failing form; control fires at A1 | **Open — next (A1)** |
| **B** — linework census: `period`, `D`, `Sep`; the straight/arc recovery | M | `rt_census_b`; `eave_spread == 0` on the recovered line | Blocked on A |
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
