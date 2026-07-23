# DESIGN — M0 round trip: what we are building, testing and deciding

The **in-flight** half. [`ROUNDTRIP.md`](../../ROUNDTRIP.md) holds only what is settled —
definitions, proved propositions, and crawler's measured constraints `X1`–`X10`. **Everything
here is a proposal, a hypothesis or an open question**, and none of it should be cited as fact.

Plan status, phases and ordering: [`README.md`](README.md).

---

## 1. Proposed laws — beyond the settled `D`/`E₂` core

Each is a **design claim**, not a theorem. Notation `A₁ … K₂` is the working numbering.

| # | law | statement | status |
|---|---|---|---|
| **A₁** | canonicity | `∀m. read(write(m)) = m` ∧ `∀T. write(read(T)) = T` | proposed |
| **A₂** | monotone extension | `𝕋ₙ ⊆ 𝕋ₙ₊₁`, and `∀T ∈ 𝕋ₙ`: same model, same field, **same bytes**; `𝕄*` grows, never shrinks (§4) | proposed |
| **B** | projection | `∀m ∈ 𝕄. σ(σ(m)) = σ(m)` ∧ `ρ(σ(m)) = 0` | proposed |
| **C₁** | fitting = fixed point | `∀m ∈ 𝕄. m ∈ 𝕄* ⟺ σ(m) = m` | proposed |
| **C₂** | closure under operations | `∀m ∈ 𝕄*, ∀op ∈ Ops. op(m) ∈ 𝕄*`, `Ops = {flip, place, combine, damage, seat}` (§5) | proposed |
| **D** | round trip | `rebuild(draw(m)) = m` | **the target** |
| **E₁** | totality | `∀f ∈ 𝔽. rebuild(f) ∈ 𝕄*` — never fails, never returns a non-fitting model | proposed |
| **E₂** | exactness on `im(draw)` | `rebuild ∘ draw ∘ rebuild = rebuild`, `ρ = 0` | **the target** |
| **E₃** | approximation off it | `f ∉ im(draw)` → `(m′, ρ)` with `ρ` **reported**; `ρ > 0` expected (§3) | proposed |
| **F** | injectivity | `draw(m₁) = draw(m₂) ⟹ m₁ = m₂` | follows from D; its *coverage* is measured |
| **G** | flip commutation | `rebuild(flip_𝔽(draw(m))) = σ(flip_𝕄(m))` | **pending OD-5** |
| **H** | flip stability | `φ ≔ σ ∘ flip_𝕄`; `φ²ⁿ(m) = m` | **pending OD-5** — may be a theorem, given `X2` |
| **I** | `O`-equivariance | `draw(τ_v ∘ o · m) = τ_v ∘ o · draw(m)` | **GREEN** (`housetest`) |
| **J** | stencil closure | `Σᵢ lenᵢ·e(hᵢ) = (0,0)` ∧ `Σᵢ turnᵢ = 12` | proposed — **pending OD-6/OD-7** |
| **K₁** | seam containment | error `= 0` in a frame interior; `≤ ε_seam` and deterministic on the seam (§6) | proposed |
| **K₂** | seam arbitration | exact at `κ ≤ 1`; deterministic pairwise at `κ = 2`; conservative + counted at `κ ≥ 3` (§6) | proposed — `X4` is **stronger** |

## 2. Proposed grammar of `𝕄*`

**Pending OD-6 and OD-7** — both could replace this wholesale.

```ebnf
⟨model⟩    ::= { ⟨stencil⟩ | ⟨place⟩ | ⟨line⟩ | ⟨join⟩ }

(* A · stencil: a CLOSED turtle polygon in a LOCAL frame, headings from H₁₂ *)
⟨stencil⟩  ::= "stencil" ⟨name⟩ "h0" ⟨h0⟩ { ⟨element⟩ }
⟨element⟩  ::= ⟨side⟩ | ⟨arc⟩ | ⟨feature⟩ | ⟨roof⟩ | ⟨layer⟩
⟨side⟩     ::= "side" ⟨nat⟩ "len" ⟨nat⟩ "turn" ⟨turn⟩
⟨h0⟩       ::= ⟨nat⟩                        (* initial heading h ∈ H₁₂ = ℤ/12 *)
⟨turn⟩     ::= ⟨int⟩                        (* Δh ∈ -5..6, twelfths of a revolution *)
⟨arc⟩      ::= "arc"  ⟨nat⟩ "ctr" ⟨point⟩ "rad" ⟨nat⟩ "from" ⟨rat⟩ "to" ⟨rat⟩
⟨feature⟩  ::= ⟨kind⟩ "side" ⟨nat⟩ "t" ⟨rat⟩ "w" ⟨nat⟩ [ "sill" ⟨nat⟩ "head" ⟨nat⟩ ]
⟨place⟩    ::= "place" ⟨name⟩ "at" ⟨point⟩ "orient" ⟨orient⟩
⟨orient⟩   ::= ⟨rot⟩ [ "flip" ]             (* o ∈ O — the ONLY choice a placement makes *)
⟨rot⟩      ::= "0" | "1" | "2" | "3" | "4" | "5"

(* B · world linework: drawn in WORLD coordinates, direction follows the run *)
⟨line⟩     ::= "line" ⟨lkind⟩ ⟨nat⟩ "from" ⟨point⟩ "dir" ⟨dir⟩ "len" ⟨nat⟩
⟨join⟩     ::= "join" ⟨nat⟩ ⟨nat⟩ "rad" ⟨nat⟩       (* G¹ arc joining two ⟨line⟩s *)
⟨lkind⟩    ::= "road" | "wall" | "cliff"

(* shared terminals *)
⟨point⟩    ::= ⟨int⟩ "," ⟨int⟩              (* lattice, or half-integer at edge midpoints *)
⟨dir⟩      ::= ⟨int⟩ "," ⟨int⟩              (* reduced; ∈ D — reachable ONLY from ⟨line⟩ *)
⟨rat⟩      ::= ⟨int⟩ "/" ⟨nat⟩              (* reduced; never a decimal *)
⟨int⟩,⟨nat⟩ ::= decimal integer
⟨name⟩,⟨kind⟩,⟨layer⟩ ::= DEFERRED
⟨roof⟩     ::= OPEN DECISION                (* domain C — height recovery; OD-2 *)
```

Two intents the grammar is meant to *enforce* rather than assert:

- **`⟨dir⟩` is unreachable from `⟨stencil⟩`** — "a stencil at one of 24 directions" is
  *unparseable*, not merely invalid.
- **There is no `⟨float⟩` production** — a model needing a float is unparseable, so the fitting
  criterion is enforced by the parser.

| quantity | stored as | never stored as |
|---|---|---|
| position | `(q,r) ∈ Λ`, half-integer at edge midpoints | metres |
| direction — **A** | `h ∈ H₁₂`, via `h0` + running `Σ turn` | degrees, or a `⟨dir⟩` |
| direction — **B** | reduced `d ∈ D` | degrees |
| length | **step count** along `e(h)` (A) or `d` (B) | metres |
| radius, sill, head, height | step count | metres |
| parameter along a side | reduced `⟨rat⟩` | decimal |

Metres and degrees are **derived for display**. Lattice lengths are irrational
(`‖(2,1)‖ = 1.5√7 m`), so storing metres would forfeit exactness.

## 3. Canonical text `𝕋`, and damage

Proposed rules — a model has **exactly one** spelling:

1. **C1 integers only** — every numeric token is `⟨int⟩`, `⟨nat⟩` or reduced `⟨rat⟩`.
2. **C2 fixed order** — elements sorted by `(kind, index, t)`; fields in declaration order.
   **`kind` orders by a fixed registry position, never alphabetically** — new kinds are appended
   (§4).
3. **C3 reduced forms** — `⟨dir⟩` and `⟨rat⟩` in lowest terms.
4. **C4 fixed layout** — single space separators, one element per line, no trailing space.
5. **C5 defaults are omitted** — an optional field is written only when it differs from its
   default, and the default reproduces prior behaviour exactly (§4).

*Illustrative only — the rules are the proposal, not the token spellings:*

```
stencil house1  h0 0
side  0  len 4  turn 3
side  1  len 5  turn 3
side  2  len 4  turn 3
side  3  len 5  turn 3
door  side 3  t 1/2  w 1
win   side 3  t 1/5  w 1  sill 2  head 5
place house1  at 3,-2  orient 4 flip

line  road 0  from 0,0    dir 2,1  len 40
line  road 1  from 31,18  dir 1,1  len 25
join  0 1  rad 6
```

Law **J** on that stencil: `Σ turn = 12` ✓, and `4·e(0) + 5·e(3) + 4·e(6) + 5·e(9) = (0,0)` ✓
since `e(h+6) = −e(h)`.

### 3.1 What is stored — proposed, and challenged by OD-6

| | stored? | role |
|---|---|---|
| `𝕋` — a body's **original** | **yes** | the truth for that body, in its local frame |
| `P` — its **pose** | **yes** | where it is in the world; free of the lattice |
| `𝔽_loc` — its local field | **no** — `draw(original)`, on demand | what collision, render and destruction read |
| `𝔽_wld` — terrain + linework | **yes** | the world's own truth |

This scopes `SPEC` **L3** rather than weakening it: *"the field is the stored truth"* holds for
the **world**; a **body**'s truth is its original plus its pose. **OD-6 challenges this directly**
— crawler stores the stencil *as a field*.

### 3.2 Damage — the one place the original is lost

Destruction mutates `𝔽_loc` directly. The original no longer describes the body and is **not
recoverable** — a ruin is not an invertible transform of a house. So the damaged field is
**re-canonicalised to a new original, by approximation**:

```
𝔽_loc ──mutate──▶ 𝔽′ ──rebuild──▶ (m′, ρ) ──write──▶ 𝕋′       ρ > 0 is EXPECTED and REPORTED
```

`𝕋′` becomes the stored original from that moment; the pre-damage `𝕋` is history, not a second
truth. **This is the only step where `ρ > 0` is legitimate**, and it is legitimate precisely
because it produces a *new original* rather than pretending to recover the old one — which is why
law **E** splits into `E₁`/`E₂`/`E₃`.

## 4. Growing the language — proposed extension contract

This is infrastructure built out **like a programming language**: `⟨tower⟩`, `⟨bridge⟩`, `⟨prop⟩`
and new parameters get added over years. Adding a keyword must never change a program already
written — law **A₂**.

| adding | the trap | the rule that prevents it |
|---|---|---|
| a **verb** (`⟨tower⟩`) | sorting `kind` alphabetically makes it interleave, **re-spelling every existing text** | **C2** — registry order, appended |
| a **parameter** | writing it always adds a token to every existing element | **C5** — omitted at default |

A re-spelling is not cosmetic: `𝕋` **is** the stored truth for a body (§3.1), so it would
invalidate every stored original and every fixture at once.

> **The census window.** Restrictions can be added to `fits?` **freely while phase A runs and
> nothing has been authored against it**. Once texts exist in the wild, tightening `fits?` is a
> **breaking change** with no migration — nobody can re-derive geometry a person hand-placed. Run
> the whole ladder, **A8 included**, before the editor ships content.

## 5. `fits?`, and the doorstep

```
fits?(m)  ⟺  syn(m) ∧ sem(m)
```

| layer | statement | decided by |
|---|---|---|
| **syn** | derivable from the §2 grammar | the parser |
| **sem·A** | *(stencil)* the boundary **cycle** is closed (law **J**) and **unique** among admitted stencils | the stencil census |
| **sem·B** | *(linework)* — **note `X3`**: representability is settled, so this is a *cost* bound, not a threshold | the linework census |
| **sem·C** | *(arcs, joins)* `(rad, span) ∈ Sep`, `G¹` at joins | `Sep` · `junction_g0` |

### 5.1 The two recovery mechanisms differ, and must stay different

|  | **A · stencil** | **B · linework** |
|---|---|---|
| matched object | the **whole closed boundary cycle** | an **open run** |
| direction set | `H₁₂` | `D` — 24 |
| span length | **short spans permitted** | long by nature |
| recovery | **exact match against the enumerated cycle set** | direction recovery |
| injectivity proved by | **exhaustive enumeration** per level, to the discovered frontier | a cost bound |

**Why stencils need no length bound.** An isolated 1-step span cannot fix its heading — one hex
edge lies on one of **3 axes**, which cannot distinguish **12** headings. But a stencil side is
never isolated: by `SPEC` **I3** a wall is the boundary of a *filled region*, so the matched
object is the **closed cycle**, whose corners carry the turn sequence that disambiguates the
short sides. *(This argument depends on **I3**, hence on **OD-7**.)*

### 5.2 The limit sits at the doorstep

**The bounds are not the problem** — there is room inside them, and a restriction found by the
census is a **fact to record**, not a defect to engineer away. What matters is that nothing
outside `𝕄*` gets in.

> **The editor refuses at authoring time.** Not a warning, not a downstream check, not a failure
> at `rebuild`. If a thing cannot survive, it cannot be made. `authorable ⊆ { m : fits?(m) }`.

Deferred breakage separates symptom from cause: a building authored on Monday looks right,
round-trips right, and breaks after a flip / beside its neighbour / once damaged, with nothing on
screen pointing back at the authoring choice. **"Eventually broken" is why law C₂ exists**:

| `op ∈ Ops` | the deferred break it would otherwise cause |
|---|---|
| `flip` | authored fine, wrong after a mirrored placement |
| `place` | fine in the local frame, wrong once seated |
| `combine` | fine alone, broken beside its neighbour — rung **A8**, the least visible axis |
| `damage` | fine intact, un-re-canonicalisable as a ruin |
| `seat` | fine on flat ground, unseatable on real terrain |

There are exactly **two doors** into `𝕄*`, and both are guarded: the **editor** (`fits?`) and
**`rebuild`** (lands in `𝕄*` by `E₁`). A refusal **names its restriction** and offers the nearest
fitting alternative with its residual — never a silent snap, never a blank rejection.

*Prior art:* `X5` — *"a stencil rotated by a non-multiple of 60° must be refused, not silently
rounded"* — is this principle, pre-dating it, generalised here from rotation to all of `Ops`.

## 6. Frames, the seam, and contention

Collision reads **several presentations at once**: the unmovable base world plus every posed body.
Each belongs to one **frame** — `Φ_wld` (identity) or `Φ_b` (the body's pose). Inside a frame
geometry is exact; **across frames it cannot be**, because a pose is continuous. Where two frames'
geometry meets there are **cracks** — the **seam** `Σ`.

**Enforced by construction, not discipline.** Every cross-frame query routes through one path:

```
  world query ──[ p⁻¹ ]──▶ local query ──exact test in 𝔽_loc──▶ hit ──[ p ]──▶ world
                    └────────── the ONLY inexact step ──────────┘
```

The pose transform is the sole floating-point step *and* is already the `I5` chokepoint, so `Σ` is
where error lives because it is the only place a transform happens.

**Forbidden fix:** closing a crack by *moving geometry* — snapping a body's wall onto the world
lattice. That relocates seam error into a frame **interior** and voids **D** for that body.

**Jank is not licence for nondeterminism.** `L7`/`I9` need byte-identical replay, so seam error
must be a deterministic function of its inputs. A crack that differs between two runs of the same
derailment is a defect, not an allowed imprecision.

### 6.1 Contention

Two kinds of disagreement, handled differently:

| kind | example | handling |
|---|---|---|
| **numerical** | a contact point computed in `Φ_a` vs `Φ_b` | **removed by construction** — compute cross-frame quantities in **one designated frame**, single-valued because only one computation happens |
| **categorical** | world says *gap*, body says *solid* | arbitration, by contention degree `κ` |

| `κ` | regime | requirement |
|---|---|---|
| `≤ 1` | no contention | **exact** |
| `= 2` | **the designed-for case** | deterministic pairwise arbitration over a total order on frames |
| `≥ 3` | rare | total, deterministic, **conservative** — and **counted** |

Two requirements that are easy to omit silently: a **total order on frames** (a "whichever is
nearer" tie-break resolved by iteration order breaks replay), and a **fail-safe direction** —
prefer *solid* over *gap*, which composes with `I4` so a crack yields a spurious contact rather
than a body falling through the world.

> **`X4` is stronger than K₂ and should probably replace it.** crawler requires overlapping
> stencils arbitrate *"deterministically **and order-freely**"* — order-free means the result does
> not depend on order at all, not merely on a fixed one. Its **level separation** also does work
> `κ` would otherwise have to: two objects on different levels never contend.

> **`κ ≥ 3` is a counter, not an assumption**, and the scene that maximises it is **`G★` itself**
> — a pile of tumbled wagons is many overlapping frames. A point query rarely finds 3 at once; a
> **swept volume** straddles frames far more easily. Measure it there, not in a two-body fixture.

## 7. Open constants

| constant | domain | produced by | status |
|---|---|---|---|
| `Cyc` | A | the stencil census, grown by level (§8) | **OPEN** |
| `period` | B | the linework census | **OPEN — probably the wrong instrument**; `X3` says representability was never the question, only cost |
| `Sep` | B | the arc sweep | **OPEN** — and aimed at a different objective than `X7`'s collision-match |
| `D` | B | — | **CLOSED** — all 24 representable (`X3`) |
| `ε_seam` | frames | measured at the chokepoint | **OPEN** |
| `κ≥3` rate | frames | `rt_contend`, in the `G★` pile | **OPEN** — asserted low, unmeasured |

## 8. Method — grow, don't presuppose

**Do not define the admitted space and then enumerate it.** That presupposes the bounds, and the
bounds *are* the answer. The restrictions are the **output**.

```
  level n:  enumerate EXHAUSTIVELY at this level ──▶ round-trip each ──▶ all pass?
                          ▲                                              │  yes → n+1
                          └──────────────────────────────────────────────┘
                                       the failing pair IS a restriction ─┘  no
```

Within the frontier law **F** is *decided*, not sampled — the growth loop sits **outside** the
enumeration, not instead of it. Every level is a complete gated increment, so the work always has
something green rather than one long red run to a verdict.

**Two growth axes**, and the second is where the discoveries are: **form** (minimal cycle → longer
sides → more sides → unequal → non-convex → features → arcs) and **combination** (two stencils
adjacent, stencil against linework, stencil on terrain). Things that round-trip alone routinely
stop round-tripping combined.

**The smallest form is concrete.** By law **J** a stencil needs `Σ turn = 12` and a closing vector
sum, so the minimum is **3 sides** — an equilateral triangle, `turn 4` at each corner, closing
because three lattice vectors 120° apart sum to zero: `(1,0) + (−1,1) + (0,−1) = (0,0)`.

> **Method warning `X9`, earned in crawler.** *"Before width-normalising, this table appeared to
> show the VERTEX directions as the worst of all. That was an artefact — a fixed nominal halfwidth
> yields 17/29/19 cells by direction, so the raw spread was measuring width, not heading. Fitting
> `W` per direction **reversed the conclusion**."* The census has the identical hazard: forms at
> different headings enclose different cell counts, so raw spread conflates **size** with
> **heading**. A census that skips this produces a confident, ranked, **inverted** table.

### 8.1 The rungs come from the scene, not the desk

§8 is the method; it is not the work-list. The current work — **a landscape with houses, trees and
a tower** — decides which rungs exist and in what order. It is not a demo of the infrastructure;
it is the **instrument that finds the infrastructure's gaps**. A contract makes the axes you
already see safe; only a real scene converts an axis nobody imagined into one you can gate.

| the scene has | it exercises | consequence |
|---|---|---|
| **houses** | polygonal stencils, features, `H₁₂` | the ladder's spine |
| **a tower** | **arcs**, immediately with features — the **doored-tower defect** (`design/FEATURES.md` §3): a wall with a door fitting **3 arcs instead of 1** | arcs move from the last rung to the middle; the defect is a named law **D** failure |
| **trees** | a class with **no verb** | **OD-3** |
| **the landscape** | terrain with **no production**, plus seating | **OD-4** |

## 9. Proposed gates

| gate | law | test | control |
|---|---|---|---|
| `rt_canon` | A₁ | text diff | reorder a field → diff |
| `rt_extend` | A₂ | replay every prior fixture; bytes **identical** | sort `kind` alphabetically → later verbs re-spell every text |
| `rt_project` | B | equality + `ρ = 0` | perturb by ½ step → `ρ ≠ 0` |
| `rt_fits` | C₁ | `fits?` vs `σ(m) = m` | a cycle in the collision set → `fits?` false |
| `rt_closure` | C₂ | `∀m, ∀op ∈ Ops. fits?(op(m))` | admit a form whose `flip` leaves `𝕄*` → fires at the door |
| `rt_door` | C₂ | every editor op yields `fits?`; refusals name their restriction | let the editor emit a non-fitting model → `rt_trip` breaks downstream instead |
| **`rt_trip`** | **D** | **`write(rebuild(draw(read(T)))) ≟ T`** | a non-fitting model bypassing `σ` → diff |
| `rt_total` | E₁ | `σ(rebuild(f)) = rebuild(f)` for arbitrary `f` | hand-corrupt an `EdgeSet` → still lands in `𝕄*` |
| `rt_ruin` | E₂,E₃ | `ρ = 0` on `im(draw)`; reported off it | crumble a wall → `ρ > 0` surfaced, not swallowed |
| `rt_census_a` | F | grown by level; **reports the frontier** | remove a corner's turn from the match key → collisions at level 1 |
| `rt_census_b` | F | the domain-B cost table | — |
| `rt_close` | J | `Σ lenᵢ·e(hᵢ) = 0` ∧ `Σ turnᵢ = 12` | drop one turn → non-zero sum |
| `rt_seam` | K₁ | error `≡ 0` in interiors; `≤ ε_seam` on `Σ` | "fix" a crack by snapping a body wall → interior error ≠ 0 |
| `rt_contend` | K₂ | `κ` histogram over the `G★` pile | tie-break on iteration order → replay diverges |
| `rt_flip` | G | text diff | asymmetric feature → diff |
| `rt_drift` | H | text diff after `φ¹²` | inject a rounding step → drift |
| `rt_orient` | I | field equality over `O × Λ` | — **GREEN** |

`rt_trip` must be **enumeration-driven** over primitive kinds — a new primitive without
`write`/`draw`/`rebuild` coverage fails the gate rather than going silently ungated.

## 10. Open decisions

> **The foxel schema (`ROUNDTRIP` §2.4) closed or narrowed most of what follows.** Recorded here
> so the reasoning survives, with the schema's consequence marked on each. **What the schema
> states is settled; the per-decision consequences below are inference and want one confirmation
> pass.**
>
> | | was | after the schema |
> |---|---|---|
> | **OD-2** roofs | in or out of the exact round trip? | **`height`.** Heights are the stored truth; a roof *profile* is a **R2** fit over them, so `roof_match`'s `tol` is legitimate — in R2 |
> | **OD-3** trees | a verb, or a prop outside `𝕄*`? | **`item`.** An occupant, not fabric. Still needs crawler's `TREES.md` read for what an item carries |
> | **OD-4** terrain | a `⟨terrain⟩` production? | **`height`.** Same slot as roofs — the two were always one question |
> | **OD-6** stencil: field or description? | the deepest one | **the foxel is the stored truth.** A description is admissible only if it draws into the schema exactly |
> | **OD-7** which wall model? | edges vs triangle band | **`wall1..3` per point — edges.** A triangle subdivision needs sub-cell resolution the schema has no slot for. `WALLS.md`'s band model cannot be *stored*, whatever its merits as a render/collision construction |
> | **OD-8** when do layers enter? | deferred | **now.** `layer*` is the outermost structure |
>
> **What survives as genuinely open:** **OD-1** (the morph — unaffected, it was already narrowed
> to option (c) by free poses) and **OD-5** (is the flip exact — `X2` says yes; unaffected by the
> schema). And a new one below.
>
> **OD-9 · does the door survive as an annotation?** `SPEC` **I1** and `FEATURES.md` require a
> door to be an interval on the analytic surface that **annotates** its edges. The schema gives an
> edge one `material` slot per wall — so a doored edge either carries a *door material* (losing the
> wall's own material) or the door lives in a layer the schema does not obviously have. `WALLS.md`
> solved this by *deleting band triangles*, which OD-7 has now ruled out. **This is the doored-tower
> defect relocated into the storage schema**, and it is rung **A5**'s real question.

**OD-1 · the morph — dead, or moved into `snap`?**
`design/EDITOR.md` §2 makes orientation a *minimal affine morph*, *"the bridge from 6 exact
rotations to **many**."* A morph is a **non-lattice affine map**, so a morphed wall lands outside
`𝕄*` and no exact round trip exists for it. EDITOR §2 names the second break itself — *"a general
two-axis morph turns a circular arc into an ellipse"*.

Free poses narrow this sharply: a building at 37° is simply a **free-posed body**, exact in its
own frame. The morph is needed **only** for a **seated** body that must share lattice cells.

| option | consequence |
|---|---|
| **(c)** unnecessary *(cheapest)* | open question shrinks to: does a *seated* building ever need an angle outside the 12? Only if a walker crosses street↔interior on shared cells at that angle |
| **(a)** superseded | EDITOR §2 deleted; free poses cover the rest |
| **(b)** into `snap` | a lossy seating convenience with residual `ρ`, never stored; `𝕄*` and **D** untouched |

**OD-2 · are roofs inside the exact round trip?**
`Heights` is neither domain A nor B: a roof is a continuous surface sampled into a height field
(`hexroof`: cone, ridge, vault, hip, dome, groin, cloister). The tree already implements recovery
*with a tolerance* — `roof_match(s, f, tol: float)` (`src/hexroof.loft:493`), which is the `ε`
**P4** forbids. Options: **(a)** roofs excluded — `𝕋` carries roof *parameters* and `Heights` is a
derived render product never recovered; **(b)** roofs are a **domain C** with an exact inverse per
profile.

**OD-3 · are trees in `𝕄*` at all?**
The scene has trees; the grammar has no verb. Either an **instanced prop** (pose + kit piece,
never round-tripped — cheaper, matches VISION's kitbashing route) or **field geometry** (a canopy
occupying cells, which makes a tree *fellable* and its stump derivable). **Do not decide from
here** — crawler holds `plans/9-canopy-trees/TREES.md` plus `src/canopy*.loft`, and `PROPS.md`.

**OD-4 · is terrain inside the exact round trip?**
No `⟨terrain⟩` production. Structurally identical to OD-2, so answer them together. Prior art:
crawler `plans/8-landform-morphogenesis/`.

---

The four below are **conflicts with settled prior art**, surfaced by inspecting crawler against
this design. Each has a position already argued somewhere. **OD-6 is the deepest and probably
orders the rest.**

**OD-5 · is the flip exact?** *(contradicts `X2`)*
Laws **G**/**H** treat the flip as *mutating by approximation*, with `rt_drift` built to measure
drift, and `SPEC` **L4** superseded on that basis. But `X2` says reflection is `k → −k`, **exact**
— so `flip∘flip = id` by construction, `rt_drift` is trivially green, and **H** is a theorem.

Three things are conflated under "the flip", and separating them likely dissolves this: the
**lattice reflection** (exact, `X2`); the **morph** (genuinely approximate — OD-1); and the
**handedness residual** (backwards text, hinges on the wrong side — a *content* problem, and the
reason EDITOR wants no mirror at all).

**OD-6 · is a stencil a *field* or a *generative description*?** *(the foundational one)*

| | crawler — stencil-as-field | here — stencil-as-description |
|---|---|---|
| the object | `(extent, HexSet, Labels?, Heights?, EdgeSet?, Features?, props?)` — *"a small **field**, not a bitmap"* | a **turtle polygon** |
| stored | the field itself | the canonical text `𝕋` |
| round trip | stamp → un-stamp restores `𝔽` **bit-for-bit** | `write(rebuild(draw(read(T)))) = T` |
| gives you | placement and removal, exactly | **parametric editing** — change a length, re-derive |
| recovery needed? | no — nothing was ever lost | yes — the whole contract |

Both can coexist (a description that *generates* a field which is then stamped), but the spec must
say which is the **stored truth** — §3.1 answers `𝕋`, crawler answers the field. It also decides
how much of **D**/**E₂** is load-bearing: if the field is stored, `rebuild` is only needed for
**R2**.

**OD-7 · which wall model?** *(contradicts `SPEC` I3; `X10` is validated)*

| | `SPEC` **I3** — boundary of a filled region | crawler `WALLS.md` — triangle-subdivision band |
|---|---|---|
| storage | `EdgeSet` — edges between in-cell and out-cell | triangles: each hex edge = **3 sub-segments** |
| thickness | none — a wall is an edge | **free**, one triangle → two hexes |
| interior walls | not expressible | *"just more wall-bands inside the footprint"* |
| 24 directions | needs the fit | *"straight + sharp + 24-direction **for free**"* |
| a door | **annotates**, never deletes (`FEATURES.md`) | *"**remove** a span of the band's triangles"* |
| status | shipping in `housedraw`, gated | validated in 2D, corner tests pass (`X10`) |

The door row is a **direct contradiction** between `design/FEATURES.md` and `WALLS.md`. It may
dissolve — deleting an *edge* fragments a run (the doored-tower defect), while deleting *band
triangles* need not, because a band is not a run — but the spec cannot hold both. This decides
rungs **A5/A7**, the `⟨side⟩` production, and whether `𝕄*` needs a thickness parameter at all.

**OD-8 · when do layers enter?**
`⟨layer⟩` is DEFERRED here. crawler `STENCILS.md`: stencils are *"multi-layer — a vertical stack
of hex planes, with ladders/stairs connecting adjacent layers… Layers are part of the model **from
the start**, not bolted on"* — with a gameplay pillar (climb tower → traverse rampart → drop into
a keep sealed at ground level; *"the route is the lock"*). By law **A₂** a deferred axis is not
free: adding one later must not re-spell existing texts, and a layer axis touches every element.
Cheaper to admit now, even unused. `X4`'s level separation is the mechanism layers would use for
arbitration.

*(Folded in rather than numbered: the grammar has no **wall thickness** and no **interior walls** —
OD-7 decides both.)*

## 11. Known conflicts in the current tree

| site | conflict | law |
|---|---|---|
| `src/housedraw.loft:299` | `place_opening` writes `OPEN_DOOR=1` / `OPEN_WINDOW=2` into the EdgeSet **surface-id** slot — the slot a recovered surface must occupy. Two channels, one integer | **D**, **E₂** |
| `src/hexroof.loft:493` | `roof_match(..., tol: float)` — a tolerance inside a recovery | **P4**; gated by OD-2 |
| `SPEC` **L4** | superseded on the assumption the flip approximates — **pending OD-5** | **G**, **H** |
| `PLAN.md` **M0** | named the work a *fit*; **D**/**E₂** admit no approximation on undamaged geometry — it is a **recovery** | **D** |
