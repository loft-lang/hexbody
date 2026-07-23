# DESIGN — M0 round trip: what we are building, testing and deciding

The **in-flight** half. [`ROUNDTRIP.md`](../../ROUNDTRIP.md) holds only what is settled —
definitions, the propositions that provably follow, and the constraints `X1`–`X31`
**with their trust tier** (§7: T1 holds `X1`, `X2`, `X19`–`X22`, `X24`–`X31`). **Everything here is a proposal, a hypothesis or
an open question**, and none of it should be cited as fact.

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
| **I** | `O`-equivariance | `draw(τ_v ∘ o · m) = τ_v ∘ o · draw(m)` | **GREEN** (`tests/house.loft`) |
| **J** | stencil closure | `Σᵢ lenᵢ·e(hᵢ) = (0,0)` ∧ `Σᵢ turnᵢ = 12` | proposed — **pending OD-6/OD-7** |
| **K₁** | seam containment | error `= 0` in a frame interior; `≤ ε_seam` and deterministic on the seam (§6) | proposed |
| **K₂** | seam arbitration | exact at `κ ≤ 1`; deterministic pairwise at `κ = 2`; conservative + counted at `κ ≥ 3` (§6) | proposed — `X4` is **stronger** |

## 2. Proposed grammar of `𝕄*`

**Now bounded by the foxel schema** (`ROUNDTRIP` §2.4): every production below must draw into
`layer* × point → (height, material, wall1..3, item)` exactly, or it is not admissible. OD-6 and
OD-7 are closed; what remains proposed is the *description* layer, not the storage.

```ebnf
⟨model⟩    ::= { ⟨layer⟩ | ⟨stencil⟩ | ⟨place⟩ | ⟨line⟩ | ⟨join⟩ }
⟨layer⟩    ::= "layer" ⟨nat⟩ { ⟨element⟩ }   (* layer* is the OUTERMOST structure — OD-8 closed *)

(* A · stencil, in a LOCAL frame.  TWO shape primitives — see §10.4, they are different
   families and neither subsumes the other. *)
⟨stencil⟩  ::= "stencil" ⟨name⟩ { ⟨element⟩ }
⟨element⟩  ::= ⟨plan⟩ | ⟨form⟩ | ⟨arc⟩ | ⟨feature⟩ | ⟨roof⟩ | ⟨layer⟩

(* rectangular massing — the house.  Continuous, rasterised centre-in-region; both axes in
   units of s.  A union of these gives L-shapes and wings. *)
⟨plan⟩     ::= "plan" ⟨nat⟩ "at" ⟨point⟩ "wid" ⟨nat⟩ "dep" ⟨nat⟩

(* lattice-native polygon — the hexagonal tower.  A closed turtle cycle, law J. *)
⟨form⟩     ::= "form" ⟨nat⟩ "h0" ⟨h0⟩ { ⟨side⟩ }
⟨side⟩     ::= "side" ⟨nat⟩ "len" ⟨nat⟩ "turn" ⟨turn⟩
⟨h0⟩       ::= ⟨nat⟩                        (* initial heading h ∈ H₁₂ = ℤ/12 *)
⟨turn⟩     ::= ⟨int⟩                        (* Δh ∈ -5..6, twelfths of a revolution *)
⟨arc⟩      ::= "arc"  ⟨nat⟩ "ctr" ⟨point⟩ "rad" ⟨nat⟩ "from" ⟨rat⟩ "to" ⟨rat⟩
⟨feature⟩  ::= ⟨kind⟩ "side" ⟨nat⟩ "t" ⟨rat⟩ "w" ⟨nat⟩ [ "sill" ⟨nat⟩ "head" ⟨nat⟩ ]
                                            (* stored as a MATERIAL on the wall slot — 2.4.1 *)
⟨side⟩ shape ::= "straight" | "rounded"     (* a slot may be rounded — this is how arcs store *)
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
⟨name⟩,⟨kind⟩ ::= DEFERRED
⟨roof⟩     ::= a HEIGHT per point           (* OD-2 closed: heights are stored, profiles are R2 *)
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

### 3.1 What is stored — settled by the foxel schema

| | stored? | role |
|---|---|---|
| `𝕋` — a body's **original** | **yes** | the truth for that body, in its local frame |
| `P` — its **pose** | **yes** | where it is in the world; free of the lattice |
| `𝔽_loc` — its local field | **no** — `draw(original)`, on demand | what collision, render and destruction read |
| `𝔽_wld` — terrain + linework | **yes** | the world's own truth |

This scopes `SPEC` **L3** rather than weakening it: *"the field is the stored truth"* holds for
the **world**; a **body**'s truth is its original plus its pose. **OD-6 is closed by the schema**
(`ROUNDTRIP` §2.4): whatever is stored, the model may only express what the foxel can hold, so
`𝕋` and the field describe the *same* admissible set.

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

### 4.1 Worked example — adding `octagon` to the slot shape vocabulary

*"There will be octagon wall types too, for octagonal towers and bay-windows — but that is an
example of how we extend our grammar."* It is the **cheapest** shape of extension, and worth
walking because it shows both what A₂ protects and what it does not.

**A new value in an existing vocabulary**, not a new production: `straight | rounded | octagon`.
It serves two scales at once — an octagonal tower and a bay window are the same chamfer.

| A₂ obligation | why `octagon` satisfies it |
|---|---|
| **C2** kind ordering | a *shape value* is not a new element kind, so nothing re-sorts |
| **C5** defaults omitted | `straight` is the default and is written nowhere, so no existing text gains a token |
| bytes unchanged | existing texts contain no shape token at all → **byte-identical**, trivially |
| `𝕄*` grows, never shrinks | it only admits more; nothing already authorable is withdrawn |

> **But A₂ is not sufficient — and this is the rule the example exposes.** A₂ protects the *text*
> layer. It says nothing about **law F**, injectivity. A newly admitted form can **collide with an
> existing one**: at small sizes an `octagon` run and a `rounded` run may rasterise to the same
> cells, and then `rebuild` cannot tell which was authored, even though every existing text still
> has identical bytes.
>
> **So every vocabulary extension re-opens the census** over the enlarged space — and when a new
> form collides with an admitted one, it is **the new form that is refused**, never the old.
> `𝕄*`-grows-never-shrinks decides the tie: the old form may already have content depending on
> it, the new one cannot.

This gives the extension procedure, in order: add the value → re-run `rt_census_a` over the
enlarged space → refuse whatever new form collides → confirm `rt_extend` still byte-matches every
prior fixture. Three of those four steps are gates that already exist.

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

### 8.0 The corpus — what the ladder actually produces

Each rung's enumeration is not thrown away. **The entries are the deliverable**, kept permanently,
and they accumulate into hexbody's own **T1** tier (`ROUNDTRIP` §7.1) — the thing almost no
inherited prior art gives us.

Shape of an entry, one per admitted form:

```
corpus/<rung>/<case>.t          the canonical text T          — the authored truth
corpus/<rung>/<case>.f          draw(read(T)), or its digest  — what it rasterises to
```

and the gate over the whole corpus is one line, by **P3**/**P4**:

```
for every entry:   write(rebuild(draw(read(T))))  ==  T        byte-for-byte
for every pair:    f(a) != f(b)                                law F, injectivity
```

**Why this is affordable exhaustively.** No golden images, no tolerance, no per-case judgement —
the check is `diff`. That is the practical payoff of keeping `𝕋` float-free (**C1**), and it is
why the ladder can enumerate a level *completely* instead of sampling it.

**Where the corpus lives, and where it does not.** These inputs are **stored for testing only**.
The editor does not store `𝕋` — it writes layer 1, the foxel (`ROUNDTRIP` §2.4.2), and `𝕋` is
explicitly not a second editor representation. The corpus is a *test* artifact; nothing at runtime
reads it.

**Why the entries are kept rather than regenerated.** `rt_extend` replays every prior entry after
any grammar change and demands byte-identical output (law **A₂**). Regenerating them would make
that gate vacuous — it would compare new output against new output and always pass. **A corpus
that regenerates is a gate that cannot fire.**

**A rung is done when** its level is exhaustively enumerated, every entry round-trips, no two
entries collide, and any restriction found is enforceable at the door (§5.2).

### 8.0.1 Where two forms touch — the hardest part of distinguishability

Rung **A8** is not just "more cases". Two forms **touching** is where distinguishability is
genuinely hard, and it is where crawler has made its biggest inroad — `FORMS.md`, *"a kit of
exact, interlocking hex parts (no seams by construction)"*, which owns *"the seam-exactness
property — no gap, no angle — and the matcher."*

Its acceptance criterion is stated as the user's own test:

> *a composite of stitched parts reads as **one continuous structure**, never a chain of joints —
> **no visible gap** (position) **and no visible angle / kink** (direction) at any seam, except
> where an angle is intended.*

**FORMS also argues our R1/R2 split from the other side**, independently, which is worth noting as
convergence rather than coincidence: trig-and-round-to-hex *"draws fine"*, but leaves **no exact,
enumerable form**, so the matcher *"would be reverse-engineering an approximation"*. Its answer —
an **exact predefined cell-form is the source of truth (matchable)**, with trig still rendering it
smoothly downstream — is `R1` reached from the matcher's end instead of the round trip's.

**Status: T3.** `FORMS.md` says of itself *"DESIGN SESSION — requirements only. No implementation,
no geometry pinned yet."* So it is **input, not authority** — usable, and to be **revalidated
against our own corpus inputs** before anything rests on it.

#### The tension it exposes, which is new

**Seam exactness and distinguishability pull against each other.** FORMS wants a composite to read
as *one continuous structure*. Law **F** wants two distinct models to draw to *distinct fields*.
The better the seam, the more nearly a composite of A and B is field-identical to some single form
C — and then `rebuild` cannot recover which was authored.

| property | what it wants | where it lives |
|---|---|---|
| **seam exactness** | parts merge with no gap (`G⁰`) and no kink (`G¹`) | a *construction* property — FORMS |
| **distinguishability** | distinct models → distinct fields | an *injectivity* property — law **F** |

**Likely resolution — needs confirming at A8, not assuming now.** The two are only in conflict if
part identity has to survive in the *fabric*, and it does not:

- **Seated fabric may merge.** Two adjacent seated stencils genuinely *become* one fabric, and
  that is correct — `rebuild` returns a **canonical representative** (P1: `𝕄* = im(rebuild)`), not
  the authoring history. Which of several field-identical models was authored is not recoverable
  and does not need to be.
- **Identity lives elsewhere** — in the placement records and the mechanism graph (§10.3), neither
  of which is fabric. A wagon coupled to a car is two bodies because they are two *frames*, not
  because their fields differ.
- **Free-posed bodies never share a field at all** (`ROUNDTRIP` §2.3), so the question does not
  arise for them.

**What must still not collide,** and this is A8's real gate: two composites that need to
*behave differently in the fabric* — different passability, different destruction fragmentation,
different material — must not be field-identical. That is a narrower and checkable claim than
"all composites are distinguishable", which is false and should not be attempted.

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

> **Status: 7 of 10 closed.** Open: **OD-1** (the morph — narrowed to *probably unnecessary*),
> **OD-5** (is the flip exact — `X2` says yes, but at T2), **OD-10** (arc parameters from rounded
> slots). Plus one unnumbered fork: **how an anchor is addressed** (§10.3.1).
>
> **The foxel schema (`ROUNDTRIP` §2.4) closed or narrowed most of what follows.** Recorded here
> so the reasoning survives, with the schema's consequence marked on each. **What the schema
> states is settled; the per-decision consequences below are inference and want one confirmation
> pass.**
>
> | | was | after the schema |
> |---|---|---|
> | **OD-2** roofs | in or out of the exact round trip? | **`height`.** Heights are the stored truth; a roof *profile* is a **R2** fit over them, so `roof_match`'s `tol` is legitimate — in R2 |
> | **OD-3** trees | a verb, or a prop outside `𝕄*`? | **`item`** — confirmed in code (`ItemDef.id_kind = TREE`, `X13`). And the class **splits by scale**: ≥ 1 hex step → `h_item`; < 1 hex step → **set dressing, outside `𝕄*`** (`ROUNDTRIP` §2.4.0.1) |
> | **OD-4** terrain | a `⟨terrain⟩` production? | **`height`.** Same slot as roofs — the two were always one question |
> | **OD-6** stencil: field or description? | the deepest one | **the foxel is the stored truth.** A description is admissible only if it draws into the schema exactly |
> | **OD-7** which wall model? | edges vs triangle band | **`wall1..3` per point — edges.** A triangle subdivision needs sub-cell resolution the schema has no slot for. `WALLS.md`'s band model cannot be *stored*, whatever its merits as a render/collision construction |
> | **OD-8** when do layers enter? | deferred | **now.** `layer*` is the outermost structure |
>
> **What survives as genuinely open:** **OD-1** (the morph — unaffected, it was already narrowed
> to option (c) by free poses) and **OD-5** (is the flip exact — `X2` says yes; unaffected by the
> schema). And a new one below.
>
> **OD-9 · does the door survive as an annotation? — CLOSED.** *"Doors and windows are materials
> on the wall slot."* The edge is never removed, so the anti-deletion rule holds and the
> doored-tower defect cannot arise — but a door **is** the material rather than an annotation
> beside one. Composition therefore lives in the **material vocabulary** ("door in a stone wall" is
> a material), and the table grows with wall-kinds × feature-kinds. See `ROUNDTRIP` §2.4.1.
>
> **OD-10 · arcs are storable — what is recoverable from them? (new, open)** *"We have rounded wall
> slots too."* So a round tower needs no sub-cell geometry: a run of slots marked **rounded** is the
> arc. What remains open is the parameter question — from a run of rounded slots, are the **centre
> and radius** recoverable exactly (R1), or is that a fit (R2)? That is `Sep` restated against the
> real storage, and it is rung **A6**'s question.

> **OD-12 · which edges IS a wall? (new, open — and the current answer is measurably wrong)**
> The three-slot foxel can only store hex edges, and a hex has edges on **three lines only —
> 30°, 90°, 150°** (`X28`). So "the wall" must be a **connected chain** of edges lying *along* the
> line, which for any other heading is an alternating **wobble**. `wall_write` currently selects
> every edge the band **crosses** — i.e. the roughly **perpendicular** ones — and the mesh
> evaluation shows the consequence: a due-east wall becomes a comb of ten vertical pickets, straying
> **6× the wall's own half-width**. See §10.8. The replacement rule is what rung **A2** has to
> settle, and §6 of `tests/wall.loft` is already the check that will judge it.

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

## 10.1 Follow-up created by the doors-as-materials fix

**Compound materials.** A doored edge now carries `OPEN_DOOR`, having lost `WALL_COTTAGE` — the
loss `ROUNDTRIP` §2.4.1 predicts. Nothing today reads a doored edge's wall material, so the gate
and the render are unaffected; but **`rebuild` will need it**, because recovering "a door in a
cottage wall" from a bare `OPEN_DOOR` is impossible. The material vocabulary must carry the
composition before phase **E**. Cost: the table grows with (wall kinds × feature kinds).

## 10.2 The round trip already exists in moros — and it is lossy, with a false-green test

`../moros/lib/moros_map/src/moros_map.loft` § *the shared document format* (moros#4) is the same
seam one level down: **storage** round trip rather than **model** round trip. Its own comment:

> *"Moros's dense 8-byte cell and hex_field's parallel arrays are ONE model — moros#1 probed it —
> with the cell as a storage concern over the field. This is that seam: a Map layer converts to a
> field, writes through hex_field's format, and comes back.*
>
> *What crosses today: occupancy, height, material. **Items, item rotation and the three wall
> bytes do NOT** — this writer calls the cells/heights/labels form of `doc_write` and never builds
> an `EdgeSet`. That is now OUR gap, not the format's. hex_field grew an edge section on
> 2026-07-22 … so walls could cross today."*

**Three of the six foxel slots do not survive the existing round trip.** And the test that should
catch it is green for the wrong reason — the comment says so itself:

> *"`test_items_and_walls_do_not_survive_yet` does NOT catch this: it was written to fail 'the day
> a section appears', but it watches our round trip, and our round trip drops the walls before the
> format ever sees them — **so the section appeared and the test stayed green**. Carrying the walls
> is what makes it fail, and then it wants deleting rather than fixing."*

A gate that cannot fire is not a gate — the house rule, and here is a live instance, already
diagnosed by its author. Two consequences for M0:

- **`draw`'s target is this seam.** Whatever hexbody emits has to cross it, so the census and
  `rt_trip` should measure against the **moros `Hex` schema**, not against `hex_field`'s structures
  in isolation.
- **Carrying walls across is a prerequisite, not a detail.** Until the three wall bytes survive,
  no stencil with walls can round-trip through the shared format at all — which is every stencil.

**Open question this raises:** is hexbody's `draw` meant to write **moros `Map` layers directly**,
or to write `hex_field` documents that moros then loads? The comment says the two are *"ONE
model … with the cell as a storage concern over the field"*, so either can be the seam — but the
census must be written against whichever one is authoritative.

## 10.3 Connections — vehicles and robot limbs: a graph beside the field, not slots in it

**The question:** couplings and joints are *sparse* — a wagon has two, a limb has one — but each
must hold a **specific point**. Where do they live, when storage is a dense per-cell foxel?

**They cannot live in the foxel, and crawler already says why.** `hexskel`'s opening line is the
principle:

> *"This is the first **graph** in the whole system. Everything before it was a **field**: a value
> per cell, per edge, per chunk. A tree's branch structure is **not a field and cannot be fitted
> like one** — the roof matcher recovers a cone by solving for five parameters, but a skeleton has
> a **variable number of nodes** and no amount of least-squares will produce one."*

That is the whole answer in two sentences, and it has a sharp consequence for this contract:

| | fabric | **mechanism** | dressing |
|---|---|---|---|
| shape | **field** — dense, fixed arity per cell | **graph** — sparse, **variable** arity | sparse sub-hex objects |
| examples | walls, floors, roofs, terrain | couplings, hinges, axles, the part-tree | drainpipes, lamps |
| in the foxel | **yes** | **no** | no |
| recoverable | yes — R1 exact, R2 fitted | **no — a fit needs fixed arity; a graph has none** | no |
| bounded by `fits?` | yes | no | no |

**So mechanism is authored or derived, never recovered.** This is not a gap to close: it is a
category difference. A cone is five parameters, so `roof_match` can solve for it; a part-graph has
no parameter vector to solve for, so no amount of fitting produces one. Law **D** is over *fabric*
— a model with anchors does not violate it, because anchors were never in `draw`'s image.

**crawler already has the representation.** `hexpart`: *"Two levels, no more: an **anchor**, and
parts in the anchor's frame"*, with the **granularity rule** deciding what earns a part —
*"split where something moves independently, merge where it does not… merge too far and animation
is impossible, split too far and every prop pays for degrees of freedom it does not have."*
`hexhinge` places a leaf at a continuous `(hx, hy)`; `hexlink` derives a whole valve gear in
closed form from one wheel phase.

### 10.3.1 The open part — how an anchor is *addressed*

`hexpart`/`hexhinge` use **float** local coordinates, which is right at the mesh level but breaks
**P4** if an anchor is written into `𝕋`: byte-equality has no floats to compare.

The likely resolution, and it reuses machinery that already exists: **address an anchor the way a
feature is addressed** — `(side, t)` with `t` a reduced rational, plus a step-count height. That
is **affine-invariant** (`SPEC` **I2**), so a coupling survives orientation *exactly*, which
`I10` requires — *"a coupling point stays coincident every tick"* — and it keeps `𝕋` float-free.
The float `(hx, hy)` then becomes what it should be: a **derived evaluation** of an exact
address, exactly as metres are derived from step counts.

**What is genuinely undecided:** whether an anchor is addressed against the **boundary** (`side`,
`t`) — natural for a drawbar on a wagon's front face — or against a **cell/vertex** — natural for
an axle inside the footprint. A hinge is on a wall; an axle is not. It may need both, and then the
question is whether that is one address type with two forms or two kinds of anchor.

## 10.4 OD-11 ✅ RESOLVED · what IS a house? — `Plan`, not the turtle cycle

Asked directly: *does hexbody follow crawler's model for presenting houses in the world?* **No.**
Inspecting crawler turns up **four** different answers, and the grammar in §2 is a fifth.

| # | model | what a house is | status |
|---|---|---|---|
| 1 | crawler `land.loft` `add_house` | a **scene node**: floats `x, y, w, d, eaves, ang` + `mat4_trs` | **shipping** — the rendered landscape; touches no field at all |
| 2 | `housedraw` `Plan` *(ours)* | a **continuous rectangle** in a local frame, rasterised **centre-in-region** | **shipping + gated** — `tests/house.loft`, 12/12 |
| 3 | crawler `STENCILS.md` | a **small field**, stamped by merging | **designed, not implemented** |
| 4 | crawler `HOUSE.md` | a `Storey = {cells, floor, soffit}` stack | **designed**; matches the foxel's `cy` |
| 5 | **`DESIGN.md` §2** *(this grammar)* | a **closed turtle polygon** over `H₁₂` | **no implementation anywhere** |

**That is the finding.** Our grammar is the only one of the five that nothing implements, and S1
showed it **cannot express the house that is already gated**: `Plan` measures both sides in units
of `s` (5 × 4 steps = 7.5 m × 6.0 m, `HOUSE.md` §1), but no two of the 12 headings are 90° apart
*and* in the same length class — headings 0 and 3 differ by `√3`. A turtle cycle cannot draw that
rectangle.

### RESOLVED — `Plan` wins, because the turtle *provably* cannot do 90° rectangles

The test is whether our model is better at **exact 90° thin walls**. It is not, and the reason is
the lattice rather than the table (`X24`, gated in `tests/form.loft` §9):

> the perpendicular of `(k,m)` is `(−m, 3k)`, whose squared length is `3m² + 9k² = 3·(3k²+m²)` —
> **exactly 3×**. Every lattice vector along that perpendicular is an integer multiple, so its
> length is `√3 ×` a rational times the original: **never equal**. There is no square sublattice
> of a hexagonal lattice.

So a turtle cycle can turn a right angle (headings 0 and 3), but its two sides quantise on
different grids — 1.5 m one way, 2.598 m the other — and **no choice of headings fixes it**.
`Plan` sidesteps it by being **continuous, then rasterised**: both axes in units of `s`, corners
exactly 90°, 12 orientations, already gated.

**Domain A's shape primitive is `Plan` — option (a).**

### A second, independent criterion picks the same answer

*"The walls in one direction will always be slightly different than the other but by
approximation they should be equal. If that is not the case the model is wrong."* — a model test,
and it separates the two cleanly (`X25`, gated §10):

| model | what differs between the two directions | apart |
|---|---|---|
| **`Plan`** | wall **lengths** are exactly proportional (both axes in units of `s`); only the **strip overhead** differs — `2/√3` vs `3√3/4` | `9/8` **exactly** — 12.5% ✓ |
| turtle | the **step length itself** — perpendicular lattice directions | `√3` — 73.2% ✗ |

The anisotropy is an **exact rational, 9/8**, which is the strongest form "approximately equal"
can take: bounded, and known in closed form rather than measured. Two independent criteria — no
square sublattice (`X24`) and approximate isotropy (`X25`) — reaching the same conclusion from
different directions is worth more than either alone.

### The remaining requirement: corners must be precise

*"And the corners between the walls where they touch have to be precise."* This is **not yet
gated**, and `tests/house.loft` does not check it — it gates side edge counts, equivariance,
openings, roof and eave, but never what happens **where two runs meet**.

It is the same property `FORMS.md` names as its acceptance criterion (*"no visible gap (position)
**and** no visible angle / kink (direction) at any seam, except where an angle is intended — a
building corner"*) and that `WALLS.md` reports its 2D prototype passing (*"rect corners exactly
90°, rhombus 60°/120°, miter offsets correct, the band covers every corner"*, `X10`, tier T2).

**Four checkable parts**, and they belong to **S4**:

| # | what must hold | how it fails |
|---|---|---|
| 1 | the boundary is **one closed loop** — no gap at a corner | a run ends before the corner cell |
| 2 | the corner **angle is exact** — 90° for a `Plan`, 60°/120° for a rhombus | the two fitted lines meet at the wrong angle |
| 3 | the corner cell is claimed **exactly once** — not doubled, not dropped | adjacent runs both own it, or neither does |
| 4 | the **miter point** — where the two fitted surfaces intersect — is at the exact corner | the recovered corner drifts off the model corner |

Parts 1 and 3 are checkable at S4 on the strip alone. Parts 2 and 4 need the fitted surface, so
they land with recovery (S8) — but they should be **written into the gate red at S4**, the same
way `rt_trip` is written before `rebuild` exists.

### Two primitives, not one — and that is the honest shape

`Plan` and the turtle cycle express **genuinely different families**, and neither subsumes the
other. Forcing one mechanism over both would be the over-unification this document exists to
catch:

| primitive | expresses | cannot express |
|---|---|---|
| **`Plan`** — `(cq, cr, wid, dep, rot, mir)`, continuous then rasterised | rectangular massing at 90°, both axes in `s`; unions give L-shapes and wings | a hexagonal or triangular tower — its corners are not 90° |
| **`Form`** — the closed turtle cycle (S1) | lattice-native polygons: **hexagonal towers**, triangles, rhombi — exact, closed by law **J** | any rectangle (`X24`) |

So S1's `Form` is **retained and gated**, not dead — it is the tower primitive, and a hex tower is
in the very scene driving this ladder (§8.1). What changes is that it is **not the spine**:
houses are `Plan`, and S3 rasterises `Plan` first.

---

*(Original framing of the question, kept because the reasoning is what produced X24.)*

**So the open question was what domain A's grammar actually is.**

| option | expresses the gated house? | recovery |
|---|---|---|
| **(a) `Plan`-parametric** — `(cq, cr, wid, dep, rot, mir)`, integers + a 6-way rotation + a flag | **yes** — it *is* the gated house | finite parameter search — **R1, exact** |
| **(b) turtle polygon** — the §2 grammar | **no** | exact match on the cycle — R1 |
| **(c) both** — `Plan` as a *shape constructor* whose boundary is a cycle | yes | R1, at the cost of two forms in `𝕋` |

Option **(a)** deserves more weight than it has had. `Plan` is already integer-parametric —
`wid`, `dep`, `rot ∈ 0..5`, `mir ∈ bool` — so it is a finite grammar with exact recovery, and it
is the one thing here with a green gate. The turtle model is *more general* in one direction
(arbitrary polygons) and **strictly less** in another (it cannot draw the fixture).

**What this does not change.** Laws A–K, the corpus, the two regimes and the trust tiers are all
independent of which shape grammar domain A uses. S0 and S1 also survive: `H₁₂`, the exact
rotation and reflection, and closure are needed by *any* of these, and `Plan`'s `rot` is exactly
the 6-rotation subgroup S0 measured. **What it changes is S3 onward**, which is why it surfaced
now rather than after `rebuild` was written against the wrong grammar.

## 10.5 The wall model — a triangle strip, and where it stands

*"So the tops form a triangle strip of triangles that divide each hex line in 3. And the sides
are the same triangles touching in pairs. That is your model."*

**This reconciles OD-7.** The triangle subdivision (`WALLS.md`, `X10`) is the wall's **geometry**;
the edge slot is its **storage**. Those were never competing — I read them as rival storage models
and rejected the triangles on the grounds that the foxel has no sub-cell slot. It does not need
one: a cell stores a wall *id*, and the `WallDef` behind it carries the body and thickness
(`X12`). The triangles are what that body *is*.

| | |
|---|---|
| **storage** | `wall1..3` — one edge slot, material + shape |
| **geometry** | a band of sub-triangles, each hex edge divided in **3** |
| **tops** | the triangles form a **strip** |
| **sides** | the same triangles, **touching in pairs** |

**Status — recorded, not verified.** What is measured: the tops band is **0.5 world units =
0.4330 m**, exactly **half a hex edge**, on the real rasterised house, with its run/wall ratio
`2/√3` matching `tests/house.loft` line for line. What is *not* confirmed is the arithmetic tying
that band to a 3-way subdivision — sub-segment `1/3` wu, triangle height `√3/6` wu, giving band
ratios of `1.5` and `√3` respectively. Neither is obviously the intended relation, so **the "3" is
recorded as stated and left to S4b to verify**, rather than back-fitted to a number I already had.

**The sides band is not measured at all**, and cannot be until corner-edge ownership is defined —
my two `u` groups came out asymmetric (2.598 m vs 6.062 m for what must be one length) purely
from corner misassignment. That makes the corner rule a **blocker for measurement**, not only for
correctness.

**So S4b's gate is now three things**, in order: (1) read and state `side_edges`'s corner-ownership
rule; (2) measure both bands in loft, per family; (3) check them against the triangle
subdivision — confirming or correcting the "3".

## 10.6 The triangle space, and the wall strip — found in crawler, rendered

![the 18-triangle fan](shots/fan18.png)
![the straight strips](shots/fan18_strips.png)

**The space is `crawler/src/realworld/trimesh.loft`** (+ `plans/1-ortler-worldgen-fixture/trimesh.py`),
not a uniform triangular lattice. **18 fan triangles over 19 vertices** per hex — centre, 6
corners, 12 edge-thirds — watertight by construction (a corner is shared by 3 hexes, an
edge-third by 2), and already gated in the Ortler fixture. Fan order:

```
loc = 3k+0 : (centre, corner_k,     edge_(k,1/3))   flank L of side k
loc = 3k+1 : (centre, edge_(k,1/3), edge_(k,2/3))   MIDDLE  of side k
loc = 3k+2 : (centre, edge_(k,2/3), corner_(k+1))   flank R of side k
```

**The wall is the chain of MIDDLE triangles** — `shots/fan18_strips.png` isolates them. Opposite
sides `k` and `k+3` share the centre vertex, so their two middles form **one straight strip
through the hex centre, one triangle thick, running edge-third to edge-third**. Chained across
hexes those strips are continuous and exactly straight. Three axis families → strips at 0°, 60°,
120°. The flank triangles belong to no strip.

**This is the wall "on the average of the lines that already exist"**: the edge-thirds are the
points that divide the existing hex edges in 3, and the strip runs between them through the
centre — all 19 vertices already exist in the mesh.

### What I had wrong, and why it took so long

| | I built | actually |
|---|---|---|
| the space | a **uniform** triangular lattice at 1/3 hex-edge | the **18-triangle fan** from each hex centre |
| the selection | triangles hit by a point probe | the **middle** triangle of each side |
| the thickness | a multi-triangle band from a distance threshold | **one triangle** |

The point probe is the centroid rule `WALLS.md` explicitly names as the bug (*"not its centroid —
that's the bug that drops half the triangles"*). And `tools/wallproto/walltri.py` — 139 lines,
renders 6 forms, runs corner tests — had already done the whole exercise on a *different* space.
**I found `tools/wallproto/` early enough to cite it as `X10`'s reference and still did not read
it.** `CLAUDE.md`'s own rule covers exactly this: *look in crawler before building; specifying
from scratch what already exists is the most likely way to waste effort here.*

## 10.7 The house outline — the construction that works

![hexes and triangles](shots/base_hex_tri.png)
![one triangle thick](shots/wall_inside.png)
![the outline](shots/wall_faces.png)

Blueprint phase, in the cheapest medium (`shots/wall_outline.py`, throwaway Python) as the
design-protocol prescribes. **The result is a closed house outline** — `shots/wall_faces.png`.

**1 · the triangle space.** Equilateral triangles, side `= 1/3` hex edge, so **three fit each hex
edge**. Basis `U` at 30°, `V` at 90°, which aligns it: every hex **corner and centre is a lattice
point**. *(Not the 18-triangle fan of `realworld/trimesh.loft` — that is a terrain mesh of skinny
slivers from the hex centre, and it does not read as a building at all.)*

**2 · the averaged line.** Per wall side (grouped by `housedraw::side_edges`' rule), take the
boundary hex edges and average them: direction `= Σ` edge vectors normalised, position `=` mean of
edge **midpoints**. This is the line the wobble is *about* — `ROUNDTRIP` §6.1.

**3 · the wall, one triangle thick.** The triangles whose **centroid** lies within half a
triangle-height of that line, inside the run's extent. **The triangles make their own straight
line; they do not trace the hex boundary** — the hex wobble crosses *under* the wall. Selecting by
what the line *touches* instead gives a **double** line, which is what `shots/avg_wall.png` shows
and why it is kept.

**4 · the two faces, equal width.** The vertical strip's own outside edges give the width —
**`√3/6` wu `= 0.2887` wu `= 0.2500 m`** — and the horizontals take that **same width on their own
trajectory**. That is the equalising rule, applied where it belongs: to the *faces*, not to the
band.

**5 · extend to meet.** All eight face lines run on until outer meets outer and inner meets inner,
giving two closed mitred rings — which is also what closes the corners.

| | outer | inner |
|---|---|---|
| ring | `±4.907 × ±3.894` wu | `±4.619 × ±3.606` wu |
| metres | **8.499 × 6.744** | **8.000 × 6.246** |

### Two measured discrepancies, not yet chased

- **The strip is not centred on its averaged line.** Vertical faces land at `−0.0962 / +0.1925`
  about the centre — offset outward by a third of the width — while the horizontals are symmetric
  at `±0.1443`.
- **The outline is larger than nominal**: 8.50 × 6.74 m against the house's 7.5 × 6.0 m. The
  averaged line sits at `x = ±4.715` rather than the cell-centre line at `±4.330`, because the
  boundary edges bulge past the centres and averaging their midpoints keeps that bulge.

### What this cost, and the rule it re-proves

Six wrong constructions before this one: a uniform lattice selected by point-probe (the **centroid
bug** `WALLS.md` names explicitly), the 18-triangle fan (a terrain mesh), a band from a distance
threshold, a strip tracing the hex boundary, and a doubled line. `tools/wallproto/walltri.py` had
already done a version of this — **and I cited that directory as `X10`'s reference without reading
the file.** `CLAUDE.md`'s first rule is exactly this case.

## 10.8 The wall→mesh evaluator already exists — and using it caught a misfiled edge

The question *"can the crawler library we already made evaluate these walls back to meshes?"* has a
better answer than crawler: **`hex_grid` already owns the edge-wall model, and moros already
evaluates it.** Nothing here is ours to invent.

| step | who owns it | what it is |
|---|---|---|
| edge → the two corners bounding it | `hex_grid::hex_edge_corners(dir)` | the table; its own header says *"walls live on hex edges, stored on 3 canonical edges per hex (dirs 0,1,2); dirs 3,4,5 belong to the neighbour"* |
| which hex stores a given edge | `hex_grid::hex_canon_edge` | dirs 0–2 here, 3–5 on the neighbour |
| the three slots → geometry | `moros_render::emit_hex_walls` | `h_wall_n` = corners 5→0, `h_wall_ne` = 0→1, `h_wall_se` = 1→2, each a quad from `floor_y` to `ceil_y` |
| a *segment* → a drawable mesh | crawler `worldmesh::build_wall_mesh` | capsule-SDF quads; 2D screen strokes, needs `Sim` |
| a marked *field* → straightened segments | crawler `wallgeo::build_walls` | **the recovery step — and approximate**: Laplacian smoothing (`SMOOTH_ITERS 3`, `λ 0.5`) plus snapping to known room side-lines within `SNAP_TOL2` / `SNAP_TOL2_V` |

**The scales agree exactly**, so this is reuse and not a port: `hex_grid`'s world is
`x = √3·(q + ½(r&1))`, `y = 1.5r`, and `hex_field`'s exact lattice gives `k·√3/2 = √3·(q + ½(r&1))`
and `m/2 = 1.5r` — the same numbers, integer and float spellings of one convention.

### The defect it caught

`hexwall` first carried its **own** corner table (corner 0 at 30°) and paired edge `c` with
`hex_field`'s `nb_q/nb_r(q, r, c)`. But the two direction orders are different:

```
hex_field   d = 0..5   →  E,  W,  SE, SW, NE, NW
hex_grid  dir = 0..5   →  E,  SE, SW, W,  NW, NE
```

so **five of the six edges were stored against the wrong neighbour** — a real edge, just not the one
the band crossed. Measured: the edge midpoint sat `0.866` or `1.500` wu from the midpoint between
the cells it was supposed to separate, on every direction but one (`c = 3`, aligned by accident).

**Every gate stayed green.** A consistently wrong edge is still written exactly once, still
idempotent, still non-empty, still non-empty in all 24 directions — sections 1–5 cannot see it. Only
evaluating the marks *back against the geometry* did. That is `I-RT` doing its job at the smallest
possible scale, and it is why `wall_edge_gap` is now a gate section (§2b) with a control that
misfiles an edge by one direction and must fire.

### The second defect it caught — `wall_write` marks the edges ACROSS the wall

The evaluation was supposed to show a sawtooth *along* the line. It does not. Measured over all 24
directions (`tests/wall.loft` §6, run of half-length 8.0):

| class | segments | worst stray | ÷ the wall's own half-width (0.1443) |
|---|---|---|---|
| `d24 ≡ 0 (mod 4)` — edge headings | 10 | 0.5000 wu | **3.46×** |
| `d24 ≡ 2 (mod 4)` — vertex headings | 30 | 0.8660 wu | **6.00×** |
| odd `d24` — the in-between 12 | 10 | 0.7559 wu | **5.24×** |

Perfectly 12-fold symmetric, which says the *geometry* is now right — and the magnitude says the
*selection rule* is wrong. A wall 0.289 wu thick cannot evaluate to a mesh straying 1.73 wu.

`probes/edge_family.loft` shows what is actually being marked:

```
  d24  wall-angle   marks per edge-direction (dir 0..5 = E SE SW W NW NE)
    0       0.00    E= 10 SE=  0 SW=  0 W= 10 NW=  0 NE=  0
    4      60.00    E=  0 SE=  0 SW= 10 W=  0 NW=  0 NE= 10
```

A pointy-top hex has edges on **three lines only: 30°, 90°, 150°.** The `E` edge (corners 4→5) is
the **90° vertical** one. So a wall running **due east** is marking the ten *vertical* edges it
passes through — `emit_hex_walls` then stands a quad on each, and the mesh is a **comb of pickets
across the wall**, spaced `√3` apart, rather than a wall along it. Same at 60°, rotated.

The cause is that `wall_crosses_edge` selects every edge the band **crosses**, and the edges a
straight band crosses are the ones roughly **perpendicular** to it. What the three-slot model needs
is the opposite: a **connected chain of edges lying ALONG the line** — which, because no hex edge
runs at 0°, must be the alternating 30°/150° **wobble**. Only walls at 30°/90°/150° get a straight
single-family run.

This is the same wobble `wallgeo` exists to straighten, and the same one the triangle subdivision
(§10.6–10.7) was chosen to beat. **`wall_write`'s selection rule is therefore still open**, and the
mesh evaluation is the check that will confirm the replacement: a correct chain must bring the stray
down to the order of the wall's own half-width, and must be *connected* — a property the current
picket set does not even have.

### What the evaluation says about the round trip

The mesh from the three slots is a **sawtooth** — a chain of hex edges — not the straight line
drawn. That is not a bug to drive to zero at this end: it is exactly the quantity `rebuild` must
undo, and §6 of the gate measures it for the first time. crawler undoes it *approximately*;
**`P4` admits no ε**, so ours cannot reuse `wallgeo`'s smoothing — but `wallgeo` stands as the
honest baseline to diff against.

## 10.9 All 24 exactly straight and exactly the same width — what is possible

The question splits into three, and they have three different answers. Two are provable.

### (a) Exactly straight — YES, for all 24, but only one way

A straight line is straight at any angle, so straightness is never the obstacle. The obstacle is
*what the wall is made of*: a union of lattice cells has a **staircase** boundary in every direction
except the three the cell edges run along (30°, 90°, 150° — `X28`). Even an exact lattice direction
like 0° does not help: the lattice lines at 0° pass through lattice points but **no triangle edge
lies on them**, so the strip cuts cells open.

So **exactly 6 of the 24 directions can have faces made of actual lattice edges.** For the other 18
the cells cannot be the truth. The construction that works for all 24 is therefore the one `X8`
already states — *a way is an exact centreline plus offsets, never a rasterised band*:

> **A wall is a line primitive** — `(anchor, direction, length, width)`, anchor on a lattice point,
> direction an exact primitive lattice vector. Its two **faces are the real lines** at `±w/2`
> perpendicular to the centreline. Straight by construction, in all 24. **The cells are derived**
> — the rasterisation of the band — and they are *not* the wall.

### (b) Exactly the same width — YES, and provably only one way

Width can come from **counting lattice rows** or from **a model constant**. Rows cannot do it.

For a primitive lattice vector `v`, the parallel lattice lines in its direction are spaced
`S·√3 / (2√N)` where `N = a² + ab + b²` is an integer. Two directions' widths, as integer row
counts, can be equal only if `√(N₂/N₁)` is rational — i.e. only if `N₁·N₂` is a **perfect square**.
Among the 24 directions exactly three values of `N` occur, and no pair qualifies:

| class | `N` | directions | spacing |
|---|---|---|---|
| vertex / edge-line | **1** | 30°, 90°, 150°, 210°, 270°, 330° | `0.288675` wu |
| edge-neighbour | **3** | 0°, 60°, 120°, 180°, 240°, 300° | `0.166667` wu |
| in-between | **21** | the odd 12 | `0.063022` wu |

`1·3 = 3`, `1·21 = 21`, `3·21 = 63` — none a perfect square (`X30`). **No choice of row counts makes any two
of these equal.** (Gated: `tests/wall.loft` §7, with the control that a class *is* commensurable
with itself.) It is the same root as `X24`: `√3` is irrational.

Therefore **width must be a model constant applied perpendicular to the centreline** — one number,
`w = √3/6 wu = 0.25 m`, for every direction. Then equal width is not achieved, it is *definitional*,
and there is nothing left to vary. Note this is exactly the `N = 1` spacing, so the wall stays "one
triangle thick" in the three edge directions and becomes a real-valued band in the rest.

### (c) At exactly 15° spacing — NO, provably, for the odd 12

`tan 15° = 2 − √3`. A lattice vector `(a,b)` has `tan θ = (a + 2b)/(a√3)`, so `tan θ = 2 − √3`
forces `2a + b = a√3`, hence `√3 = (2a+b)/a` — rational. Contradiction unless `a = b = 0`.
**No lattice vector points at 15°** (`X31`), and the same argument kills every odd multiple of 15°.
The even 12 are all exact (`X29`).

So the odd 12 are straight and equally wide, just **not at their nominal angle** — and that is a
property of the hex lattice, not of our construction.

### What is NOT forced: the 4.107° error

The current in-between direction is the **shortest** one — the sum of the two adjacent headings,
`N = 21`, off by `4.1066°`. That error is a *choice of period*, not a law. Longer primitive vectors
approach 15° as closely as wanted:

| vector | `N` | period | angle | error vs 15° | vs today |
|---|---|---|---|---|---|
| `(5,−1)` | **21** | 1.528 wu | 19.107° | **+4.1066°** | ***current*** |
| `(3,−1)` | 7 | 0.882 wu | 10.893° | −4.1066° | same error, **43% shorter period** |
| `(4,−1)` | **13** | **1.202 wu** | 16.102° | **+1.1021°** | **3.7× better, 21% shorter** |
| `(11,−3)` | 97 | 3.283 wu | 14.705° | −0.2953° | 13.9× |
| `(15,−4)` | 181 | 4.485 wu | 15.079° | +0.0791° | 51.9× |
| `(56,−15)` | 2521 | 16.737 wu | 15.006° | +0.0057° | 722.8× |

Note the second row: the current vector is **not even the shortest at its own accuracy**. Summing
the two adjacent headings lands on `(5,−1)`, `N = 21`; the mirror `(3,−1)`, `N = 7`, has the *same*
`4.1066°` error with a period 43% shorter. So today's choice is dominated outright.

**The recommendation is `N = 13`, the vector `(4,−1)`.** It is 3.7× more accurate than today *and*
21% shorter in period, so it is strictly better on both axes — there is no trade to make. Period is
what matters for short runs: a house wall of 7.5 m is 8.66 wu, so `N = 13` gives ~7 repeats
of the wobble while `N = 181` gives fewer than two — at which point the run no longer *reads* as that
direction at all. The long vectors are only usable for roads and cliffs, where runs are long.

This is a **live proposal, not a decision** — changing the in-between vector changes every stored
in-between wall, so it belongs to the extension contract (`I-EXTEND`) and wants deciding before the
corpus is built rather than after.

### The consequence for storage

If the truth is the line and the cells are derived, then storing **only** the three wall slots
(`L3`, and the user's *"I only want the 3 walls per hex foxel"*) means the line must be **recovered
exactly** from the marks — the anchor and direction, since the width is now a constant and needs no
recovery. That is precisely `I-RT` under regime **R1**, and it forces one design rule:

> **the centreline must be anchored on lattice points.** With a continuous anchor the map from line
> to marks is many-to-one — infinitely many offsets rasterise identically — and no exact recovery
> exists. Quantising the anchor makes the question finite, and the level-1 census (**S5**) is what
> answers it.

## 10.10 Where a line may start and end — the editor's doorstep, analytically

The editor can draw only straight lines. `K-FIT` says the limit sits **at the doorstep** — the
editor refuses at authoring time — so it needs `fits?` for a line as a closed-form test, not a
trial rasterisation. This derives it.

### Why the endpoints are hex vertices, and nothing else

The stored form is hex-edge marks, and `emit_hex_walls` stands a quad on the segment between an
edge's two corners. So **every mesh extremity is a hex vertex.** An endpoint anywhere else is not
merely inaccurate — it is *unrepresentable*: the rebuilt wall stops at the nearest vertex, and the
round trip fails at `I-RT` before anything else is even considered. So:

> `fits?(line)` ⟺ **both endpoints are hex vertices**, and `B − A` is a whole number of the
> direction's vertex-to-vertex period.

### The arithmetic — one invariant decides it

In triangle coordinates `(a,b)`, hex vertices **and** centres are exactly the points with
`a ≡ b ≡ 0 (mod 3)` — the sublattice `3L`, three points per hex (one centre, six corners each
shared by three). The class

```
c(a,b) = ((a − b)/3) mod 3          c = 0 → a hex CENTRE (never an endpoint)
                                    c = 1, 2 → the two vertex sublattices of the honeycomb
```

separates them. A primitive direction vector `v` never has both coordinates divisible by 3, so a
displacement `n·v` reaches `3L` only when `3 | n`. Write `n = 3p`; the class then shifts by
`p·(aᵥ − bᵥ) mod 3`, and there are exactly two cases:

| `(aᵥ − bᵥ) mod 3` | which `p` work | directions |
|---|---|---|
| **0** | **every** `p`, from **every** vertex | `N = 3` (0°, 60°, …) and `N = 21` (the odd 12) |
| **1 or 2** | **exactly two of every three**, and *which* two depends on the start class | `N = 1` (30°, 90°, …) |

The second case is not an edge case, it is geometry: along 30° a line runs one hex edge, then
another, and then meets a hex **centre** — so `p ≡ 2 (mod 3)` has nothing to land on. Going straight
up from a vertex the points at 1 wu spacing read *vertex, vertex, centre, vertex, vertex, centre…*

### The three quantisations the editor snaps to

| class | directions | endpoint step | availability |
|---|---|---|---|
| **N = 3** | 0°, 60°, 120°, 180°, 240°, 300° | **1.5000 m** *(exactly one hex step)* | every multiple, any vertex |
| **N = 1** | 30°, 90°, 150°, 210°, 270°, 330° | **0.8660 m** *(one hex edge)* | **2 of every 3** — the third is a centre |
| **N = 21** | the odd 12 (in-between) | **3.9686 m** | every multiple, any vertex |

Three consequences worth stating plainly:

1. **The in-between directions are unusable for buildings.** A 3.97 m endpoint quantum means a wall
   is 0, 3.97, 7.94 m — there is no such thing as a 5 m in-between wall. They are fine for roads and
   cliffs, which is exactly where `I-DOMAIN` already puts them. This is now a *second*, independent
   reason for the even-only rule, beside `X29`'s 4.107°.
2. **A rectangle's two sides quantise differently.** `0°` and `90°` are perpendicular, but one is
   `N = 3` (1.5 m) and the other `N = 1` (0.866 m with a hole). That is `X24` — no square sublattice
   — surfacing where the user meets it, and it is the same fact `S1` hit when the `4,5,4,5` house
   outline turned out not to be a lattice cycle.
3. **The refusal can always name its restriction.** `wall_snap_p` searches outward from the wanted
   length, so a refusal comes with the nearest admissible run on both sides — never a silent snap
   (`K-FIT`).

### The routine

```loft
tri_class(a, b)                    // 0 = hex centre, 1/2 = the two vertex classes
tri_is_vertex(a, b)                // on the 3-lattice AND not a centre
wall_run_ok(d24, a0, b0, p)        // fits? — the doorstep test itself
wall_min_p(d24, a0, b0)            // the snap unit from THIS vertex
wall_snap_p(d24, a0, b0, want)     // nearest admissible, ties to the shorter run
wall_end_a / wall_end_b            // the endpoint
wall_run_len(d24, p)               // its length in world units
```

Gated by `tests/wall.loft` §8 over all 24 directions × both vertex classes × `p = 1..9`, with two
controls: a run starting at a hex **centre** must be refused in every direction, and on an `N = 1`
direction some `p` must actually be refused *and* the snap must offer a different admissible one —
otherwise the doorstep is vacuous.

### From an arbitrary mouse point to a legal line — two snaps, both exact

The editor's real input is two arbitrary float points, neither on anything. Both snaps are exact
once the doorstep above is known, and neither is a heuristic.

**Snap 1 — the anchor.** Hex vertices *and* centres together form a triangular lattice of spacing
1 wu (`(a,b) = (3i, 3j)`), so one cube-rounding — `hex_grid::hex_round`, the library's, not ours
(`L11`) — gives the nearest hex-scale point. If it landed on a **centre**, take the nearest of its
six neighbours, which are all vertices.

That fix-up is **complete, not approximate**: the query lies in the rounded point's Voronoi cell, of
circumradius `1/√3 = 0.577`, so a neighbour is at most `1.577` away while every vertex outside the
six is at least `√3 − 0.577 = 1.155`… and more sharply, since the rounded point is by construction
the *nearest* hex-scale point, no non-neighbour vertex can beat all six. The nearest vertex is
always among them.

**Snap 2 — the far end.** For each of the 24 directions, project the target onto it to get a
real-valued period count, then test the integers around it. The rounding of the projection is *not*
enough on its own: the `N = 1` directions refuse one `p` in three, so the nearest legal run is
sometimes two away from the nearest integer. Searching `±3` covers it — the only refusals are that
one-in-three, so a legal `p` is never further. Then keep the globally closest admissible endpoint
**over all 24 directions**, which is precisely *"move towards any point that gives a correct line, in
any of the 24"*.

```loft
nearest_vertex(x, y)                  // snap 1 — arbitrary point -> hex vertex (a,b)
snap_run_d24(a0, b0, tx, ty)          // snap 2 — the best of the 24 directions
snap_run_p(d24, a0, b0, tx, ty)       //          and the legal period count in it
run_end_dist(d24, a0, b0, p, tx, ty)  // the residual the editor should show
```

Both are gated against **brute force** rather than against themselves (`tests/wall.loft` §9): 49
arbitrary points snapped and compared to an exhaustive search over a 17×17 block of hex-scale
points, and six arbitrary targets compared to an exhaustive search over all 24 directions × 13
period counts. The control is the naive snapper — round to hex scale and stop — which must land on
a **centre** often enough to prove the six-neighbour fix-up is doing work.

The residual `run_end_dist` is what `K-FIT` requires a refusal to carry: the editor shows the user
how far the legal endpoint sits from where they pointed, rather than silently moving it.

### What this does not yet settle

The endpoints are pinned; the **offset** is not. Two parallel lines a fraction of a wall-width apart
still rasterise to the same marks, and nothing above prevents it — the anchor is quantised to
vertices, but whether *direction plus anchor* is jointly recoverable from the marks is the level-1
census (**S5**). And all of this assumes the corrected write rule; under today's picket rule
(**OD-12**) the marks do not even form a chain, so §8 constrains the *model*, not yet the *stored
result*.

## 10.11 The box, and the two kinds of wall

The editor's gesture is *"select the inside hexes as a rectangle"* — the user picks the **room**,
never the wall. `src/hexbox.loft` makes that one selection the input to everything a building needs.

### Twelve directions, and why they are two families

`housedraw`'s `Plan` rotates in `0..5`, sixty degrees a step, because those six are the lattice's
own rotations. But a stencil side runs in one of the **twelve** headings of `H₁₂`, so `Box` rotates
in `0..11` — thirty degrees a step — and the twelve split into two families that are *not*
interchangeable:

| family | `rot` | local `u` on | behaviour |
|---|---|---|---|
| **edge** | even | an edge heading | the six are exact lattice rotations of each other — `Plan`'s family |
| **vertex** | odd | a vertex heading | also six, also mutually exact — but **not related to the even family by any exact map** |

A 30° rotation is not a lattice symmetry (`X24`), so the odd six are a **second family of boxes,
not a rotation of the first**. Measured at 5×4 (7.5 m × 6.0 m):

```
   EDGE family (even rot): every rotation 27 cells — equivariant true
   VERTEX family (odd rot): every rotation 23 cells — equivariant true
   wall-edge cost: edge family 38, vertex family 38     (perimeter — identical)
   cell count:     edge family 27, vertex family 23     (area — not identical)
```

**Same perimeter, different area**, and the difference is not mysterious: 45 m² over a 1.949 m²
hex is 23.1 cells, so the *vertex* figure is the metric one and the edge family takes **four extra
cells from the boundary tie** — along an edge heading, cell centres land exactly on the side line
and `draw_floor`'s inclusive comparison takes them. That is precisely what `hexform::plan_u_can_tie`
exists to state, and why the exact inside test places the boundary *between* centres. **The gated
`Plan` path over-counts its own footprint by 17%**, which is worth knowing before any area-based
constant is measured off it.

`tests/box.loft` §3 checks the even-`rot` `Box` against `housedraw`'s `Plan` **cell for cell** over
all six rotations — 0 differences — so this generalises the gated path rather than replacing it.

### Two kinds of wall, and they differ in kind, not in thickness

| | the **thin** wall | the **thick** wall |
|---|---|---|
| what it is | an **edge** between an inside cell and an outside one | a **ring of whole cells** |
| costs | no floor at all — 27 cells of house stay 27 | a ring of ground, outside the selection |
| is | a boundary | **ground you stand on**, with an inside and an outside |
| for | houses, cottages, towers | **castles, town walls** |
| routine | `housedraw::draw_walls` (already gated) | `box_ring_out` / `box_ring_in` |

`box_ring_out` puts the wall **outside** the selection — the user's courtyard is untouched, which
is what the editor's gesture implies. `box_ring_in` takes the outermost layer of the selection
instead, for a wall drawn to a surveyed outer boundary.

**A thick wall is tested by trying to walk in, not by counting it.** `flood_outside` floods the
exterior and `leak_count` asks whether it reached the courtyard — zero for all 12 rotations, and
the control punches **one cell** out of the ring and gets 27 courtyard cells reachable. That is
`SPEC` **I3**'s control ("2 components, 0 enclosed") in the form a thick wall actually needs.

The same wall without an enclosure is `line_hexes` — a curtain wall or rampart, the cells a segment
passes through, connected by construction and one cell wide. Gated over all 24 directions on
admissible runs from §10.10, with a control that removes one cell mid-run and must read
disconnected.

### The cost of getting here

One hour went to a **toolchain defect**, not to geometry: a struct constructed *inside an argument
list*, beside a store-allocated `HexSet`, is corrupted from the second loop iteration on. Section 1
of the gate hoisted the constructor and read 27/23; sections 3 and 5 inlined it and read 27, 10, 9,
8. **Both looked like plausible rasterisation results.** Filed as **H4** in crawler's
`LOFT-HANDOFF.md` with the six things ruled out, worked around by hoisting, reproducer kept at
`probes/inline_struct.loft`, and the rule added to `CLAUDE.md`'s traps. loft is consumer-only here —
file, work around, keep moving.

## 11. Known conflicts in the current tree

| site | conflict | law |
|---|---|---|
| `src/housedraw.loft:299` | ~~`place_opening` wrote the opening kind into the **surface-id** slot~~ — **FIXED**: doors and windows are now materials via `edge_set_mat`, per `ROUNDTRIP` §2.4.1. Gate green and `house12.png` byte-identical, so the change is behaviour-preserving. The `surf` slot is now unused outside `hexedge`, free for the analytic surface it is named for | **D**, **E₂** |
| `src/hexroof.loft:493` | `roof_match(..., tol: float)` — a tolerance inside a recovery | **P4**; gated by OD-2 |
| `SPEC` **L4** | superseded on the assumption the flip approximates — **pending OD-5** | **G**, **H** |
| `PLAN.md` **M0** | named the work a *fit*; **D**/**E₂** admit no approximation on undamaged geometry — it is a **recovery** | **D** |
