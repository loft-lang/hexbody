# PLAN — producing the derailment: what to build, in what order

**hexbody production plan.** The design corpus ([`VISION`](VISION.md),
[`ARCHITECTURE`](ARCHITECTURE.md), [`design/*`](design/)) says *what* and *why*; this says
**what to produce, in what order**. The target is the **derailment hero demo** — the first
full-stack acceptance test; the first brick is **`bodytest` + a wheel**; the recurring
dependency is **the fit**. Sequenced by the critical path.

Each milestone lists **produce** (the loft modules), **gate** (with a control that must fire),
**depends on**, and **done when**. Names like `proxy.loft` are proposed, not fixed. Each
milestone earns its own detailed plan directory when it is *started* — the org plan convention,
imported from crawler and bound for hexbody in [`plans/README.md`](plans/README.md). This file
is the synthesis layer (crawler's `ROADMAP.md` role), not a plan index.

---

## The critical path

```
  M0 fit ───────────────┐
                         ├──▶ M4 render + editor ─┐
  P body ─▶ M1 body ─────┴─▶ M2 interact ─▶ M3 train ─▶ M5 destruction+atlas ─▶ M6 DERAILMENT ─▶ M7 colossus
```

Two tracks converge: the **mechanics spine** (body → interact → train → destruction → dynamics)
and the **visual track** (fit → render → editor). The derailment needs both, so neither track
can be left to the end.

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

## M0 — the fit *(unblocks everything visual)*

Recover the straight/arc **surface** from the two-direction edge strip (crawler `BUILDING.md`
§4 designs it). Until it lands, walls render as the zigzag and features have no straight surface
to sit on — it is named as the dependency in every design doc.

- **produce** — `fit.loft`: strip → analytic surface (straight, then arc).
- **gate** — `eave_spread == 0` on the fitted line; a 15° wall renders as **one** straight quad;
  **control:** read the wall top at the zigzag → it wanders ±0.43 m.
- **depends on** — `hex_field`, `housedraw`.
- **done when** — any wall renders as its analytic surface, not its strip. *(May later extract to
  the shared lib with the surface/collision layer — `EXTRACTION` seam.)*

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

- **M0 the fit is load-bearing and blocks all visual work.** Do it early, in parallel with the
  mechanics spine.
- **M6 the dynamics is the frontier.** Scope to *plausible rest*, build *deterministic from line
  one* (it cannot be retrofitted, `DYNAMICS` §5), and guard the whole way against the
  infinite-physics-engine sink.
- **M5 the atlas (walls-become-floors) is a candidate, not a proven design.** Pin the two-patch
  probe on paper/throwaway before the general system — it is the load-bearing invariant of the
  whole tiltable-interior frontier.
- **Determinism (M6) and the fit (M0) are the two things that are cheap now and expensive later.**
  Both belong early.

## Start here

The first move is unambiguous and small, and it is two things in parallel:

1. **P + M1** — `body.loft` (Body / Part / Joint) then `bodytest.loft` with one wheel
   (`angle = travel/radius`) and its proxy. A housetest-sized gate; the mechanics spine's first
   brick.
2. **M0** — `fit.loft`, porting crawler `BUILDING.md` §4, so walls render straight and the visual
   track is unblocked.

Both are small, both gated, both on the critical path. Everything else in this plan is reached by
repeating the loop that built `housedraw`: one exact brick, one gate with a control seen to fire,
then the next.
