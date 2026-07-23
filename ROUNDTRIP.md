# ROUNDTRIP — the formal model, its canonical form, and the laws

The **exact world model**, the **field** it is drawn onto, and the **bijection** between them.
Peer to [`SPEC.md`](SPEC.md): `SPEC` lists *what must be achieved*, this defines *what the objects
are and which equations hold*. On disagreement about an object, a map, or a law, **this file is
authoritative**; `SPEC` items cite it by law letter.

Notation is normative. Concrete syntax marked *illustrative* is not.

---

## 1. Objects

| symbol | set | description |
|---|---|---|
| `Λ` | `ℤ²` | the hex lattice, axial coordinates `(q,r)` |
| `𝕄` | — | **models** as authored: arbitrary real position, direction, radius |
| `𝕄*` | `⊆ 𝕄` | **fitting** models — the subset that draws injectively (§5) |
| `𝕋` | — | **canonical texts** — the written form (§4) |
| `𝔽` | — | **field** states: `⟨HexSet, EdgeSet, Heights, Labels⟩` |
| `𝔽_loc` | `⊆ 𝔽` | a **body's own** field, in its **local** frame — derived from its original, never shared |
| `𝔽_wld` | `⊆ 𝔽` | the **world** field — terrain and linework only (§1.1 B) |
| `P` | `ℝ² × S¹ × …` | a **pose**: continuous position and orientation of a body in the world |
| `O` | `⊂ P` | **orientations**: `{0..5} × {id, flip}`, `|O| = 12` — the *lattice-exact* poses |
| `H₁₂` | `≅ ℤ/12` | **headings**: the 12 directions a **stencil side** may run in, 30° apart |
| `D` | `⊂ Λ/±` | **linework directions**: reduced vectors, `gcd(|a|,|b|) = 1`, `|D| = 24` |

`H₁₂` splits into two rotation orbits of 6, with **different step lengths** — a fact the gate
already reports:

| class | `h` | lattice step | `‖step‖` | strip | observed |
|---|---|---|---|---|---|
| **edge** | even | neighbour vector | `s` | zigzag, 2 axes | `ratio 2⁄√3 = 1.15470` |
| **vertex** | odd | corner vector | `s√3` | staircase, 3 axes | `ratio 3√3⁄4 = 1.29904` |

The 6 rotations act on `H₁₂` by `h ↦ h + 2`, so the two classes **never mix**; the flip acts by
`h ↦ -h`. `O` acts on stencils, `H₁₂` indexes their sides — the coincidence `|O| = |H₁₂| = 12`
is not an identification.

Position map `π : Λ → ℝ²`, `π(q,r) = (κ(q,r)·√3⁄2, μ(q,r)⁄2)` in world units, where `κ, μ` are
`hex_field`'s integer `lattice_k` / `lattice_m`. Triangular-lattice norm on `d = (a,b)`:

```
‖d‖  =  s · √(a² + ab + b²),        s = 1 step = 1.5 m          (L8)
```

Check: `‖(1,0)‖ = ‖(1,-1)‖ = s` (edge class); `‖(1,1)‖ = s√3` (vertex class); `‖(2,1)‖ = s√7`.

### 1.1 Two domains — `O` and `D` are not interchangeable

| | **A · stencil** | **B · world linework** |
|---|---|---|
| what | house, tower, **castle** *(the large edge case)* | road, town wall, cliff |
| authored | once, in a **local frame** | **directly in world coordinates** |
| direction comes from | the stencil's own shape; placement picks `o ∈ O` | the run itself, quantised to `d ∈ D` |
| free choice of direction | **none** — sides derive from the plan; only `o` is chosen | none — `d` follows where the run goes |
| joins | — | arcs, `G¹`-continuous (`hexedge::junction_g0`) |
| gated today | `housetest`, 12/12 | — |

**`D` is never an authoring palette.** A stencil is never placed at one of 24 directions; it is
placed at one of the 12 `o ∈ O`. Conversely a road is never a stencil: it is drawn where it runs.
Forcing one grammar over both is the over-unification this document exists to prevent — the two
domains have different fitting sets, different join obligations, and different round-trip laws
(**I** for A, **F**/`Sep` for B).

### 1.2 Bodies are never stamped into the world — the pose carries them

**A robot's limb in a pose and a derailed wagon at rest are the same problem**: an exact original
at an **arbitrary continuous orientation**. A hex lattice cannot represent a body rotated 37°, and
it never has to, because a body is **not drawn into `𝔽_wld`**. It is:

```
Body  =  ⟨ original ∈ 𝕄*,  pose ∈ P,  joints ⟩          — the original is STORED, the pose is STORED
                                                          𝔽_loc = draw(original)  is DERIVED
```

The body keeps its own local field, exact and lattice-aligned in **its own** frame, and the pose
places it in the world. Nothing is ever rasterized at a non-lattice angle, so no approximation
enters — the arbitrary orientation lives in `P`, which is continuous, not in `Λ`, which is not.

| mode | pose | commensurate with `𝔽_wld`? | used for |
|---|---|---|---|
| **seated** | `o ∈ O` + `v ∈ Λ` — lattice-exact | **yes** — cells and edges align, a walker crosses the seam | a house in a town, a wagon on rails |
| **free** | any `p ∈ P` | **no** — the body is its own frame | a tumbling wagon, a robot limb, a colossus' arm |

A body **transitions** seated → free at the break (`DYNAMICS` §2, kinematic → dynamic) and free →
seated when it settles onto the lattice again. `O` is exactly the subset of `P` where the two modes
coincide, which is why the 12 are the *seating* set and not an authoring palette (§1.1).

> **Consequence for `𝔽_wld`.** The world field holds **terrain and linework only** — domain B.
> Bodies are separate objects transformed by their poses. Two bodies of different scale interact
> through their proxies and swept volumes (`I5`), never by sharing lattice cells at a free pose.

## 2. Maps

```
snap    : 𝕄  → 𝕄* × ℝ≥0          σ ≔ π₁∘snap  (projection)   ρ ≔ π₂∘snap  (residual, metres)
write   : 𝕄* → 𝕋
read    : 𝕋  → 𝕄*
draw    : 𝕄* → 𝔽_loc             a body's own field, in its own frame
rebuild : 𝔽   → 𝕄* × ℝ≥0         exact (ρ=0) on im(draw); approximate off it (§2.1.1)
place   : 𝕄* × P → world          NOT a rasterization — the pose transforms, it never stamps
flip_𝕄  : 𝕄* → 𝕄               flip_𝔽 : 𝔽 → 𝔽
τ_v     : translation by  v ∈ Λ,  acting on 𝕄* and on 𝔽
```

```
        σ                write            draw
  𝕄 ─────────▶ 𝕄* ═══════════════▶ 𝕋   ─────────▶ 𝔽
  │            ▲  ◀═══════════════      ◀─────────  │
  └── ρ (m) ──▶│         read            rebuild    │
               └───────────────────────────────────┘
```

**`snap` is the only lossy map.** Every other map is a bijection onto its image (Prop. 2, 3).

### 2.1 What is stored — the originals only

> **Store the original and its pose. Derive everything else.**

| | stored? | role |
|---|---|---|
| `𝕋` — a body's **original**, canonical | **yes** | the truth for that body, in its local frame |
| `P` — its **pose** | **yes** | where it is in the world; free of the lattice (§1.2) |
| `𝔽_loc` — its local field | **no** — `draw(original)`, on demand | what collision, render and destruction read |
| `𝔽_wld` — terrain + linework | **yes** | the world's own truth; domain B only |
| `𝕄*` | **no** — transient | the value handed between `read` and `draw` |

**Reconciliation with L3.** `ARCHITECTURE` and **L3** say *"the 2.5-D field is the stored truth."*
That holds for the **world** (`𝔽_wld`); it does **not** hold for a **body**, whose truth is its
original plus its pose. The distinction is what makes an arbitrary orientation representable at
all — a stored body-field could only ever hold the 12. **L3's real content survives intact**: one
truth per object, derived views never persisted.

**Never keep `𝕋` and a body's `𝔽_loc` both live and reconcile them.** Two persisted truths that
must agree is the failure L3 exists to prevent; here it does not arise, because `𝔽_loc` is derived.

### 2.1.1 Damage — the one place the original is lost

Destruction mutates `𝔽_loc` directly (crumble, ruin, floor-to-hill). The original no longer
describes the body, and it is **not recoverable** — a ruin is not an invertible transform of a
house. So the damaged field is **re-canonicalised to a new original, by approximation**:

```
𝔽_loc  ──mutate──▶  𝔽′  ──rebuild──▶  (m′, ρ)  ──write──▶  𝕋′        ρ > 0 is EXPECTED here
                                                                       and is reported, not hidden
```

`𝕋′` becomes the body's stored original from that moment; the pre-damage `𝕋` is history, not a
second truth. This is the **only** step in the whole model where a `ρ > 0` is legitimate — and it
is legitimate precisely because it produces a *new original* rather than pretending to recover
the old one.

> **Therefore law E splits** (§6): `rebuild` is **exact** on undamaged fields and **approximate,
> with a reported residual**, on mutated ones. An earlier draft required `rebuild` to be exactly
> total over all of `𝔽`; that was stronger than the domain warrants, and a ruin is the
> counterexample.

### 2.1.2 Frames, and the only place imprecision is allowed

Collision reads **several presentations at once**: the unmovable base world, plus every body
placed and rotated onto it. Each belongs to exactly one **frame**:

| frame | transform | geometry |
|---|---|---|
| `Φ_wld` | identity | `𝔽_wld` — terrain, linework; unmovable |
| `Φ_b` | the body's pose `p ∈ P` | `𝔽_loc` — that body's own field, exact in its own frame |

**Inside a frame, geometry is exact** — lattice-exact, `𝕄*`, round-tripping by law **D**. **Across
frames it cannot be**, because a pose is continuous and a lattice is not. Where two frames' geometry
meets, there are **cracks** — gaps, slivers, double-counted overlap. Call that set the **seam** `Σ`.

> **Law K₁ · seam containment.** Imprecision is permitted **only on `Σ`**, is bounded by `ε_seam`
> metres, and is **deterministic**. In the interior of any single frame the error is **exactly 0**.

**Enforced by construction, not by discipline.** Every cross-frame query routes through one path:

```
  world query ──[ p⁻¹ ]──▶ local query ──exact test in 𝔽_loc──▶ hit ──[ p ]──▶ world
                    └────────── the ONLY inexact step ──────────┘
```

The pose transform is the sole floating-point step and it is already the interaction chokepoint
(`I5`, ARCHITECTURE § *one chokepoint*). So `Σ` is where error lives **because that is the only
place a transform happens** — the invariant is a property of the architecture rather than a rule
anyone has to remember.

**The failure this forbids.** Closing a crack by *moving geometry* — snapping a body's wall onto
the world lattice so a gap disappears. That relocates seam error into a frame **interior**, breaks
exactness, and voids law **D** for that body. Cracks are absorbed by the **transform** or by the
**proxy**; never by the model.

**Jank is not licence for nondeterminism.** `L7` and `I9` require byte-identical replay, so the
seam error must be a *deterministic function of its inputs* — reproducible jank, not random jank.
A crack that differs between two runs of the same derailment is a defect, not an allowed
imprecision.

**Two budgets, both in metres (`L8`), and they compose:** `ε_seam` for frame crossing, and
`K-PROXY`'s overshoot bound for proxy conservatism. Because a proxy **contains** its shape (`I4`),
seam error fails *safe* — a spurious contact, never a missed one.

### 2.1.3 Contention — when frames disagree, and how many at once

The jank is reducible but never zero: the same question answered through different frames can
return **non-matching results**. Two kinds:

| kind | example | bounded by |
|---|---|---|
| **categorical** | world says *gap*, body says *solid* — a crack you fall through, or a doubled contact | arbitration (below) |
| **numerical** | a contact point computed in `Φ_a` vs in `Φ_b` differs | `ε_seam` |

**The numerical kind is removed by construction, not reconciled.** Any cross-frame quantity is
computed in **one designated frame** — single-valued because only one computation happens, rather
than agreed after the fact by two. Reconciling two computed values is the shape that goes wrong;
having only one is the shape that cannot.

**The categorical kind needs arbitration, and its cost is set by how many frames contend at once.**
Define the **contention degree** `κ(q)` — the number of frames giving conflicting answers to query
`q`:

| `κ` | regime | requirement |
|---|---|---|
| `≤ 1` | no contention | **exact** — the single frame's answer, no error |
| `= 2` | **the designed-for case** | **deterministic pairwise arbitration** over a total order on frames |
| `≥ 3` | rare | must still be **total, deterministic and conservative** — need not be optimal — and **counted** |

Two requirements fall straight out, and both are easy to omit silently:

- **A total order on frames**, or arbitration is not deterministic and `L7`/`I9` fail. "Whichever
  is nearer" needs a tie-break that is a function of identity, not of iteration order.
- **A fail-safe direction**: on conflict prefer **solid** over **gap**. Combined with `I4`
  (a proxy contains its shape), a crack then yields a spurious contact rather than a body falling
  through the world.

> **`κ ≥ 3` is a counter, not an assumption.** *"The chance of more than two at once is low"* is a
> falsifiable claim, so it is **measured** — a histogram of `κ`, with the `κ ≥ 3` rate reported.
> An assumed-rare case that silently becomes common is how a seam budget quietly stops holding.

**Where to measure it, honestly.** `κ` rises with query volume: a **point** query rarely finds 3
frames meeting at once, but a **swept volume** straddles frames far more easily. And the scenario
that maximises `κ` is **`G★` itself** — a pile of tumbled wagons resting on each other on terrain
is many overlapping frames at once. The hero demo is the worst case for contention, not a mild
one, so the histogram belongs in that scene rather than in a two-body fixture.

### 2.2 Scope — what this model does not cover

**In scope:** a body's **original** (`𝕄*`/`𝕋`), its **pose** `P` as a stored representation (§1.2),
world terrain and linework, and the maps between them.

| out of scope | why | owner |
|---|---|---|
| how a pose **evolves** — integration, contacts, settling | this model defines the *representation* of orientation, never its dynamics | `DYNAMICS`, `L1`/`L2` |
| **joint values** and the part-tree | `Body = ⟨original, pose, joints⟩`; the joint value is its own interface, and only `original` round-trips | `K-JOINT` |
| the **collision proxy** | derived, never stored. *But:* with an exact `𝕄*` the proxy is better derived from the **model** than from the rasterization — analytic, with a closed-form error bound instead of a measured one. That refines `ARCHITECTURE`'s *"derived from the field"* and is a consequence of this contract, not a contradiction of it | `K-PROXY` |
| **authored motion tracks** | the consumer's, by construction | `L5` |
| **set-dressing kit pieces / props** | likely authored meshes, hence outside `𝕄*` — the boundary must be drawn before the editor is built on top (VISION § *frontier*) | **OPEN** |
| the **patch-atlas** overlay | derived on demand, never persisted — therefore never in `𝕋` | `L3` |

## 3. Grammar of `𝕄*`

```ebnf
⟨model⟩    ::= { ⟨stencil⟩ | ⟨place⟩ | ⟨line⟩ | ⟨join⟩ }

(* ── A · stencil: a CLOSED turtle polygon in a LOCAL frame, headings from H₁₂ ──── *)
⟨stencil⟩  ::= "stencil" ⟨name⟩ "h0" ⟨h0⟩ { ⟨element⟩ }
⟨element⟩  ::= ⟨side⟩ | ⟨arc⟩ | ⟨feature⟩ | ⟨roof⟩ | ⟨layer⟩
⟨side⟩     ::= "side" ⟨nat⟩ "len" ⟨nat⟩ "turn" ⟨turn⟩
⟨h0⟩       ::= ⟨nat⟩                                (* initial heading h ∈ H₁₂ = ℤ/12 *)
⟨turn⟩     ::= ⟨int⟩                                (* Δh ∈ -5..6, in twelfths of a revolution *)
⟨arc⟩      ::= "arc"  ⟨nat⟩ "ctr" ⟨point⟩ "rad" ⟨nat⟩ "from" ⟨rat⟩ "to" ⟨rat⟩
⟨feature⟩  ::= ⟨kind⟩ "side" ⟨nat⟩ "t" ⟨rat⟩ "w" ⟨nat⟩ [ "sill" ⟨nat⟩ "head" ⟨nat⟩ ]
⟨place⟩    ::= "place" ⟨name⟩ "at" ⟨point⟩ "orient" ⟨orient⟩
⟨orient⟩   ::= ⟨rot⟩ [ "flip" ]                     (* o ∈ O — the ONLY choice a placement makes *)
⟨rot⟩      ::= "0" | "1" | "2" | "3" | "4" | "5"

(* ── B · world linework: drawn in WORLD coordinates, direction follows the run ─── *)
⟨line⟩     ::= "line" ⟨lkind⟩ ⟨nat⟩ "from" ⟨point⟩ "dir" ⟨dir⟩ "len" ⟨nat⟩
⟨join⟩     ::= "join" ⟨nat⟩ ⟨nat⟩ "rad" ⟨nat⟩       (* G¹ arc joining two ⟨line⟩s *)
⟨lkind⟩    ::= "road" | "wall" | "cliff"

(* ── shared terminals ─────────────────────────────────────────────────────────── *)
⟨point⟩    ::= ⟨int⟩ "," ⟨int⟩                      (* lattice, or half-integer at edge midpoints *)
⟨dir⟩      ::= ⟨int⟩ "," ⟨int⟩                      (* reduced; ∈ D — reachable ONLY from ⟨line⟩ *)
⟨rat⟩      ::= ⟨int⟩ "/" ⟨nat⟩                      (* reduced; never a decimal *)
⟨int⟩,⟨nat⟩ ::= decimal integer
⟨name⟩,⟨kind⟩,⟨layer⟩ ::= DEFERRED                  (* §8 constants must land before these freeze *)
⟨roof⟩     ::= OPEN DECISION                        (* domain C — height recovery; see §11.1 *)
```

> **`⟨dir⟩` is unreachable from `⟨stencil⟩`.** A stencil's side directions are determined by its
> plan; its placement selects `o ∈ O` and nothing else. The grammar makes "a stencil at one of 24
> directions" **unparseable**, which is the correction §1.1 states, enforced rather than asserted.

> **There is no `⟨float⟩` production.** Therefore §5's syntactic criterion is enforced **by the
> parser**, not by a downstream check: a non-fitting model is *unparseable*, not merely invalid.

| quantity | stored as | never stored as |
|---|---|---|
| position | `(q,r) ∈ Λ`, half-integer at edge midpoints | metres |
| direction — **A** | `h ∈ H₁₂`, reached only via `h0` + running `Σ turn` | degrees, or a `⟨dir⟩` |
| direction — **B** | reduced `d ∈ D` | degrees |
| length | **step count** `n ∈ ℕ` along `e(h)` (A) or `d` (B) | metres |
| radius, sill, head, height | step count | metres |
| parameter along a side | reduced `⟨rat⟩` | decimal |

Metres and degrees are **derived for display** via `‖·‖` and `s = 1.5 m`. Lattice lengths are
irrational (`‖(2,1)‖ = 1.5√7 m`), so storing metres would forfeit exactness — which is the whole
foundation. Observed in `housetest` gate 7: `run 8.66 m` vs `wall 7.50 m`, `ratio = 2⁄√3`.

## 4. Canonical text `𝕋`

Normative rules — a model has **exactly one** spelling:

1. **C1 integers only** — every numeric token is `⟨int⟩`, `⟨nat⟩` or reduced `⟨rat⟩` (§3).
2. **C2 fixed order** — elements sorted by `(kind, index, t)`; fields in declaration order.
   **`kind` orders by a fixed registry position, never alphabetically** — new kinds are *appended*,
   so adding one never interleaves and never re-spells an existing text (§4.1).
3. **C3 reduced forms** — `⟨dir⟩` and `⟨rat⟩` in lowest terms; `⟨dir⟩` in the canonical sign
   representative of `Λ/±`.
4. **C4 fixed layout** — single space separators, one element per line, no trailing space.
5. **C5 defaults are omitted** — an optional field is written **only when it differs from its
   default**, and the default must reproduce the pre-existing behaviour exactly. So adding a
   parameter leaves every existing text byte-identical (§4.1).

*Illustrative* (rules C1–C4 are normative; the token spellings are not):

```
stencil house1  h0 0
side  0  len 4  turn 3
side  1  len 5  turn 3
side  2  len 4  turn 3
side  3  len 5  turn 3
door  side 3  t 1/2  w 1
win   side 3  t 1/5  w 1  sill 2  head 5
roof  ridge  eave 2
place house1  at 3,-2  orient 4 flip

line  road 0  from 0,0    dir 2,1  len 40
line  road 1  from 31,18  dir 1,1  len 25
join  0 1  rad 6
```

Law **J** on this stencil: `Σ turn = 3+3+3+3 = 12` ✓, and `4·e(0) + 5·e(3) + 4·e(6) + 5·e(9) =
(0,0)` ✓ since `e(h+6) = -e(h)`. Note what the stencil block does **not** contain: any `⟨dir⟩`.
`place` carries `orient 4 flip` (`o ∈ O`); only `line` carries `dir 2,1` (`d ∈ D`).

**Consequence:** equality on `𝕋` is **byte equality**. No tolerance parameter exists anywhere in
the round-trip gate, because there is no float to compare (Prop. 4).

### 4.1 Growing the language — new verbs and parameters, without breaking the old ones

This is **infrastructure, built out like a programming language**: `⟨tower⟩`, `⟨bridge⟩`, `⟨prop⟩`
and new parameters on existing verbs get added over years. A language stays usable only if adding
a keyword never changes the meaning of a program already written. Same contract here:

> **Law A₂ · monotone extension.** For grammar versions `n → n+1` with `𝕋ₙ ⊆ 𝕋ₙ₊₁`, every existing
> `T ∈ 𝕋ₙ` satisfies
> `readₙ₊₁(T) = readₙ(T)` · `drawₙ₊₁(…) = drawₙ(…)` · **`writeₙ₊₁(readₙ₊₁(T)) = T`**
> — same model, same field, and **the same bytes**.

The third clause is the one that bites, and it is why **C2** and **C5** are worded as they are:

| adding | the trap | the rule that prevents it |
|---|---|---|
| a **verb** (`⟨tower⟩`) | sorting `kind` alphabetically makes `tower` interleave, renumbering and **re-spelling every existing text** | **C2** — registry order, new kinds appended |
| a **parameter** (`⟨feature⟩ … "bevel" ⟨nat⟩`) | writing it always adds a token to every existing element | **C5** — omitted at default; the default reproduces old behaviour |

A re-spelling is not a cosmetic problem: `𝕋` **is** the stored truth for a body (§2.1), so
re-spelling every text at once invalidates every stored original and every fixture in one commit.

**`𝕄*` grows; it must never shrink.** A new verb may *admit* more; it must never *un-admit*
something already authorable — that would break content already made, and there is no migration
for geometry someone hand-placed.

> **Therefore the census window matters.** Restrictions can be added to `fits?` **freely while
> phase A is running and nothing has been authored against it**. Once texts exist in the wild,
> tightening `fits?` is a **breaking change**. Run the whole ladder before the editor ships
> content — the alternative is discovering rung A8's combination limits after people have built
> with the tool.

**Enforced by the gates being enumeration-driven** (§9): a new verb without `write`/`draw`/
`rebuild` coverage fails `rt_trip` rather than going silently ungated — the language equivalent of
not being able to add a keyword without a test.

## 5. `fits?` — two layers, both decidable, both forward

```
fits?(m)  ⟺  syn(m) ∧ sem(m)
```

| layer | statement | decided by |
|---|---|---|
| **syn** | `m` is derivable from the §3 grammar | the parser (total, exact) |
| **sem·A** | *(stencil)* the boundary **cycle** is closed (law **J**) and **unique** among admitted stencils | the **stencil census** — exhaustive |
| **sem·B** | *(linework)* every run of direction `d`, length `n` satisfies `n ≥ period(d)` | `period`, §8 |
| **sem·C** | *(arcs, joins)* `(rad, span) ∈ Sep`, and every `⟨join⟩` is `G¹` at both ends | `Sep` · `junction_g0` |

### 5.1 The two recovery mechanisms are different, and must stay different

|  | **A · stencil** | **B · linework** |
|---|---|---|
| matched object | the **whole closed boundary cycle** | an **open run** |
| direction set | `H₁₂` — finite, small | `D` — 24 |
| span length | **short spans permitted** | long by nature |
| recovery | **exact match against the enumerated cycle set** | period-based direction recovery |
| injectivity proved by | **exhaustive enumeration** at each level, up to the discovered frontier (§8.1) | `n ≥ period(d)` bound |
| failure mode | two distinct stencils sharing one boundary cycle | a run too short to fix its direction |

**Why stencils need no length bound.** An isolated 1-step span cannot fix its heading: one hex edge
lies on one of **3 axes**, which cannot distinguish **12** headings. But a stencil side is never
isolated — by **I3** a wall is the boundary of a *filled region*, so the matched object is the
closed cycle, and the corners carry the turn sequence that disambiguates the short sides. Recovery
reads `(len, turn)*` off the cycle, not a heading off a span.

> **Therefore `sem·A` is a uniqueness claim, not a threshold**, and it is settled by **exhaustive
> enumeration**, not by a bound. With `|H₁₂| = 12` and bounded side counts and lengths, the
> admitted stencil space is finite and can be enumerated **completely** — so law **F** is *proved*
> for domain A, not sampled. That is the "precise matching" this domain requires, and it is
> strictly stronger than anything available to domain B.

**Lemma (orientation invariance).** For `o ∈ O` acting as a lattice automorphism,
`σ_strip(o·ℓ) = o·σ_strip(ℓ)`, so the census result transfers across all of `O`. This holds for
the **6 rotations unconditionally**; for the **flip only if the flip is exact**. The flip is stated
to mutate by approximation (§6 **G**, **H**), so transfer across the flipped half of `O` is **not**
free — it is what `rt_drift` measures. Should it fail, the census must be run over all 12 of `O`
rather than over 6 and transferred.

### 5.2 The limit sits at the doorstep

**The bounds are not the problem.** There is a great deal of room inside them, and a restriction
found by the census (§8.1) is a **fact to record**, not a defect to engineer away. What matters is
not how large `𝕄*` is, but that **nothing outside it ever gets in.**

> **The editor refuses at authoring time.** Not a warning, not a later validation pass, not a
> failure at `rebuild`. If a thing cannot survive, it cannot be made.

```
                 authorable  ⊆  { m : fits?(m) }                             (K-FIT)
```

**Why the door and not a downstream check.** Deferred breakage separates the symptom from its
cause: a building authored on Monday looks correct, round-trips correctly, and breaks after a
flip, or when combined with its neighbour, or after it takes damage. By then nothing on screen
points at the authoring choice that caused it. A refusal at the door costs one dialogue; the same
limit discovered three steps later costs a debugging session and a corrupted save.

**"Eventually broken" is the operative word — hence law C₂.** It is not enough that `m`
round-trips *today*. `𝕄*` must be **closed under everything that will later be done to it**:

| `op ∈ Ops` | the deferred break it would otherwise cause |
|---|---|
| `flip` | authored fine, wrong after a mirrored placement (laws **G**, **H**) |
| `place` | fine in the local frame, wrong once seated on the world lattice |
| `combine` | fine alone, broken beside its neighbour — rung **A8**, the least visible axis |
| `damage` | fine intact, un-re-canonicalisable as a ruin (**E₃**) |
| `seat` | fine on flat ground, unseatable on the real terrain (`K-SEAT`) |

If `m` fits but `flip(m)` does not, **`m` is refused** — because the flip *will* happen. Admitting
it would be trading a certain later failure for a momentary convenience.

**There are exactly two doors into `𝕄*`**, and both are guarded: the **editor** (guarded by
`fits?`) and **`rebuild`** (which lands in `𝕄*` by law **E₁**, by construction). Nothing else
constructs a model. That is what makes the guarantee enforceable rather than aspirational.

**What a refusal looks like.** Refuse, **name the restriction**, and offer the nearest fitting
alternative with its residual `ρ` — the `K-SEAT` shape, `(z₀, T′, residual)`. Never silently snap
(that hides the limit and the author never learns it), never reject blankly (that hides the
reason). A limit the author can see is a limit they can design within.

## 6. Laws

Let `m` range over `𝕄*`, `f` over `𝔽`, `T` over `𝕋`, `v` over `Λ`.

| # | law | statement |
|---|---|---|
| **A₁** | canonicity | `∀m. read(write(m)) = m`  ∧  `∀T. write(read(T)) = T` |
| **A₂** | monotone extension | `𝕋ₙ ⊆ 𝕋ₙ₊₁`, and `∀T ∈ 𝕋ₙ`: `readₙ₊₁(T) = readₙ(T)`, `drawₙ₊₁ = drawₙ`, `writeₙ₊₁(readₙ₊₁(T)) = T`. A new verb or parameter never re-spells an existing text; `𝕄*` grows, never shrinks (§4.1) |
| **B** | projection | `∀m ∈ 𝕄. σ(σ(m)) = σ(m)`  ∧  `ρ(σ(m)) = 0` |
| **C₁** | fitting = fixed point | `∀m ∈ 𝕄. m ∈ 𝕄* ⟺ σ(m) = m` |
| **C₂** | closure under operations | `∀m ∈ 𝕄*, ∀op ∈ Ops. op(m) ∈ 𝕄*` — where `Ops = {flip, place, combine, damage, seat}`. What is admitted must survive **everything that will later be done to it** (§5.2) |
| **D** | round trip | `∀m. rebuild(draw(m)) = m`   ⟺   `draw ∘ rebuild ∘ draw = draw` |
| **E₁** | totality | `∀f ∈ 𝔽. rebuild(f) ∈ 𝕄*` — `rebuild` is **total**; it never fails, never returns a non-fitting model |
| **E₂** | exactness on undamaged fields | `∀f ∈ im(draw). rebuild ∘ draw ∘ rebuild = rebuild`, with `ρ = 0` |
| **E₃** | approximation on damaged fields | `∀f ∉ im(draw)`: `rebuild(f) = (m′, ρ)` with `ρ` **reported**; `m′ ∈ 𝕄*` and `σ(m′) = m′`. `ρ > 0` is expected (§2.1.1) |
| **F** | injectivity | `∀m₁,m₂. draw(m₁) = draw(m₂) ⟹ m₁ = m₂` |
| **G** | flip commutation | `∀m. rebuild(flip_𝔽(draw(m))) = σ(flip_𝕄(m))` |
| **H** | flip stability | `φ ≔ σ ∘ flip_𝕄`.  `∀m, ∀n ∈ ℕ. φ²ⁿ(m) = m` |
| **I** | `O`-equivariance | `∀m, o ∈ O, v ∈ Λ. draw(τ_v ∘ o · m) = τ_v ∘ o · draw(m)` |
| **J** | stencil closure | `∀` stencil: `Σᵢ lenᵢ · e(hᵢ) = (0,0) ∈ Λ`  ∧  `Σᵢ turnᵢ = 12`, where `hᵢ = h₀ + Σ_{j<i} turnⱼ ∈ H₁₂` |
| **K₁** | seam containment | error `= 0` in any frame interior; error `≤ ε_seam` and **deterministic** on the seam `Σ` (§2.1.2) |
| **K₂** | seam arbitration | exact for `κ ≤ 1`; **deterministic** pairwise arbitration at `κ = 2` over a total order on frames; total, deterministic, **conservative and counted** for `κ ≥ 3` (§2.1.3) |

*Naming.* Laws are always written **law A₁**…**law K₂**; `SPEC` items always carry a suffix (`I3`,
`L8`, `K-PROXY`). The two namespaces do not collide.

**D and E₂ are the Moore–Penrose pair.** On `im(draw)` — undamaged geometry — `draw` and `rebuild`
are mutual pseudo-inverses; that pair is the exact core of the contract, and A–C, F–J are its
preconditions, extensions and measurements.

**E₁ is quantified over *all* `f`**, including field states no `draw` produced: destruction (`M5`)
mutates `EdgeSet`/`Heights` directly, so `rebuild` must never fail and never assume provenance.
**E₃ is what keeps that honest** — outside `im(draw)` the result is an *approximation with a
reported residual*, not a recovery. Demanding exactness there would be over-reach: a ruin is not
an invertible transform of a house, and no amount of care makes it one.

## 7. Derived propositions

| | proposition | from |
|---|---|---|
| **P1** | `𝕄* = im(σ) = im(rebuild)` — the fitting set need not be axiomatised; it *is* the image | B, C₁, E₁ |
| **P2** | `draw│𝕄*` is injective (law F) | D |
| **P3** | `write(rebuild(draw(read(T)))) = T` — **the round-trip gate is a text `diff`** | A₁, D |
| **P4** | round-trip equality is byte equality; no `ε` exists in the gate | C1, P3 |
| **P5** | `σ│𝕄* = id` — re-snapping an authored model is a no-op; the editor cannot jitter under repeated edit | B, C₁ |
| **P6** | `write, read` are mutually inverse bijections `𝕄* ≅ 𝕋` | A₁ |

*Proof of P2.* `draw(m₁) = draw(m₂)` ⟹ `m₁ = rebuild(draw(m₁)) = rebuild(draw(m₂)) = m₂`. ∎
*Proof of P3.* `read(T) = m ∈ 𝕄*` (P6); `rebuild(draw(m)) = m` (D); `write(m) = T` (A₁). ∎

> **An `ε` appearing in a round-trip comparison is a defect signal, never a tuning knob**: by P4 it
> can only mean `𝕄*` was drawn wider than `draw` is injective on — i.e. law F is false and `𝕄*`
> must shrink.

## 8. Open constants — measured, not defined

| constant | domain | signature | produced by | status |
|---|---|---|---|---|
| `Cyc` | **A** | the admitted boundary cycles **up to the discovered frontier**, and the first form that fails | the **stencil census** — grown by level (§8.1) | **OPEN** |
| `period` | **B** | `D → ℕ` — least `p` with `σ_strip(ℓ_d)` invariant under `τ_{p·d}` | the **linework census** | **OPEN** |
| `Sep` | **B** | `⊆ ℕ × ℚ` — `(rad, span)` where an arc strip differs from every line strip | the arc sweep | **OPEN** |
| `D` | **B** | which 24 reduced vectors are admitted | follows from `period` | **OPEN** |
| `ε_seam` | **frames** | the crack budget at a frame crossing, **in metres** (`L8`) | measured at the chokepoint | **OPEN** |
| `κ≥3` rate | **frames** | the fraction of queries with 3+ contending frames, measured in the `G★` pile | `rt_contend` histogram | **OPEN** — asserted low, not yet measured |

**A · the stencil census is a proof obligation, not a measurement** — but see §8.1: it is run as a
**search for the frontier**, not as a verdict over a presupposed space. At each level the
enumeration is exhaustive, so within the frontier law **F** is *decided*, not estimated. A
collision is not a defect to eliminate; it is the **boundary of `𝕄*` being located.**

**B · the linework census is a measurement.** Runs are long by nature, so `period(d)` is a
threshold that is expected to be satisfiable; the census produces the table and the minimum length
in metres that `L8` requires.

### 8.1 How the constants are found — grow, don't presuppose

**Do not define the admitted space and then enumerate it.** That presupposes the bounds, and the
bounds *are* the answer. The restrictions are not known in advance; **they are the output.**

Instead, grow — smallest forms first, combine, and let the first failure locate the boundary:

```
  level n:  enumerate EXHAUSTIVELY at this level  ──▶ round-trip each  ──▶ all pass?
                          ▲                                                │  yes → n+1
                          └────────────────────────────────────────────────┘
                                                                           │  no
                                    the failing pair IS a restriction ─────┘
                                    record it in fits?, then continue
```

**Two growth axes, and the second is where the discoveries are:**

| axis | ladder |
|---|---|
| **form** — one object, more complex | minimal closed cycle → longer sides → more sides → unequal sides → non-convex (reflex turns) → features → arcs |
| **combination** — objects together | two stencils adjacent (a shared boundary: which owns the edge?) · stencil against linework · stencil on terrain |

Things that round-trip alone routinely stop round-tripping **combined** — that is the axis no
single-object enumeration can see, and it is the reason the ladder does not stop at "one complex
stencil works."

**The smallest form is concrete.** By law **J** a stencil needs `Σ turn = 12` and a closing vector
sum, so the minimum is **3 sides**: an equilateral triangle, `turn 4` at each corner. It closes
exactly because three lattice vectors 120° apart sum to zero — e.g. `(1,0) + (-1,1) + (0,-1) =
(0,0)`. `len 1` at each heading class is level 1.

**What this changes about the gate.** `rt_census_a` is not pass/fail over an assumed space; it
**reports the frontier** — the largest level that round-trips, and the exact form that first
fails. Both outcomes are results. And because every level is a complete, gated increment, the
work always has something green rather than one long red run to a single verdict.

> **Dissolved.** An earlier draft asked whether house walls could carry the fine directions, given
> sides of 4–5 steps. They cannot and need not: houses are `H₁₂` with **short spans permitted**,
> recovered by exhaustive cycle matching (§5.1); the 24 directions belong to world linework, which
> is long. The two domains never had the same question.

## 9. Gates — one per law, each with a control that must fire

| gate | law | domain | test | control |
|---|---|---|---|---|
| `rt_canon` | A₁ | — | text diff | reorder a field (violate C2) → diff |
| **`rt_extend`** | **A₂** | — | replay every prior fixture against the current grammar; bytes must be **identical** | sort `kind` alphabetically instead of by registry → every text with a later-added verb re-spells |
| `rt_project` | B | — | equality + `ρ = 0` | perturb by ½ step → `ρ ≠ 0` |
| `rt_fits` | C₁ | — | `fits?` vs `σ(m) = m` | **A:** a cycle in the collision set → `fits?` false · **B:** `n < period(d)` → `fits?` false |
| **`rt_closure`** | **C₂** | both | `∀m ∈ 𝕄*, ∀op ∈ Ops. fits?(op(m))` — over the census output | admit a form whose `flip` leaves `𝕄*` → fires at the door, not after the flip |
| `rt_door` | C₂ | — | every editor authoring op yields `fits?`; a refusal names its restriction and offers `(m′, ρ)` | let the editor emit a non-fitting model → `rt_trip` breaks downstream instead |
| **`rt_trip`** | **D** | both | **`write(rebuild(draw(read(T)))) ≟ T`** | a non-fitting model bypassing `σ` → diff |
| `rt_total` | E₁ | both | `σ(rebuild(f)) = rebuild(f)` for arbitrary `f` | hand-corrupt an `EdgeSet` → still lands in `𝕄*`, never fails |
| `rt_ruin` | E₂,E₃ | A | `ρ = 0` on `im(draw)`; `ρ` **reported** off it | crumble a wall → `ρ > 0` and is surfaced, not swallowed |
| **`rt_census_a`** | **F** | **A** | grow by level (§8.1), exhaustive at each; **reports the frontier** — largest level that round-trips, and the first form that fails | remove a corner's turn from the match key → collisions appear at level 1 |
| `rt_census_b` | F | B | count colliding strips over `D × ℕ`; emit `period` | shorten below `period(d)` → collision |
| `rt_close` | J | A | `Σ lenᵢ·e(hᵢ) = 0` ∧ `Σ turnᵢ = 12` | drop one turn → non-zero sum |
| **`rt_seam`** | **K₁** | both | error `≡ 0` sampled in frame interiors; `≤ ε_seam` on `Σ`; replay byte-identical | "fix" a crack by snapping a body wall to the world lattice → interior error ≠ 0 |
| **`rt_contend`** | **K₂** | both | `κ` histogram over the `G★` pile; `κ≥3` rate reported; arbitration byte-identical on replay | tie-break on iteration order instead of frame identity → replay diverges |
| `rt_flip` | G | both | text diff | asymmetric feature → diff |
| `rt_drift` | H | both | text diff after `φ¹²` | inject a rounding step → drift |
| `rt_orient` | I | A | field equality over `O × Λ` | — **GREEN**: `housetest` gate 2, 12/12, mismatched 0 |

**`rt_trip` is the spine.** It must be **enumeration-driven** over primitive kinds — a new primitive
(tower, curve, layer) without `write`/`draw`/`rebuild` coverage fails the gate rather than going
silently ungated. A hand-written case list re-introduces the `N > 1` silent-omission failure that
laws D and E exist to remove.

## 10. Relation to `SPEC.md`

| `SPEC` item | resolution |
|---|---|
| **I-RT** *(new)* | law **D** — `rebuild(draw(m)) = m`; control per `rt_trip` |
| **I-TOTAL** *(new)* | laws **E₁**/**E₂**/**E₃** — `rebuild` never fails; exact on undamaged fields, approximate-with-residual on damaged ones |
| **I-POSE** *(new)* | §1.2 — a body is `⟨original, pose, joints⟩`; the original and pose are stored, the local field is derived, and a body is **never** stamped into `𝔽_wld` |
| **L3** | **scoped, not weakened.** "The field is the stored truth" holds for the **world**; a **body**'s truth is its original plus its pose (§2.1). One truth per object either way |
| **I-FLIP** *(new)* | laws **G**, **H** |
| **I-EXACT** *(new)* | P4 — no `ε` in a round-trip comparison |
| **K-FIT** *(new)* | §5 — one `fits?`/`snap` chokepoint; `authorable ⊆ fits?` |
| **I-CLOSE** *(new)* | law **J** — a stencil boundary is a closed turtle cycle over `H₁₂`, exact in `ℤ²` |
| **I-DOMAIN** *(new)* | §1.1 — `O` (place a stencil), `H₁₂` (a stencil's sides), `D` (world linework) are three distinct sets; no production crosses them |
| **L4** | **superseded.** L4 forbids the mirror outright; the flip exists (`stencil_mirror`, `housetest`'s 12 = 6 × 2) and is governed by **G** and **H** instead |
| **L7** | **served by P4.** L7 requires byte-identical results from identical input. Byte-equality on `𝕋` (P4) is a *cheaper and earlier* determinism instrument than replaying a simulation: a representation that cannot be spelled two ways cannot drift. Determinism is checkable from the first gate, not only at `M6` |
| **L8** | `s = 1.5 m` is retained as a **display** constant only (§3) |
| **I8**, **G2** | unchanged; both are forward-direction claims about rendering |
| **I1** | strengthened — a feature is a `⟨rat⟩` interval in `𝕋` (§3), so affine-invariance is syntactic |

## 11. Open decisions and known conflicts

### 11.1 Open decisions — these change what the model *is*, and block the grammar freeze

**OD-1 · the morph — dead, or moved into `snap`?**
[`design/EDITOR.md`](design/EDITOR.md) §2 makes orientation a *minimal affine morph*, explicitly
*"the bridge from 6 exact rotations to **many**."* This model admits exactly `|O| = 12`.

They are incompatible at the level of law **D**, not merely in count: a morph is a **non-lattice
affine map**, so a morphed wall lands off-lattice, outside `𝕄*`, and no exact round trip exists
for it. EDITOR §2 names the second break itself — *"a general two-axis morph turns a circular arc
into an ellipse"* — which `⟨arc⟩` (one integer `rad`) cannot express.

**§1.2 narrows this sharply.** EDITOR §2's morph exists to answer *"how do I get a building to a
non-lattice angle and keep it lattice-exact?"* — a question that only arises if the building must
be **stamped into `𝔽_wld`**. Under the free-pose model it need not be: a building at 37° is simply
a body at a **free pose**, exact in its own frame, no morph and no residual. The morph is therefore
needed **only** for a **seated** body — one that must share lattice cells with the world.

| option | consequence |
|---|---|
| **(c)** morph is **unnecessary** *(new, and now the cheapest)* | a non-12 building is free-posed. The open question shrinks to: **does a seated building ever need an angle outside the 12?** It does only if a walker must cross street↔interior on shared cells at that angle |
| **(a)** morph is superseded — seated buildings are the 12, full stop | EDITOR §2 is deleted; free poses cover the rest |
| **(b)** morph moves **into `snap`** — a lossy seating convenience with residual `ρ`, never a stored form | EDITOR §2 survives for *seated* bodies only; `𝕄*` and law **D** untouched; the morph's bound becomes `ρ`'s bound |

**OD-2 · are roofs inside the exact round trip?**
Heights is neither domain A nor B: a roof is a **continuous surface sampled into a height field**
(`hexroof`: cone, ridge, vault, hip, dome, groin, cloister), and recovering it is a **third
mechanism — domain C**. The tree already implements it *with a tolerance*:

```loft
pub fn roof_match(s: HexSet, f: Heights, tol: float) -> RoofFit    // src/hexroof.loft:493
```

A `tol: float` in a recovery function is exactly the `ε` that **P4** forbids.

| option | consequence |
|---|---|
| **(a)** roofs are **excluded** from the exact round trip | `𝕋` carries the roof *parameters*, and `Heights` is a derived render product never recovered — law **D** applies to the plan, not the roof |
| **(b)** roofs are **included** — domain C with exact recovery | `roof_match`'s `tol` is replaced; every roof profile needs an exact inverse, and `Sep`-style separation constants for each |

### 11.2 Known conflicts in the current tree

| site | conflict | law |
|---|---|---|
| `src/housedraw.loft:299` | `place_opening` writes `OPEN_DOOR=1` / `OPEN_WINDOW=2` into the EdgeSet **surface-id** slot — the slot a recovered surface must occupy. Two channels, one integer | **D**, **E₂** — `rebuild` cannot invert a slot carrying two meanings |
| `src/hexroof.loft:493` | `roof_match(..., tol: float)` — a tolerance inside a recovery | **P4**; gated by **OD-2** |
| `SPEC.md` **L4** | ~~forbids the mirror the gate exercises~~ — **RESOLVED**: L4 superseded, flip governed by **G**/**H** | **G**, **H** |
| `PLAN.md` **M0** | names the work a *fit*; laws **D**/**E₂** admit no approximation on undamaged geometry — it is a **recovery** | **D** |
| `PLAN.md` critical path | sequenced for **G★ the derailment**, which needs **E₁**/**E₃** (ruins) and §1.2 (free poses), not the exact core. This contract's exact half serves VISION's **indie path** — the editor authors `𝕋` and re-canonicalises after in-world edits | — |

## 12. Build order

```
 A ─ stencil census (exhaustive) ──▶ Cyc, collisions = 0 ──┐
                                                           ├─▶ §3 grammar frozen ──▶ write / read
 B ─ linework census ──▶ period, D, Sep ───────────────────┘             │
                                                                         ▼
                                            rt_canon · rt_project · rt_fits · rt_close
                                                                         │
                                                 rt_trip (empty, red) ◀──┘
                                                          │
                              rebuild ──▶ rt_trip GREEN ──▶ rt_total · rt_flip · rt_drift
```

**A precedes B.** Domain A is what exists today (`housedraw` / `housetest`, gate `rt_orient`
already green) and its census is a *decidable proof obligation* over a finite space — so it either
closes completely or names the exact colliding pair. Domain B has no code yet and its census is a
measurement. Freezing the grammar needs both, but A is where the current tree is falsifiable.

`rt_trip` is written **before** `rebuild` exists: it needs no ground truth (P3), only `write`,
`read`, `draw`, `rebuild` and `diff`. It goes green when `rebuild` becomes correct.
