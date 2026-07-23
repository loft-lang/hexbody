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

## S5 ✅ · field digest + the level-1 census — `src/formcensus.loft` + `tests/census.loft` · S · **DONE**

`rt_census_a` at `n = 1`. The level is finite, so law **F** is **decided** here, not sampled.

- **gate** `tests/census.loft`, four sections, every control fires.
- **the enumeration is exhaustive**: every 3-sided unit form, all 12 starting headings × every
  turn triple summing to 12 — **660 proposed, law J admitted 30**. Law J is the admission filter
  and the control confirms it rejects 630, so it filters something.
- **the digest is canonical up to ORIENTATION and TRANSLATION**, and that is the design decision:
  a stencil is authored once and *placed* at one of the 12 orientations, so orientation-images are
  the same stencil (law **I**). It is **exact** — the sorted cell list compared element by element,
  no modular hash, because a hash collision in a census looks exactly like a law F violation.
- **cells determine edges at this level**, so the digest is over cells alone: by `I3` the wall IS
  the boundary of the fill. That stops holding when edges carry their own material (a door, A5),
  and the digest gains a material component there — recorded, not assumed.
- **THE FRONTIER: 30 admitted forms draw 3 distinct shapes; 183 colliding pairs, 0 unexplained.
  Law F holds at level 1.**
- **the finding, and it is for S6**: the stated expectation was *"the orientation-images of one
  triangle collide with each other and nothing else"*. The measurement is a **refinement** of it —
  collisions are the orientation-images **and the cyclic re-spellings**. A closed cycle has no
  distinguished first corner, so `[2,5,5]`, `[5,5,2]` and `[5,2,5]` are one triangle walked from
  three places. **The canonical text must fix the starting CORNER, not just the winding (C3)** —
  otherwise one stencil is written ~10 ways and reads as many. Recorded as `X38`.
- **the mistake this caught in my own check**: the first version asserted that a collision across
  `h0` parity was a law F violation, on the assumption that `h0` parity classifies the form. It
  does not — `h0 = 0` with turns `2,5,5` runs headings 0, 2, **7**, mixing both classes. The gate
  went red on 72 "violations" that were nothing of the kind. Law F had to be stated correctly
  before it could be checked at all.
- **controls**: keying on the cell COUNT instead of the shape collapses 3 shapes to 2; dropping the
  turn sequence from the identity collapses 30 forms to 12; and the re-spelling test itself is
  checked both ways (`[4,4,4]` is not a re-spelling of `[2,5,5]`; `[5,5,2]` is).

## S6 ✅ · canonical text — `src/formtext.loft` + `tests/text.loft` · S · **DONE**

`write` / `read` for the S1 cycle form: `stencil / h0 / side len turn`, rules **C1–C5**.

- **gate** `tests/text.loft` (`rt_canon`), three sections, every control fires.
- **`write(read(T)) = T` byte-for-byte** over all 30 forms the S5 census admits, and
  `read(write(f)) = f` as a Form. The round-trip gate is a byte `diff` (`P3`), which is only
  meaningful if a model has exactly ONE spelling — so this and the corner rule are two halves of
  one claim.
- **the START CORNER is now fixed** (`X38`, the requirement S5 found). Of the `n` cyclic
  spellings, the canonical one is the lexicographically smallest `(turns, lens, h0)` —
  deterministic, total, and needing no extra tie-break: a fully periodic cycle like `[4,4,4]` has
  several spellings with identical turns and the `h0` component then decides. Every re-spelling of
  every admitted cycle canonicalises to the same text (30 cycles × 2 alternative corners, 0
  disagreements). Control: the RAW spellings must differ, or there was nothing to canonicalise.
- **the collapse is exact: 30 enumerated spellings → 10 canonical texts**, i.e. 10 cycles × 3
  corners. What remains is `h0` alone, and the gate proves it: every pair sharing a field whose
  canonical texts differ does so **only** in the `h0` field. That closes the loop with S5.
- **orientation is deliberately NOT quotiented.** `h0` is the stencil's own authored heading and
  placement carries `orient` separately (`DESIGN.md` §3's example). Two stencils differing only by
  `h0` are different authorings that law **I** makes interchangeable at USE time — placement's job,
  not the text's.
- **the parser is strict, and refuses rather than repairs**: a reordered field (`turn` before
  `len`) and out-of-order side indices both parse to 0 sides. A lenient reader would admit a
  second spelling of one model and the byte diff would stop meaning anything. Control: a
  well-formed text must still parse, or the two refusals prove only that it rejects everything.

## S7 ✅ · the corpus, and `rt_trip` **red** — `corpus/a1/` + `tests/trip.loft` · XS · **DONE**

- **the corpus is written and committed**: 10 entries, one per canonical level-1 text.
  `src/corpusgen.loft` wrote them **once**; it is deliberately NOT in `make test`, because a gate
  that regenerates its own baseline compares new output against new output and passes
  unconditionally — the `X15` failure in our own tree. Re-running it is a **decision**, not a
  chore: if `form_write` or `draw` changes, read the diff and judge.
- **gate** `tests/trip.loft`, RED on purpose until S8 lands `rebuild`.
- **the runner ASSERTS the redness** (`run_red` in `tools/run_tests.sh`). The gate must not print
  its OK marker and must print `TRIP RED: rebuild absent` — red for the *stated* reason, never
  because it crashed. So it **runs on every `make test`** and cannot rot, and **if it ever goes
  green by accident the runner fails** and demands the row be promoted. That is strictly stronger
  than a gate that is simply always red, and it keeps `make test` a live signal.
- **the legs that exist are already green against committed bytes**: every committed `T`
  round-trips `write(read(T)) = T`, and `draw(read(T))` still reproduces the committed `.f`. That
  second one is the **regression anchor** — it fires against bytes written before any future
  change to `form_fill` or the digest.
- **law F over the corpus**: 0 sharing pairs among the 10 entries.
- **the finding — the corpus digest and the census digest are DIFFERENT FUNCTIONS.** The first
  `.f` used the census's `field_digest`, which quotients by orientation because the census asks
  *how many shapes does this level hold* (law I). Law F asks something else: is `draw` **injective**
  — about the cells actually written. A stencil at `h0=0` and the same stencil at `h0=6` draw
  genuinely different cells, so the shape digest called them equal and the gate reported **17 false
  law F failures on a 10-entry corpus**. `field_exact` (no orientation quotient, no translation
  quotient) is the corpus digest; recorded as `X40`. Caught before the corpus was committed, which
  is the only time it was cheap to fix.

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
