# VEHICLES — an articulated chain: a wagon behind a car, truck, or train

**hexbody design.** "Wagons not fixed together" made concrete. A car + caravan, a truck +
trailer, a locomotive + wagons: each is a **separate body** — a stencil, *houses on a smaller
scale* — joined to the one ahead by a **coupling**, and the trailing body **follows** through
*derived* kinematics, not an authored path. It is the canonical case of the derived-motion cell
in the [`ARCHITECTURE`](../ARCHITECTURE.md) geometry × motion table, and it is sealed: the
developer builds a car and a wagon and hitches them; the follow is computed.

Design-protocol order: concrete target, the model, the follow kinematics, presentation, the
honest hard parts, gates. §0's numbers are the *predicted* target — no vehicle code exists yet.

---

## 0. The concrete target (the shape to pin, not yet measured)

A car (2-hex body) with one wagon (2-hex body) hitched behind it. The car drives a curve of
radius ~6 m:

- the wagon **follows, cutting the corner** — its path is *inside* the car's, by an amount set by
  the drawbar length and the wagon's wheelbase;
- the **coupling point stays coincident** — the car's hitch and the wagon's drawbar-eye are the
  same world point every tick, to within ε;
- both render at their **own derived poses**, and each carries its **own collision proxy**, so
  the wagon can clip a gatepost the car cleared;
- unhitch it and the wagon is a **free body** — it rolls straight to a stop on its own wheels.

---

## 1. The model — a chain of bodies joined by couplings

An articulated vehicle is **not one rigid model**; it is a chain of independent bodies:

```
   car  ──hitch──▶  wagon  ──hitch──▶  wagon
   (body, pose)      (body, pose)       (body, pose)
```

- Each **body** is a stencil (footprint, walls, floor) with its own continuous pose (position +
  heading) and its own wheels (`hexwheel`).
- A **coupling** is a joint (`hexhinge` family): a **hitch point** fixed on the lead body and a
  **drawbar** of fixed length on the trailing body, constrained to meet at one world point. It
  is a **breakable** joint (§4).

The chain is only connectivity — the *poses* are derived (§2), so a wagon dropped mid-chain is a
node removed, not a rebuilt model.

---

## 2. The kinematics — how the trailing wagon follows (derived, cheap, gated)

The follow is the classic **trailer / bicycle model**, and **the wheels are what make it work.**
A wheel (`hexwheel`) enforces *rolling*: a wheeled body moves **along its heading**, never
sideways (a non-holonomic constraint). That is precisely why a trailer *swings to align with the
pull* instead of sliding — a sled would just drag.

Per trailing body, each tick:

1. the **drawbar-eye** is dragged to the lead's hitch point (the coupling constraint);
2. the body's **heading turns toward the drawbar** — `heading = atan2(hitch − rear_axle)` — because
   the rear axle can only roll along the heading;
3. the **rear axle advances** along that heading by the distance the eye moved.

Each wagon applies this to the coupling *ahead* of it, so the whole chain articulates through a
curve from the front back — the last wagon cutting the corner the most. It is **derived**
(no keyframes), **cheap** (a few trig ops per body), and **exactly gateable**: the coupling
points stay coincident, and the heading obeys the rolling constraint. This is the derived-motion
face of the body model, in one worked mechanism.

---

### Correct wheel turning

The wheels are not decoration — they carry two derived quantities, both exact and gated:

- **Rotation.** Each wheel's spin angle is `travel / radius` — the rolling constraint from
  `hexwheel`, the `bodytest` + wheel gate. A wheel that rotates too fast or slow *skids*, which
  reads wrong immediately; gated, it can't.
- **Steering.** The lead's **front wheels turn to set its heading**; the rear roll straight. On a
  curve the inner and outer wheels travel different arc lengths (a differential), so their
  rotation rates differ — the same `travel / radius` per wheel, with each wheel's own travel.

So "correct wheel turning" is the wheel derived-motion applied per wheel: rotation from its own
travel, steer angle on the front. Nothing new — it is the wheel primitive doing its job under
the vehicle.

### Wagons staying in line

The forward follow (§2) is **stable**: behind a cab driving straight, each wagon tracks *directly
in line* and stays there — the rolling constraint pulls a drifted wagon back onto the drawbar, it
does not snake or oscillate. Through a curve they track in line along the *curve* (cutting the
corner by the fixed amount), and on the next straight they settle back directly behind. The only
place "in line" breaks is **reverse** (§5), where the follow inverts and goes unstable — which is
exactly why reverse is called out as its own hard case rather than assumed to be forward run
backward.

## 3. Presentation — rendering the articulated train

Rendering is just *draw each body at its derived pose* — there is no special articulated
renderer:

- each wagon is drawn from its stencil at its `(position, heading)`;
- the **hitch** renders as a visible drawbar between consecutive bodies;
- each wagon's **proxy** is its stencil proxy transformed by its pose, so collision, coexistence,
  and the swept-interaction test all work **per wagon** — a long trailer sweeps a wider arc than
  the cab, and that arc is what the proxy tests.

In the transparent editor ([`EDITOR.md`](EDITOR.md)) the chain shows *articulating live* as you
drag the lead through a curve — you watch the wagons cut the corners and see any that swing into
something they shouldn't.

---

## 4. Not fixed together — attach, detach, break off

The coupling is a **breakable joint** (ARCHITECTURE — *breakable couplings*):

- **attach / detach** — hitch a wagon on, drop it off: a node added or removed from the chain;
- **break off under force** — a coupling that exceeds its strength (a jackknife slam, a snapped
  drawbar) breaks, and the freed wagon becomes an **independent body** carrying its residual
  velocity, rolling to a stop on its own wheels.

Both are the same mechanism as gripping-and-being-thrown-off a colossus: *decouple*, which is
**destruction applied to a joint**. "Not fixed together" is exactly what buys this for free.

---

## 5. The honest hard parts

- **Jackknife** — a trailing body can only turn so far relative to the lead before the coupling
  angle folds; past that it jackknifes. The kinematic model needs a **turn limit** at the hitch,
  and hitting it is either a hard stop or the force that breaks the coupling (§4).
- **Reversing is the nasty case.** Backing a trailer inverts the kinematics — the trailer swings
  *opposite* the steer, and the follow model becomes **unstable** (small errors amplify, it wants
  to jackknife). This is the one place the clean forward model does not simply run backward;
  reversing needs its own controller and is honestly flagged as hard, not assumed.
- **Multi-wagon amplification** — each wagon cuts the corner a little more than the one ahead, so
  a long train's tail swings wide; the chain compounds and must be measured, not assumed benign.
- **Kinematic follow is the tractable core; full dynamics is the frontier.** Sway, snaking, the
  momentum of a heavy trailer shoving the cab — that is *simulation*, the bounded-sim line
  (ARCHITECTURE): derive the consequence (the wagon follows), do not simulate the impulse unless
  a specific feature earns it.

---

## 6. Existing primitives, and the seed

Everything this rests on is already vocabulary: `hexwheel` (the rolling constraint that makes the
follow work), `hexhinge` (the coupling/articulation joint), `hexseat` (a driver riding the cab),
the part-tree, and ARCHITECTURE's breakable couplings. **The seed is `bodytest` + a wheel**
(the roadmap's first brick) plus **one coupling and the follow step** — a two-body car-and-wagon
is the smallest thing that exercises the whole design.

---

## 7. Gates — each with a control that must fire

| gate | control |
|---|---|
| **coupling stays coincident** — hitch and drawbar-eye are one point every tick | let the eye drift free of the hitch → the wagon detaches geometrically without a decouple |
| **the follow obeys rolling** — the wagon moves along its heading, never sideways | let the rear axle translate off-heading → the wagon "crabs" sideways, which a wheel cannot |
| **wheels turn correctly** — each wheel's rotation = its own travel / radius; front wheels steer the heading | spin a wheel at a rate independent of travel → it skids; drive a curve with equal rotation on inner and outer wheels → they skid on the differential |
| **stays in line forward** — a wagon drifted off the drawbar returns to line and does not snake behind a straight-driving cab | give the follow gain that overshoots → the wagon oscillates instead of settling (proves the forward model is stable, and isolates that reverse is not) |
| **corner-cut is correct** — the wagon's path is inside the lead's by drawbar+wheelbase | draw the wagon rigidly aligned with the cab → it does not cut the corner (a rigid, not articulated, chain) |
| **per-wagon proxy follows** — each wagon collides at its own swept pose | share one proxy for the chain → the trailer's wider arc is not tested and it clips through posts |
| **decouple → free body** — a broken coupling frees the wagon with its residual velocity | on decouple, delete the wagon or freeze it → the break has no consequence |
| **jackknife is bounded** — the coupling angle cannot fold past the limit | remove the turn limit → the wagon rotates through the cab |
| **reverse is flagged** — backing is the unstable case, handled by its own controller, not the forward model run backward | reverse with the forward follow model → it jackknifes immediately (the control that proves reverse needs its own path) |

---

## 8. Order

| | | depends on |
|---|---|---|
| **V1** | a coupling joint (hitch point + drawbar) on the `hexhinge` family | `hexhinge` |
| **V2** | the forward follow step — the trailer/bicycle kinematics | V1, `hexwheel` |
| **V3** | per-wagon proxy at the derived pose (collision follows) | V2, the proxy |
| **V4** | attach / detach / break-off (breakable coupling) | V1, breakable couplings |
| **V5** | the editor shows the chain articulating live | V2–V4, the editor |
| **V6** | jackknife limit + the reverse controller | V2 |

V2 (the forward follow) is the tractable core and the first real result; V6 (reverse, jackknife)
is where the honest difficulty lives and can wait. A two-body car-and-wagon at V3 already
*presents* a trailing wagon that follows and collides — which is the question this doc answers:
yes, and it is a short chain of designed primitives away.
