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

> **⚠ Three claims are bundled above, and only one of them is settled. `OD-13` (`DESIGN.md` §10)
> is a standing requirement to change the other two.**
>
> | claim | status |
> |---|---|
> | a stencil is **placed** at one of the 12 `o ∈ O`, never one of the 24 | **settled — and unaffected by `OD-13`** |
> | **`D` is never an authoring palette** | **contested** — `OD-13` requires the in-between 12 be *first class*, because *"a city/castle needs more directions to be believable"* |
> | **a road is never a stencil** | **contested, and untested** — `X57` measured *walls*; `hexway`'s `Track` is a float world-space curve with no lattice anchoring, so stencil-carried roads are unexamined |
>
> **The first claim is about PLACEMENT; `OD-13` is about CONTENTS, and they are separable.** `X57`
> is what makes them safe together: **`D` is closed under `O`** — the 24 directions map onto each
> other exactly under all 12 orientations (0/24 on rotation, reflection and six-rotations-identity;
> a wall segment mirrors 96/96, in-between included). So a stencil *carrying* in-between linework
> still has exactly **12 distinct placements**. Nothing about placement has to move.
>
> **What has to move is permission and round-trip, and it is not built yet** — the grammar (a
> stencil is footprint-only today), `draw`, `rebuild` (it returns the turtle form alone, so embedded
> linework would be silently dropped and `rt_trip` would not even notice), and `fits?`. Until then
> this section states what **is**, not what is intended: the normative claim stands, and this note
> exists so the conflict cannot be missed rather than to soften it.

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
| **X43** | **side count grows cleanly, but the two axes MULTIPLY — the frontier becomes COST** — `draw` stays injective at 3/4/5/6 sides (10, 21, 30, 36 forms, all distinct fields), so law F still holds. What breaks is affordability: `sides × maxlen` gives 32/138/372/900 forms at maxlen 2, i.e. **1442 forms and ~66 s merely to enumerate**. Today's 4-sided house `[4,5,4,5]` needs `maxlen 5` ≈ **1.2 M proposals**, so **enumerate-and-match recovery cannot reach it** — that wants indexed recovery. Law F is not what fails; *deciding* it exhaustively is | **T1** ✅ (side counts, in-gate) / **T2** (the 5×2, 6×2 costs, probed) | **`tests/census.loft`** §5–§6 |
| **X44** | **indexed recovery removes the per-lookup cost — and only that** — drawing each candidate once into a `digest → form` map makes recovery a single probe: **119 fills to build against the 14 161 the scan cost**, 0 digest collisions, and the index verified to agree with the scan on every entry (regime *and* residual). Law F is now checked **once over the whole candidate space** at build time instead of per lookup. **It does NOT shrink the enumeration** — the index is built by that same walk — so the house of `X43` stays out of reach; that needs **constructive** recovery, not a faster table | **T1** ✅ | **`tests/trip.loft`** §4, §6 — control: both recoveries must agree, 119/119 |
| **X45** | **constructive recovery is exact for convex forms, and reaches past the enumeration** — every admitted form is **convex** (law J: turns positive, summing to one revolution), every polygon vertex is a hex centre, so the **convex hull of the filled cells IS the turtle polygon** and its vertices are the corners. Sides resolve by trying all 12 headings (no gcd reduction — `head_step(0)` is `(2,0)`, not `(1,0)`). The hull is taken in `(k,m)`, safe because that basis map has determinant `√3/4 > 0` and so preserves convexity and orientation; **no float enters**. It proposes then VERIFIES by re-drawing. Measured: **119/119** corpus entries, 0 diffs, and today's 4-sided house — **R2 by enumeration, R1 with `ρ = 0` constructively**. **Limit: convex only**; non-convex (A4) needs boundary tracing | **T1** ✅ | **`tests/trip.loft`** §7 — controls: the house must MISS by enumeration, a blob must stay R2 |
| **X46** | **law J is NOT a sufficient admission rule — non-convex forms violate law F** — law J constrains only closure, and admits both non-simple walks (a repeated vertex, so "inside" is undefined) and non-convex forms. Measured over the simple non-convex 4-sided forms: **0 of 94 recover at any scale**, and 86/66/60 of them (at scale 1/3/5) draw a field that **another form also draws** — the recovery reproduces the field exactly (`ρ = 0`) while returning a different form. `draw` is not injective there, so **no recovery method can separate them**; scaling shrinks the failure but never removes it. The admissible (convex ∧ simple) set: 138 forms, 0 failures. **The fix belongs at the doorstep (`K-FIT`), not in the recovery** | **T1** ✅ | **`tests/census.loft`** §7 — control: admitting non-convex must be shown to BREAK law F, or the restriction is unjustified |
| **X47** | **the wall surface is the exact average of its edges — §6.2's constants confirmed, and one it omits** — the summed edge vector is **exactly parallel** to a heading (zero cross product) over all 24 side-runs across 6 rotations, and the position is an exact rational. The **corner** bands are `1/2 u` (east) and `√3/2 u` (north), ratio exactly `√3`; the widening `(√3−1)/2` total / `(√3−1)/4` per face lands exactly on the larger band. **Not in §6.2:** the **midpoint** band is 0 on the east family (the mean line passes through every midpoint) and the full `√3/2` on the north — the row stagger, which the corners hide. Control: the scatter a least-squares fit would threshold is `0` east and `0.9167` north, so *averaging vs fitting* is measured, not rhetorical | **T1** ✅ | **`tests/surface.loft`** — the triangle-subdivision correspondence remains **unverified** and the gate says so |
| **X48** | **a feature's position is exact only at the edge centres — and it never fragments the run** — the model stores `(side, t)` but the field stores a material on edges, so `t` is recoverable only at `t = (2i+1)/2n` (odd numerator, the edge centres); every other `t` **snaps**, and `fits?` must refuse it, exactly as line endpoints are quantised (§10.10). Measured: a door at `7/20` recovers as `7/20`, a 3-edge window at `1/2` as `7, 9, 11`. And `I1` holds both ways — re-materialling leaves **38 wall edges and 0 dangling ends**, deleting the edge instead gives **37 and 2**, so the doored-tower defect cannot arise from this path | **T1** ✅ | **`tests/surface.loft`** §6–§7 — controls: an off-centre `t` must snap, a deleted edge must open the run |
| **X49** | **an arc's CENTRE is exact, its RADIUS is a shell** — from a region of rounded slots the centre recovers exactly (25 towers, 25 recovered; a non-disk is refused), but the radius does not: 161 radii over `0.5..4.5 u` collapse to **4** distinct fields. The admissible radii are the realisable values of `3k²+m²` (`vec_n2_4`) — out to 64 they are **`0, 12, 36, 48`**, matching the float sweep's breakpoints exactly. The whole formulation is **integer**, no float. So an arc is **R1 on a quantised parameter grid**, resolving `OD-10` | **T1** ✅ | **`tests/arc.loft`** — controls: a blob must be refused; distinct shells must not share a field |
| **X50** | **A CONTINUOUS MODEL PARAMETER MUST BE QUANTISED TO WHAT THE FIELD DISTINGUISHES** — measured independently three times and landing identically each time: line **endpoints** → hex vertices a whole number of periods apart (§10.10), feature **`t`** → edge centres `(2i+1)/2n` (`X48`), arc **radius** → shells (`X49`). Off the grid a value is **silently snapped, not rejected**, so `fits?` must refuse it at the doorstep — otherwise the round trip reports success on a model the author did not write | **T1** ✅ | the three gates above, together |
| **X51** | **the doored tower is R1 as ONE arc — a feature composes with an arc at no cost** — a door on a tower is a **material override on a span of the wall's boundary edges** (`arc_door_wedge`), never a deletion. Arc recovery (`arc_recover_centre` / `arc_shell_max`) consumes only the **cells**, and a door touches only edge **materials**, so the doored tower's centre and shell come back **byte-identical** to the plain tower and the door reads straight off storage (`17` edges annotated, `17` recovered, no fit). This is the **named doored-tower defect refused by construction** (`design/FEATURES.md` §3): the door API can only re-material, so the defect is unreachable through it. Measured on a shell-108 tower: three doors annotated leave the arc unchanged and the wall **one closed loop** (0 ends); deleting the three spans instead fragments the wall into **3 arcs** (6 ends), and notching the disk's cells **loses the arc** (centre not found) | **T1** ✅ | **`tests/arc.loft`** §5 — controls: deleting the doors must give 3 arcs; a notched disk must not recover as an arc |
| **X52** | **two adjacent stencils are "mark all, THEN cut once" — order-free by construction, and the shared edge fuses** — re-measuring crawler's `cut_arb` (`EXTRACTION.md`; **T2 → T1** here). Do not draw each stencil's walls and overlay them; **union the footprints, then cut the boundary of the union once**, tagging each edge with its cell's source material (`combine_cut`). Because that reads only the finished union and a fixed source map — never stamp order — `combine(A,B) == combine(B,A)` byte-for-byte (the overlap tie-break is the **lower id**, intrinsic, so order-freeness holds for overlapping stencils too). The **shared edge is interior to the union, so it is never cut**: nobody owns it, two adjacent stencils **fuse** into one fabric (`X4` / law **K₂**; DESIGN §8.0.1). Distinguishability lands exactly right — the merged composite is **field-identical to the single stencil of the union** (the authoring split is not recoverable, and by **P1** need not be), while a composite that **behaves** differently (an authored sealed wall) **is** field-distinct. The naive per-body overlay breaks all three: it is order-dependent (7 edges) and marks a spurious seam wall (7 edges). Exact, no float. **Not covered:** `ε_seam` / `κ ≥ 3` (posed bodies, different frames — the seam here is exact because both live in the world frame), overlap arbitration by nearest surface, linework, terrain, levels | **T1** ✅ | **`tests/combine.loft`** — controls: the per-body overlay must depend on order and must mark the seam; a behavioural difference must be field-distinct |
| **X60** | **a stencil carries a wall in ANY in-between direction, and the run READS BACK EXACTLY** — `OD-13`'s load-bearing half plus its blocker. An embedded wall is a **material on INTERIOR edges** (both cells in the footprint), distinguishable from a boundary edge with no extra tagging. On a 127-cell hexagon, **all 12** in-between directions: footprint **127 cells**, `rebuild` returns the **authored text**, run **wholly interior**, chain **2 ends / 0 branches** (`X32`). **THE READER IS EXACT AND NEEDS NO FIT:** a run's two chain ends *are* its endpoints, they are hex vertices, and the doorstep put the authored ones exactly there — so `wall_read_run` recovers `(d, anchor, p)` by a degree count and one integer division, canonicalising to the end with `p > 0`. Verified over the whole pipeline (draw the stencil's own walls, add the embedded run, **extract the interior edges**, read): **6/6 runs recover the same segment exactly**. Controls: an embedded wall drawn as a **gap** breaks the round trip; a **fragmented** marking is **refused**, never averaged into an answer (`P4`). ⚠ **`OD-13` is still not closed** — `rebuild` does not yet *call* the reader, so an embedded wall is silently dropped and `rt_trip` does not notice. ⚠ **A retracted claim:** an earlier version of this constraint recorded *"only 4 of 12 directions fit, structural, unexplained"*. It was neither — `interior_count` mixed `nb_q`/`nb_r` with hex_grid's corner order, and an 8.5-minute widened search "confirmed" the wrong number because it shared the broken helper | **T1** ✅ (carrying + reader) / **OPEN** (`rebuild` wiring) | **`tests/embed.loft`** — controls: a gap must break the trip; a fragmented chain must be refused |
| **X59** | **seating writes the `height` slot and nothing else, so terrain and stencil are ORTHOGONAL — and the slope's cost is a flagged residual** — `OD-4`'s open half. Its schema half was already settled (terrain *is* `height`, "the same slot as roofs"); what stayed open was **seating** a flat-authored stencil on ground that is not flat, which `SPEC` **G5** requires to leave a *"residual flagged"*. Measured on a 15-cell stencil over flat ground and a `0.75/q` slope: **0 cell diffs, 0 edge diffs**, and `rebuild` returns the **authored text** identically on both — the round trip does not notice the terrain at all, because the recovery reads **cells** and seating writes **heights**. The slope's real cost is the **residual** (the largest gap between the seat height and the ground beneath), **returned rather than absorbed**: `0.000` flat, `1.650` on the slope. Which height to seat at is a **policy** — low `3.000`, mean `1.650` (smallest), high `3.000` — and it moves the residual while leaving recovery untouched, the same split `A6` found between `Sep` and `X7`. **This is the third instance of one pattern:** a door is a *material* not a hole (`X51`), a level is a *filter before the cut* not an arbitration after it (`X58`), terrain is a *height* not a change of footprint — **the round trip survives a new feature exactly when that feature lands in a slot the recovery does not read** | **T1** ✅ | **`tests/terrain.loft`** — controls: flat ground must report residual `0`; a seating that **clips** the footprint to the ground (9 of 15 cells) must **break** the round trip, or orthogonality is a restatement of the construction |
| **X58** | **the BRIDGE GUARANTEE — two things on different LEVELS never contend, because a level filters BEFORE the cut** — re-measuring crawler's `bridgetest` (**T2 → T1** here). A **level** is the topological *sheet* a thing sits on — OSM's `layer` tag, and the `layer*` axis the foxel already carries at the top of its schema (§2.4; moros's `cy`). **It is not a height** — the actual `z` comes from the surface/feature interval. The whole fixture is **one pair of overlapping stencils drawn twice with only the level integer different**, which is crawler's own framing: *"the SAME two ways, at the same level, are a level crossing; at different levels, a bridge. Nothing about the ways changes — only the sheet."* Measured: **same level** → they fuse (shared edges `0`, per `X52`) and contend (`κ = 2`); **different levels** → each sheet holds one stencil alone (30 edges each), `κ = 1` at *both*, and the shared boundary becomes **7 real wall edges** instead of fusing. So the level does work `κ` would otherwise have to (`X4`, `DESIGN` §6.1): different sheets never fuse, never arbitrate, never contend. **And level 0 is free** — the level-aware path is byte-identical to the level-blind `combine_cut` (0 diffs), so the common case pays nothing for a feature it does not use | **T1** ✅ | **`tests/level.loft`** — control: flattening the levels must restore fusion (`7 → 0`) and contention (`κ 1 → 2`) and reproduce the level-crossing field exactly |
| **X57** | **linework is closed under the 12 orientations, and a wall segment's mirror REVERSES its traversal** — law **G** (`rt_flip`) had no gate at all; this is it. `rt_orient` was green only over **houses**, which are drawn by `draw_walls` (the exact combinatorial boundary); **world linework goes through `wall_write`, a band around a line, and nothing gated that path under the orientations.** Vectors: the 24 directions are closed exactly — rotation `d→d+4`, reflection `d→12−d`, six-rotations-is-identity, **0/24 each**. Field level, comparing edges by their exact **triangle-lattice corners** (integer, no tolerance anywhere): a wall segment **mirrors exactly in all 24 directions at 4 lengths — 96/96, 48 of them in-between** — under the rule **`mirror(wall(d,A,p)) = wall(−d, mirror(farend), p)`**. The mirror **reverses traversal**, because `wall_write`'s band is offset to one side of the centreline *by traversal direction*. The naive `d→12−d` anchored at the mirrored **start** is wrong, and fails on **exactly the two directions the mirror FIXES** (90°, 270°) — where reversing traversal is the only difference and nothing else masks it. Rotation is exact for **all three** families. **So a stencil MAY carry an in-between wall: the geometry survives every orientation.** **This gate also FOUND AND FIXED a real defect in `wall_separates`.** It first reported 18 `N=1` rotation mismatches, and the root cause was a **false claim in that function's own comment**: *"for a wall anchored on a vertex it never fires, because a vertex is never at the same offset as a cell centre."* It does — `d=2` from vertex `(3,0)` at `p=3` puts cell `(1,1)` exactly on the line. The offset is mathematically **0**, but in float it evaluates to **`−1.39e-16`** in one orientation and a clean **`0`** in the rotation of the same wall, so the bare `oc >= 0.0` tie-break sorted that cell onto **opposite sides** in the two orientations and the rasterisation was not rotation-covariant. Fixed by comparing against `−WALL_EPS`, which makes a mathematical zero read as zero in every orientation — **not** a tolerance in a fit (`P4`): the quantity is exactly zero and the epsilon only removes rounding noise from a **sign** test. **The fix also sharpened the control**: the naive mirror rule now fails on the **whole chiral `N=1` family** (6 of 6, and no other family), where float noise had been masking four of the six. Houses never came near it (`draw_walls`, the exact combinatorial boundary, gated 12/12) | **T1** ✅ | **`tests/flip.loft`** — controls: the naive mirror rule must fail on exactly the `N=1` family and no other; the `N=1` rotation count is asserted as a regression guard |
| **X56** | **domain B's cost is a THREE-CLASS table over THREE axes — and the third axis, `δ`, decides how linework LINKS to the house angles** — `rt_census_b`, the census `D`'s closure (`X3`) left open. Representability was never the question; **cost** was. Measured over all 24 with the gated `wall_run_len`/`wall_min_p`/`tri_a`/`tri_b`: **6** directions at period `√3` wu and **6** at period `1` wu, all **angle-exact**; **12** in-between at period `√39` wu = **5.408 m**, all `1.1021°` off nominal. **The third axis is `δ = (tri_a − tri_b) mod 3`:** a run of `p` periods from a vertex of class `c` ends on class `(c + p·δ) mod 3`, and class 0 is a hex **centre**, which the doorstep refuses. So `δ = 0` **preserves** the class — every multiple admissible from either class — and `δ ≠ 0` **cycles** it: one run in three refused, and the shortest legal run depends on which class you started from. Since a house wall can leave you on **either** class, `δ` is exactly whether linework links to the house angles unconditionally. Measured: **18** directions link unconditionally, **6** conditionally (the `N=1` house family, 30/90/150°). **Two doc corrections:** DESIGN §10.9's ladder had the period as `√N/3` (a clean **3×** — the signature of a counter bug, here in the table not the code), and had **no `δ` column at all**, which is why it called the old `N = 21` *"dominated outright"* — on the linking axis it was on the frontier. `N = 7`'s "43% shorter period" is likewise `δ = 1`, so its effective grid is only **13%** finer. **The in-between vector was therefore switched to `N = 39` `(7,−2)`**, not the finer-looking `N = 13`: both buy the same `3.7×` accuracy, but `N = 13` is `δ = 2` and would spend the unconditional linking. Exhaustive over `N ≤ 400`: **no vector improves the angle while keeping both today's grid and `δ = 0`** | **T1** ✅ | **`tests/censusb.loft`** — controls: a conditional direction must exist and show a class-dependent `min_p`, or "unconditional" is vacuous; `N = 13` must genuinely beat `N = 39` on period, or nothing was traded; the measured period must **not** equal `√N/3` |
| **X55** | **the cut spans the A/B domain boundary — a stencil and world linework are cut as ONE, and a world line recovers exactly straight** — A8's linework axis. A **stencil** (domain A, a tower arc) standing on **world linework** (domain B, an E–W run in a direction `d ∈ D`) is cut by the same `cut_arb` pass, with the surface set spanning both domains: **112/112** boundary edges take the nearest surface, the run's flat top goes to the **world line** (30/30) and the stencil's rim to its **arc** (26/26) — the domains do not bleed into each other — and both build orders give **0** tag differences. **Linework recovery is exact:** both the NE and NW boundary edge of a top-row cell have midpoint `y = 0.75`, so an E–W world line is exactly collinear on the lattice — **eave_spread = 0**, the phase-B verify. Control: the same spread ruler over the curved rim reads **6.75**, so `0` is a result and not a dead instrument; and a fixed "always the stencil's arc" rule strands **84** edges >1 u from their surface. **Still open:** the full domain-B census (`rt_census_b`, the `period` cost table over all 24) | **T1** ✅ | **`tests/line.loft`** — controls: the spread ruler must see the curve; a fixed rule must strand the linework |
| **X54** | **overlap arbitration is by NEAREST SURFACE — order-free, geometric, ties to the lower id** — gating crawler's `cut_arb` (copied into `hexway`, ungated until now). Where X52's cut tags each boundary edge with its cell's source *material*, `cut_arb` tags it with the nearest analytic *surface* — the edge's collision proxy, chosen by `surf_distance`, ties resolved to the lower id. "Mark all, THEN cut once" reads the finished union and the fixed surface set, never stamp order, so it is **order-free by construction**. Measured on two overlapping tower disks (their rims splitting the union boundary): all **66/66** boundary edges get the true nearest surface, **33 → A, 33 → B**; a fixed "always the lower id" rule mis-tags **31** edges (the far rim, >1 u from surface A) — the geometric work nearest-surface does and a fixed rule cannot; both stamp orders give **0** tag differences; and with a surface registered **twice**, all **42** edges take the lower id (the strict-`<` tie-break). The collision-proxy half of the union cut, complementing `X52` | **T1** ✅ | **`tests/arb.loft`** — controls: a fixed rule must mis-tag the far rim; duplicate surfaces must all resolve to the lower id |
| **X53** | **the frame seam: a posed body's error lives ONLY at the pose transform, and both open constants are now measured** — the first measurement of `ε_seam` and the `κ ≥ 3` rate, which DESIGN §7 left OPEN. A cross-frame query routes through the pose transform once (world → p⁻¹ → exact local test), which is the **sole float step**; measured over 41×41 × 6 poses, `ε_seam` (the round-trip residual `\|p(p⁻¹(x))−x\|`) is **≈ 7.1e-15 — machine ε**, far below lattice resolution, so a routed query **agrees with an exact integer oracle on every one of 1681 points** (interiors exact; the error band is ε-wide). The **forbidden fix** — snapping a body's wall onto the world lattice to close a crack — displaces the body 0.4 in its own frame and **misclassifies 12 interior cells** (routed: 0): it trades a machine-ε seam for real interior error and voids law **D**. `κ ≥ 3` is **rare at a point** (10 of 841) but a **swept segment touches 4 frames where no point sees more than 3** — so κ≥3 is a **counter measured on sweeps**, not an assumption. Arbitration is **order-free** (owner = lowest id among the solids, `arb(A,B)=arb(B,A)`) and **fail-safe** (a world gap under a body solid resolves to *solid* — no fall-through, `I4`). The oracle is exact because the pose is **Pythagorean** (cos 4/5, sin 3/5) | **T1** ✅ | **`tests/seam.loft`** — controls: snapping must misclassify interior cells; a world-blind counter must undercount; a first-solid-wins owner must diverge by order |
| **X30** | **equal wall width cannot come from counting lattice rows** — a face on a lattice line makes the width an integer multiple of `S√3/(2√N)`, `N = a²+ab+b²`; two such widths are equal only if `N₁·N₂` is a **perfect square**. Among the 24 directions only `N ∈ {1, 3, 21}` occur, and `3`, `21`, `63` are none of them. **Therefore width is a model constant applied perpendicular to the centreline, and the cells are its rasterisation** — the same `√3`-irrationality root as `X24` | **T1** ✅ | **`tests/wall.loft`** §7 — all pairs tested, control: a class is commensurable with itself |
| **X31** | **no lattice vector points at 15°** — `tan 15° = 2−√3`, and a lattice vector has `tan θ = (a+2b)/(a√3)`, so `2a + b = a√3` forces `√3` rational. The **odd 12 of `D` cannot be at their nominal angle at all**; they can be exactly straight and exactly as wide, just not at 15°·odd. The **even 12 are exact**. The angle error is however **not forced** — it is a choice of vector, and the vector was changed: `(5,−1)` (`N = 21`, `4.1066°`) → **`(7,−2)` (`N = 39`, `1.1021°`)**, `3.7×` more accurate. `X56` gated the ladder on **three** axes and found the earlier two-axis reading wrong: `(4,−1)` (`N = 13`) is equally accurate and finer, but `δ ≠ 0`, so it forfeits unconditional linking; `N = 39` keeps it | **T1** ✅ (proof **and** ladder — the ladder gated by `X56`) | proof above; ladder now measured in **`tests/censusb.loft`** §4, anchored to the gated direction 1 (its periods in `DESIGN.md` §10.9 were 3× too small, and it had no `δ` column, until then) |
| **X29** | **the in-between 12 of `D` are inexact by a UNIFORM bias — now `1.1021°`** — no odd multiple of 15° is reachable at all (`X31`), so the in-between directions carry a fixed offset. What matters and is gated is that it is a **uniform bias, not scatter**: all twelve share it, spread `0.0000°`, and the even 12 are exact to `0.0000°`. *The value was `4.1066°` while the vector was the sum of the two adjacent headings (`N = 21`); `X56` changed the vector to `N = 39` and the bias with it.* This is why **a house is never drawn with an in-between angle** — they are world linework (`D`), where nothing has to close or meet a corner | **T1** ✅ | **`tests/wall.loft`** §2 — printed per direction; controls require the offset be non-zero **and uniform across all 12**, so the constraint survives a change of vector |

> **What is settled, and what is still leaned on.** T1 now holds `X1`, `X2`, `X19`–`X22`,
> `X24`–`X60`. Of those, **eight were re-measured *here*** — `X1`, `X2`, `X20`, `X24`, `X25` by
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
