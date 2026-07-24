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

## S4b ✅ · the wall surface, by averaging — `src/hexsurf.loft` + `tests/surface.loft` · S · **DONE**

The surface a run approximates is the **exact average** of its edges (`ROUNDTRIP` §6.1) — nothing
is fitted, so nothing has a tolerance.

- **the blocker was already cleared.** S4b was listed as *blocked on corner ownership*; S4 gated
  that `side_edges`' four runs **partition** the boundary (`X36`), so per-side quantities are well
  defined. The rule was, as the step said, *never missing, only unread*.
- **direction** — the summed edge vector is **exactly parallel** to a heading, zero cross product,
  over all 24 side-runs across 6 rotations. Position is kept as an exact **rational**
  (numerator/denominator in doubled coordinates); no float enters the derivation.
- **the bands of §6.2, measured and confirmed exactly**:

  | family | corner band | §6.2 |
  |---|---|---|
  | east (tops), `dm = 0` | `0.50000000` | `1/2 u` ✓ |
  | north (sides), `dk = 0` | `0.86602540` | `√3/2 u` ✓ |
  | ratio | `1.73205081` | `√3` ✓ |

- **the widening rule** — `(√3−1)/2` total, `(√3−1)/4` per face, tops only, landing **exactly** on
  the sides' band. In metres: `0.31699 m` total, `0.15849 m` per face.
- **a fact §6.2 does not state**: the **midpoint** band is not the corner band. On the east family
  the edge midpoints are **exactly colinear** (band 0) — the mean line passes through every one —
  while on the north family they span the full `√3/2`. The corners hide it; the row stagger causes
  it.
- **control**: the scatter a least-squares fit would have to threshold — `0.0000000` on the east
  family, `0.9166667` on the north. Real on one family, so *"averaging beats fitting"* is a
  measurement rather than rhetoric: averaging names that same geometry as the exact constant `√3/2`
  and has nothing to tune.
- **NOT verified, and the gate says so**: that this band matches the **triangle subdivision** (each
  hex edge in 3, wall width `√3/6 u`). `X10` is T2 and has not been re-measured here.

### The check was written wrong twice before it was written right

Both wrong versions failed on geometry that was never in doubt, and both were *my formalisation of
"exact" being too narrow*:

| spelling | why it was wrong | failed |
|---|---|---|
| "one component is zero" | only 4 of 12 headings have one; a NE side is `(1,3)` | 16 of 24 |
| "an integer multiple of the step" | the SUM over a run is `(0,14)` where the step is `(0,6)` | 12 of 24 |
| **"parallel — zero cross product"** | what §6.1 actually claims: the *direction* is exact, the magnitude carries no claim | **0 of 24** |

Worth recording because the failure looked like a geometry defect each time. The lesson is the one
A4 taught in a different form: when a check fails, ask what the claim actually is before assuming
the subject is broken.

## S8 ✅ · `rebuild`, level 1 — `src/formfit.loft` · M · **DONE**

Recover `(h0, lens, turns)` from a drawn field — **regime R1**: the grammar is the prior, so this
is an **exact match against the enumerated set**, not a fit. No tolerance appears anywhere.

- **gate**: `tests/trip.loft` is **GREEN**. `write(rebuild(draw(read(T)))) == T` byte-for-byte over
  all 10 committed corpus entries, 0 diffs, and all 10 recover as **R1, ρ = 0, exactly one match**.
  Its runner row moved out of `run_red` into the normal table — the promotion the tripwire demanded.
- **what makes the match legitimate is the S5 census, not an assumption**: it decided level 1 is
  finite and that law F holds over it, so an exact match is unique when it exists. `rebuild` does
  not take that on trust — it **counts its matches** and refuses to answer if more than one
  candidate fits, because a second match would mean law F failed at this level.
- **a third digest, for a third question.** `rebuild` matches on `field_norm`: translation
  quotiented, orientation NOT. A recovered stencil must be the same shape at the same heading
  (`h0` is authored, `X39`), but WHERE it was drawn is placement's business. The three:

  | digest | quotients | question |
  |---|---|---|
  | `field_digest` | orientation + translation | how many SHAPES? (census, law I) |
  | `field_exact` | nothing | is `draw` INJECTIVE? (corpus, law F) |
  | `field_norm` | translation | which STENCIL is this? (rebuild, R1) |

- **control**: a 5-cell hand-drawn blob lands in **R2 with ρ = 2 and 0 matches**, and
  `rebuild_text` returns **empty** for it — an R2 guess can never be spelled as if it were an
  authored stencil. The control is checked both ways: a real corpus field still comes back R1.
- **H4 bit again, and the rule caught it.** The verification loop built `form_read(...)` **inline
  in an argument list** beside a store-allocated `HexSet` and recovered **9 of 10** while the
  hoisted loop beside it was byte-perfect — exactly the corruption-from-the-second-iteration
  signature filed as crawler `LOFT-HANDOFF` **H4**. Hoisting fixed it. The discrepancy between two
  loops doing the same thing is what exposed it; a single loop would have read as a real defect.

## A2 ✅ · grow `len` on the same shape — **DONE** *(rung, not a step: the machinery was written at S5–S8)*

The rung ladder's question: **does length alone ever collide?** The answer is **no** — and what
unequal sides *do* add is something level 1 could not show.

- **the enumeration is parameterised**: `forms_upto(n)` / `forms_at_level(n)` — a form's LEVEL is
  its longest side, so the levels nest and `corpus/a1` stays untouched forever.

  | level | forms | shapes | distinct fields | `draw` injective? |
  |---|---|---|---|---|
  | 1 | 10 | 3 | 10 | ✅ |
  | 2 | 32 | 7 | 32 | ✅ |
  | 3 | 60 | 12 | 60 | ✅ |

- **law F holds at every level scanned.** `draw` is injective — every canonical form has its own
  field — so `rebuild` can stay exact and the frontier is not below level 3.
- **THE FINDING: unequal sides introduce CHIRALITY.** Collisions by *shape* digest split into
  rotations and **mirrors**, and the mirrors appear only from level 2:

  | level | collisions | rotation | mirror | neither |
  |---|---|---|---|---|
  | 1 | 17 | 17 | **0** | 0 |
  | 2 | 100 | 64 | **36** | 0 |
  | 3 | 198 | 126 | **72** | 0 |

  Level 1 has none because equal sides make every admitted form **achiral** — its mirror is just a
  rotation. Unequal sides make a form and its mirror genuinely different texts (`turn 3,5,4`
  against `turn 3,4,5`) that draw mirror-image fields. The flip is one of the 12 orientations, so
  they share a shape digest: **law I, not a law F failure.**
- **the S5 check was level-1-specific, and was also the wrong instrument.** It asserted every
  shape-collision is a cyclic *re-spelling*; that holds only while forms are achiral, and it
  reported 36 "unexplained" collisions at level 2 that are simply the flip. It was tautological
  besides — collisions are *grouped by* an orientation-quotienting digest, so "every collision is
  an orientation-image" cannot fail. The non-vacuous law F question is injectivity of `draw`
  (`field_norm`), which is what the census now asserts.
- **the corpus grew**: `corpus/a2/` holds the **22** forms new at level 2; `rt_trip` now covers
  **32 entries across both levels**, all byte-for-byte, all R1 with `ρ = 0` and exactly one match.
- **`corpusgen` now REFUSES to overwrite a level that already has entries** — the never-regenerate
  rule enforced mechanically instead of trusted to memory.
- **a loft defect cost real coverage** (crawler `LOFT-HANDOFF` **H6**): reading a file invalidates
  a live `list_dir` result from the second listing on, so the gate loaded **3 of 22** a2 entries
  and reported a clean pass on what it saw. A gate that silently tests a third of its corpus and
  says OK is worse than one that fails. Worked around by snapshotting the names before any file
  read; 20-line standalone repro filed.

## A3 ✅ · grow side count — 4, 5, 6 — **DONE** *(the houses rung)*

- **the enumerator is now parameterised in SIDES too** (`forms_sides(sides, maxlen)`), using a
  mixed-radix odometer over the turn tuple rather than nested loops, so the side count is an
  argument instead of a shape baked into the code.

  | sides | forms | shapes | distinct fields | `draw` injective? |
  |---|---|---|---|---|
  | 3 | 10 | 3 | 10 | ✅ |
  | 4 | 21 | 5 | 21 | ✅ |
  | 5 | 30 | 4 | 30 | ✅ |
  | 6 | 36 | 9 | 36 | ✅ |

- **law F holds at every side count.** `corpus/a3/` adds the **87** forms with 4–6 sides at unit
  length; `rt_trip` now covers **119 committed entries across a1 + a2 + a3**, all byte-for-byte,
  all R1 with `ρ = 0` and exactly one match.
- **`rebuild`'s candidate space is now built ONCE per run** (`rebuild_with`). It was re-enumerated
  on every lookup, which is quadratic over a corpus and was already wasteful at 32 entries.
- **THE FINDING: the frontier is now COST, not correctness.** The two growth axes MULTIPLY:

  | sides × maxlen | forms |
  |---|---|
  | 3 × 1 → 10 | 3 × 2 → 32 |
  | 4 × 1 → 21 | 4 × 2 → **138** |
  | 5 × 1 → 30 | 5 × 2 → **372** |
  | 6 × 1 → 36 | 6 × 2 → **900** |

  Sides 3–6 at maxlen 2 is **1442 forms and ~66 s just to enumerate**. Law F has not failed
  anywhere — what fails is the affordability of *deciding* it exhaustively.
- **and that is what puts today's house out of reach.** The 4-sided house `[4,5,4,5]` needs
  `maxlen 5` — roughly **1.2 M proposals** — so `rebuild` cannot enumerate its class. That is a
  real limit this rung found, recorded rather than papered over: `DESIGN.md` §8's *"within the
  frontier law F is decided, not sampled"* now has a measured boundary on where that frontier can
  be afforded.
  - ⚠ **this bullet originally named indexed recovery as the way through, and that was wrong** —
    see the correction under *Indexed recovery* below. An index still has to be BUILT by walking
    the space, so it does not shrink the enumeration at all. The house needs **constructive**
    recovery.

## Indexed recovery ✅ · draw the candidates once — `src/formfit.loft` · S · **DONE**

`rebuild_with` re-DREW every candidate on every lookup: **O(N) fills per field, O(N²) over a
corpus — 14 161 fills for the 119 entries we hold.** A candidate's field never changes, so its
digest can be computed once into a `digest → form` map and recovery becomes a single probe.

- **measured**: `index: 119 entries, 119 fills to build, 0 digest collisions` — against the
  **14 161** the scan would have cost. Exactness is unchanged: the digest *is* the field, compared
  in full, so a hit is the same R1 answer the scan gave, not a heuristic narrowing.
- **law F is now checked ONCE, over the whole candidate space, instead of per lookup.** Two
  candidates sharing a digest would silently overwrite each other in the map, so the build counts
  clashes and the gate asserts zero — strictly better than the old per-lookup `rb_matches`, which
  only ever looked where a corpus entry happened to land.
- **an R2 miss falls back to the scan**, and only then, purely to compute the residual. R2 is the
  exceptional path, so paying O(N) there costs nothing and keeps `ρ > 0` a real measurement.
- **control**: every corpus entry is recovered **both ways** and the two must agree — 119 entries,
  0 disagreements, plus the R2 blob matching on regime *and* residual. A faster recovery that
  quietly answers differently is worse than a slow one. That control is why the gate still pays
  the O(N²) scan once; the *production* path no longer does.

### ⚠ The correction: this does NOT reach the house

A3's write-up said indexed recovery was "what the house needs". **That was wrong, and the mistake
is worth naming**: it confused two different costs.

| cost | fixed by an index? |
|---|---|
| **per-lookup** — redrawing N candidates for every field | **yes** — O(N²) → O(N) |
| **space construction** — enumerating the admissible forms at all | **no** — the index is built *by* that walk |

The house's class is ~1.2 M proposals to enumerate, and an index still has to walk it. So the house
is exactly as far out of reach as before. Reaching it needs **constructive recovery** — reading
`(h0, lens, turns)` off the field's own geometry (boundary → corners → turtle) — which is
`hexmatch`-shaped work (`X21`), not a faster table.

## Constructive recovery ✅ · read the form off the field — `src/formfit.loft` · M · **DONE**

Indexed recovery removed the per-lookup cost but is **built by** the enumeration, so it could only
ever recover what was enumerated. This enumerates **nothing**: it reads `(h0, lens, turns)` off the
field's own geometry in O(cells), independent of how large the admissible space is.

### The construction, and why it is exact

1. **Every admitted form is CONVEX.** Law J requires the turns to be positive and to sum to 12 —
   all exterior angles positive, exactly one revolution, which *is* convexity. Not an assumption
   about the corpus; a consequence of the admission rule.
2. **Every polygon vertex is a hex centre** (S3), and `form_fill` takes every hex on or inside. For
   a convex polygon whose vertices are lattice points, the **convex hull of the contained lattice
   points is the polygon itself** — the corners are extreme and cannot be hulled away.
3. So hull the filled cells; the hull vertices **are** the turtle's corners, in order. Collinear
   cells along a long side are interior to an edge and drop out — exactly right, they are not
   corners.
4. Each side vector is an exact integer multiple of one of the 12 heading steps, found by trying
   all 12 (a constant). **No gcd reduction**: `head_step(0)` is `(2,0)`, not `(1,0)`, so a
   primitive reduction would land off the table.

**The hull is taken in `(k,m)`, not in world coordinates**, and that is safe rather than lucky:
`(k,m) → (k√3/2, m/2)` is linear with determinant `√3/4 > 0`, so it preserves convexity *and*
orientation. No float enters the recovery at any point.

**It proposes, then VERIFIES by re-drawing.** That keeps `ρ = 0` a measured fact rather than a
claim, and sends anything that does not reproduce its own field to R2.

### Measured

- **119 of 119** committed corpus entries recovered constructively, **0 diffs**.
- **The house.** Today's 4-sided `[4,5,4,5]` needs `maxlen 5` (~1.2 M proposals, `X43`), so it is
  deliberately *not* a candidate — and the gate asserts that indexed recovery **misses** it, or the
  comparison would prove nothing:

  | recovery | the house `[4,5,4,5]`, 30 cells |
  |---|---|
  | indexed (enumerated space) | **R2**, `ρ = 22` — cannot be found this way |
  | constructive | **R1**, `ρ = 0`, canonical text identical |

  **Constructive recovery reaches strictly further than the enumeration.** That is the whole point
  of the exercise, and it is now gated rather than argued.
- **control**: a hand-drawn blob still lands in **R2** with `ρ = 5` and an **empty** text — so
  "reaches further" does not mean "answers anything".

### The limit, stated rather than discovered later

The hull argument holds **only for convex forms**. A non-convex form (**A4**'s L-shaped house)
needs a negative turn, which law J's turn condition does not currently produce and the hull would
silently smooth away. Reaching those wants boundary **tracing** rather than hulling — `hexmatch`'s
shape (`X21`) — and that is the next real piece of work, not an extension of this one.

## A4 ✅ · unequal sides, non-convex — **DONE** *(and it moved the doorstep, not the recovery)*

The rung's question: **where does a reflex corner stop being recoverable?** The answer is *at every
size measured* — and the reason is not the recovery.

### Law J is not a sufficient admission rule

Law J asks only that the walk CLOSES (`Σ turn = 12`, vector sum zero). Allowing negative turns
shows it admits two things it must not:

- **non-simple walks** — a repeated vertex, so the boundary is not a simple closed curve and
  "inside" is undefined;
- **non-convex forms** — which **violate law F outright**.

| scale | simple non-convex 4-sided | recovered | **same field, OTHER form** | refused |
|---|---|---|---|---|
| 1 | 94 | **0** | 86 | 8 |
| 3 | 94 | **0** | 66 | 28 |
| 5 | 94 | **0** | 60 | 34 |

The middle column is the finding: the recovery reproduces the field **exactly** (`ρ = 0`) while
returning a *different* form. Two distinct forms draw one field, so `draw` is not injective there —
and **no recovery method can separate them.** Scaling the shape five times shrinks the failure
(86 → 60) but never removes it.

Against that, the **admissible** (convex, simple) 4-sided set: **138 forms, 0 failures.**

### ⚠ This corrects the guidance I left at constructive recovery

§10.22 said *"A4 must switch to boundary tracing"*, on the theory that hull recovery was the thing
failing. **That was wrong.** Tracing would rescue only the *refused* column (8→34 cases); the
majority are ambiguous **in the model**, and a better algorithm cannot help. The problem was never
the method.

### So the fix is at the DOORSTEP, not in the recovery

`form_admissible` = **closed (law J) ∧ simple ∧ convex**, and the enumerations now call it instead
of `form_closes`, so the rule is single-sourced rather than implied by a turn range. `fits?` must
refuse non-convex and non-simple stencils **at authoring time** (`K-FIT`) — they cannot be
recovered even in principle, so they must never be authored. That is `DESIGN.md` §5.2 exactly: *a
restriction the census finds is a fact to record, not a defect to engineer away.*

Counts are unchanged by the switch (10/32/60 by level, 10/21/30/36 by side count), which confirms
the earlier enumerations were already inside the rule — they just had not said so.

## A5 ✅ · features on straight sides — **DONE** *(the `surf`-slot question, answered)*

The rung asked *does the `surf`-slot collision bite here?* **No — it was already fixed**, earlier
in this plan: `place_opening` writes `edge_set_mat`, not `edge_set_surf`, so a feature IS the
material on the wall slot (`OD-9`, closed). What A5 adds is whether that **survives the round
trip**.

### The feature grid — `t` is exact only at the edge centres

The model stores `(side, t)` (`I2`); the field stores a **material on edges**. So `t` must come
back out of a set of marked edges, and an arbitrary `t` cannot: every `t` in an interval of width
`1/n` selects the same edge. What *is* exact:

```
the edge centres along a run of n edges sit at   t = (2i + 1) / 2n     (odd numerator)
```

Measured on a 5×4 plan's side 3 (`n = 10`): every stored edge's numerator is odd and in range; a
door authored at `t = 7/20` recovers as **exactly 7/20**; a 3-edge window at `t = 1/2` recovers as
**7, 9, 11** — consecutive centres. **Control**: a door authored at `t = 0.32`, between centres,
**snaps** to `7/20` — so `fits?` must refuse off-centre `t`, exactly as §10.10 quantises line
endpoints to what the storage can distinguish.

The run is **not** stored in `t` order (`side_edges` fills it in cell-scan order), so a feature is
indexed by its exact `t` numerator, never by its position in the run.

### `I1`, measured both ways

| | wall edges | dangling ends |
|---|---|---|
| plain wall | 38 | 0 |
| **door re-materialled** | **38** | **0** |
| **edge deleted instead** | 37 | **2** |

The averaged surface (S4b) is untouched by the door — direction `(10,0)`, heading 0 — because a
feature is a material, not a geometry change. **The doored-tower defect cannot arise from this
path**, and the control shows the check can see it if it did.

### A third wrong check in as many steps

`wall_edge_count` first iterated only the **three owned** directions and read **19** where the
boundary has **38** — a boundary edge can be owned by the *outside* cell, so half were missed. The
geometry was, again, never in doubt. Recorded because the pattern is now consistent enough to be
worth naming: **a count that disagrees with a gated number by a clean factor is a bug in the
counter, not a discovery.**

## A6 ✅ · arcs — the round tower shell — **DONE** *(`OD-10` resolved)*

`OD-10` asked whether a run of rounded slots gives back its **centre and radius** exactly (R1) or
only by a fit (R2). The answer is **split**:

| parameter | recoverable? |
|---|---|
| **centre** | **exactly** — 25 towers at 25 different centres, all recovered; a blob is refused |
| **radius** | **no** — 161 radii over `0.5..4.5 u` collapse to **4** distinct fields |

**The shells are exact integers, so `hexarc` is float-free.** Four times a cell's squared distance
is `3k² + m²` — `vec_n2_4`, already in the tree — so a shell is an integer `N`, its radius is
`√N/2 u`, and membership is the integer test `N' ≤ N`. Out to 64 the shells are **`0, 12, 36, 48`**,
matching the float sweep's breakpoints (`√12/2 = 1.732`, `√36/2 = 3.0`) — the cross-check that the
integer and continuous formulations describe one geometry.

### The `Sep` / `X7` fork was narrower than I flagged

I said A6 needed `Sep` reconciled against crawler's collision-match objective **before** starting.
Having measured, they do not compete:

- **`Sep` is recoverability** — *which radii are distinguishable?* Answered exactly: the shell grid.
- **`X7` is a choice policy** — *which shell should the editor snap a nominal radius to?* Nearest
  by radius, or the one whose collision proxy best matches.

The policy cannot affect the round trip, because whichever shell is chosen is what the field
stores. **A6 was never blocked**; the fork is real, lives in the editor, and stays open harmlessly.

### The third parameter to land the same way — now an invariant

| parameter | quantised to |
|---|---|
| line endpoints | hex vertices, a whole number of periods (§10.10) |
| feature `t` | edge centres `(2i+1)/2n` (`X48`) |
| **arc radius** | **shells**, realisable `3k²+m²` (`X49`) |

Three independent measurements, one rule — recorded as **`X50`** / `SPEC` **I-QUANT**: *a
continuous model parameter must be quantised to what the field distinguishes; off the grid it is
silently snapped, not rejected.*

### The gate caught my fourth wrong helper

`arc_shells_upto` first filtered offsets by `k ≡ m (mod 2)` alone and invented shells — `N = 4`,
from `(0,2)` — that **no pair of cells realises**, because a cell-to-cell offset has `m = 3·Δr` and
so `m` must be divisible by **three**. Two sections failed on it. Worth noting the other side of
that ledger, though: **every one of these was caught by a control before it became a recorded
fact.** That is the discipline working, not failing.

## A7 ✅ · the doored tower — **DONE** *(the named defect, refused by construction — `X51`)*

A7 combines the arc (A6) with a feature (A5): a door on a round tower. The rung's question was
*the named defect* — "a wall with a door fitting **3 arcs instead of 1**" (`design/FEATURES.md`
§3), a law **D** failure with prior art. Like A5, the answer is **already fixed**, and A7 shows
*why the two pieces compose at no cost*.

### The arc's recovery is blind to the door — by its own type

A tower is a filled disk (A6); its wall is the boundary edge loop. A door is a **material override
on a contiguous span of those boundary edges** (`arc_door_wedge`) — it re-materials them and never
removes a cell. The composition is free for a reason visible in the signatures:

```
arc_recover_centre(cells)   arc_shell_max(cells, …)     ← take only the CELL set
arc_door_wedge(…, edges, …, mat)                        ← writes only edge MATERIALS
```

So the doored tower's cells are **byte-identical** to the plain tower's, and its centre and shell
come back unchanged — not by discipline, but because the recovery **cannot see** the edges. `N`, the
number of sites that must re-assert "a feature is a material, not a hole," is **1**: the door API is
the only writer, and it can only re-material. The defect is **unreachable through it**.

### Measured on a shell-108 tower (37 cells, wall 42 edges, one closed loop)

| | centre | shell | wall | door edges |
|---|---|---|---|---|
| plain | `(0,0)` | `108` | 1 loop, 0 ends | — |
| **3 doors annotated** | **`(0,0)`** | **`108`** | **1 loop, 0 ends** | 17 written, **17 recovered** (exact) |
| CONTROL — delete the 3 spans | — | — | **6 ends → 3 arcs** | — |
| CONTROL — notch the disk's cells | **not found** | — | — | — |

The door reads straight off storage (a door-material edge *is* a door, `ROUNDTRIP` §2.4.1) — R1,
no fit. **Deleting** the three spans instead fragments the one loop into **three arcs** — the named
defect, reproduced exactly — and notching the disk's cells **loses the arc** (the centre no longer
recovers). Both controls have to *reach around* the door API to touch cells or blank a material,
which is the point: authoring cannot express the defect.

### The check was almost vacuous — and a control fixed that

"After annotating, the arc is unchanged" is true *by construction*, so on its own it is a check that
cannot fail (`CLAUDE.md`: a check that cannot go red is not a check). It is made live by **CONTROL
B**: notching the cells shows the recovery **is** sensitive to the disk, so "unchanged" is a real
result, not a tautology — confirmed by a falsification probe (a door that deletes its cells flips
`found` from true to false). The one-loop check is made live the same way by **CONTROL A**.

## A8 · two stencils adjacent — **adjacency axis DONE** *(the rung the single-object census cannot see — `X52`)*

A8 is *combination* — where things that work **alone** stop working **together**. It has several
axes; this step closes the first and most concrete, **"who owns the shared edge?"**, and names the
rest so they are not mistaken for covered.

### Most of the work was already done — in crawler

crawler settled the mechanism (`EXTRACTION.md`; `cut_arb` in its `hexway.loft`) and stated it in one
line: **"mark every part, THEN cut once."** Do not draw each stencil's walls and overlay them —
**union the footprints, then cut the boundary of the union once**, tagging each edge with its cell's
source material. It is a **T2** prototype there; re-measured here float-free, it becomes **T1**.

### Who owns the shared edge? Nobody — and that is the answer

The shared edge of two adjacent stencils is **interior to the union**, so cutting the union's
boundary never marks it. The two stencils **fuse** into one fabric. Three claims, measured on two
adjacent blocks (`combine_cut` vs the naive per-body overlay):

| claim | union-then-cut | per-body overlay (the control) |
|---|---|---|
| **order-free** — `combine(A,B) == combine(B,A)` | **0 diffs** | **7 diffs** — last-writer, order-dependent |
| **the seam fuses** — shared edges marked | **0** | **7** — a spurious seam wall |
| **merged == single stencil of the union** | **0 diffs** (canonical rep, P1) | — |
| **a sealed wall is field-distinct** | **7 diffs** (behaviour survives) | — |

So the per-body overlay — which is *fine for one stencil* — is **order-dependent and invents a
seam** the moment there are two. `combine_cut` is order-free **by construction** (it reads the
finished union and a fixed source map, never stamp order), and the overlap tie-break is the **lower
material id** — intrinsic, so order-freeness holds for overlapping stencils too, not only the gated
disjoint case (verified by a falsification probe on two overlapping blocks).

### Distinguishability lands exactly where the design predicted

The **authoring split is not recoverable** — the merged composite is field-identical to the single
stencil of the union — and that is *correct* (`P1`: `rebuild` returns the canonical representative;
which two parts were authored is not fabric). What **must** survive is a **behavioural** difference:
a composite with a *sealed* interior wall is field-distinct from the open merged one. Both halves
are gated — the narrow, true form of law **F** for composites (DESIGN §8.0.1), not the false
"all composites are distinguishable."

### What this rung does NOT cover — named, not skipped

The seam here is **exact** because both stencils live in the **world frame** (no pose, no float), so
`ε_seam` and the `κ ≥ 3` contention rate — which need **posed** bodies in different frames — are
untouched and stay open (`DESIGN.md` §6–§7). The other A8 axes wait on machinery this rung does not
build: **overlap** arbitration by nearest surface (only the lower-id degenerate case is here),
**linework** (domain B), **terrain** (`OD-4`), and **level** separation (crawler's bridge
guarantee — different levels never contend). A8's spine is closed; its reach is recorded.

## A8 · the frame seam — posed bodies, `ε_seam` and `κ` **MEASURED** *(the two OPEN constants, closed — `X53`)*

The one A8 axis with no crawler prototype: the frame seam. crawler's collision (`collide`,
`sweep_path`) is all **single-frame**; a **posed body against the world** — two frames related by a
continuous pose — was a **T3 design** (`DESIGN.md` §6), never built. So this is hexbody's own first
measurement, and it closes the two constants `DESIGN.md` §7 left **OPEN**: `ε_seam` and the `κ ≥ 3`
rate.

### The instrument: a Pythagorean pose gives an exact oracle

A pose is a rotation + translation, and rotation by a general θ is float. But `cos 37° ≈` nothing
rational — so choose the **3-4-5 angle**: `cos = 4/5`, `sin = 3/5`. The transform then maps
**rationals to rationals**, so an **exact integer oracle** exists, and the float pipeline's
disagreement with it *is* the seam band. Without this trick "the error is small" is an assertion;
with it, it is measured against ground truth.

### K₁ — the pose transform is the sole float step, and `ε_seam` is machine ε

Every cross-frame query routes through the transform once (world → p⁻¹ → exact local test), which is
the **only** float in a stack that is otherwise all integer (`X1`–`X52`). So `ε_seam` is the entire
error budget, and it is the transform's round-trip residual:

| measured | value |
|---|---|
| `ε_seam = max \|p(p⁻¹(x)) − x\|` over 41×41 × 6 poses | **≈ 7.1e-15** (machine ε) |
| routed float vs the exact oracle, 1681 points | **0 disagreements** (interiors exact) |
| **CONTROL** — snap the body's wall to the world lattice | body displaced **0.4**, **12 interior cells** misclassified |

The error band is ε-wide — astronomically below the lattice spacing of 1 — so no lattice query is
ever misclassified. The **forbidden fix** (snapping to close a crack) does the opposite of help: it
moves a machine-ε *seam* error into a real 0.4 *interior* displacement, voiding law **D**. That
control is what makes "0 disagreements" a result rather than a tautology.

### K₂ — κ is a counter, rare at a point and worse on a sweep; arbitration is order-free + fail-safe

A pile of posed bodies + the world. Contention degree `κ` = how many frames claim a point:

| measured | value |
|---|---|
| `κ ≥ 3` at a **point** | **10 of 841** (rare) |
| a **swept** segment | max κ at any point **3**, but the sweep touches **4** distinct frames |
| **CONTROL** — a κ counter that forgets the world frame | short on **113** cells |

So `κ ≥ 3` is a **counter, measured on sweeps** (a swept volume straddles frames a point never
sees) — exactly the design's warning, now with numbers. Arbitration where frames disagree is
**order-free** (the owner is the lowest id among the solids, so `arb(A,B) = arb(B,A)`) and
**fail-safe** (a world *gap* under a body *solid* resolves to **solid** — a crack is a spurious
contact, never a fall-through, `I4`). Control: a "first-solid-wins" owner diverges by order (2 vs 5),
which is what `arb_owner` avoids.

### What of A8 remains

Overlap arbitration by nearest *surface* (next), **linework** (domain B), **terrain** (`OD-4`), and
**level** separation. The seam and contention machinery — the load-bearing, never-before-built part
— is now measured and gated.

## A8 · overlap arbitration by nearest surface — **DONE** *(gating `cut_arb` — `X54`)*

The last arbitration axis. X52 (`combine`) tagged each boundary edge with its cell's source
**material** — the union-then-cut principle. crawler's `cut_arb` does the richer thing: it tags each
boundary edge with the nearest analytic **surface** — the edge's *collision proxy*, chosen by
geometry. It was already **copied into `hexway`** (byte-identical to crawler's) but **ungated here**;
this rung gates it.

### The mechanism, and the case it handles that X52 does not

`cut_arb` is "mark all, THEN cut once": for each boundary edge of the finished union it picks the
nearest surface by `surf_distance`, ties to the lower id. It reads only the finished cells and the
fixed surface set, never stamp order — **order-free by construction**. Where X52 answered *which
material*, this answers *which surface an edge collides against* — the thing X52's material-only cut
never assigned.

### Measured on two overlapping tower disks (their rims splitting the union boundary)

| claim | value |
|---|---|
| boundary edges tagged with the **true nearest** surface | **66 / 66** |
| the two surfaces each win edges (real arbitration) | **33 → A, 33 → B** |
| **CONTROL** — a fixed "always the lower id" rule | mis-tags **31** edges (the far rim, >1 u from surface A) |
| **order-free** — A-then-B vs B-then-A stamp order | **0** tag differences |
| **tie-break** — the same surface registered twice | all **42** edges take the **lower id** |

So nearest-surface does **geometric** work a fixed rule cannot (the 31 far-rim edges it tags with B,
the fixed rule gets wrong), it is order-free, and its tie-break is deterministically the lower id
(the strict-`<` in `cut_arb`, exercised by duplicate surfaces — a "higher wins" or non-strict rule
would take all 42). This is the collision-proxy half of the union cut, complementing `X52`.

## A8 · stencil against linework — **DONE** *(the cut spans domains A and B — `X55`)*

Domain **A** is a stencil (authored in a local frame, placed at one of 12 orientations); domain **B**
is world linework (a road, town wall or cliff, drawn where it runs, quantised to `d ∈ D`). They are
*"not interchangeable"* (`ROUNDTRIP` §2.2) — so A8's linework axis asks what happens where they meet.

### The answer: the same cut, with a surface set that spans both domains

A round tower (domain A, an arc) standing on a flat-topped world run (domain B, an E–W line in a
direction `d ∈ D`), cut by one `cut_arb` pass:

| measured | value |
|---|---|
| boundary edges taking the nearest surface | **112 / 112** |
| the run's flat top → the **world line** | **30 / 30** |
| the stencil's rim → its **arc** | **26 / 26** |
| both build orders (run-first vs tower-first) | **0** tag differences |

The domains do not bleed into each other: no flat-top edge is taken by the stencil's arc, and no rim
edge by the world line. **Nothing new was needed** — the cut that handles two adjacent stencils
(`X52`) and two overlapping ones (`X54`) already spans A and B, because "nearest analytic surface"
never asked which domain a surface came from.

### Linework recovers exactly straight — the phase-B verify

Both the NE **and** the NW boundary edge of a top-row cell have midpoint `y = 0.75`. The strip
zigzags in *x*, but its edge midpoints share **one** `y` — so an E–W world line is exactly collinear
on the lattice: **eave_spread = 0**, which is what phase B asks for on a recovered line.

**Control, and it matters here:** the same spread ruler over the *curved* rim reads **6.75**. Without
it, "spread 0" could equally mean the instrument is dead. A fixed "always the stencil's arc" rule
strands **84** edges more than 1 u from their surface — the linework the cross-domain cut gets right.

### What of linework remains

The full domain-B **census** (`rt_census_b`) — closed next, below.

## Domain B · the census — **DONE** *(`rt_census_b`, the period cost table — `X56`)*

`D` is **closed** — all 24 directions are representable (`X3`) — so domain B's open constant was
never representability but **cost**: what does each direction cost in **period** (how far a run must
go before landing back on a hex vertex) and in **angle error**? A census *reports* a table; the
assertions pin its shape.

### The cost table has three classes — and three axes

| class | count | period | angle | `δ` — links? |
|---|---|---|---|---|
| edge | **6** | `√3` wu = 1.5 m | **exact** | 0 — unconditional |
| vertex | **6** | `1` wu = 0.866 m | **exact** | 1 — **conditional** |
| in-between | **12** | `√39` wu = **5.408 m** | **1.1021° off** | 0 — unconditional |

**18 directions link unconditionally, 6 conditionally.**

### The third axis, which the ladder never had

`δ = (tri_a − tri_b) mod 3`. A run of `p` periods from a vertex of class `c` ends on class
`(c + p·δ) mod 3`, and class 0 is a hex **centre**, which `wall_run_ok` refuses. So:

- **`δ = 0`** — the class is *preserved*: every multiple of the period is admissible, from either
  vertex class.
- **`δ ≠ 0`** — the class *cycles*: one run in three lands on a centre and is refused, and the
  shortest legal run depends on which class you started from.

A house wall can leave you on **either** class (the `N=1` family, 30/90/150°, changes it), so `δ` is
exactly whether world linework links to the house angles **unconditionally**. That is a cost the
two-axis ladder could not see.

### Two doc corrections, and a reversed conclusion

**The period column was 3× too small.** §10.9's ladder said `√N/3`, §10.10 said the metre figure. A
clean factor between two numbers is the signature of a counter bug, so the gate measured with the
gated `wall_run_len` rather than picking a side. The period is `√N`.

**The `δ` column did not exist — and that reversed the verdict.** §10.9 called the old `N = 21`
*"dominated outright"*. On the linking axis it was **on the frontier**: only `N = 21`, `39` and `291`
have `δ = 0` in the whole neighbourhood. `N = 7`'s "43% shorter period" is `δ = 1`, so one run in
three is refused and its effective grid is only **13%** finer.

### The vector was switched — to `N = 39`, not `N = 13`

| | angle | period | links |
|---|---|---|---|
| `N = 21` *(old)* | 4.1066° | 3.969 m | unconditional |
| `N = 13` | **1.1021°** | **3.122 m** | conditional — 6.245 m min from half of all house corners |
| **`N = 39`** *(chosen)* | **1.1021°** | 5.408 m | **unconditional** |

Both buy the same **3.7×** accuracy. `N = 13` is also finer, but spends the linking property — and
spends it exactly where two domains meet, the hardest thing to reason about later. `N = 39` pays
2.29 m of period to keep it. Exhaustive over `N ≤ 400`: **nothing improves the angle while keeping
both today's grid and `δ = 0`.** Switched while domain B had **no stored content**, so it cost
nothing; after linework exists it would be unmigratable (`A₂`).

### The gate had no control in the plan; it has three now

`DESIGN.md` §9 listed `rt_census_b`'s control as "—", and a census that only prints a table can never
go red. So: **a conditional direction must exist** and show a class-dependent `min_p`, or
"unconditional" is vacuous; **`N = 13` must genuinely beat `N = 39` on period**, or nothing was
traded and the third axis decided nothing; and **the measured period must not equal `√N/3`**.

## Linework under the 12 orientations — **DONE** *(law **G**, `rt_flip`, finally gated — `X57`)*

Asked directly: *houses cannot hold walls in the extra 12 directions, but a stencil should be able
to — does that survive the flip?* It does, and gating it filled a hole: **`rt_flip` had no gate at
all**. `rt_orient` was green, but only over **houses**, which are drawn by `draw_walls` (the exact
combinatorial boundary of a filled region). World linework goes through **`wall_write`**, a band
around a line, and *nothing* had gated that path under the orientations.

### The geometry survives — including the in-between 12

Edges are keyed by their exact **triangle-lattice corners**, so the whole comparison is integer with
no tolerance: a mismatch is a mismatch.

| check | result |
|---|---|
| the 24 vectors under rotation / reflection / six-rotations-identity | **0 / 0 / 0 of 24** |
| a wall segment **mirrors** exactly, 24 directions × 4 lengths | **96 / 96** (48 in-between) |
| a wall segment **rotates** exactly — `N=3` and `N=39` families | **0 mismatches** |

### The segment mirror rule — and the trap that hides it

A wall is an **undirected segment**, and `wall_write`'s band sits to one side of the centreline *by
traversal direction*. So mirroring **reverses traversal**:

```
mirror(wall(d, A, p))  ==  wall(−d, mirror(farend(d, A, p)), p)
```

The naive `d → 12−d` anchored at the mirrored **start** is wrong — and wrong in a way almost nothing
exposes, because for every direction *except the two the mirror fixes* (90°, 270°) the two rules
agree. There, reversing traversal is the only difference and nothing masks it. That is the gate's
control, and it fires on exactly those two.

### The gate found a real defect — a false comment, and a float sign test

It first reported **18** `N = 1` rotation mismatches. The root cause was a claim in
`wall_separates`'s own comment:

> *"for a wall anchored on a vertex it never fires, because a vertex is never at the same offset as
> a cell centre"*

**False.** `d = 2` from vertex `(3,0)` at `p = 3` puts cell `(1,1)` **exactly on the line**. The
offset is mathematically `0` — but in float it evaluates to `−1.39e-16` in one orientation and a
clean `0` in the rotation of the same wall:

| | offset of the on-line cell | `oc >= 0.0` |
|---|---|---|
| `d=2 p=3` from `(3,0)` | `−1.3877787807814457e-16` | **false** → negative side |
| its 60° rotation, `d=6` from `(0,3)` | `0` | **true** → positive side |

One cell, sorted onto opposite sides in the two orientations — so the rasterisation was not
rotation-covariant. Fixed by comparing against `−WALL_EPS`, which makes a mathematical zero read as
zero in **every** orientation. That is not a tolerance in a fit (`P4`): the quantity is *exactly*
zero and the epsilon only removes rounding noise from a **sign** test.

**The fix sharpened the control rather than breaking it.** The naive mirror rule now fails on the
**whole chiral `N = 1` family** — 6 of 6, and no other family, at every length — where float noise
had been masking four of the six. `N = 1` is the three-axis staircase, so its mirror is the
other-handed staircase and only reversing traversal reproduces it; the symmetric families cannot
tell the two rules apart. The gate keeps the count as a regression guard.

**Houses never came near it** — `draw_walls` is the exact combinatorial boundary, gated 12/12.

### What this does NOT establish

The **geometry** survives; the **model** still forbids it. `ROUNDTRIP` §2.2 says *"`D` is never an
authoring palette… a road is never a stencil"*, the stencil grammar is footprint-only (`stencil /
side len turn`), and `rebuild` recovers the turtle form alone. So a stencil carrying linework needs
`draw`, `rebuild` and `fits?` extended together — a design step, not a build. And **roads were not
tested at all**: `hexway`'s `Track` is a float world-space curve with no lattice anchoring, which
raises questions walls do not.

## A8 · level separation — **DONE** *(the bridge guarantee — `X58`)*

The last A8 axis besides terrain. crawler settled it (`bridgetest.loft`) and stated it as a contrast
this gate reproduces exactly:

> *the SAME two ways, at the same level, are a level crossing; at different levels, a bridge.
> Nothing about the ways changes — only the sheet.*

So the whole fixture is **one pair of overlapping stencils drawn twice, with only the level integer
different**. If the results differ, the sheet is doing the work and nothing else is.

| | shared edges | κ | edges cut |
|---|---|---|---|
| **same level** — the level crossing | **0** (fused, per `X52`) | **2** | 38 (one union) |
| **different levels** — the bridge | **7** (a real wall on each sheet) | **1** at *both* levels | 30 + 30 (two fields) |

### A level is a FILTER BEFORE the cut, not an arbitration rule after it

That is the whole mechanism, and it is why different sheets *never* fuse, arbitrate or contend —
at either level, one of the two simply is not there. It does work `κ` would otherwise have to
(`X4`, §6.1). **A level is not a height:** the sheet is a discrete index; the actual `z` comes from
the surface/feature interval.

**Level 0 is free.** Most of a world exists only there, and the level-aware path is **byte-identical**
to the level-blind `combine_cut` (0 diffs) — the common case pays nothing for a feature it does not
use.

**Control:** flattening the levels restores everything — fusion (`7 → 0`), contention (`κ 1 → 2`),
and the level-crossing field reproduced exactly. Without it, §2's separation could be an artefact of
the fixture rather than of the sheet.

## A8 · terrain — **DONE**, and A8 with it *(`OD-4`'s open half — `X59`)*

`OD-4` came in two halves and only one had been closed. **Storage** was settled — terrain *is* the
foxel's `height` slot, *"the same slot as roofs; the two were always one question"*. What stayed
open was **seating**: a stencil is authored flat, and the ground is not. `SPEC` **G5** already
required the answer to leave a *"residual flagged"*.

### Seating writes the `height` slot — and nothing else

That is the whole construction, and it is why the round trip does not notice terrain: **recovery
reads cells, seating writes heights.** A 15-cell stencil, over flat ground and over a `0.75/q` slope:

| | cells | edges | `rebuild` |
|---|---|---|---|
| flat vs sloped | **0 diffs** | **0 diffs** | identical, **and equal to the authored text** |

### What the slope costs is a residual, and it is returned

A stencil seated at *one* height cannot match ground that varies under it. That gap is real and is
**returned rather than absorbed** (`G5`): `0.000` flat, **`1.650`** on the slope. The seat height is
a **policy**, and it moves the residual while leaving recovery alone — the same split `A6` found
between `Sep` (recoverability) and `X7` (a choice):

| policy | seat `z` | residual | recovers the authored text |
|---|---|---|---|
| low | 4.00 | 3.000 | ✅ |
| **mean** | 5.35 | **1.650** — smallest | ✅ |
| high | 7.00 | 3.000 | ✅ |

**Control:** a seating that **clips** the footprint to the ground (9 of 15 cells dropped) **breaks**
the round trip. Without it, "terrain leaves the cells alone" would be a restatement of the
construction rather than a result.

### The pattern, now visible three times

- a **door** is a *material*, not a hole (`X51`)
- a **level** is a *filter before the cut*, not an arbitration after it (`X58`)
- **terrain** is a *height*, not a change of footprint (`X59`)

> **The round trip survives a new feature exactly when that feature lands in a slot the recovery
> does not read.** Each time the temptation was to change the cells, and each time the control was
> to do so and watch recovery break.

### A note on the fixture, not the subject

The gate first reported **0 cells** — an inline canonical text with a **trailing newline**, which the
parser refuses rather than repairs (`X39`, and the corpus loader trims for the same reason). The
assertion that caught it was written to say so in as many words: *"the fixture is wrong, not the
terrain claim."* Fourth time a first red has been the measurement rather than the subject.

## OD-13 · a stencil carrying an in-between wall — **the load-bearing half only** *(`X60`)*

`OD-13` is a standing requirement, not a question: *"a city/castle needs more directions to be
believable so the other 12 need to be first class."* The geometry was already gated (`X56`, `X57`).
This probes the half everything else rests on, **before** the grammar work.

### The construction, from the pattern

> An embedded wall is a **material on INTERIOR edges** — edges whose two cells are *both* in the
> footprint. The footprint cells are untouched, so form recovery reads a slot the wall never writes.

An interior edge is geometrically distinguishable from a boundary edge with no extra tagging.
Measured on a 127-cell hexagon, for every in-between direction that fits: footprint **127 cells**,
`rebuild` returns the **authored text**, run **wholly interior**, chain **2 ends / 0 branches**
(the gated `X32` measure). **Control:** the same wall drawn as a *gap* (5 cells removed) **breaks**
the round trip — so orthogonality is a result, not a restatement.

### The round trip now carries the run — the silent-drop hole is closed

`Draft` = form + embedded run. `write(rebuild(draw(read(T)))) = T` **byte-for-byte over all 12
in-between directions**, and **dropping the run fails the trip in 12 of 12**. `rebuild` was the one
site the design flagged as silent on omission; it now reads the run, so a missing wall is a text
diff rather than a quiet success. Controls: a wall drawn as a *gap* breaks the trip; a fragmented
marking is refused; a two-`wall`-line record is refused rather than repaired.

**`Draft` is the DESCRIPTION side**; `hex_field::Stencil` is the FIELD side. Those are `OD-6`'s two
halves, they both exist, and they must not share a name.

### The doorstep refuses what would not round-trip

`draft_fits` returns a **named** reason — centre anchor, zero periods, bad direction, an endpoint off
the period grid, or a run leaving the footprint — and `draft_fit_p` **offers the nearest shorter run
that does fit** (`K-FIT`: never a blank no). The contract that matters is law **C₁**: `fits?` must
agree with whether the model actually round-trips. Measured: **0 disagreements, 0 false accepts** —
and a false accept is the dangerous direction, since it lets through exactly what the doorstep exists
to refuse. A refused 9-period run is offered `p = 3`, which itself fits.

**Still open on `OD-13`:** only **one** run per stencil — several need the interior edges split into
connected components first.

### The dangerous site, as it was

`rebuild` still does **not read** that chain. An embedded wall is therefore **silently dropped, and
`rt_trip` does not notice** — precisely the site the design flagged as the one whose omission is
silent. **`OD-13` is not closed.** It is closed when dropping the wall makes `rt_trip` fail.

### The reader — exact, and needing no fit

A run's two chain **ends** *are* its endpoints. `X32` says the marking is one chain; the endpoints
are hex vertices; the doorstep (§10.10) put the authored ones exactly there. So `wall_read_run`
recovers `(d, anchor, p)` by a **degree count and one integer division** — no averaging, no
tolerance, nothing to fit. Gated over the whole pipeline (stencil walls + embedded run → **extract
the interior edges** → read): **6/6 runs recover the same segment exactly**, and a **fragmented**
marking is **refused** rather than averaged into an answer (`P4`).

### ⚠ One root cause behind four separate failures — and a retracted claim

Three reader instruments were wrong, and then the interior extraction broke *after* the reader was
right. All four had **one cause**: mixing **`nb_q`/`nb_r`** (hex_field's neighbour order) with
**`hex_edge_corners`** (hex_grid's). The two enumerate the same six neighbours in a *different
order*, so scanning "directions 0..2" picks a different canonical set and the corner lookup reads a
different edge. **`SPEC` L11's named hazard, and `X26`'s exact failure mode: the counts stay
plausible while the geometry is nonsense.**

It also produced a **false finding that was recorded as fact**: *"only 4 of 12 in-between directions
fit — structural, unexplained."* With one convention throughout, **all 12 fit.** Worse, that claim
had been "confirmed" by widening the anchor search `±14 → ±26` at a cost of 8.5 minutes — and the
widened search shared the broken helper.

> **A slow, expensive confirmation of a bad measurement is still a bad measurement.** When a result
> is surprising, re-derive the *instrument* before spending effort confirming the *number*.

## `G2` · the fitted wall, and the corner miter — **DONE** *(`X61`, `X62`)*

The surface was already exact (`X47`: direction exactly a heading, position an exact rational).
What `G2` needed was its **extent** — so a renderer emits one quad per side instead of one strip
per stored edge — and then, immediately, its **ends**.

### The fit exposed the next defect, which is what a fit is for

`surface_span` projects the run's corners onto the mean line and takes the extremes, so both
endpoints lie **on** the line and the quad's own perpendicular spread is **exactly 0**. On the 5×4
house: **38 stored edges → 4 fitted quads**. Control: the strip being replaced spreads by `X47`'s
band (`0.8660` / `0.5000` wu) — if that were 0 the fit would remove nothing.

Drawing it made the *next* problem visible at once: adjacent quads **did not miter**, so a rotated
house showed corner gaps. That was not a new defect — it is `I-CORNER` parts 2 and 4, the
`SURFACE_LANDED` tripwire `S4` left standing for exactly this moment.

### The tripwire cashed in — and it cost one wrong measurement to do it

Flipping `hexform::SURFACE_LANDED` to `true` made the gate red on the PENDING branch, as designed.
The real checks that replaced it:

| part | what is measured | result | control |
|---|---|---|---|
| 2 · the angle | heading difference between adjacent fitted surfaces | `3` unmirrored, `9` mirrored — **exactly 90°**, 48/48, integer indices, no float | a difference off `3`/`9`, or an inconsistent winding within one handedness, fails |
| 4 · the miter | gap in the mitered outline at each corner | **exactly 0**, 48/48 | the un-mitered spans leave **11.592 wu** |

⚠ **The first version of part 2 failed 24 of 48** — it tested only difference `3`. The mirrored
orientations wind the other way and give `9`. That is the **fourth** consecutive time a red was my
measurement rather than the subject, so the standing rule applied again: a count that disagrees
with an already-gated number by a clean factor (here exactly half) is a bug in the counter. The fix
also added a per-handedness winding check, so accepting `3` **or** `9` did not weaken the test.

### Part 4's own wording was wrong, and the bias is the tell

§10.4 said the miter point *"sits on the exact model corner"*. It does not — measured drift is
`0.4794643204817` at **every** corner, spread `1.33e-15`. **Uniform bias, not scatter**, which is
the signature of a definition difference rather than an error: `Plan` is continuous-then-rasterised,
so the continuous rectangle's corner is **quantised away** (`I-QUANT`, `X50`) before any surface
exists. The field holds only the **cell-region** corner, and the miter recovers *that* one exactly.

`make shot` now draws the miter-to-miter segment (`surface_quad`), with each feature as an interval
on that surface. The rot-0 panels close cleanly; the closure itself is gated over all 12.

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
