# `m1-moving-body` — DESIGN, the in-flight half

**Cite nothing from this file as fact.** Everything here is a proposal, a consequence still being
worked out, or an open question. What is settled lives in [`../../SPEC.md`](../../SPEC.md) (what
must be achieved) and [`../../ROUNDTRIP.md`](../../ROUNDTRIP.md) (what the objects are) — this file
carries the reasoning those two must not.

*Opened 2026-07-24, because the body's decisions were otherwise landing in `SPEC` rows and in
`ASSESSMENT.md`. `m0-roundtrip/DESIGN.md` is the same tier for a plan that is closed.*

---

## 0. The four decisions this milestone starts from

All four are **the user's**, made 2026-07-24. A measurement cannot overturn them; they bound what
may be designed. Recorded formally where each belongs, and reasoned about here.

| decision | formal home |
|---|---|
| a body is a **rig** — `⟨bones, joint limits⟩`, never a pose | `SPEC` **I-POSE** |
| **flex is joints**, not deformation | `SPEC` **I-POSE** |
| the game's state is not the world's; hexbody offers containers, never content | `SPEC` **L15** |
| **now** is the only tense; no universal domain abstraction | `SPEC` **L15** |

---

## 1. What M0's method gives the body, and what it does not

**It does not transfer wholesale.** Every gate in M0 compares committed bytes to recomputed bytes —
`write(rebuild(draw(read(T)))) = T` over a corpus of 119 entries. A moving part has no corpus,
because motion is not authored.

**What transfers is the split.** A rig is a *description*, exactly the kind of object a stencil's
`Form` is: finite, authorable, static. So phase A inherits M0 whole — a canonical text, a byte-diff
round trip `write(read(R)) = R`, a doorstep that refuses what would not survive it, and a census if
the admissible space needs deciding. The **pose** is on the other side of that line: derived, never
authored, never committed to a corpus.

> **The rule to reach for, now five times earned** (`X51` door, `X58` level, `X59` terrain, `X60`
> run, and now motion): *the round trip survives a new feature exactly when that feature lands in a
> slot the recovery does not read.* Motion lands **outside the authored model entirely**, which is
> why it costs the round trip nothing.

### 1.1 Why there is no joint round trip, and why that is not a gap

An earlier framing (mine, and wrong) called `I6` *"a round trip: joints → pose → recover joints"*.
`I6` gives a **function**, not an injective one. `θ` and `θ + 2π` are the obvious collision, so
`recover_joints(pose(j)) = j` would need a stated domain — and recovering joints from a pose is
**inverse kinematics**, which is non-unique by nature.

The rig decision **dissolves** the question rather than answering it: joints are authored and
stored, the pose is derived, so nothing ever needs to run that recovery. The body's round trip is on
the rig text. **`tests/joint.loft` §3 records the dissolution and asserts nothing.**

---

## 2. Flex is joints — the consequence most likely to be missed

> *"An airplane is an interesting one, because in any realistic scenario the wings have to be
> different defined objects, they are attached but not rigid, otherwise they would fail
> immediately. They can bend quite a bit upwards."* — user, 2026-07-24

A part that bends is **more bones**, not a soft bone. The flex is expressed as joint values along a
chain and the aggregate bend is their composition.

Three consequences, and the third is the one that saves work:

1. **`I6` survives a flexing wing unchanged** — a bent wing is still a pure function of its joint
   values, because the bend *is* joint values.
2. **`fits?` stays local** — each joint carries its own limit; the wing's total travel is what those
   limits compose to. No global deformation constraint to solve.
3. **hexbody never needs vertex deformation, skinning weights, or a soft body.** The reflex when
   someone says "the wing bends" is to reach for skinning; that would break `I6` and buy nothing.

**Open, and cheap to answer when phase A starts:** how many bones does a wing want? That is a
fidelity/cost trade for a *consumer* to make, not a number hexbody should fix — the engine supplies
the chain, the game decides its length. Probably belongs in the rig's doorstep as *no limit*, the
same result `X66` measured for levels.

---

## 3. ✅ ANSWERED — `G4` and `G★` were never deliverables

**Resolved 2026-07-24, by the user, and more broadly than the question asked:**

> *"The demo itself is not hexbody's goal. All these examples are for us to know what to build,
> what to allow — not what to ship. Other projects — the editor, crawler, moros — will build on
> our basis. Our goal is to provide libraries for them."*

So the fork was mis-framed. It was never *"do these stay hexbody's goals or become consumers"* —
they were **requirement sources all along**, and reading them as deliverables is what made them look
like a contradiction with `L15`.

**What that changes, concretely.** `G4`, `G★` and `G✦` moved out of `SPEC`'s Goals table into a
**Use cases** section: each names the capability the libraries must *allow*, and is satisfied when a
consumer *could* build it. `I10`/`I11` (coupling coincidence, trailer-follow stability) are the
train's invariants and stay the **consumer's to satisfy** — hexbody's obligation is to make them
**expressible**, not to implement them. And `L1`'s *earned set*, which named `G★` as the one place
full rigid-body dynamics was earned, is now **empty here**: dynamics is a consumer's call in a
consumer's project, and what hexbody owes is that its libraries do not *prevent* one.

**The recommendation I had made was right for the wrong reason.** I argued "consumers, because a
harness proven by something outside itself is stronger evidence". True, but beside the point: the
demos are not evidence hexbody owes at all. They are how we *learn the requirements*.

### 3.1 ⚠ And the real consequence, which is bigger than the fork

**`G-LIB`: a capability is not done when a hexbody gate is green — it is done when a consumer can
depend on it.** Measured the same day:

- `loft.toml` has **no `[library]` entry**. hexbody is packaged as the *application* kind, like
  crawler; `hex_field` — a real library — declares `[library] entry = "src/hex_field.loft"`.
- **No consumer references hexbody**, checked across `../crawler` and `../moros`.
- So the only way in is `--lib ../hexbody/src/` at a working tree — **the exact unpinned-tree
  fragility that broke this suite on 2026-07-24**, and it would break a consumer's the same way.

**Open, and it is a design decision rather than a packaging chore: what is the library split?**
hexbody has 20 modules. One library, or several? The natural seams look like *form/text/census*
(the grammar), *wall/surface/box/arc* (the geometry), *edge/way/roof* (already crawler's, and due to
land in `loft-libs-world` anyway), *fit/draft* (the doorstep) and *frame/seat/combine* (placement).
**Do not guess it** — and the reason got stronger the same day: *"there will be similar other projects in the future: world creation, world simulation, weather, physics simulation for that — probably their own project to prevent clutter, almost all of them building in some way on our work."* hexbody is **the base of a family**, so a published seam is as hard to move as a published text
(`A₂`, and `I-EXTEND` says the same law governs the API one level up).

⚠ **CORRECTION to how I first put this.** I wrote *"the split is what consumers depend on"*, which
reads as *survey the consumers first*. The user's framing says otherwise: *"we are pretty much a
programming language — it doesn't define who can use them. Many consumers are there, some known some
unknown."* **A language does not wait to meet its users before defining its primitives.** So the
split is decided from the **objects** — `ROUNDTRIP`'s objects and maps, which are already settled and
already have natural seams — and *not* from what the editor, crawler and moros happen to need this
month. Designing for the three known consumers is how you get a seam that breaks the fourth.

This wants its own plan, and `loft-ship` is the skill for the cross-target parity half.

## 4. Open, smaller

- **Does a saved world persist a pose, or re-derive it?** Answered in principle by `L15` — a pose is
  *game* state, so it is the game's to keep and `L13` never had to hold it. What is left is whether
  hexbody offers a **container** for it (`L15` permits one, keyed by location and blind to the
  payload) or stays out entirely. Cheap either way; needs a consumer to want it first.
- **`L15`'s opt-in half is not yet checkable.** *"Nothing on the geometry path depends on an offered
  structure"* needs an offered structure to exist. The check is a `use`-graph assertion in
  `tests/scope.loft` and should be written the same day the first container is.
- **`X17` is still T3** — crawler's *"two levels, no more: an anchor, and parts in the anchor's
  frame"*. It is a design try, not a measurement. **Re-measure here before the rig's shape leans on
  it**, exactly as `X52`/`X58` were re-measured from crawler prototypes.
