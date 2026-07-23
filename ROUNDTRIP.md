# ROUNDTRIP — the settled formal core

**Only what is not in dispute**: definitions, what provably follows from them, and what has been
measured or gated. Peer to [`SPEC.md`](SPEC.md) — `SPEC` says *what must be achieved*, this says
*what the objects are*. On disagreement about an object or a map, this file is authoritative.

**Everything still being designed, built or decided — the grammar, `fits?`, the censuses, the
seam budget, the eight open decisions — is in
[`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md).** Nothing here depends on it.

---

## 1. The lattice

`Λ = ℤ²`, axial coordinates `(q,r)`. Position map `π : Λ → ℝ²`,
`π(q,r) = (κ(q,r)·√3⁄2, μ(q,r)⁄2)` in world units, where `κ, μ` are `hex_field`'s integer
`lattice_k` / `lattice_m`. Triangular-lattice norm on `d = (a,b)`:

```
‖d‖  =  s · √(a² + ab + b²),        s = 1 step = 1.5 m          (SPEC L8)
```

Check: `‖(1,0)‖ = ‖(1,-1)‖ = s`; `‖(1,1)‖ = s√3`; `‖(2,1)‖ = s√7`.

**Rotation and reflection are exact integer maps** — measured, not assumed:

```
60° rotation:   k' = (k − m)/2,   m' = (3k + m)/2          reflection:   k → −k
```

Both integral for every cell, since cell centres satisfy `k ≡ m (mod 2)`. *Verified over 625
cells: zero non-integer images, and six rotations are exactly the identity.* Reflection is
likewise exact, which is where the **12 orientations** come from. So stencils rotate and reflect
with **no resampling and no drift**. *(crawler `EXTRACTION.md` § Stencils.)*

## 2. Objects

| symbol | set | description |
|---|---|---|
| `𝕄` | — | **models** as authored: arbitrary real position, direction, radius |
| `𝕄*` | `⊆ 𝕄` | **fitting** models — those that draw injectively |
| `𝕋` | — | **canonical texts** — the written form |
| `𝔽` | — | **field** states: `⟨HexSet, EdgeSet, Heights, Labels⟩` |
| `𝔽_loc` | `⊆ 𝔽` | a **body's own** field, in its **local** frame |
| `𝔽_wld` | `⊆ 𝔽` | the **world** field — terrain and linework |
| `P` | `ℝ² × S¹ × …` | a **pose**: continuous position and orientation in the world |
| `O` | `⊂ P` | **orientations**: `{0..5} × {id, flip}`, `|O| = 12` — the *lattice-exact* poses |
| `H₁₂` | `≅ ℤ/12` | **headings**: the 12 directions a stencil side may run in, 30° apart |
| `D` | `⊂ Λ/±` | **linework directions**, `|D| = 24` |

### 2.1 `H₁₂` has two classes, with different step lengths

| class | `h` | lattice step | `‖step‖` | strip | measured by `housetest` |
|---|---|---|---|---|---|
| **edge** | even | neighbour vector | `s` | zigzag, 2 axes | `ratio 2⁄√3 = 1.15470` |
| **vertex** | odd | corner vector | `s√3` | staircase, 3 axes | `ratio 3√3⁄4 = 1.29904` |

The 6 rotations act by `h ↦ h + 2`, so the two classes **never mix**; the flip acts by `h ↦ −h`.
`O` acts on stencils, `H₁₂` indexes their sides — `|O| = |H₁₂| = 12` is a coincidence, not an
identification.

### 2.2 Two domains, not interchangeable

| | **A · stencil** | **B · world linework** |
|---|---|---|
| what | house, tower, castle | road, town wall, cliff |
| authored | once, in a **local frame** | **directly in world coordinates** |
| direction from | its own shape; placement picks `o ∈ O` | the run itself, quantised to `d ∈ D` |
| free choice of direction | **none** | none — `d` follows where the run goes |

**`D` is never an authoring palette.** A stencil is placed at one of the 12 `o ∈ O`, never at one
of the 24. A road is never a stencil: it is drawn where it runs.

### 2.3 Bodies carry a pose; they are not stamped at one

A robot's limb in a pose and a derailed wagon at rest are the same problem: an exact original at
an **arbitrary continuous orientation**. A lattice cannot represent a body rotated 37°, and does
not have to:

```
Body  =  ⟨ original ∈ 𝕄*,  pose ∈ P,  joints ⟩          𝔽_loc = draw(original)
```

The body keeps its own field, exact in **its own** frame; the pose places it in the world. The
arbitrary orientation lives in `P`, which is continuous — not in `Λ`, which is not.

| mode | pose | commensurate with `𝔽_wld`? |
|---|---|---|
| **seated** | `o ∈ O` + `v ∈ Λ` | **yes** — cells and edges align |
| **free** | any `p ∈ P` | **no** — the body is its own frame |

`O` is exactly the subset of `P` where the two coincide, which is why the 12 are the *seating*
set. A body transitions seated → free at the break, and back when it settles.

## 2.4 The foxel — the storage schema, and therefore the limit

```
foxel  =  layer*  ×  point → ( height, material, wall1, wall2, wall3, item )
```

**We limit the model to what the foxel can store.** This is the binding constraint on `𝕄*`, and
it replaces every abstract argument about what "fits": a model is admissible **iff it draws into
this schema exactly**.

- **`layer*`** — layers are part of the model, at the top, not an axis added later.
- **`wall1..3`** — the three edges a point *owns*; the other three belong to its neighbours. This
  is the `EdgeSet` shape, and matches the `h_wall_n/ne/se` storage `WALLS.md` cites in moros.
- **`height`** — terrain, floors, roofs: all one scalar per point per layer.
- **`item`** — props, trees, and anything that is an occupant rather than the fabric.

> **`fits?` becomes syntactic and finite.** Not *"is this recoverable in principle"* but *"does
> this land in six slots per point per layer, exactly." * The census (`DESIGN.md` §8) stops being
> a search for an unknown bound and becomes an enumeration against a **known schema**.

**What the schema forecloses**, and it is worth stating plainly because each was an open question:
no sub-cell geometry (so no triangle subdivision), no wall thickness beyond the material carried
on an edge, no second material on the same edge, and no geometry that is not a height, an edge, or
an occupant.

## 3. Maps

```
snap    : 𝕄  → 𝕄* × ℝ≥0      σ ≔ π₁∘snap (projection)   ρ ≔ π₂∘snap (residual, metres)
write   : 𝕄* → 𝕋             read : 𝕋 → 𝕄*
draw    : 𝕄* → 𝔽_loc         rebuild : 𝔽 → 𝕄* × ℝ≥0
place   : 𝕄* × P → world      NOT a rasterization — the pose transforms, it never stamps
```

**`snap` is the only lossy map.**

## 4. The core contract, and what provably follows

```
D:   rebuild(draw(m)) = m        ⟺   draw ∘ rebuild ∘ draw = draw      (on undamaged geometry)
E₂:  rebuild ∘ draw ∘ rebuild = rebuild
```

`draw` and `rebuild` are **mutual pseudo-inverses** — the Moore–Penrose pair. Given D and E₂,
plus `B: σ∘σ = σ`, `C₁: m ∈ 𝕄* ⟺ σ(m) = m`, and `A₁: read∘write = id ∧ write∘read = id`, the
following are **theorems**, not design choices:

| | proposition | from |
|---|---|---|
| **P1** | `𝕄* = im(σ) = im(rebuild)` — the fitting set need not be axiomatised; it *is* the image | B, C₁ |
| **P2** | `draw│𝕄*` is **injective** | D |
| **P3** | `write(rebuild(draw(read(T)))) = T` — **the round-trip gate is a text `diff`** | A₁, D |
| **P4** | with no float in `𝕋`, that equality is **byte equality** — no `ε` exists in the gate | P3 |
| **P5** | `σ│𝕄* = id` — re-snapping an authored model is a no-op; no jitter under repeated edit | B, C₁ |
| **P6** | `write, read` are mutually inverse bijections `𝕄* ≅ 𝕋` | A₁ |

*Proof of P2.* `draw(m₁) = draw(m₂)` ⟹ `m₁ = rebuild(draw(m₁)) = rebuild(draw(m₂)) = m₂`. ∎
*Proof of P3.* `read(T) = m ∈ 𝕄*` (P6); `rebuild(draw(m)) = m` (D); `write(m) = T` (A₁). ∎

> **Consequence.** An `ε` in an **R1** round-trip comparison (§6) is a **defect signal**: by P4 it
> can only mean `𝕄*` was drawn wider than `draw` is injective on.

## 5. Established today

| | status |
|---|---|
| **law I** — `∀m, o ∈ O, v ∈ Λ. draw(τ_v ∘ o · m) = τ_v ∘ o · draw(m)` | **GREEN** — `housetest`, 12/12 equivariant in cells *and* edges, mismatched 0 |
| everything else | [`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) |

## 6. Two recovery regimes

Recovery is exact in one and a fit in the other. Confusing them is the trap.

| regime | input | prior | recovery | residual |
|---|---|---|---|---|
| **R1 · grammar-guided** | a stencil **we authored** | the **grammar** constrains the answer to a finite set | **exact match**, integer | `ρ = 0` |
| **R2 · trace** | arbitrary **cell-authored** content — a hand-drawn footprint, no `𝕋` behind it | **none** | **fit**, with a pinned tolerance | `ρ > 0`, reported |

**P4 governs R1 only.** R2 is reached by damage, by an editor that paints cells, and by any
content authored before a grammar existed. It is prototyped in crawler
`plans/5-geometry/matcher.py`, and it is the harder problem: a traced boundary **zigzags** —
*"no two consecutive edges are collinear (measured); every run wanders around the true line by
roughly the hex corner offset."*

> **The trap:** using R2's machinery where R1 applies — fitting a line to a stencil whose turtle
> description we hold throws away an exact answer and reintroduces a tolerance nothing needs.

## 7. Constraints from `../crawler` — measured, prototyped or gated

Prior art. **Not open**; re-deriving these is waste.

| # | constraint | source |
|---|---|---|
| **X1** | 60° rotation is an exact integer map; six rotations are the identity (verified, 625 cells) | `EXTRACTION.md` |
| **X2** | reflection is exact (`k → −k`) — the source of the 12 orientations | `EXTRACTION.md` |
| **X3** | **all 24 headings are representable** — *"representability was never the question, only cost"*. Width-normalised: edge (6) `1.00×`, vertex (6) between, off-axis (12) `≈3.5×` — *"bounded, not catastrophic"* | `5-geometry/directions.py` |
| **X4** | arbitration is solved and **order-free**: same level → `cut_arb` nearest-wins; different levels → no contest (the bridge guarantee) | `EXTRACTION.md` |
| **X5** | **refusal, not rounding**, is already a gate: *"a stencil rotated by a non-multiple of 60° must be refused, not silently rounded"* | `EXTRACTION.md` |
| **X6** | a traced boundary **zigzags** — no two consecutive edges collinear (measured) | `5-geometry/matcher.py` |
| **X7** | footprints are chosen by best **collision** match, not best **shape** match | `roundness.py`, `collision_fit.py` |
| **X8** | a way is an exact **centreline plus offsets**, never a rasterised band | `5-geometry/ways.py` |
| **X9** | **width-normalise before ranking by heading**, or the table inverts — this reversed a conclusion in crawler before it was caught | `directions.py` METHOD NOTE |
| **X10** | the triangle-subdivision **wall band model is validated in 2D**; corner tests pass | `WALLS.md` |

## 8. Relation to `SPEC.md`

`SPEC` cites this file by law letter and proposition. **Items in `SPEC` marked ⚠ depend on an open
decision and are not settled** — see
[`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) § *Open decisions*.
