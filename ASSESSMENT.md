# ASSESSMENT — the project measured against its goals

*Written 2026-07-24, from the gated state at `dd38f26` (18 green gates, `X1`–`X62`).*
*Updated the same day: §4's "biggest risk" was gated, §5's items 1–2 are done, and the palette is schema-checked — 21 gates, `X1`–`X70`. The original wording
is kept visible rather than rewritten, because what it got right and wrong is the useful part.*

**The question this answers**, asked by the user: *can we use this work in a friendly but powerful
editor, and as assets in a game?*

**How to read it.** Every claim below is marked: **[G]** gated here (T1, a green gate with a
control that fires) · **[B]** built but ungated · **[J]** my judgement, falsifiable but not
measured. Do not promote a **[J]** to a fact by citing this file — that is exactly the `X15`
mistake this repo exists to avoid. This is a **synthesis document**, not an authority: on any
object or map `ROUNDTRIP.md` wins, on any target `SPEC.md` wins.

> **WHAT IS STORED HERE.** Where the project stands **against its goals**, every claim marked
> **[G]**/**[B]**/**[J]**, plus the frontier and one-line pointers to the open decisions.
> **NOT HERE:** a new fact (→ [`ROUNDTRIP.md`](ROUNDTRIP.md) or [`SPEC.md`](SPEC.md)) · the
> reasoning behind an open decision (→ the owning plan's `DESIGN.md`). This file **points at**
> those; it does not hold them, and it is never the authority for either.

---

## 1. The short answer

**The editor foundation is real and mostly done. The game-asset half is largely unbuilt, and the
gap is not where it looks.**

The load-bearing, genuinely hard part — *a model that survives a round trip through a lattice
field exactly, with no tolerance anywhere* — is **done and gated**. That is what an editor stands
on, and it buys more than it appears to: save/load, undo, copy/paste, diffable project files,
orientation, and refusal-with-an-offer all fall out of it.

The **body** half of "hexbody" — motion, interaction, vehicles, destruction (`G1`, `G3`, `G4`,
`G6`) — is **not built at all**. Today the repo is an exact-geometry round-trip harness with a
body-shaped hole. That is on-plan (`PLAN.md` M0 is the round trip), but it means "assets in a
game" currently means *static* assets.

---

## 2. The editor — what is already yours

`SPEC` **L6** says the editor itself is the **consumer's**, not hexbody's. So the question is not
"is there an editor" (there is not, by design) but **"does hexbody hand an editor what it needs?"**

### What "friendly" needs, and what exists

| an editor needs | status | where |
|---|---|---|
| **never a blank "no"** — refuse with a *named reason* and an *offer* | **[G]** `draft_fits` returns a named reason (centre anchor, zero periods, bad direction, endpoint off the period grid, run leaving the footprint); `draft_fit_p` offers the nearest shorter run that fits. **0 disagreements, 0 false accepts** against the trip itself | `X60`, `tests/embed.loft` |
| **arbitrary mouse point → legal geometry** | **[G]** `nearest_vertex` + `snap_run_d24` / `snap_run_p`, both gated against brute force; `run_end_dist` is the residual to display | `tests/wall.loft` §8 |
| **no silent correction** — the user must see what was changed | **[G]** `I-QUANT`/`X50` is the rule and it is measured three independent ways (endpoints → hex vertices, feature `t` → edge centres, arc radius → shells). Off the grid a value is *silently snapped, not rejected*, which is precisely why the doorstep must refuse it | `X48`, `X49`, `X50` |
| **save / load / undo / diff** | **[G]** `write(rebuild(draw(read(T)))) = T` **byte-for-byte** over 119 corpus entries + all 12 in-between directions. A canonical text means project files are diffable and merge sanely | `X41`, `X60` |
| **author once, get every orientation** | **[G]** law **I**, 12/12 equivariant in cells *and* edges; the flip is exact on linework too (96/96) | `G0`, `X57` |
| **place on terrain without re-authoring** | **[G]** seating writes the `height` slot only — 0 cell diffs, 0 edge diffs, authored text back on flat ground *and* on a slope; the slope's cost is a **returned residual** (`1.650`), not an absorbed one | `X59` (`G5`'s seating half) |
| **combine pieces predictably** | **[G]** union-then-cut, order-free by construction, adjacent stencils **fuse** (nobody owns the shared edge) | `X52` |
| **bridges / floors that do not interfere** | **[G]** a level **filters before the cut**, so different sheets never fuse or contend; level 0 is byte-identically free | `X58` |
| **clean render of what you authored** | **[G]** one flat quad per wall, corners **mitered** to a 0 gap; features draw as intervals on the surface | `X61`, `X62` (`G2` ✅) |

**[J] This is a strong hand.** The refuse-with-an-offer contract in particular is the thing most
editors get wrong and it is here *gated against the round trip itself*, which is the only check
that cannot be gamed: the doorstep is correct exactly when it accepts what round-trips and refuses
what does not.

### What is missing before an editor can ship

| gap | severity | note |
|---|---|---|
| **the editor** | — | **by design** (`L6`). Consumer-side. Not a hexbody defect |
| **the coarse-quantum presentation obligation** | **[J] medium** | The user accepted the 5.408 m in-between quantum *"as long as they are clearly visible inside the editor"*. The **mechanism is gated** (`wall_snap_p`, `run_end_dist`); the **showing** is consumer-side and unbuilt. This is a promise hexbody has made and cannot itself keep |
| ~~**`fits?` covers form + ONE run**~~ | **CLOSED 2026-07-24** | `src/hexfit.loft` + `tests/fit.loft` (`X65`, `X66`). Features and arcs refuse off-grid values with a named reason, an offer and a residual — **0 false accepts, 0 disagreements** against what actually recovers. Levels and terrain were **measured to have nothing to refuse**, which is a result, not a gap. The `h_height` fork is now **closed** — moros's `Hex` is the storage of record (`SPEC` **L13**), heights are integers at `0.25` wu (`X67`) |
| **one embedded run per stencil** | **[G]** known, recorded | Several need the interior edges split into connected components first (`X60`) |
| **L-shaped houses are not authorable** | **[G]** a real limit, written down | `I3` makes the wall the boundary of the fill, so a reflex corner enclosing no distinct cells is invisible to the field (`X46`). Not a bug — a grammar limit the editor must express |
| **no `Plan`-as-primitive doorstep** | **[J] medium** | `Plan` is continuous-then-rasterised; `X62` measured that its corner is *quantised away*. An editor that shows the user a continuous rectangle is showing them something the field does not hold |

---

## 3. Game assets — what is real and what is claimed

### The founding claim, and how far it is honoured

The project's premise: *collision **proxies are derived from the geometry itself***. That is the
part that distinguishes it from "a mesh and a hand-drawn hitbox".

| the claim | status |
|---|---|
| the wall's **analytic surface** is exact, not fitted | **[G]** direction *exactly* a heading (zero cross product, 24/24), position an exact rational, no tolerance (`X47`) |
| it renders as **one quad per side**, mitered | **[G]** 38 stored edges → 4 quads, `eave_spread` exactly 0; miter gap exactly 0 at 48/48 corners (`X61`, `X62`) |
| the **proxy** is tagged from the geometry | **[G]** `cut_arb` tags each boundary edge with its **nearest analytic surface**, 66/66 and 112/112, order-free, ties to the lower id (`X54`, `X55`) |
| a **posed body** meets the world within machine ε | **[G]** `ε_seam ≈ 7.1e-15`; a routed query agrees with an exact integer oracle on all 1681 grid points, interiors exact. The forbidden fix (snapping the body to the world lattice) misclassifies 12 interior cells — so 0 is a result, not a tautology (`X53`) |
| arbitration is **order-free and fail-safe** | **[G]** owner = lowest id among solids; a world gap under a body solid reads solid, no fall-through (`X53`, `I4`) |
| **determinism** | **[G] partly** — the seam and arbitration are deterministic functions of their inputs by construction (`L7`/`I9`). **[J]** untested as a *replay*, because there is nothing animate to replay yet |

**[J] The static-asset story is genuinely good.** For a building that does not move, you can emit
clean wall quads and a collision proxy derived from the same geometry, and trust both exactly.
That is more than most pipelines can say.

### What is not built

| missing | status |
|---|---|
| **`G1` moving body** (revolute joints, wheel angle = travel/radius) | **not built** |
| **`G3` interaction** (swept volumes, `dt`-independent) | **not built** |
| **`G4` vehicles** (the train) | **not built** |
| **`G6` destruction** (ruins, crumble, wall-becomes-floor) | **not built** |
| **`G★` the demo, `G✦` the colossus** | **not built** |
| **mesh export** | **not built** — `G2` *computes* the quads; nothing emits a mesh format. **[J] small but real: an asset you cannot export is not an asset** |
| **roofs** | **[G] partly** — `hexroof` is a byte-identical copy of crawler's, but `tests/house.loft` *does* exercise it: `draw_roof`, `roof_ponds` (must be 0) and `eave_spread`. **[J]** That gates *drainage and the eave*, not the roof as a recoverable object — no roof goes through `draw`/`rebuild`, so it has no round-trip status |
| **roads** | **[B] and unexamined** — `hexway`'s `Track` is a float world-space curve with **no lattice anchoring**. `X55` gated *linework* (`d ∈ D`), which is a different thing. Treat "stencils carry roads" as unverified |
| **terrain generation** | **not built** (crawler's plan #8 is *"Future — nothing built"*). A **producer**, not a round-trip question, so it blocks nothing here |

---

## 4. ~~The biggest risk~~ — GATED on 2026-07-24, and here is what is left

> **UPDATE — this section's headline claim is now out of date, and deliberately left visible.**
> The foxel was gated the same day this file was written (`X63`, `X64`, `tests/foxel.loft`). What
> follows is the original assessment, then what actually happened. The **[J]** call was right about
> the risk and right about the priority; it was **wrong that the schema had never been exercised as
> a storage format** in the sense that mattered — the machinery was there, nobody had pointed a
> gate at it.

**The original claim:**

> **The foxel schema is still T4.** `layer* × point → (height, material, wall1, wall2, wall3,
> item)` — `X11`–`X15`, *shape real, behaviour unverified*.

That schema is the **storage layer the entire design is written against**. It is what closed
`OD-2`, `OD-3`, `OD-4`, `OD-6`, `OD-7` and `OD-8`, and it is what makes `fits?` syntactic and
finite. Every "the round trip survives because the feature lands in a slot the recovery does not
read" result (`X51` door, `X58` level, `X59` terrain, `X60` run) is an argument **about slots in
this schema**.

**[G] Checked while writing this file:** the string `foxel` occurs in `src/` and `tests/` **only in
comments**. The working representation is `HexSet` + `EdgeSet`, which *models* the schema; **no code
here writes a foxel, reads it back, and checks it.**

**[J]** The round trip has been verified end-to-end many times over, so the schema is very unlikely
to be *wrong* in shape. But it has never been exercised **as a storage format**, which is a
different claim from the one all those green gates support. Every other load-bearing thing in this
repo has been dragged to T1; this one has not, and it is the one underneath all the others.

**[J] If I could gate one more thing, it would be this**, ahead of any new feature.

### What happened when it was gated

**[G] The schema held, in every slot.** Footprint → `OCCU`, `height` → `HGHT`, `material` → `LABL`,
`wall1..3` → `EDGE` (the halo grid, literally ×3 per cell), `item` + rotation → a named `LAYR`
section, and `layer*` — the **storey** sense — is **N documents, not a section**. All compared
exactly after a write/read: **0 diffs everywhere**. And the whole model trip crosses:
`write(rebuild(load(store(draw(read(T)))))) = T` **byte-for-byte, 6 of 6** in-between directions.

**[G] `X15`'s lossy writer is now a live control.** moros's own admission was that its writer
*"never builds an `EdgeSet`"*; reproduced here (`has_e = false`) it returns **0 of 38** edges and
**breaks the trip**, while still carrying the footprint — so it is the *documented* loss, not a
broken write. That is the control moros's own test could not fire.

**[G] The gating found a second thing, and it bit this gate first.** `doc_write` **appends**: a
reused path leaves the second document unreachable and the reader returns the **first** with
`doc_code == HXF_OK` (`X64`). Worse, the obvious instrument for detecting it — write twice, compare
byte lengths — reads **0 and 0**, because **`file().content()` returns empty for non-UTF-8 bytes,
silently** (loft, both backends; filed as `crawler/LOFT-HANDOFF.md` **H7**). `0 == 0 * 2` is a
vacuously true *"it appended"*, and this gate **printed exactly that** before it was caught. Both
are now `SPEC` **L12**.

**[G] What is still T4, and the split matters.** `X63` did **not** touch the **palette**: `X12`
(`wd_body`, `wd_thickness`) and `X13` (`ItemDef` / `MaterialDef` categories) are untouched by any
gate here, and `X14`'s *5-bit, 0–23* is still a claim about moros even though the rotation slot
round-trips. **Cite the split, never "the foxel is gated".**

**[G] UPDATE — the palette is now SCHEMA-CHECKED every run** (`X69`, `X70`). moros's *behaviour*
is still T4 and always will be from here, but its *shape* is verified against moros's own source on
every `make test`, which closes the way a transcribed claim rots. It also surfaced one real
disagreement: moros stores a door as material 0 (*"a door is a gap"*), and measured that **breaks
the wall** (38 edges/0 ends → 36/2). An opening is never absence — it carries its own geometry.

**[J] The residual risk is much smaller and has moved.** What is unverified is now a *vocabulary*
(which body shapes and categories exist), not a *mechanism* (whether the model survives storage).
A wrong palette costs an enumeration value; a wrong storage layer would have cost the design.

---

## 5. Where to pick up

*Rewritten 2026-07-24 after items 1–2 and the palette landed. M0's round trip is closed; the whole
storage/doorstep/vocabulary stack is now gated or schema-checked.*

### Done since this file was written

| | |
|---|---|
| ~~gate the foxel schema~~ | **DONE** — `X63`, `X64`, `tests/foxel.loft`. See §4 |
| ~~finish the doorstep~~ | **DONE** — `X65`, `X66`. Corrected `X48` (the feature grid is two families) |
| ~~the `h_height` fork~~ | **CLOSED** — `L13`/`L14`, and moros's `HEIGHT_SCALE = 0.25` already fixed the unit (`X67`, `X68`) |
| ~~the palette~~ | **DONE** — `X69`, `X70`. Schema-checked every run; found the door disagreement |

### The frontier now

0. ~~**Arm a forward gate before writing body code. [G] there is currently none.**~~ **DONE —
   `tests/joint.loft`.** The observation held: `SURFACE_LANDED` was `true` and `run_red` was defined
   but uninvoked, so the project was entering its first unbuilt half with **zero armed tripwires**,
   having just credited that pattern (§6) for its best result. **[G]** The gate is now written and
   held red — `run_red` fails if it prints `JOINT OK`, fails if it is red for any other reason, and
   a tripwire flips it to `JOINT BLOCKED` the moment a body verb is declared in `src/`. Both
   controls verified live. It states the two checks `G1` must satisfy: **purity by two different
   paths** (one call always equals itself, so a single path proves nothing) and
   **`skid = |r·θ − d| = 0`** with the spec's own spin-off-travel control.
   ⚠ **[J] It deliberately does NOT assert the joint round trip.** I had called `I6` *"a round
   trip (joints → pose → recover joints)"*; writing the gate corrected that. `I6` gives a
   **function**, not an injective one, and `θ` vs `θ + 2π` is the obvious collision — so
   `recover_joints(pose(j)) = j` needs a stated domain, which is a `DESIGN.md` §10 decision before
   it is any gate's assertion. Same shape `X38`'s census settled for `draw`.
1. **Start the body** (`G1`) — the first genuinely new subsystem, and the half of "hexbody" that
   does not exist yet (`G1`/`G3`/`G4`/`G6` are all unbuilt). Largest by far. Read `crawler` first
   (`bodytest`). **[J] this is the real next milestone**; everything before it was M0 finishing.
   ⚠ **It is also the first milestone with no round-trip framing** — M0's method (a corpus of
   committed bytes, a byte diff) does not transfer to motion unmodified. See item 0.
2. **Mesh export** — still small, still the thing that most directly unblocks "assets in a game".
   `G2` computes the quads; nothing emits a format.
3. **An opening body in the palette** — `wd_body` has no `DOOR`/`OPENING`/`DOORWAY` (`X70`). moros
   owns the palette and `L13` means hexbody consumes it, so this is **upstream work**, not hexbody's.
   Until it exists, an opening has no geometry to render.
4. **Multiple runs per stencil** — the recorded `OD-13` remainder; needs the interior edges split
   into connected components first.
5. **The roof material** — `draw_roof` writes 27 heights and 0 materials, so a roof cell is
   indistinguishable from terrain at that height (`X69`). Costs nothing today; fixing it means
   deciding what a roof material *is*.

### The coverage ledger, and what it says

**[G] Measured 2026-07-24 by applying `SPEC`'s own rule** (*a gate defending no spec item, or a spec
item no gate defends, is the thing to fix*) — the count lives in [`SPEC.md`](SPEC.md) beside the
gate map. First pass: **56 spec items defined, 33 defended, 23 not**, of which **21 were unbuilt on
purpose** (the body half, plus limits not yet violable because there is no simulation to overreach)
and exactly **two were checkable today and unchecked** — `L6` (the seam) and `L8` (scale).

**[G] Both are now gated** — `tests/scope.loft` and `tests/scale.loft`, four and five controls
respectively. **56 defined, 35 defended, 21 not, and the checkable-but-unchecked column is empty.**

**[G] Each found something.** `L8`'s ladder is exact — a hex step is `3/2` m, `WALL_W` is `1/4` m,
`BAND_SIDES` is `3/4` m, all within **1 ulp** — but the figure `SPEC` L8 *prints*, `0.866`, misses
by 4.4e-5, nearly **2e11 ulps**: the doc's three-decimal value is for reading and must never be
computed with. And `L6`'s first scanner reported a violation in `mat_opacity`, because *"city"* is
a substring of *"opacity"*; matching whole `_`-segments fixed it, and a control now pins that a
rename of innocent code is never demanded.

**[J] That ratio is the honest headline of this file.** Nothing load-bearing that *could* be gated
is ungated. The gap is entirely "not built yet", which is a schedule, not a debt.

### Open decisions, all recorded rather than pending

- **Where a door's OPEN/CLOSED state lives** (`DESIGN.md` §10.28) — two wall ids (**recommended**:
  free, round-trips today, collider derived at layer 2) vs an `L14` overlay. No round-trip
  consequence either way, which is why it can wait.
- **The body's decisions and its one live fork now live in a plan, not here.**
  [`plans/m1-moving-body/DESIGN.md`](plans/m1-moving-body/DESIGN.md) is the in-flight tier for M1,
  opened 2026-07-24 because M0's `DESIGN.md` belongs to a closed plan and the body's material was
  landing in `SPEC` rows and in this file — the formal and synthesis tiers. In one line each:
  - **[G] A body is a RIG** — `⟨bones, joint limits⟩`, never a pose; **flex is joints**, not
    deformation (`SPEC` **I-POSE**; DESIGN §0, §2).
  - **[G] The game's state is not the world's** (`SPEC` **L15**; DESIGN §0, §3) — so a pose is
    *game* state, `L13` never had to hold it, and the world stays reconstructable from the voxels.
    The limit **arrived already defended**: `tests/scope.loft`'s vocabulary is exactly its
    violation condition. ⚠ Its *opt-in* half is not yet checkable — it needs an offered structure
    to exist first.
  - ~~**Is joints → pose injective?**~~ **Dissolved**, not answered (DESIGN §1.1): joints are
    authored and the pose is derived, so nothing ever runs that recovery — it is inverse
    kinematics, non-unique by nature. **[J] Fifth instance of the slot pattern** (`X51`, `X58`,
    `X59`, `X60`): motion lands outside the authored model entirely.
  - ⚠ **UNRESOLVED — do `G4` (the train) and `G★` (the derailment) remain hexbody's goals?**
    `L15` says the engine does not know a train from a dock and does not model future state; those
    two goals name both, as do `I10`/`I11`, and `L1` calls `G★` the one place dynamics is *earned*.
    **[J] Likely they become consumers in their own projects** — a harness proven by something
    outside itself is stronger evidence — but that changes what the project claims, so it wants an
    explicit answer. Costs of each reading: DESIGN §3.
- **OD-1** the morph — narrowed to *probably unnecessary* by free poses.
- **OD-5** is the flip exact — `X2` and `X57` both say yes at T1. **[J] closeable by inspection
  rather than new work.**

### What can no longer be re-derived cheaply — read these first

`SPEC` **L13** (the voxel is the ceiling on permanent world state) and **L14** (a side table is
area-limited *and* time-limited) are **user decisions**, not findings. They bound `𝕄*` and they are
why `h_height` quantises. `X70`'s taxonomy — an opening is never *"no wall"* — is likewise a
decision with a measurement behind it, not a preference.

---

## 6. What this project got right, worth not losing

**[J]**, but grounded in the record:

- **The tripwire pattern.** `SURFACE_LANDED` sat `false` from S4 to `G2`, printing PENDING, and
  fired on exactly the step it was aimed at (`X62`). Better than both a permanently red suite and
  a forgotten TODO. **Reach for it for the next requirement that outruns its machinery.**
- **"The feature lands in a slot the recovery does not read."** Seen four times now (`X51`, `X58`,
  `X59`, `X60`). It is the first thing to try on any new feature, and each time the *tempting*
  design changed the cells and the control was to do exactly that and watch recovery break.
- **A count that disagrees with a gated number by a clean factor is a bug in the counter.** Earned
  five times, most recently `X62` part 2 (24/48 = exactly half). Zero real defects among them.
- **Re-derive the instrument before confirming the number.** An 8.5-minute widened search
  "confirmed" a false finding because it shared the broken helper (`X60`).
- **A comment asserting "this case never happens" is a claim like any other.** `wall_separates`'
  comment was load-bearing, wrong, and sat under a green suite (`X57`).
