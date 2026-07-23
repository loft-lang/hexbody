# STEPS — the initial work, in small safe steps

The **implementation** order for M0 phase A. [`README.md`](README.md) has the phases and the
A1–A8 rung ladder; [`DESIGN.md`](DESIGN.md) has the model. This says **what to write, in what
file, and what gate proves it** — at a size where each step can be read and judged in one sitting.

## What makes a step "safe" here

1. **Additive.** A new file and a new gate. No step edits a path `tests/house.loft` covers, so the green
   gate stays green and any breakage is attributable to the step that caused it.
2. **Independently gated**, with a control that must fire. A step that cannot go red is not done.
3. **Verifiable by reading the output.** Counts and identities, printed — not a pass/fail bit.
4. **Cross-checked against the existing green path** wherever the two can produce the same number.
   That is the cheapest correctness evidence available and it is free until S3.

Convention per gate: **`tests/<topic>.loft`** with an `ok` flag and a final `=== <NAME> OK ===`,
plus a `Makefile` line that greps for it. Modules stay in `src/`; the `Makefile` passes
**`--lib src/`** so a test can `use` them.

---

## S0 ✅ · the heading table `e(h)` — `src/hexform.loft` · XS · **DONE**

The 12 headings of `H₁₂` as lattice step vectors in **odd-r offset** `(q,r)`. Even `h` are the six
edge-neighbour directions (`nb_q`/`nb_r`); odd `h` are the six vertex directions.

- **gate** `tests/form.loft`: `e(h+6) = −e(h)` for all `h`; rotation `h ↦ h+2` permutes the table onto
  itself; the two classes' step lengths are in ratio `√3` (`ROUNDTRIP` §2.1).
- **control**: perturb one entry → the involution fails.
- **why first**: everything downstream indexes this table, and it is pure data — the cheapest
  possible thing to be wrong about, and the cheapest to check.
- **result**: green, all six controls fire. Steps are held in **doubled `(k,m)`**, which is
  parity-free — proved against `hex_field`'s `nb_q`/`nb_r` on both row parities (`X20`). `X1` and
  `X2` were re-measured here and are now **T1**: 625 cells, 0 non-integral images, six rotations
  exactly the identity. Two corrections fell out — the reflection `k → −k` acts as `h ↦ 6 − h`
  (not `h ↦ −h`, which is `m → −m`), and loft's `%` is truncating (`−1 % 12 = −1`), so `head_norm`
  is defending a real trap. **S2 is absorbed into S0** — its checks are gate section 3.
- **watch, two traps, both silent**:
  1. `r & 1` makes the step vectors **row-dependent** — `e(h)` is a function of `(h, r&1)`, not of
     `h` alone (odd-r offset, `ROUNDTRIP` §1).
  2. **A negative index reads from the END of a loft vector; it does not return `null`.** The
     running heading `h = h0 + Σ turn` goes negative routinely, since turns are `−5..6`. Normalise
     to `0..11` — `((h % 12) + 12) % 12` — *before* indexing. Both traps return a plausible wrong
     answer rather than failing, which is why they are S0's gate rather than S3's debugging.

## S1 ✅ · law **J**, closure — `src/hexform.loft` · XS · **DONE**

`cycle_closes(h0, lens, turns) → bool`: `Σ turnᵢ = 12` **and** `Σ lenᵢ·e(hᵢ) = (0,0)`, integer
arithmetic only.

- **gate** `tests/form.loft` §7: five admissible forms close — triangles at `len 1` and `len 3`,
  a **vertex-class** triangle (`h0 = 1`), a hexagon, a rhombus `4×5`.
- **control** §8, and it is sharper than planned: **neither condition implies the other**, so
  each needs a control the other misses.
  - *dropped final turn* → residual stays `(0,0)`, `Σ turn = 11`. The last turn happens **after**
    the last side, so it cannot move the endpoint — only the turn total sees it.
  - *wrong side length* → `Σ turn = 12`, residual `(−1,3)`. Only the vector sum sees it.
  - *walked clockwise* → residual `(0,0)`, `Σ turn = −12` — a genuine closed cycle in the other
    direction, rejected so that **C3** has one spelling per shape.
  - *2 sides* → rejected; it bounds nothing.
- **note**: the planned second case was "the house outline (`len 4,5,4,5`, `turn 3` ×4)". That is
  **not a lattice cycle** — headings 0/3/6/9 alternate edge and vertex class, whose steps differ
  by `√3`, so `4,5,4,5` there is a rhombus in world space, not the 6.00 m × 7.50 m house.
  `housedraw`'s `Plan` is a **continuous** rectangle rasterised by centre-in-region, not a turtle
  polygon at all. The rhombus `[4,5,4,5]` with turns `[2,4,2,4]` (all edge-class) replaces it.
  **This is a real constraint on S3's cross-check** — see there.

## S2b ✅ · the 24-direction wall, and its evaluation back to a mesh — `src/hexwall.loft` · S · **DONE**

Not in the original ladder. It was added because the wall is the **primitive the house is four
of**, and because *"can crawler's library evaluate these walls back to meshes?"* turned out to be
the cheapest available round-trip: a **write** we authored, evaluated by an emitter **we did not**.

- **gate** `tests/wall.loft`, seven sections, each with a control that fires.
- **the evaluator is not ours** — `hex_grid::hex_edge_corners` owns the edge table and
  `moros_render::emit_hex_walls` evaluates the three slots (`X26`). `hex_grid`'s world scale and
  `hex_field`'s exact lattice agree term for term, so it is reuse, not a port.
- **it caught two defects that every other gate was green through:**
  - `X26` — a **private corner table** beside `hex_field`'s neighbours misfiled **five of six**
    edges. A consistently wrong edge is still written once, still idempotent, still non-empty:
    sections 1–5 cannot see it. Now `SPEC` **L11** and gate §2b.
  - `X28`/`X32` — `wall_crosses_edge` first selected the edges the band **crosses** (the
    perpendicular ones), so a due-east wall was a **comb of pickets**. **Fixed (OD-12 resolved,
    DESIGN 10.12):** `wall_write` now marks the edges that **separate** the wall's two sides — the
    boundary between two half-planes, one connected chain **along** the line. §6 asserts every wall
    is one chain (2 ends, 0 branches) against the picket comb as control.
- **what it settled** (`DESIGN.md` §10.9): all 24 can be exactly straight and exactly equally wide
  **iff** a wall is a line primitive with a constant width and the cells are its rasterisation.
  Counting lattice rows provably cannot equalise them (`X30`), and no lattice vector points at 15°
  (`X31`). The `4.107°` in-between error is a **choice of period**, not a law.
- **the editor's doorstep is now closed-form** (DESIGN 10.10, gate sections 8-9): a line's
  endpoints must be hex VERTICES separated by a whole number of the direction's period, and
  the three quantisations are 1.5000 m (N=3), 0.8660 m with one in three refused (N=1) and
  3.9686 m (N=21, the in-between — too coarse for a building, which is a second independent
  reason for the even-only rule). An arbitrary mouse point snaps in two exact steps, both
  gated against brute force.
- **what it costs**: ~3 min in the interpreter — 24 directions × two full-field passes. The field
  is sized to the wall and §3b **proves** the window clips nothing (`SPEC` **L10**).

## S2c ✅ · the box in 12 directions, thin-walled and thick-walled — `src/hexbox.loft` · S · **DONE**

The editor's gesture is *"select the inside hexes as a rectangle"*, so the box is the input and
both kinds of wall are derived from it. (DESIGN 10.11.)

- **gate** `tests/box.loft`, five sections, every control fires.
- **twelve directions, two families.** `Plan` rotates in 0..5 (60 deg); `Box` rotates in 0..11
  (30 deg), and the odd six are a SECOND family, not a rotation of the first — a 30 deg turn is
  not a lattice symmetry (`X24`). Within a family the cell set is exactly equivariant.
- **measured**: same perimeter (38 edges both families), different area (27 vs 23 cells). The
  metric answer is 23.1, so the EDGE family — the gated `Plan` path — **over-counts its own
  footprint by 17%** on the boundary tie. Worth knowing before any area constant is read off it.
- **agreement**: even-rot `Box` == `housedraw`'s `Plan` cell for cell over all six rotations,
  0 differences, so this generalises the gated path instead of replacing it.
- **two walls, different in kind**: the THIN wall is an edge and costs no floor (houses); the
  THICK wall is a ring of whole cells you stand on (castles, town walls). The thick one is tested
  by flooding the outside and trying to walk in — 0 leaks in all 12 rotations, and the control
  removes ONE ring cell and gets 27 courtyard cells reachable.
- **cost**: an hour to a loft defect, not to geometry — a struct built inside an argument list is
  corrupted from the second loop iteration (crawler `LOFT-HANDOFF` **H4**, worked around by
  hoisting, reproducer at `probes/inline_struct.loft`). Two gate sections disagreed and BOTH
  readings looked like plausible rasterisation results.

## S3 ✅ · the turtle → cells — `src/hexform.loft` · S · **DONE** *(OD-11 resolved)*

**The `Plan`→cells half was already done by S2c** (`Box`/`Plan` rasterised, cross-checked
cell-for-cell against `housedraw`, 0 differences). What was left is the half S1 set up and never
filled: **a closed turtle `Form` → a filled region**, the hexagonal-tower primitive.

- **gate** `tests/form.loft` §12 / §12b / §13, every control fires.
- **the turtle walks CENTRE to CENTRE**, so its polygon vertices are hex centres and the path
  traces the centre-line of the boundary ring. The region is every hex on or inside it —
  `poly_holds` is exact integer point-in-polygon (zero cross product for on-edge, a cross-product
  SIGN for the crossing count), so there is no division and no epsilon anywhere.
- **the closed forms are PREDICTED, not read off the fill** — combinatorial counts of lattice
  points in the centre basis, and all ten cases match exactly:

  | shape | closed form | measured |
  |---|---|---|
  | triangle side `n` | `(n+1)(n+2)/2` | 3, 6, 10, 15 for n=1..4 |
  | rhombus `a×b` | `(a+1)(b+1)` | 20, 25, 30 for 4×3..4×5 |
  | hexagon side `n` | `3n²+3n+1` | 7, 19, 37 for n=1..3 |

  This is why the turtle is kept at all: a lattice polygon provably cannot be a rectangle
  (`X24`), but it holds a triangle, a rhombus and a hexagon **exactly** — the family `Plan`
  cannot express. Two primitives, two families, neither a special case of the other.
- **control**: a non-closing cycle (turn sum 11) is **refused** — `form_fill` returns `-1` and
  fills nothing. Law J is the admission test; filling "what it would have enclosed" invents a
  shape the author never wrote.
- **anchor invariance** (§13): the same form on 16 anchors across both row parities fills the same
  count, 0 disagreements — the cheapest check that the fill reads the SHAPE and not `r & 1`.
- **the area identity is NOT the fill's cross-check, and saying so was the real finding.**
  crawler's `hexforms.py` pins `shoelace(boundary) = 12 × cells` (T2). Re-measured here it holds —
  but it is an **identity** (Green's theorem) true for *any* cell set, holes included: punching the
  centre out of the hexagon gives 18 cells and shoelace 216, still balanced, which is **correct**.
  So it cannot validate the fill, and claiming it did would be the `X15` mistake — green for the
  wrong reason. What it *does* check is the boundary CONVENTION (corner table × edge table ×
  neighbour table), the `X26` class. Its control is therefore a deliberately wrong corner pairing
  (`i` with `i+2`), which collapses it: 294 vs 216. Recorded as **X33**.
- **the fill's cross-check is the closed forms** — independent predictions, not a second
  implementation, which is `STEPS`' option (b) as written.
- **L11 again**: the corner table in doubled `(k,m)` is `hex_field`'s `corner_k`/`corner_m`,
  already canonical. The first draft restated it privately and the compiler caught the
  redefinition — exactly the `X26` shape, caught by the language this time.

## S4 ✅ · turtle → walls, and the corner — `src/hexform.loft` · S · **DONE**

Boundary edges of the filled region, reusing `housedraw::draw_walls` **unchanged**. The new work
is the requirement `tests/house.loft` never checked: **what happens where two runs meet**
(`DESIGN.md` §10.4, four parts).

- **gate** `tests/form.loft` §14–§17, every control fires.
- **part 1 — the boundary is ONE CLOSED LOOP.** Measured over seven turtle shapes (both heading
  classes): `ends = 0`, `branches = 0`, `loops = 1`, every one. Vertices key by exact doubled
  `(k,m)` integers, so "the same corner" is integer equality, not a float compare.
  - `branches = 0` re-measures crawler's **no-pinch** claim (a hex vertex touches exactly three
    mutually adjacent cells, so a boundary cannot pinch — asserted there over 412 forms, T2).
  - **control**: punch a **strictly interior** cell out → the boundary becomes **2 loops**, which
    is `I3`'s named failure.
- **part 3 — the corner cell is claimed EXACTLY ONCE.** `housedraw::side_edges` classifies each
  boundary edge to a side, and nothing had ever checked the four runs **partition** the boundary:
  `5×4 → 38 = 9+10+9+10`, `4×4 → 38 = 11+8+11+8`, `6×4 → 46 = 11+12+11+12`. Control: three of the
  four sides cover only 28 of 38.
- **`I3`'s own control, now reachable**: the BAND rule against the BOUNDARY rule. An edge wall
  costs **no floor**; a band wall eats what it should enclose — hexagon n=1 keeps 1 of 7 cells,
  **triangle n=2 keeps 0 of 6**: a house with no room.
- **parts 2 and 4 are written now and enforced later.** The corner ANGLE and the MITER POINT need
  the fitted surface (S8). §10.4 says write them red at S4; a permanently red suite is not a
  signal, so they are a **tripwire** instead: `hexform::SURFACE_LANDED` is `false`, the gate prints
  both as PENDING, and flipping it at S8 makes the gate FAIL until the real checks are written.
  They cannot be forgotten and `make test` stays live. *(Flip it today if literal red is wanted —
  the section is already written.)*
- **the mistake worth recording**: the first hole control did not fire. `form_fill` anchors the
  turtle's **start vertex** at the given cell, so `(0,0)` is a **corner** of the shape, not its
  middle — removing it only dents the boundary. The same slip was in S3 §12b, which reported
  "punch the centre out" while removing a boundary cell; the section still passed because the
  area identity holds for any set. Both now find a **strictly interior** cell (all six neighbours
  filled) instead.

## S5 · field digest + the level-1 census — `src/formcensus.loft` + `tests/census.loft` *(new)* · S

A digest over `(cells, edges)`, then enumerate level 1 — the minimal closed form at every `h0`,
both classes — and count collisions.

- **gate** `tests/census.loft`: **reports the frontier** (largest level that round-trips, first colliding
  form). At level 1 the expected result is *the orientation-images of one triangle collide with
  each other and nothing else* — which is law **I**, re-seen from the census side.
- **control**: drop `turn` from the match key → collisions appear immediately.
- **note**: this is `rt_census_a` at `n = 1`. Growing `n` is the ladder; the machinery is written
  once, here.

## S6 · canonical text — `src/formtext.loft` + `tests/text.loft` *(new)* · S

`write` / `read` for the S1 cycle form only — `stencil / h0 / side len turn`. Rules **C1–C5**
(`DESIGN.md` §3): integers only, fixed order, reduced forms, fixed layout, defaults omitted.

- **gate** `tests/text.loft` (`rt_canon`): `write(read(T)) = T` byte-for-byte over every S5 form.
- **control**: reorder a field, or emit a default → diff.

## S7 · the corpus, and `rt_trip` **red** — `corpus/` + `tests/trip.loft` *(new)* · XS

Write the level-1 entries out as corpus files, and the round-trip gate **before `rebuild` exists**
— so it starts red and goes green when S8 lands.

```
corpus/a1/<case>.t      the canonical text
corpus/a1/<case>.f      draw(read(T)), or its digest
```

- **gate** `tests/trip.loft`: `write(rebuild(draw(read(T)))) ≟ T`, byte-for-byte, enumeration-driven over
  every corpus entry.
- **control**: a non-fitting model bypassing `snap` → diff.
- **the rule that makes it a gate at all**: entries are **committed and never regenerated**
  (`DESIGN.md` §8.0). Regenerating compares new output against new output and always passes.

## S4b · the wall surface, by averaging — `src/hexform.loft` · S *(new, from the model decision)*

The surface a run approximates is the **exact average** of its edges (`ROUNDTRIP` §6.1) — mean
direction is the integer sum of edge vectors, mean position the rational mean of edge midpoints.
Verified numerically: both exact, wobble ≤ 0.199 world units (0.172 m) on both families.

- **BLOCKED FIRST on corner ownership.** Per-side quantities are undefined until it is stated
  which side owns a corner edge — measuring today gives 2.598 m and 6.062 m for what must be one
  length (`DESIGN.md` §10.5). Read `housedraw::side_edges`'s rule, state it, gate it.
- **the corner rule exists** — `housedraw::side_edges` classifies by *which local coordinate is
  furthest outside the massing* (`ex_u = |lu| − hw` vs `ex_v = |lv| − hd`), no corner table. State
  it and gate it; it was never missing, only unread.
- **gate**, in order: (1) the corner rule holds; (2) both bands **in loft**, exact — tops `1/2 u`,
  sides `√3/2 u`, ratio `√3` (`ROUNDTRIP` §6.2); (3) the widening `(√3−1)/2 u` total,
  `(√3−1)/4 u` per face, applied to the tops only; (4) the band matches the **triangle
  subdivision** (each hex edge in 3) — recorded, **not yet verified**.
- **no tolerance appears in any of these.** Every constant is exact in `ℚ(√3)`; a gate that needs
  an `ε` here has the wrong formulation.
- **gate**: the recovered direction of a `Plan` side equals the nominal one **exactly**; the
  recovered offset is an exact rational; the wobble is reported per family.
- **control**: fit by least squares instead → a residual appears where there should be none.
- **why this replaces "the fit"**: `PLAN.md` M0 was originally "recover the straight/arc surface".
  Averaging *is* that recovery, with no tolerance — so the word "fit" was wrong twice over.

## S8 · `rebuild`, level 1 — `src/formfit.loft` *(new)* · M

Recover `(h0, lens, turns)` from a boundary cycle — **regime R1**: the grammar is the prior, so
this is an **exact match against the enumerated set**, not a fit. No tolerance appears.

- **gate**: `tests/trip.loft` goes **green**.
- **control**: hand a traced non-grammar footprint → it must land in **R2** and report `ρ > 0`,
  never silently return an R1 answer.

---

## Order, and where it can go wrong

```
S0 ✅ ─▶ S1             integers only, no geometry yet
          └──▶ S3 ─▶ S4  geometry, cross-checked against tests/house.loft
              └──▶ S5   the census machinery
                    └──▶ S6 ─▶ S7 ─▶ S8   text, corpus, recovery
```

- **S0–S1 are integer-only.** S0 is **done**, and it is where `X1`/`X2` stopped being inherited
  claims — `T2 → T1` for a dozen lines of gate, which is why re-measuring came first rather than
  being deferred as a nicety. *(S2 was a separate step for that re-measurement; it is absorbed
  into S0's gate section 3 and no longer numbered.)*
- **S3–S4 are where the design meets the existing code.** If the turtle path cannot reproduce
  `tests/house.loft`'s 27 cells and 38 edges, something in the model is wrong and it is far better to
  discover that here than at S8.
- **S5 is the first irreversible-ish commitment** — the digest defines what "the same field"
  means, and law **F** is stated against it.
- **S8 is the only M-sized step.** Everything before it is XS or S by construction, so if the
  ladder stalls it stalls somewhere cheap.

## What is deliberately not here

`⟨line⟩`/domain B, arcs, features, layers, `place`, and rungs A2–A8. All of them want S0–S8 to
exist first, and several want an open decision closed (`DESIGN.md` §10). The point of stopping at
level 1 is that **the whole pipeline runs end to end on the smallest possible form** before it has
to carry anything else.
