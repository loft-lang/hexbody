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

## 3. ⚠ OPEN — do `G4` and `G★` remain hexbody's goals?

**This is the one live fork in this milestone, and it is a decision, not a measurement.**

`L15` says the engine does not know whether a piece of geometry is a train, and does not model
future state. Two `SPEC` goals name exactly a domain and a time evolution:

- **`G4`** — *"the train: a coupled car+wagon follows a curve, wheels `= travel/radius`, wagon in
  line, detaches on decouple"*, checked by *"vehicle gates"*.
- **`G★`** — *"a coupled train off the rails tumbles, piles, settles to a **deterministic** rest"*.

`I10` (a coupling point stays coincident) and `I11` (the forward trailer-follow is stable) are the
same shape, and **`L1` names `G★` as the one place full rigid-body dynamics is *earned*.**

**The likely reading**, from the user's own clarification: *"we still can provide routines for any
specific instance we listed — they cannot be part of the world… but we can add simulations and the
like. Those will probably live eventually in different projects, to prevent clutter."* So `G4`/`G★`
become **consumers** — demos built *on* hexbody, in their own repos — which is consistent with the
harness thesis (*live-test a game system before art exists*; a demo is a consumer).

**What it costs either way:**

| | if they stay hexbody's | if they become consumers |
|---|---|---|
| `SPEC` | `G4`, `G★`, `I10`, `I11` unchanged; `L15` needs an explicit carve-out for the earned set | `G4`, `G★`, `I10`, `I11` move out; `L1`'s *earned set* becomes empty and `L1` simplifies |
| `tests/scope.loft` | must stop refusing `train`/`vehicle`/`wagon` in `src/` | unchanged — it already encodes the strict reading |
| the demo | hexbody proves itself | hexbody is proven *by* a separate repo, which is a stronger claim about the seam |

**Recommendation: consumers.** A harness demonstrated by something outside itself is better evidence
than one that demonstrates itself, and it is the only reading under which `L15` needs no exception.
But `SPEC` currently says otherwise in four places, so this wants an explicit answer.

Until it is answered, `tests/scope.loft` encodes the strict reading and would refuse a `train_*`
declaration in `src/`.

---

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
