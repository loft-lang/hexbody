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

## S1 · law **J**, closure — `src/hexform.loft` · XS

`cycle_closes(h0, lens, turns) → bool`: `Σ turnᵢ = 12` **and** `Σ lenᵢ·e(hᵢ) = (0,0)`, integer
arithmetic only.

- **gate** `tests/form.loft`: the equilateral triangle (`len 1`, `turn 4` ×3) closes; the house outline
  (`len 4,5,4,5`, `turn 3` ×4) closes.
- **control**: drop one turn → non-zero vector sum, and `Σ turn ≠ 12`.

## S3 · turtle → cells — `src/hexform.loft` · S

Walk the cycle and produce the filled region as a `HexSet` (**fill, then take the boundary** —
`SPEC` **I3**, never a buffered band).

- **gate** `tests/form.loft`: the triangle's cell count matches the closed-form prediction; **the house
  outline reproduces `housedraw`'s 27 cells exactly**.
- **control**: a non-closing cycle → refused, not silently patched.
- **the cross-check is the point.** S3 is the first step that can be validated against the
  existing green gate rather than against its own expectation. Take it.

## S4 · turtle → walls — `src/hexform.loft` · S

Boundary edges of the filled region, reusing `housedraw::draw_walls` unchanged.

- **gate** `tests/form.loft`: the house outline gives **38 boundary edges**, matching `tests/house.loft`.
- **control**: buffer a band instead of taking the boundary → 2 components, 0 enclosed (`I3`'s
  own control, now reachable from the new path).

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
