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
1.5 m). They are parented to a surface, authored by the editor, and **read by render only**
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

## 7. Constraints from the sibling repos — and how far each is trustworthy

Prior art, in **two tiers**. Re-deriving the first tier is waste; adopting the second tier
without re-gating it is the mistake this project exists to avoid.

| tier | source | status | how to use it |
|---|---|---|---|
| **measured** | `../crawler` — `X1`–`X10`, `X16`–`X17` | **measured, prototyped or gated** — crawler introduced the rigor layer | **cite as settled** |
| **schema** | `../moros` — `X11`–`X15` | **read from code; the implementation is mostly untested** | the *shape* is real; the *behaviour* is not verified. **Cherry-pick where applicable, then gate it here to our standard** |

`X15` is the exception inside its tier: it is moros's own written admission of a defect, so it is
trustworthy **as a warning** even though the surrounding code is unverified.

### 7.1 Measured in `../crawler`

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
| **X16** | **a graph is not a field and cannot be fitted like one** — *"the roof matcher recovers a cone by solving for five parameters, but a skeleton has a variable number of nodes and no amount of least-squares will produce one"*. This is why mechanism is authored/derived, never recovered | `hexskel` |
| **X17** | the part representation exists: *"two levels, no more: an **anchor**, and parts in the anchor's frame"*, with the granularity rule — *split where something moves independently, merge where it does not* | `hexpart` |

### 7.2 Schema read from `../moros` — the shape is real, the behaviour is untested

| # | constraint | source |
|---|---|---|
| **X11** | the foxel **exists**: `Hex`/`HexAddress`/`Chunk`, layers are `cy`, walls are the three owned edges | moros `moros_map/src/types.loft` |
| **X12** | the **wall shape vocabulary** is `WallDef.wd_body` (`SOLID…THICK_CURVED…`), and **thickness lives in the palette** (`wd_thickness`), not the cell | moros `moros_map/src/palette.loft` |
| **X13** | **trees are items** (`ItemDef.id_kind = TREE`) and **roofs are materials** (`MaterialDef.md_category = roof`) — OD-3 and OD-2 confirmed against code, not inferred | moros `palette.loft` |
| **X14** | items carry a **5-bit rotation, 0–23** — the 24-set is already in the storage | moros `types.loft` |
| **X15** | **a Map↔`hex_field` round trip already exists and is lossy**: *"What crosses today: occupancy, height, material. Items, item rotation and the three wall bytes do NOT."* Its test is **green for the wrong reason** — see `DESIGN.md` §11 | moros `moros_map.loft` § *the shared document format* |

## 8. Relation to `SPEC.md`

`SPEC` cites this file by law letter and proposition. **Items in `SPEC` marked ⚠ depend on an open
decision and are not settled** — see
[`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) § *Open decisions*.
