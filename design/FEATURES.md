# FEATURES — doors, windows, and the layer stack on a wall that runs in two directions

**hexbody design.** How to place openings (doors, windows, loopholes) *inside* a wall — and
the stack of layers a wall carries — given that a wall on the hex lattice is **always** stored
as a strip of edges running in **two not-equal directions** (three, for a wall along a lattice
line; a spread of directions, for a curved wall).

This is the mantra made concrete ([`../VISION.md`](../VISION.md) — *"customers never worry
about the storage layers"*). **The two-direction zigzag is storage the author never sees.** A
door is placed on a *straight* wall at a width and a position; that the straight wall is stored
as edges pointing two different ways is sealed below the interface. If the two directions ever
reach the author — if a door's width changes because the wall's edges happen to zigzag — the
abstraction has leaked and the design has failed.

Design-protocol order: the concrete end-result first, then the one invariant, then the sites
where it could leak, then the gates with controls. Do not implement past a gate whose control
has not been seen to fire.

> **WHAT IS STORED HERE.** Durable design prose for this area — the ***why*** and the ***how***,
> updated in place as the code changes. **Reference only: never a build input.**
> **NOT HERE:** anything a gate must cite. A claim something depends on belongs in
> [`../SPEC.md`](../SPEC.md) (a target or a limit) or [`../ROUNDTRIP.md`](../ROUNDTRIP.md) (an
> object or a law); in-flight design belongs in the active plan's `DESIGN.md`. A one-row
> `## Open work` table here is the lightest plan (`../plans/README.md`).

---

## 0. The concrete end-result (measured, not hypothesised)

The 5 × 4 house (7.5 m × 6.0 m), the fixture `tests/house.loft` already gates. A wall is a strip of
hex edges, and how it runs depends on its heading — this is the "two not-equal directions" in
numbers, measured across all 12 orientations:

| side | wall | edges | run | overhead | edge directions |
|---|---|---|---|---|---|
| 1, 3 (±v faces) | 7.50 m | **10** | 8.66 m | **2/√3 = 1.1547** | **2** — a *zigzag* between two axes |
| 0, 2 (±u faces) | 6.00 m | **9** | 7.79 m | **3√3/4 = 1.2990** | **3** — a *staircase* over three axes |

One hex edge = 1.000 world unit = **0.866 m**. Across the 12 orientations the per-side edge
counts are identical `[9 10 9 10]` and the axis histogram is a permutation — the same wall
turned, never a different wall.

Now place, on side 3 (the 10-edge zigzag):

- a **door** at `t = 0.50`, 1 edge → **0.87 m clear**, opening exactly 1 edge, deleting none;
- a **window** at `t = 0.20`, sill 0.90 m, head 2.00 m → **opens 0 edges**, alters no cell.

The requirement: place the *same* `(side, t)` door on side 0 (the 9-edge, **three**-direction
staircase) and it must still be a 0.87 m door at the same reading position — the author wrote
"a door here, this wide," and the different edge-direction count underneath is invisible.

The layer stack for one wall edge, bottom to top:

```
  storage    an EdgeSet slot: this edge, in one of two/three directions   (hidden)
  surface    the fitted straight line the strip approximates              (the sealed interface)
  material   {solid, opacity, sound, permeability, height, bounce}        (the wall's properties)
  feature    intervals on the surface: door [s0,s1]; window [s0,s1]×[sill,head]  (override a SUBSET)
  dressing   props kitbashed onto the surface, parented to the wall-part  (set dressing)
```

---

## 1. The invariant

> **A feature is an interval on the wall's exact analytic surface. The edge strip — two
> directions for a straight wall, three along a lattice line, a spread for an arc — is storage
> the feature never indexes. The surface is straight (or a clean arc) at any width, position,
> and heading, so the door is straight and the window's frame is straight, *however* the
> underlying edges zigzag.**

Plan #5 §4 L1b, already gated by `feattest` upstream: *"A door is `[s0, s1]` along an exact
straight or arc, so it is straight because the surface is, at any width and any position. The
cell/edge layer only answers which edges that interval opens. The zigzag never reaches the
render or the mesh."*

Everything below is this invariant defended at each site it could be broken.

The same `(side, t)` anchoring carries two things beyond this file: it is **affine-invariant**
(a ratio survives any morph), which is what lets a building be *oriented by a minimal morph
instead of a mirror* and lets an editor show every orientation from one authoring pass — see
[`EDITOR.md`](EDITOR.md).

---

## 2. The wall in two not-equal directions — why the feature is blind to it

A straight hex wall alternates between exactly two edge axes (the zigzag); a wall along a
lattice line uses three (the staircase). The two directions differ by ~60°, each ~±30° off the
nominal wall line — *not-equal*, and neither is the wall's own direction. So the storage is
genuinely two (or three) directions, and any rule that maps a feature to edges by walking that
strip inherits its raggedness.

The escape is that **clear width is a SURFACE quantity, never a sum of edge lengths.** A door's
clear width is `(s1 − s0)` measured along the fitted surface — 0.87 m for one edge — *not* the
0.866 × (zigzag factor) you would get by adding the edge lengths. Concretely, the width
contributed by one open edge varies **~19 % with the edge's direction** (plan #5's measured
table: 1 edge = 1.0 unit at every heading on the surface, but its projection differs by which
axis it lies on). So:

- **width is read on the surface** → a door is the interval you asked for, at any heading;
- **the edge count is chosen per heading to hit a target width** → 1 edge ≈ 0.87 m, 2 ≈
  1.6–1.9 m (a double door), 4 ≈ 3.1–3.6 m (a gateway), the quantum varying ~19 % with heading;
- **which specific edges open** are those whose surface-projection falls in `[s0, s1]` —
  computed through the surface, so the two/three directions never enter the author's model.

The **arc** is the same mechanism one step out: a curved wall's surface is an arc, its strip
spreads over many directions, and a door is still `[s0, s1]` *along the arc* — straight on the
surface, i.e. a constant-width opening that follows the curve. Straight-wall (two directions)
is the minimal case; the arc is the generalisation, and both are one rule.

---

## 3. Door vs window — they override different layers

Both are intervals on the surface. What differs is **which of the wall's terms each overrides**
(plan #5 §4 L4) — and a window carries a dimension the field cannot:

| | horizontal interval | overrides | leaves alone | extra |
|---|---|---|---|---|
| **door** | `[s0, s1]` | `solid` — you pass through | opacity, sound, the material, the run | — |
| **window** | `[s0, s1]` | `opacity`, `sound`, `permeability` | **`solid`** — you cannot walk through | a **vertical** interval `[sill, head]` |
| **loophole** | `[s0, s1]` | `opacity` over a narrow slot | `solid` | a high, short `[sill, head]` |

**Neither deletes anything.** A door annotates its edges (flips `solid` on them); it never
removes the edge. Deleting fragments the run — the doored-tower defect (a wall with a door
fitting 3 arcs instead of 1). The edge keeps its wall material; the feature overrides a subset
of terms beside it.

**The window's vertical interval is the one thing the field genuinely cannot carry.**
`Materials.height` is a *scalar*; a window needs `[sill, head]` — an interval up the wall
(plan #5 §4 L3; HOUSE.md §4). So a window is a record on the surface `(side, t0, t1, sill,
head)` resolved at render, and it is the elevation layer's reason to exist. **The dependency,
stated now rather than discovered in a frame: windows do not appear until the vertical interval
reaches the renderer.** A window that opens 0 edges is correct footprint behaviour *and*
invisible until the elevation layer is read.

---

## 4. The layer stack, and the override rule

A wall carries a stack, each layer a function of the one below, each higher layer overriding a
**subset** of the terms beneath it:

| layer | carries | written by | read by |
|---|---|---|---|
| **storage** | the EdgeSet strip (edges in 2–3 directions) + mat/surf slots | `draw_walls`, `place_opening` | nobody above — sealed |
| **surface** | the fitted straight/arc the strip approximates | the *fit* | render, collision, the feature layer |
| **material** | `{solid, opacity, sound, permeability, height, bounce}` per surface | the consumer's material table | collision, audio, sight |
| **feature** | intervals `[s0,s1]` (+ `[sill,head]` for windows), each an override-subset | `place_opening` / `feature_add` | collision (solid), sight (opacity), render (the gap) |
| **dressing** | props kitbashed onto the surface, parented to the wall-part | the editor | render only |

**The override composition is the rule that keeps it coherent:** evaluating any wall property
at a point on the surface = the material's value for that term, unless a feature interval
covering that point overrides that specific term. A door overrides `solid` and nothing else; a
window overrides `opacity`/`sound`/`permeability` and *not* `solid`. This is why a window you
cannot walk through and a door you can see through both fall out of one evaluation, and why a
wall with three doors and a window is still **one surface** — the features are annotations on a
continuous body, never breaks in it.

---

## 5. The chokepoint — where the two directions could leak, counted

The invariant holds iff **every** map from a feature to edges goes through the surface, never
by indexing the strip. There are four re-assertion sites, and the design's job is to route all
four through **one** function (`surf_param` / the fitted surface), so "seal the storage" is a
property, not a hope:

| site | must ask | leak if it instead… |
|---|---|---|
| **placement** (`place_opening`) | which edges' surface-projection ∈ `[s0,s1]` | picks the *n nearest edges by strip order* → count/width wobbles with the zigzag |
| **passability** | is this edge inside a `solid`-overriding interval? | reads the edge direction to decide → door width heading-dependent |
| **render** | draw the gap as the surface interval | draws the zigzag gap → a bent, faceted doorway |
| **collision** (swept) | does the path cross a non-open span of the surface? | tests the raw edges → tunnels through the zigzag corners |

`N = 4`, and each is silent on failure (a bent door, a wrong width — a wrong result, not a
compile error). So the design **collapses N toward 1**: a single `feature_edges(surface, s0,
s1)` that all four consult. If any consumer computes its own edge set from the strip, the
two-direction storage has reached the author, and the mantra is broken at that site.

---

## 6. Gates — each with a control that must fire

A gate whose control cannot go red proves nothing (STATE.md lesson 3). State, for each, what
would have to break.

| gate | control that must fire |
|---|---|
| **door width exact** — n edges → n × the surface width, on the **zigzag** side *and* the **staircase** side | compute width as the sum of edge lengths → it differs between the 2-direction and 3-direction sides |
| **window opens nothing** — 0 edges, no cell altered, footprint unchanged | make the window override `solid` → the house leaks / a cell is removed |
| **feature is blind to the directions** — same `(side,t)` door opens the surface-interval's preimage on 2-dir and 3-dir walls | select edges by strip order instead of surface-projection → the opened set is not the interval's preimage |
| **facade order stable** — window left of door on every side, all 12 orientations | omit the endpoint exchange → 24 of 24 reverse (this session's gate) |
| **vertical interval reaches render** — a window's `[sill, head]` is stored and drawn, not collapsed to the scalar height | drop `[sill,head]` and read `Materials.height` → the window vanishes / becomes a full-height gap |
| **override is a subset** — a door changes `solid` only; a window changes opacity/sound/perm and **not** `solid` | make a door also zero opacity, or a window flip `solid` → both must be caught |
| **features do not fragment the run** — a wall with 3 doors + a window fits as **one** surface | delete an edge instead of annotating → it fits as 3 arcs (the doored-tower defect) |
| **arc parity** — a door on a curved wall is constant-width along the arc | measure width in world chords instead of arc length → it narrows toward the curve's inside |

---

## 7. What exists, and the gaps this design closes

Most of the machinery is built or upstream; this design is the consolidation plus three named
gaps.

**Exists:**
- `place_opening` + `side_edges` (hexbody `housedraw`) — n edges centred at `t`, annotating
  the surf slot, never deleting; and the ordered per-side edge list with its `t`. Gated by
  `tests/house.loft` (door 0.87 m, window 0 edges, nothing deleted).
- `Features` / `feature_add` / `apply_features` / `surf_param`, and `Materials` with the full
  property vector, in `hexedge` (extraction to the shared lib pending — see ARCHITECTURE §*core*).
- The two-direction measurement itself — `tests/house.loft` gate 7.

**Gaps this design names:**
1. **The FIT for thin walls** — the surface layer must be *recovered* from the two-direction
   strip, or the feature has no straight surface to be an interval on. Until it lands, `t` maps
   to edges via the strip and the two directions can still leak into width. **This is the
   load-bearing gap** and it is the same fit the renderer needs (BUILDING.md §4).
2. **The elevation layer to the renderer** — the window's `[sill, head]` must reach the draw
   path, or windows stay invisible. Upstream of "windows are validated."
3. **The override composition formalised** — one `wall_eval(surface, term, s)` that applies the
   material then the covering feature's subset-override, so all consumers evaluate identically
   rather than each re-deriving passability/opacity.

## 8. Order

| | | depends on |
|---|---|---|
| **F1** | `feature_edges(surface, s0, s1)` — the single map, the chokepoint | the fit (gap 1) |
| **F2** | `wall_eval` — material + subset-override, one evaluator | F1 |
| **F3** | the elevation layer `(sill, head)` stored and reaching render | F1, the renderer |
| **F4** | the gates in §6, each control seen red | F1–F3 |
| **F5** | arc parity — the same on curved walls | F1, `surf_arc` |

F1 depends on the fit, so the fit is upstream of doors-that-stay-put — the same ordering the
renderer already has. Windows depend additionally on F3 (elevation). Everything here defends
one invariant at four sites; if it grows a fifth mechanism, a direction has leaked and that is
the bug to find.
