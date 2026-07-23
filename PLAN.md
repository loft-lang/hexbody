# PLAN — producing the derailment: what to build, in what order

**hexbody production plan.** The design corpus ([`VISION`](VISION.md),
[`ARCHITECTURE`](ARCHITECTURE.md), [`design/*`](design/)) says *what* and *why*;
[`ROUNDTRIP`](ROUNDTRIP.md) and [`SPEC`](SPEC.md) say *what is true, checkably*; this says
**what to produce, in what order**. The target is the **derailment hero demo** — the first
full-stack acceptance test. The **foundation is M0, the round trip** — it determines the block
everything else is built on — and its first move is the **stencil census**. Sequenced by the
critical path.

Each milestone lists **produce** (the loft modules), **gate** (with a control that must fire),
**depends on**, and **done when**. Names like `proxy.loft` are proposed, not fixed. Each
milestone earns its own detailed plan directory when it is *started* — the org plan convention,
imported from crawler and bound for hexbody in [`plans/README.md`](plans/README.md). This file
is the synthesis layer (crawler's `ROADMAP.md` role), not a plan index.

---

## The critical path

```
  M0 ROUND TRIP ── infrastructure; everything below sits on it ──┐
      │                                                          └──▶ M4 render + editor ─┐
      └──▶ P body ─▶ M1 body ─▶ M2 interact ─▶ M3 train ─▶ M5 destruction ─▶ M6 DERAILMENT ─▶ M7 colossus
```

**M0 is infrastructure, not a track.** It fixes what a body *is* — an exact original plus a pose,
never stamped into the world lattice — and where imprecision may live. Nothing else can be built
first without guessing those answers and rebuilding later.

Two tracks then converge on it: the **mechanics spine** (body → interact → train → destruction →
dynamics) and the **visual track** (render → editor). The derailment needs both, so neither can
be left to the end.

**Which half of M0 gates what** — stated honestly, because they are not equally urgent:

| M0 half | what it settles | gates |
|---|---|---|
| **representation** — `ROUNDTRIP` §2.3 · `DESIGN` §3.1, §6 | body = original + pose; the field is derived; frames, the seam, arbitration | **the mechanics spine** — `body.loft` cannot be written without it |
| **exact recovery** — laws **D**/**E₂**, the censuses, `write`/`read` | the model is recoverable from the field, provably | **the editor / indie path**, and re-canonicalising after damage |

---

## P — the Body and joint model *(prerequisite)*

hexbody today has `housedraw` / `hexedge` / `hexway` / `hexroof`; it has **no Body**. Build it —
a `Stencil` + a continuous pose + a **part-tree of joints** — fresh in hexbody, informed by
crawler's `hexwheel` / `hexhinge` / `hexseat`, to ARCHITECTURE's part-tree and *joint-value-is-
the-interface* rule.

- **produce** — `body.loft`: `Body`, `Part`, `Joint` (revolute / prismatic / coupling); each
  part's world pose evaluated from its joint values up the tree.
- **gate** — a two-part tree evaluates the child's pose from the joint; **control:** feed a joint
  value and the child moves, feed none and it sits at rest.
- **depends on** — `hex_field`, `housedraw`.
- **done when** — a `Body` holds a part-tree and derives every part's pose from its joints.

## M0 — the round trip *(infrastructure — the block everything else is built on)*

The exact model is drawn onto the field and **rebuilt from it exactly**. Formally:
**[`ROUNDTRIP.md`](ROUNDTRIP.md)** (settled core) + [`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md)
(the in-flight half). This is not "the fit": it is a
**recovery**, and the word matters, because an exact-invariant domain punishes every approximation
you reach for instead (`DESIGN` §11).

- **produce** — the stencil census → `Cyc`; the linework census → `period`, `D`, `Sep`;
  `write`/`read` (canonical text); `fits?`/`snap` (the one chokepoint, shared with the editor);
  `rebuild`.
- **gate** — `rt_census_a` (grown by level, **reports the frontier**) · `rt_canon` · `rt_project` ·
  `rt_fits` · `rt_closure` · `rt_door` · `rt_close` · `rt_extend` · **`rt_trip`** —
  `write(rebuild(draw(read(T)))) ≟ T`, a **text diff**, no `ε` · `rt_total` · `rt_ruin` ·
  `rt_seam` · `rt_contend` · `rt_flip` · `rt_drift`. Controls per `DESIGN` §9; the spine
  control is a non-fitting model bypassing `snap` → diff.
- **depends on** — `hex_field`, `housedraw`. `rt_orient` (law **I**) is **already green**:
  `housetest`, 12/12 in cells *and* edges. **And on `../crawler`** — much of this is prototyped
  there, and `ROUNDTRIP` §7 lists ten constraints (**X1–X10**) already measured or gated.
- **done when** — `rt_trip` is green over every primitive kind, and the census has **located the
  frontier** (the restrictions are M0's output, not a pass/fail).

> **Read before starting.** `ROUNDTRIP` **§7** — what crawler already settled (exact rotation
> *and reflection*; all 24 headings representable; order-free nearest-wins arbitration; the
> refusal gate) — and [`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) **§10, OD-5…OD-8**, four conflicts with that prior art.
> **OD-6** (is a stencil a *field* or a *generative description*?) is the deepest and probably
> orders the rest, because it decides how much of laws **D**/**E₂** is even load-bearing.

**Order inside M0 — grow, don't presuppose** (`DESIGN` §8). The **stencil census** is first,
and it is a **ladder**: the smallest closed form (an equilateral triangle, `len 1`), then longer
sides, more sides, unequal sides, reflex corners, features, arcs — and finally **combination**,
where forms that round-trip alone stop doing so together. Each rung enumerates exhaustively, so
within the frontier law **F** is *decided*; the outer loop is what discovers where the frontier
is. **The restrictions are M0's output, not its input** — defining the admitted space first would
presuppose exactly the bounds being sought.

`rt_trip` is written **before** `rebuild` exists (it needs no ground truth, only
`write`/`read`/`draw`/`rebuild` and `diff`), and goes green when `rebuild` becomes correct.

**Blocking the grammar freeze:** **OD-2** — are roofs inside the exact round trip?
`hexroof.loft:493` `roof_match(..., tol: float)` is the `ε` law **P4** forbids. The census does
**not** need this answer; freezing `⟨roof⟩` does.

*(The straight/arc surface — crawler `BUILDING.md` §4, the old "M0 fit" — is the recovery for
domain B linework and one part of this, not a milestone of its own.)*

## M1 — the moving body *(the first brick)*

A `Body` with one revolute joint (a wheel) that moves by **derived** motion and carries an
**error-bounded proxy**.

- **produce** — `proxy.loft` (footprint → oriented box, bounded); `bodytest.loft`.
- **gate** — wheel angle `= travel / radius`; `proxy ⊇ footprint`, overshoot `≤ X m`, across all
  12 orientations; **controls:** spin the wheel off-travel → it skids; shrink the proxy below the
  footprint → a real overlap is missed.
- **depends on** — P.
- **done when** — `bodytest` is green: derived motion + per-part proxy, gated. *(This is the
  housetest-sized first coding step.)*

## M2 — bodies interact *(the one chokepoint)*

The swept-crossing test: two bodies of different scale collide **dt-independently**, through
**one** function.

- **produce** — `interact.loft` (or adopt `hexedge`'s `sweep_path`).
- **gate** — interaction **iff** swept volumes cross; no tunnelling at any `dt`; **control:** an
  instantaneous-position test → a fast pass tunnels.
- **depends on** — M1.
- **done when** — a person-scale and a truck-scale body register interaction correctly at every
  speed and frame rate.

## M3 — the train, kinematic *([`VEHICLES.md`](design/VEHICLES.md) realized)*

Couplings + the follow + correct wheel turning; a coupled train follows on rails, wheels turn,
wagons stay in line.

- **produce** — `couple.loft` (hitch + drawbar, breakable); `follow.loft` (trailer kinematics).
- **gate** — the VEHICLES gates: coupling coincident · follow obeys rolling · corner-cut correct
  · wheels `= travel/radius`, front steers · stays in line forward; each with its control.
- **depends on** — M1, M2.
- **done when** — a two-body car-and-wagon follows through a curve, wheels turning, wagon in
  line, and becomes a free body on decouple.

## M4 — presentation: render + the transparent editor *([`EDITOR.md`](design/EDITOR.md), [`PLACEMENT.md`](design/PLACEMENT.md))*

Render bodies (via the fit); the morph-based orientation; the side-by-side single-authored
editor; seating on terrain.

- **produce** — the renderer; `morph.loft` (minimal affine best-fit to the lattice); the editor;
  `seat.loft` (best height + terrain morph).
- **gate** — the EDITOR gates (live equivariance, morph bounded, derived-never-authored, residual
  shown) + the PLACEMENT gates (best height minimises earthwork, seated terrain drains, skirt
  respects repose).
- **depends on** — M0 (fit), M1, the morph.
- **done when** — a building shows in every orientation from one authoring pass, seated on the
  actual terrain, in a side-by-side editor.

## M5 — destruction + the tiltable-interior atlas

The destruction models (ruins / crumble / floor-to-hill) + the walls-become-floors atlas.

- **produce** — `destroy.loft` (the three field-native transforms + run-ids); `atlas.loft` (the
  patch shell, gravity-selected floor, seam-crossing).
- **gate** — proxy re-derives after any mutation; a wall crumbles mass-conservingly; a floor
  becomes a hill plane; **the two-patch probe** — a wall becomes a floor under tilt, continuously.
- **depends on** — M1, M2.
- **done when** — the three destructions run re-deriving the proxy, and the two-patch tilt seats
  a walker on a former wall.

## M6 — THE DERAILMENT *(the hero demo · first full-stack acceptance test)*

Dynamics scoped to **plausible rest**, **deterministic**; the interior tilting through the tumble.

- **produce** — `dynamics.loft` (free rigid bodies: gravity + momentum + collision response +
  resting contact, fixed-step, deterministic); the demo scene.
- **gate** — the six [`DYNAMICS`](design/DYNAMICS.md) gates: continuous handoff · deterministic
  (byte-identical rest on replay) · settles · no tunnelling · interior tilts through the tumble ·
  nested frame.
- **depends on** — M2, M3, M5, and I-CROSS-in-a-moving-frame.
- **done when** — a coupled train run off the rails tumbles, piles, settles to a **deterministic**
  rest, its interiors rolling through — and a cold viewer reads it as a train wreck. **This is
  the milestone the whole plan aims at.**

## M7 — the colossus *(the larger capstone)*

Procedural, destructible, climbable in its moving frame, crushing buildings, losing a decoupled
limb. The bigger acceptance test, once the derailment has proved the stack integrates.

---

## Where the effort and the risk concentrate — read before sequencing

- **M0 the round trip is infrastructure, not a parallel track.** It fixes what a body *is* and
  where imprecision may live; build the spine ahead of it and you guess those answers, then
  rebuild. Its cheapest, most decisive piece — the stencil census — is also its first.
- **M6 the dynamics is the frontier.** Scope to *plausible rest*, build *deterministic from line
  one* (it cannot be retrofitted, `DYNAMICS` §5), and guard the whole way against the
  infinite-physics-engine sink.
- **M5 the atlas (walls-become-floors) is a candidate, not a proven design.** Pin the two-patch
  probe on paper/throwaway before the general system — it is the load-bearing invariant of the
  whole tiltable-interior frontier.
- **Determinism (M6) and the round trip (M0) are the two things that are cheap now and expensive
  later.** Both belong early — and determinism is partly *delivered* by M0: byte-equality on the
  canonical text (law **P4**) is a determinism instrument available from the first gate, not only
  at M6. A representation that cannot be spelled two ways cannot drift.

## Start here

**M0, and M0 first.** The round trip is infrastructure — it determines the block everything else
is built on, so building the spine ahead of it means guessing what a body *is* and rebuilding
later. The first move is one thing, not two:

**The stencil census, rung A1** — the *smallest* closed form: an equilateral triangle, `len 1`,
`turn 4` at each of 3 corners, in both heading classes. By law **J** that is the minimum a stencil
can be (`Σ turn = 12`, and three lattice vectors 120° apart sum to zero). Rasterize it, rebuild
it, compare. Then grow (`DESIGN` §8).

It is the right first move for four reasons: each level is **finite**, so law **F** is *decided*
rather than sampled; it needs **no new representation** (`housedraw` already rasterizes); it is
**falsifiable today** against the one thing already green; and its output — `Cyc`, and the
`period` table from its domain-B sibling — is the **shared artifact** both `rt_trip` and the
editor's `fits?` consume, so it is not a throwaway probe.

Every rung is a green increment. Where a rung fails, that failure **is** a restriction — recorded
into `fits?` and carried forward, not patched away.

Then `P + M1` (`body.loft`, `bodytest.loft` with one wheel at `angle = travel/radius`) on top of
a settled representation. Everything after is the loop that built `housedraw`: one exact brick,
one gate with a control seen to fire, then the next.
