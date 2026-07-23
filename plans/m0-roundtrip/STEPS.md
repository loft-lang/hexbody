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
  - `X28` — `wall_crosses_edge` selects the edges the band **crosses**, i.e. the roughly
    *perpendicular* ones, so a due-east wall evaluates to a **comb of pickets** straying `6×` the
    wall's own half-width. **OD-12, still open** — this is the next thing to fix.
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

## S3 · **`Plan`** → cells — `src/hexform.loft` · S *(OD-11 resolved)*

Walk the cycle and produce the filled region as a `HexSet` (**fill, then take the boundary** —
`SPEC` **I3**, never a buffered band).

- **gate** `tests/form.loft`: the triangle's and rhombus's cell counts match the closed-form
  prediction.
- **control**: a non-closing cycle → refused, not silently patched.
- **the planned cross-check against `housedraw`'s 27 cells does not work as written** (found at
  S1). `housedraw`'s `Plan` is a **continuous rectangle rasterised by centre-in-region**, not a
  turtle polygon, and its two side directions are both in units of `s` — which no pair of the 12
  headings gives, since headings 90° apart are in different length classes. So a turtle cycle
  cannot express that house.
- **OD-11 resolved: rasterise `Plan`, not the turtle.** A lattice polygon *provably* cannot be a
  rectangle (`X24`), so `Plan`'s `(cq, cr, wid, dep, rot, mir)` is domain A's spine. The turtle
  `Form` is retained as the **hexagonal-tower** primitive — a different family, also in the scene.
- **and the cross-check is back**: since S3 now rasterises the same `Plan` `housedraw` does, the
  27-cell / 38-edge comparison against `tests/house.loft` works after all. Take it.
- **what to cross-check instead** *(if the turtle wins)*, in preference order: (a) a **rhombus** drawn both ways — turtle
  fill vs a `Plan` with the matching parallelogram — if `housedraw` can express one; (b) Euler /
  shoelace: the enclosed cell count from an independent closed-form area, which needs no second
  implementation; (c) failing both, accept that S3 has **no external cross-check** and say so,
  rather than inventing agreement between two things that do not model the same shape.

## S4 · turtle → walls — `src/hexform.loft` · S

Boundary edges of the filled region, reusing `housedraw::draw_walls` unchanged.

- **gate** `tests/form.loft`: the house outline gives **38 boundary edges**, matching
  `tests/house.loft`.
- **control**: buffer a band instead of taking the boundary → 2 components, 0 enclosed (`I3`'s
  own control, now reachable from the new path).
- **CORNERS MUST BE PRECISE** — the requirement `tests/house.loft` does not currently check
  anywhere (`DESIGN.md` §10.4). Four parts: (1) the boundary is **one closed loop**, no gap at a
  corner; (2) the corner **angle is exact** — 90° for a `Plan`; (3) the corner cell is claimed
  **exactly once**, neither doubled nor dropped; (4) the **miter point** of the two fitted
  surfaces sits on the exact corner. Parts 1 and 3 are checkable here on the strip; parts 2 and 4
  need the fitted surface, so **write them into the gate red at S4** and let S8 turn them green —
  the same discipline as `rt_trip`.

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
