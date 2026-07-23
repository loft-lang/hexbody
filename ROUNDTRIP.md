# ROUNDTRIP — the settled formal core

**Only what is not in dispute**: definitions, what provably follows from them, and what has been
measured or gated. Peer to [`SPEC.md`](SPEC.md) — `SPEC` says *what must be achieved*, this says
*what the objects are*. On disagreement about an object or a map, this file is authoritative.

**Everything still being designed, built or decided — the grammar, `fits?`, the censuses, the
seam budget, the open decisions — is in
[`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md).** Nothing here depends on it.

---

## 1. The lattice

`Λ = ℤ²`, **pointy-top, odd-r offset** coordinates `(q,r)` — *not axial*. Position map
`π : Λ → ℝ²`, `π(q,r) = (κ(q,r)·√3⁄2, μ(q,r)⁄2)` in world units, where `κ, μ` are `hex_field`'s
integer `lattice_k` / `lattice_m`:

```
κ(q,r) = 2q + (r & 1)          μ(q,r) = 3r
```

The `(r & 1)` is what makes it **offset** rather than axial (axial would give `κ = 2q + r`), and
it matches moros's convention — crawler migrated to it deliberately (`tools/wallproto/hexoffset.py`:
*"migrate crawler's hex geometry from AXIAL to moros's POINTY-TOP, ODD-R OFFSET"*). `nb_q`/`nb_r`
branch on `r & 1` for the same reason. Triangular-lattice norm on `d = (a,b)`:

```
‖d‖  =  s · √(a² + ab + b²),        s = 1 step = 1.5 m          (SPEC L8)
```

Check: `‖(1,0)‖ = ‖(1,-1)‖ = s`; `‖(1,1)‖ = s√3`; `‖(2,1)‖ = s√7`.

**Rotation and reflection are claimed to be exact integer maps.** *Tier **T2** (§7) — crawler
states it verified this over 625 cells, but that is a design try, not a gate here. It is the
single most load-bearing inherited claim in this file, and **re-measuring it is rung A1's first
by-product**.*

```
60° rotation:   k' = (k − m)/2,   m' = (3k + m)/2          reflection:   k → −k
```

Both are integral for every cell if cell centres satisfy `k ≡ m (mod 2)`. crawler reports *"zero
non-integer images, and six rotations are exactly the identity"* over 625 cells, and that
reflection is likewise exact — which is where the **12 orientations** come from, and why stencils
would rotate and reflect with **no resampling and no drift**. *(crawler `EXTRACTION.md` §
Stencils; `X1`, `X2`.)*

## 2. Objects

| symbol | set | description |
|---|---|---|
| `𝕄` | — | **models** as authored: arbitrary real position, direction, radius |
| `𝕄*` | `⊆ 𝕄` | **fitting** models — those that draw injectively |
| `𝕋` | — | **canonical texts** — the written form |
| `𝔽` | — | **field** states — the **foxel** (§2.4): `layer* × point → (height, material, wall1..3, item)`. *`hex_field`'s `HexSet`/`EdgeSet`/`Heights`/`Labels` are one **encoding** of it, not a second model — moros: "ONE model … with the cell as a storage concern over the field"* |
| `𝔽_loc` | `⊆ 𝔽` | a **body's own** field, in its **local** frame |
| `𝔽_wld` | `⊆ 𝔽` | the **world** field — terrain and linework |
| `P` | `ℝ² × S¹ × …` | a **pose**: continuous position and orientation in the world |
| `O` | `⊂ P` | **orientations**: `{0..5} × {id, flip}`, `|O| = 12` — the *lattice-exact* poses |
| `H₁₂` | `≅ ℤ/12` | **headings**: the 12 directions a stencil side may run in, 30° apart |
| `D` | `⊂ Λ/±` | **linework directions**, `|D| = 24` |

### 2.1 `H₁₂` has two classes, with different step lengths

| class | `h` | lattice step | `‖step‖` | strip | measured by `tests/house.loft` |
|---|---|---|---|---|---|
| **edge** | even | neighbour vector | `s` | zigzag, 2 axes | `ratio 2⁄√3 = 1.15470` |
| **vertex** | odd | corner vector | `s√3` | staircase, 3 axes | `ratio 3√3⁄4 = 1.29904` |

The 6 rotations act by `h ↦ h + 2`, so the two classes **never mix**. A reflection acts by
`h ↦ 6 − h` when it is `k → −k`, or `h ↦ −h` when it is `m → −m` — both are lattice reflections,
differing by a 180° rotation. `tests/form.loft` gates the first, since `X2` states `k → −k`.
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

**This is not a proposal — it exists**, in `../moros/lib/moros_map/src/types.loft`:

```loft
pub struct Hex {                      pub struct HexAddress {      pub struct Chunk {
  h_height:        integer,             ha_q:  integer,              ck_cx: integer,
  h_material:      integer,             ha_r:  integer,              ck_cy: integer,   // the LAYER
  h_item:          integer,             ha_cy: integer,  // LAYER    ck_cz: integer,
  h_item_rotation: integer,           }                              ck_hexes: vector<Hex>,  // 32×32
  h_wall_n:        integer,                                        }
  h_wall_ne:       integer,
  h_wall_se:       integer,
}
```

| the schema | in moros |
|---|---|
| `layer*` | **`cy`** — the vertical index, on `HexAddress` and every `map_*` call |
| `wall1..3` | `h_wall_n` / `h_wall_ne` / `h_wall_se` — the three **owned** edges; `map_set_wall_dir` maps the other three onto the neighbour that owns them |
| `material` | `h_material` → `MaterialDef`, whose `md_category` includes `terrain`, `floor`, **`roof`**, `stair`, `water`, `void` |
| `item` | `h_item` → `ItemDef`, whose `id_kind` includes `PILLAR`, **`TREE`**, `FURNITURE`, `CONTAINER` |
| — | `h_item_rotation` packs a **5-bit rotation, 0–23** — items place at **24** rotations |

**The wall shape vocabulary already exists** as `WallDef.wd_body`:
`SOLID · HALF_HEIGHT · FENCE · BATTLEMENT · THICK_FLAT · THICK_CURVED · ROAD_GUIDE` — so
`THICK_CURVED` *is* the rounded slot, and an **octagon body is a new value in this enumeration**,
exactly the extension shape (`DESIGN.md` §4.1). `WallDef` also carries **`wd_thickness: float`**:
thickness lives in the **palette**, not the cell — a cell stores a wall *id*, and the definition
behind it carries body and thickness.

**We limit the model to what the foxel can store.** This is the binding constraint on `𝕄*`, and
it replaces every abstract argument about what "fits": a model is admissible **iff it draws into
this schema exactly**.

- **`layer*`** — layers are part of the model, at the top, not an axis added later.
- **`wall1..3`** — the three edges a point *owns*; the other three belong to its neighbours. This
  is the `EdgeSet` shape, and matches the `h_wall_n/ne/se` storage `WALLS.md` cites in moros.
  A slot carries a **material** and a **shape** — `straight`, `rounded` (an arc: a round tower, a
  curved wall), `octagon` (a chamfer: octagonal towers, bay windows), and more as they are needed.
  This is how curved and chamfered forms are stored **without any sub-cell geometry**, and the
  shape vocabulary is the model's designed **extension point** (`DESIGN.md` §4.1).
- **`height`** — terrain, floors, roofs: all one scalar per point per layer.
- **`item`** — props, trees, and anything that is an occupant rather than the fabric.

### 2.4.0 Four things are called "layer" — they are not the same thing

| sense | what it is | where | in the foxel? |
|---|---|---|---|
| **storey** | the **vertical** axis — ground, upper, rampart | moros `ha_cy` / `ck_cy` | **yes — this is `layer*`** |
| **attribute plane** | a named scalar per cell (`ly_names`/`ly_vals`) | `hex_field::Layers` | no — a parallel structure |
| **wall stack** | an *evaluation* order, each overriding a subset below: storage → surface → material → feature → dressing | `design/FEATURES.md` §4 | no — a rule, not storage |
| **set dressing** | sub-hex props kitbashed onto surfaces | crawler `PROPS.md`, `plans/10-props/` | **no — see below** |

Only the **storey** sense is the foxel's `layer*`. `𝕄*` is bounded by that one; the others are
adjacent mechanisms that must not be conflated with it.

### 2.4.0.1 Set dressing is a separate layer, and it is outside `𝕄*`

Props — drainpipes, streetlamps, chimneys, inset panes, fence posts — are **not fabric**. crawler
settled the discriminator against the scale contract: **below the resolution floor a thing is an
OBJECT, not a field**, and *"almost everything on the list is below one hex step"* (1 step =
1.5 m). They are parented to a surface and **read by render only** — and in crawler they are not authored at all but **derived from the architecture plus a seed** (`X23`): *"a village furnishes itself"*
(`FEATURES.md` §4, the *dressing* row).

The foxel cannot hold them anyway: `h_item` is **one item per hex**, so a wall carrying a
drainpipe *and* a lamp *and* a chimney is not expressible in it.

| scale | example | home |
|---|---|---|
| **≥ 1 hex step** | tree, wagon, trough, double door | **`h_item`** — in the foxel, `ItemDef` |
| **< 1 hex step** | drainpipe, lamp, chimney, pane | **set dressing** — outside `𝕄*`, render-only |

So it does **not** round-trip, is **not** collision truth, and is **not** bounded by `fits?`.
This is VISION's kitbashing route, and it likely lives in crawler rather than here — but the
boundary matters in both directions: hexbody must not absorb it, and must not be asked to
recover it.

### 2.4.1 A door is a material, not an annotation beside one

**Doors and windows are materials on the wall slot.** The edge is never removed — it carries a
*door* material instead of a *wall* material. So the anti-deletion rule survives intact (a run is
never fragmented, and the doored-tower defect cannot arise), but its mechanism changes: it is not
an annotation *beside* the material, it **is** the material.

| | consequence |
|---|---|
| **won** | features are **directly readable** from storage — an edge with a door material *is* a door — so feature recovery is exact (R1), not inferred |
| **lost** | a doored edge cannot also carry its wall's own material in the same slot |
| **therefore** | composition moves into the **material vocabulary**: "door in a stone wall" is a material, not two values on one edge |
| **the cost** | the material table grows with (wall kinds × feature kinds) rather than adding a channel. That is the trade the single slot buys |

> **`fits?` becomes syntactic and finite.** Not *"is this recoverable in principle"* but *"does
> this land in six slots per point per layer, exactly." * The census (`DESIGN.md` §8) stops being
> a search for an unknown bound and becomes an enumeration against a **known schema**.

**What the schema forecloses**, stated plainly because each was an open question: no sub-cell
geometry (so no triangle subdivision), no second wall on the same edge, and no geometry that is
not a height, an edge, or an occupant. **Thickness is *not* foreclosed** — it comes from the
`WallDef` behind the id, not from the cell.

### 2.4.2 Two layers, split by consumer — and the editor gets only one

| | **layer 1 — stored** | **layer 2 — derived** |
|---|---|---|
| what | the **foxel**: compact, uniform, everywhere | collision structures, **meshes**, water flow, air flow, sound |
| who | the editor **writes** this, and *only* this | the game runs on it; the editor **reads** it to render |
| authored? | yes | **never** — derived from layer 1 on demand |
| persisted? | yes | **never** |

> **The editor WRITES only layer 1; it READS layer 2 to render.** The rule is about authoring and
> storage, not display. One compact form, written everywhere, so working on distant parts of the
> world needs no swap between representations and no conversion step — a *constraint on layer 1*:
> the stored form must be good enough to edit directly.

**It is an *in-world* editor — the game is running all the time.** You edit inside the live world,
so layer 2 already exists and the editor simply sees through it. Two consequences follow, and the
second is a hard requirement:

- **Editing and destruction are the same operation** — mutate layer 1, re-derive layer 2, check
  the invariants survive. `ARCHITECTURE` says this already (*"collision, destruction, editor — the
  same operation"*); the in-world editor is what makes it literal rather than an analogy.
- **Layer 2 derivation must be LOCAL and INCREMENTAL.** With the game never stopping, an edit
  cannot re-derive collision, meshes, flow and sound globally — a single cell change must dirty a
  **bounded region** and nothing more. `I7` states this for the proxy; the in-world editor extends
  it to all of layer 2, and turns it from a correctness rule into a **latency** one.

### 2.4.3 The dirty unit is the chunk — and it already exists

**32×32 chunks are not net-new.** The world is already held in memory as chunks, layer 2 is
derived per chunk, and rendering draws everything in a chunk at once as separate meshes — which
is what makes moving through the world affordable.

| piece | where |
|---|---|
| the chunk grid + addressing — `chunk_idx_32(v) = floor(v/32)`, `hex_idx_32(v) = v mod 32`, **sparse storage + GC of empty chunks** | `loft-libs-world/hex_world.loft` |
| 32×32 chunks with **height + multi-layer** — `Layer{x, y (mult of 32), layer, tiles}` | moros `wall.loft` |
| the chunked **batched-mesh pipeline** — `SegMesh`, `seg_mesh_append`, **one VBO per render-group** | `gridmesh` (loft-libs-graphics) |
| the runtime chunk itself — `Chunk{ck_cx, ck_cy, ck_cz, ck_hexes}`, 32×32 | moros `moros_map/types.loft` |

So the "bounded region" of §2.4.2 is not a mechanism to invent: **an edit dirties the chunks it
touches, and their layer-2 meshes rebuild.** What still needs care is an edit on a **chunk
boundary**, which dirties the neighbour too — a wall slot is owned by one cell but bounds two.

> **Chunk seams are EXACTLY ZERO — they are not a jank site.** crawler gates this already as its
> own **`I-SEAM`**: *"integer-metre bases ⇒ globally-aligned grid ⇒ **watertight**"*, `d = 0`, green
> in its `make test`. Achieved by **construction** (aligned addressing), not by tolerance.
>
> **Name collision, worth keeping straight.** crawler's **`I-SEAM`** is the **chunk** seam and is
> exact. This project's seam law — renamed here to **`I-FSEAM`**, law **K₁** — is the **frame** seam: a posed
> body against the world — and is the *only* place `ε > 0` is permitted. Reading one for the other
> would license cracks between chunks, which is already forbidden and gated.

**Layer 2 is `SPEC` L3's rule, generalised.** L3 wrote it for the patch-atlas; the same rule
covers the whole layer — *derived on demand, never persisted, never a branch in a hot-path op*.
So the patch-atlas is one member of layer 2, not a special case, and **`K-PROXY`'s collision
proxy is layer 2 as well**.

**Consequence for `𝕋`.** The canonical text is **not** a second editor representation, and must
not become one — that is exactly the second layer the editor is not allowed to have. Its role is
narrower: an authored **stencil** may carry a description, but once placed the world is foxel. So
`rebuild` is genuinely load-bearing rather than a validation nicety — it is how a description is
recovered *from* the world, for editing, for re-canonicalising after damage, and for extraction.

**Consequence for `draw`.** Its target is **layer 1, the foxel**. The census and `rt_trip` measure
against that, not against a runtime structure.

### 2.5 Scope — what this model does not cover

**In scope:** a body's **original** (`𝕄*`/`𝕋`), its **pose** `P` as a stored representation (§2.3),
world terrain and linework, and the maps between them.

| out of scope | why | owner |
|---|---|---|
| how a pose **evolves** — integration, contacts, settling | this model defines the *representation* of orientation, never its dynamics | `DYNAMICS`, `L1`/`L2` |
| **mechanism** — the part-tree, joints, couplings, anchors | a **graph**, not a field: sparse and of **variable arity**, so the foxel cannot hold it and no fit can recover it (a cone is five parameters; a part-graph has no parameter vector). Authored or derived, never recovered. `Body = ⟨original, pose, joints⟩` — only `original` round-trips | `K-JOINT`, crawler `hexpart`/`hexskel` |
| the **collision proxy** | derived, never stored. *But:* with an exact `𝕄*` the proxy is better derived from the **model** than from the rasterization — analytic, with a closed-form error bound instead of a measured one. That refines `ARCHITECTURE`'s *"derived from the field"*, and is a consequence of this contract rather than a contradiction of it | `K-PROXY` |
| **authored motion tracks** | the consumer's, by construction | `L5` |
| **set dressing** — sub-hex props | objects below the resolution floor, parented to a surface, render-only (§2.4.0.1). Does not round-trip, is not collision truth, is not bounded by `fits?` | crawler `PROPS.md` |
| the **patch-atlas** overlay | derived on demand, never persisted — therefore never in `𝕋` | `L3` |

## 3. Maps

```
snap    : 𝕄  → 𝕄* × ℝ≥0      σ ≔ π₁∘snap (projection)   ρ ≔ π₂∘snap (residual, metres)
write   : 𝕄* → 𝕋             read : 𝕋 → 𝕄*
draw    : 𝕄* → 𝔽             rebuild : 𝔽 → 𝕄* × ℝ≥0
                              domain A lands in 𝔽_loc, domain B in 𝔽_wld; both are LAYER 1
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

## 5. Established today — the whole of it

**T1 is short.** Everything below the line is a proposal (`DESIGN.md`) or inherited at T2–T4 (§7).

| | status |
|---|---|
| **law I** — `∀m, o ∈ O, v ∈ Λ. draw(τ_v ∘ o · m) = τ_v ∘ o · draw(m)` | **GREEN** — `tests/house.loft`, 12/12 equivariant in cells *and* edges, mismatched 0 |
| **`X1`** the 60° rotation is exact and acts as `h ↦ h+2`; **`X2`** the reflection is exact, `h ↦ 6−h` | **GREEN** — `tests/form.loft` (S0): 625 cells, 0 non-integral images, 0 six-rotations-not-identity |
| **`X20`** the heading table is **parity-free** in doubled `(k,m)` | **GREEN** — `tests/form.loft`, against `hex_field`'s own `nb_q`/`nb_r` |
| the two `H₁₂` step-length classes (§2.1) — `2⁄√3`, `3√3⁄4` | **GREEN** — measured by `tests/house.loft` gate 7 |
| the eave is level on the fitted line (`SPEC` **I8**) | **GREEN** — `tests/house.loft` gate 4, `spread 0.0000`, control fires |
| chunk seams are `d = 0` (`X19`) | **GREEN**, but in *crawler's* gate, not ours |
| **everything else** | proposed, or inherited below T1 |

**The propositions of §4 are theorems, not gates** — they hold *given* D, E₂, A₁, B, C₁, all of
which are still proposals. They tell you what to check; they are not themselves checked.

## 6. Two recovery regimes

Recovery is exact in one and a fit in the other. Confusing them is the trap.

| regime | input | prior | recovery | residual |
|---|---|---|---|---|
| **R1 · grammar-guided** | a stencil **we authored** | the **grammar** constrains the answer to a finite set | **exact match**, integer | `ρ = 0` |
| **R2 · trace** | arbitrary **cell-authored** content — a hand-drawn footprint, no `𝕋` behind it | **none** | **fit**, with a pinned tolerance | `ρ > 0`, reported |

**P4 governs R1 only.** R2 is reached by damage, by an editor that paints cells, and by any
content authored before a grammar existed. It is the harder problem — a traced boundary
**zigzags** — and it **already exists in loft, gated**: crawler's `hexmatch` (`X21`), with
`roofmatch` doing the same for height fields (`X22`).

> **R2's tolerance is a lattice constant, not a knob.** `hexmatch`: *"THE TOLERANCE IS NOT
> TUNED. A boundary vertex is a hex CORNER, so it can sit at most one circumradius — exactly
> 1.0 world unit — from the true surface it came from … large enough to absorb the zigzag
> (worst measured residual on a straight wall is 0.81), small enough that a real corner never
> fits inside it."* So even in R2 there is nothing to calibrate: the tolerance is derived from
> the lattice and carries a measured margin, `0.81 < 1.0`.

> **The trap:** using R2's machinery where R1 applies — fitting a line to a stencil whose
> description we hold throws away an exact answer and reintroduces a tolerance nothing needs.

### 6.1 A wall surface is the exact AVERAGE of its edges — not a fit

The straight/arc surface a wall run approximates is **derived by averaging the edges that are
already there**, never fitted to them:

| | |
|---|---|
| **direction** | `Σ` edge vectors — an **exact integer** vector in doubled coordinates |
| **position** | the mean of the edge **midpoints**. A cell corner is an integer in `(k,m)`, so a midpoint is a half-integer and the mean is an **exact rational** |
| **band** | the exact perpendicular extent of the strip about that mean — **not an error term**: it is the geometry of the triangle strip, and it is an exact algebraic constant per family (§6.2) |

**Nothing is fitted, so nothing has a tolerance.** This is what makes domain-A straight-wall
recovery **R1**: least-squares would introduce a residual to threshold, while an average of exact
rationals *is* the answer. It also respects §2.4's invariant by construction — the mean line of a
set of hex edges lies **between** cell centres, never through one.

`hexmatch`'s derived tolerance (`X21`) remains right for **R2**, where there is no grammar and no
edge run to average — only a traced boundary of unknown provenance.

### 6.2 The band constants, and the widening rule — exact, in `ℚ(√3)`

**There is no approximation anywhere in this model.** The band is not wobble to be tolerated; it
is the exact extent of the triangle strip, and both constants are exact algebraic numbers. Work
in **world units** (`1 u` = one hex edge = the circumradius; `1 hex step = √3 u = 1.5 m`):

| family | mean direction | band `(u)` | band `(m)` |
|---|---|---|---|
| **tops** — 1 axis, run/wall `= 2/√3` | due east, `dm = 0`, so the deviation **is** `m/2` | **`1/2`** | `√3/4` ≈ 0.4330 |
| **sides** — 2 axes | due north, `dk = 0`, so the deviation **is** `k·√3/2` | **`√3/2`** | **`3/4`** = 0.7500 |
| ratio | | **`√3`** exactly | |

Each band is *one doubled-coordinate unit* of span, measured on the axis the mean direction makes
perpendicular — which is why one is rational in `u` and the other rational in metres.

**The widening rule.** Both walls are presented straight and **equally thick**, at the larger
band `W = √3/2 u`. Only the tops widen:

```
  total    W − 1/2  =  (√3 − 1)/2  u  =  (3 − √3)/4  m  ≈ 0.3170 m
  per face            (√3 − 1)/4  u  =  (3 − √3)/8  m  ≈ 0.1585 m
```

**This is the only adjustment in the model, and it is an exact rule** — a closed-form constant in
`ℚ(√3)`, applied symmetrically, with nothing measured, fitted or tuned. So `P4` holds through the
presentation layer as well: there is no `ε` anywhere between `𝕋` and the rendered wall.

## 7. Prior art from the siblings — and how far each is trustworthy

Tiered by **evidence kind, not by repo**. The distinction that matters: a **design try** — a
prototype or a design doc — is *input*, not authority. Its numbers are indicative and **must be
re-measured here** before anything load-bearing rests on them.

| tier | what it is | how to use it |
|---|---|---|
| **T1 · gated** | a green gate **with a control that must fire**, running in a repo's `make test` | **authoritative** |
| **T2 · measured by a try** | a prototype produced a number | indicative — **re-measure here** before it carries weight |
| **T3 · designed** | a doc argues a construction | **input to design, never truth** |
| **T4 · schema** | a shape read from **untested** code (`../moros`) | the *shape* is real; the *behaviour* is unverified — cherry-pick, then gate here |

**hexbody is the strictest of the three**, and that is the whole point: adopting a sibling's
result without re-gating it forfeits exactly what this project is for.

| # | constraint | tier | source |
|---|---|---|---|
| **X1** | 60° rotation is an exact integer map, `k' = (k−m)/2`, `m' = (3k+m)/2`; six rotations are the identity; acts on `H₁₂` as `h ↦ h+2` | **T1** ✅ | **`tests/form.loft`** — 625 cells, 0 non-integral, 0 non-identity |
| **X2** | reflection is exact (`k → −k`), acting on `H₁₂` as `h ↦ 6 − h` | **T1** ✅ | **`tests/form.loft`** — 12/12 |
| **X20** | the heading table is **parity-free in doubled `(k,m)`** — the 6 neighbour deltas are identical on both row parities, so nothing below needs to branch on `r & 1` | **T1** ✅ | **`tests/form.loft`** — vs `hex_field`'s `nb_q`/`nb_r` |
| **X3** | **all 24 headings representable** — *"representability was never the question, only cost"*; width-normalised edge `1.00×`, off-axis `≈3.5×` | **T2** | `5-geometry/directions.py` |
| **X4** | arbitration nearest-wins and **order-free**; different levels never contest | **T3** | crawler `EXTRACTION.md` |
| **X5** | **refusal, not rounding** — *"a stencil rotated by a non-multiple of 60° must be refused"* | **T3** | crawler `EXTRACTION.md` |
| **X6** | a traced boundary **zigzags** — no two consecutive edges collinear | **T2** | `5-geometry/matcher.py` |
| **X7** | footprints chosen by best **collision** match, not best **shape** match | **T3** | `roundness.py`, `collision_fit.py` |
| **X8** | a way is an exact **centreline plus offsets**, never a rasterised band | **T3** | `5-geometry/ways.py` |
| **X9** | **width-normalise before ranking by heading**, or the table inverts — a conclusion actually reversed in crawler | **T2** | `directions.py` METHOD NOTE |
| **X10** | the triangle-subdivision wall band, *"validated in 2D, corner tests pass"* | **T2** | `WALLS.md`, `tools/wallproto/` |
| **X16** | **a graph is not a field and cannot be fitted like one** — a cone is five parameters; a skeleton has a variable node count | **T3** | crawler `hexskel` |
| **X17** | the part representation: *"two levels, no more: an anchor, and parts in the anchor's frame"* + the granularity rule | **T3** | crawler `hexpart` |
| **X11** | the foxel **exists**: `Hex`/`HexAddress`/`Chunk`; layers are `cy`; walls are the three owned edges | **T4** | moros `moros_map/types.loft` |
| **X12** | wall shape vocabulary `WallDef.wd_body`; **thickness in the palette** (`wd_thickness`) | **T4** | moros `palette.loft` |
| **X13** | **trees are items**, **roofs are materials** | **T4** | moros `palette.loft` |
| **X14** | items carry a **5-bit rotation, 0–23** | **T4** | moros `types.loft` |
| **X15** | the Map↔`hex_field` round trip is **lossy**, and its test is **green for the wrong reason** | **T4**, but trustworthy **as a warning** — it is moros's own written admission | moros `moros_map.loft` |
| **X18** | 32×32 chunks are **not net-new** — grid, addressing, sparse storage + GC; the batched-mesh pipeline (`gridmesh`, one VBO per render-group) | **T2/T4** | `hex_world.loft`, `gridmesh`, moros `wall.loft` |
| **X19** | **chunk seams are exactly `d = 0`** — *"integer-metre bases ⇒ globally-aligned grid ⇒ watertight"*, green in crawler's `make test` | **T1** | crawler `chunktest` |
| **X24** | **there is no square sublattice of a hexagonal lattice** — the perpendicular of `(k,m)` is `(−m,3k)`, whose squared length is **exactly 3×**, so two perpendicular lattice directions can never be counted in the same unit (`√3` is irrational). A lattice polygon therefore **cannot be a rectangle** | **T1** ✅ | **`tests/form.loft`** §9 — 840 vectors, 0 violations |
| **X25** | **isotropy** — walls in the two directions must be *approximately* equal, and are: `Plan`'s wall lengths are exactly proportional, and the only anisotropy is the **strip overhead**, `(3√3/4) ÷ (2/√3) = 9/8` **exactly** — 12.5% apart. Perpendicular lattice steps would be `√3`, 73.2% apart, which fails the criterion | **T1** ✅ | **`tests/form.loft`** §10 |
| **X21** | **R2 recovery exists in loft and is GATED** — `hexmatch`, traced boundary → straights + arcs, `MATCH OK` in crawler's test table. Its tolerance is **derived** (one circumradius = 1.0 world unit), not tuned, with margin 0.81 | **T1** | crawler `hexmatch` + `matchtest` |
| **X22** | **roof recovery exists and is GATED** — `roofmatch`, *"recover the cone; planar roofs just interpolate"*, `ROOFMATCH OK` | **T1** | crawler `roofmatchtest` |
| **X23** | **props are DERIVED from the architecture plus a seed, not authored** — *"a village FURNISHES ITSELF: every wall opening gets a door, and nothing about that is authored data"* | **T3** | crawler `hexderive`, `land.loft` |
| **X26** | **the wall→mesh evaluator is not ours to write** — `hex_grid::hex_edge_corners` / `hex_canon_edge` own the edge table (*"walls live on hex edges, stored on 3 canonical edges per hex; dirs 3,4,5 belong to the neighbour"*), and `moros_render::emit_hex_walls` evaluates the three slots to quads (`n` = corners 5→0, `ne` = 0→1, `se` = 1→2). `hex_grid`'s world scale and `hex_field`'s exact lattice **agree term for term**, so it is reuse, not a port | **T1** ✅ | **`tests/wall.loft`** §2b — every edge midpoint halfway between the cells it separates, control fires |
| **X27** | **the marks evaluate back to the SAWTOOTH, not the line** — the stored field reproduces a chain of hex edges; the straight line is `rebuild`'s job. crawler's `wallgeo` undoes it **approximately** (`SMOOTH_ITERS 3`, `λ 0.5`, `SNAP_TOL2`), which `P4` forbids us — it is the baseline to diff against, not the mechanism to adopt | **T1** ✅ | **`tests/wall.loft`** §6 — stray measured for all 24 directions |
| **X28** | **a hex has edges on three lines only — 30°, 90°, 150°** — so a wall in any other heading *cannot* be a straight run of hex edges; it is an alternating **wobble**. A rule that selects the edges a band **crosses** selects the ones **perpendicular** to it (a comb of pickets); the rule that selects the edges **separating** the wall's two sides selects the ones **along** it (a connected chain). The first was the defect, the second the fix | **T1** ✅ | **`tests/wall.loft`** §6 + `plans/m0-roundtrip/probes/edge_family.loft` |
| **X32** | **a wall is the boundary between two half-planes** — the hex edges lying along a straight line are exactly those that **separate a cell on one side from a cell on the other** (`wall_separates`), which is `housedraw::draw_walls`' inside/outside rule applied to a half-plane. This is always **one connected chain** (two degree-1 ends, no branch), threshold-free because edges key by their shared vertices as **exact triangle-lattice integers**. It resolves OD-12 | **T1** ✅ | **`tests/wall.loft`** §6 — every wall one chain; controls: a picket comb reads 18 ends, breaking an interior edge splits 2→4 |
| **X33** | **the lattice holds a triangle, a rhombus and a hexagon EXACTLY** — a lattice polygon cannot be a rectangle (`X24`), but a closed turtle cycle fills to a combinatorial closed form: triangle side `n` → `(n+1)(n+2)/2`, rhombus `a×b` → `(a+1)(b+1)`, hexagon side `n` → `3n²+3n+1`. This is the family `Plan` **cannot** express, which is why both primitives are kept | **T1** ✅ | **`tests/form.loft`** §12 — ten shapes, all exact; control: a non-closing cycle is refused, not filled |
| **X34** | **`shoelace(boundary) = 12 × cells` is an IDENTITY, not a cross-check** — true by Green's theorem for *any* cell set, holes included (a hole is a negatively-wound loop and subtracts its own area, so a punched hexagon still balances at 18 cells / 216). It therefore **cannot** validate a fill; it validates the boundary CONVENTION — corner table × edge table × neighbour table — which is the `X26` class. crawler's `hexforms.py` states it as the round-trip invariant (T2); re-measured here, with the honest reading of what it proves | **T1** ✅ | **`tests/form.loft`** §12b — control: pairing corner `i` with `i+2` collapses it, 294 vs 216 |
| **X35** | **a hex region's boundary is ONE CLOSED LOOP and never pinches** — `ends = 0`, `branches = 0`, `loops = 1` over seven turtle shapes in both heading classes. The no-pinch half re-measures crawler's property (a hex vertex touches exactly three mutually adjacent cells, so unlike a square grid a boundary cannot pinch — asserted there over 412 forms, T2). A **hole shows as a second loop**, which is `I3`'s named failure made detectable | **T1** ✅ | **`tests/form.loft`** §14 — control: punch a strictly interior cell → 2 loops |
| **X36** | **the side runs PARTITION the boundary — a corner edge is claimed exactly once** — `housedraw::side_edges` assigns every boundary edge to one side, and the four runs sum to the boundary exactly: `5×4 → 38 = 9+10+9+10`, `4×4 → 38 = 11+8+11+8`, `6×4 → 46 = 11+12+11+12`. Never checked before; it is corner part 3 (`DESIGN.md` §10.4) | **T1** ✅ | **`tests/form.loft`** §16 — control: three of four sides cover only 28 of 38 |
| **X37** | **an edge wall costs no floor; a band wall eats the house** — the boundary-as-edges rule keeps every cell (hexagon n=2: 19 of 19), while a buffered band of cells keeps 7 of 19, and on a small shape **0 of 6** — a house with no room. This is why `I3` says boundary, never buffer | **T1** ✅ | **`tests/form.loft`** §15 |
| **X38** | **law F holds at level 1, and every collision is one cycle RE-SPELLED** — the exhaustive level-1 enumeration (660 proposed, **30 admitted** by law J) draws **3 distinct shapes** with **183 colliding pairs, none unexplained**. A closed cycle has no distinguished first corner, so `[2,5,5]`, `[5,5,2]`, `[5,2,5]` are one triangle walked from three places. **The canonical text must therefore fix the starting CORNER, not just the winding** (C3) — a requirement discovered by the census, not assumed | **T1** ✅ | **`tests/census.loft`** §3 — controls: a count key collapses 3 shapes to 2, a turn-blind identity collapses 30 forms to 12 |
| **X39** | **the canonical text is byte-exact, and the corner rule closes it** — `write(read(T)) = T` byte-for-byte over every admitted level-1 form. Canonical spelling = the lexicographically smallest `(turns, lens, h0)` over the `n` cyclic starts, which needs no extra tie-break (a periodic cycle like `[4,4,4]` is decided by `h0`). **30 enumerated spellings collapse to exactly 10 canonical texts** = 10 cycles × 3 corners, and every remaining pair that shares a field differs **only** in `h0` — orientation, which placement carries, not the text | **T1** ✅ | **`tests/text.loft`** — controls: a reordered field and out-of-order indices both refuse; a well-formed text still parses |
| **X40** | **the census digest and the corpus digest answer different questions and must be different functions** — the census quotients by orientation (*how many distinct shapes does this level hold?*, law **I**); law **F** asks whether `draw` is **injective**, which is about the cells actually written. A stencil at `h0=0` and at `h0=6` draw genuinely different cells, so the shape digest calls them equal — using it for law F reported **17 false failures on a 10-entry corpus**. The corpus `.f` uses `field_exact`: no orientation quotient, no translation quotient | **T1** ✅ | **`tests/trip.loft`** §3 — 0 sharing pairs over the committed corpus |
| **X41** | **the round trip CLOSES at level 1** — `write(rebuild(draw(read(T)))) = T` **byte-for-byte** over all 10 committed corpus entries, 0 diffs, every one recovered as **R1 with `ρ = 0` and exactly one match**. Recovery is an exact match against the enumerated set, licensed by the census having decided the level finite and injective; `rebuild` counts its matches rather than assuming uniqueness. A non-grammar footprint lands in **R2 with `ρ > 0`** and cannot be spelled as an authored stencil | **T1** ✅ | **`tests/trip.loft`** — control: a hand-drawn blob → R2, ρ = 2, 0 matches, empty text |
| **X42** | **length alone never collides, but unequal sides introduce CHIRALITY** — `draw` stays injective at every level scanned (10/10, 32/32, 60/60 distinct fields), so law F holds and `rebuild` can be exact. What unequal sides add is a **mirror**: a form and its reflection are different texts (`turn 3,5,4` vs `3,4,5`) drawing mirror-image fields, and since the flip is one of the 12 orientations they share a *shape* digest. Mirrors are impossible at level 1, where equal sides make every form **achiral** — 0 at level 1, 36 at level 2, 72 at level 3 | **T1** ✅ | **`tests/census.loft`** §2–§3 — control: the mirror test must reject a non-mirror and accept a genuine one |
| **X30** | **equal wall width cannot come from counting lattice rows** — a face on a lattice line makes the width an integer multiple of `S√3/(2√N)`, `N = a²+ab+b²`; two such widths are equal only if `N₁·N₂` is a **perfect square**. Among the 24 directions only `N ∈ {1, 3, 21}` occur, and `3`, `21`, `63` are none of them. **Therefore width is a model constant applied perpendicular to the centreline, and the cells are its rasterisation** — the same `√3`-irrationality root as `X24` | **T1** ✅ | **`tests/wall.loft`** §7 — all pairs tested, control: a class is commensurable with itself |
| **X31** | **no lattice vector points at 15°** — `tan 15° = 2−√3`, and a lattice vector has `tan θ = (a+2b)/(a√3)`, so `2a + b = a√3` forces `√3` rational. The **odd 12 of `D` cannot be at their nominal angle at all**; they can be exactly straight and exactly as wide, just not at 15°·odd. The **even 12 are exact**. The `4.1066°` error of `X29` is however **not forced** — the current vector `(5,−1)` (`N = 21`, period 1.528 wu) is **dominated outright**: `(4,−1)` (`N = 13`) gives `1.1021°` at a period of 1.202 wu, *better on both axes*, and `(15,−4)` (`N = 181`) reaches `0.0791°` at 4.485 wu | **T1** ✅ (proof) / **T2** (the ladder) | proof above; ladder measured in `plans/m0-roundtrip/DESIGN.md` §10.9 |
| **X29** | **the in-between 12 of `D` are inexact by exactly 4.1066°** — an odd `d24` is built by summing the two adjacent headings, but those differ in length by `√3` (edge class vs vertex class), so their sum does **not** bisect the angle. The offset is a **uniform bias, not scatter**: all twelve are `4.1066°`, spread `0.0000°`. The even 12 are exact to `0.0000°`. This is why **a house is never drawn with an in-between angle** — they are world linework (`D`), where nothing has to close or meet a corner | **T1** ✅ | **`tests/wall.loft`** §2 — printed per direction, control requires the offset be non-zero |

> **What is settled, and what is still leaned on.** T1 now holds `X1`, `X2`, `X19`–`X22`,
> `X24`–`X42`. Of those, **eight were re-measured *here*** — `X1`, `X2`, `X20`, `X24`, `X25` by
> `tests/form.loft` (steps **S0**/**S1**), and `X26`–`X29` by `tests/wall.loft`. Still below the
> line and still leaned on: the **24-direction cost** (`X3` — `X29` has now re-measured its
> *accuracy* here, but not its cost), the **wall-band validation** (`X10`), and the whole **foxel
> schema** (`X11`–`X15`), which remains **T4** — shape real, behaviour unverified.
>
> **`X26`–`X29` are the first constraints hexbody discovered rather than inherited.** They came out
> of running the sibling libraries' own evaluator against our own write, which is exactly what the
> census is for — and two of them (`X26`, `X28`) are **defects that every other gate was green
> through**. That is the argument for the round trip stated as evidence rather than as prose.

### 7.1 So we build our own corpus

Since almost nothing inherited is **T1**, hexbody has to produce its own — and the math in §4 is
what makes that mechanical rather than a matter of judgement:

- **P3** — the check is `write(rebuild(draw(read(T)))) ≟ T`, a **text diff**.
- **P4** — with no float in `𝕋`, that diff is **byte equality**. No tolerance, nothing to tune.

So a corpus entry is **a text file and a diff**. That is what makes an exhaustive, permanent
corpus affordable at all: no golden images to eyeball, no ε to calibrate, no judgement call per
case. It sits cleanly under `SPEC` **L9** — these are exact texts, not validation images.

**One artifact, three jobs:**

| the corpus is | which gate uses it |
|---|---|
| the record of **what round-trips** | `rt_trip` |
| the record of **what is distinguishable** — no two entries may share a field (law **F**) | `rt_census_a` |
| the **extension guard** — every entry replayed byte-identically after any grammar change | `rt_extend` |

It is grown by the ladder (`DESIGN.md` §8): each rung enumerates its level exhaustively, and the
entries it produces are **kept forever**. That accumulation *is* hexbody's T1.

## 8. Relation to `SPEC.md`

`SPEC` cites this file by law letter and proposition. **Items in `SPEC` marked ⚠ depend on an open
decision and are not settled** — see
[`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) § *Open decisions*.
