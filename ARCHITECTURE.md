# ARCHITECTURE — the mechanism

The *why* is [`VISION.md`](VISION.md); this is *how*. It is one small core with several
faces, not a pile of features.

---

## One core, N faces

Everything below is the same core seen from a different angle: **a mutable, exact field; a
body is an oriented volume in it; interaction is a swept-crossing test; consequences are
derived, not simulated.**

| face | what it is | reads or writes the field |
|---|---|---|
| **static body** | a house — footprint, walls, roof, drawn in 12 orientations | writes (built) |
| **moving body** | a vehicle, a creature — the same body with a continuous pose | writes each tick |
| **point-vs-field collision** | a walker crossing a wall | reads |
| **volume-vs-volume combat** | a swing sweeping a hurtbox | reads (swept) |
| **destruction** | ruins, crumbling walls, collapsing floors | writes (mutate + re-derive) |
| **editor** | interactive field mutation — the indie's art pipeline | writes |

Three of these — collision, destruction, editor — are the same operation (*mutate/read the
field, re-derive the dependents, verify the invariants survive*). Combat is the interaction
test at higher volume complexity. Static and moving bodies differ only by whether the pose
changes. The **static house is the degenerate case of the whole system**, which is why the
geometry work seeds it.

## The two axes — and their blend

A body is a **tree of Parts** joined by **joints**. Each Part has two independent choices:

|                       | **derived motion** (a constraint) | **authored motion** (a track) |
|-----------------------|-----------------------------------|-------------------------------|
| **field geometry**    | a wagon — house-parts, rolling wheels | **a mech foot — a house, walked by a gait** |
| **authored mesh**     | a mesh gear turning by kinematics | a bespoke boss — mesh + mocap |

- **Geometry source** — field-stencil (produced; free proxy + free destruction) *or* authored
  mesh. This is the studio/indie swap; the appearance is the implementation, the proxy is the
  interface.
- **Motion source** — **derived** (a wheel rolls: angle = travel / radius; a piston slides;
  a trailer follows its coupling — *produced*, exact, gateable) *or* **authored** (a keyframed
  track — the stored kernel) *or* **both** (authored swing + a *derived* ground-plant that
  IK's the foot onto the field's real terrain — the produced world *correcting* the authored
  motion).

**The joint value is the interface.** Whether a joint angle came from a rolling constraint or
a keyframe, everything downstream — proxy transform, collision, coexistence, destruction —
reads the current pose and does not care how it got there. That is what makes the blend clean
and lets one body mix derived joints (its wheels) with authored ones (its legs).

The **irreducible authored kernel is only the motion tracks** — not "animation" as a whole.
Mechanical/kinematic motion is *produced* and belongs to the core; organic/authored motion is
the outlier, and even it rides on produced geometry through the joint-value seam.

## The collision proxy — and the contract that makes it a product

Because a body is structured field data, its collision volume is **computed from the static
geometry**: the footprint (a `HexSet`) gives a 2-D extent, `Heights` gives the z-band, and
from them a **clean, cheap proxy** (an oriented box, a hull, a capsule) is derived once in the
body's local frame and transformed by the pose each tick.

> **The proxy contract — the load-bearing invariant.** A proxy must **contain** the true shape
> (never miss a real overlap — conservative) and its **overshoot is bounded, stated in
> metres**. `proxy ⊇ footprint  ∧  overshoot ≤ X`.

That bound is the *product*. It underwrites the exit paths: a system validated against a proxy
transfers to *any* body whose proxy stays within the same bound — and a **conformance gate**
run on an authored mesh confirms it does. Without the bound, "it'll carry over to your mesh"
is faith; with it, the transfer is falsifiable. An ungated fast proxy is exactly the silent
wrong-world that a measurement discipline exists to kill — proxy fidelity is a *dial*, and the
overshoot is the dial read in metres, not hidden.

## Interaction — the one chokepoint

- **Broad phase = the field.** A body's occupied cells (its real footprint, tighter than an
  AABB) are the acceleration structure; interaction candidates share or neighbour cells. The
  z-band separates a person walking *under* a blimp from one *hit* by it.
- **Narrow phase = continuous swept volumes.** The lattice culls; continuous geometry
  arbitrates, because a body at a continuous heading is not lattice-aligned.
- **The invariant:** two bodies interact this tick **iff their swept volumes cross, and the
  answer is independent of frame rate / `dt`**. Combat hit, vehicle collision, trample,
  block, ride, a stomping foot — all the *same* swept-crossing query with different consequence
  handlers. It must route through **one chokepoint**, or every interaction type grows its own
  tunnelling bug (a fast swing phasing through a dodge is the composing-corrections bug wearing
  a sword).
- **Consequences are derived, not simulated.** Detect the interaction and apply the gameplay
  result (damage, stagger, block, carry, decouple). This is *not* full Newtonian response
  (momentum, restitution, ragdoll) — that is a different, much larger thing, added only where a
  specific feature earns it. **Derailment is where a feature earns it** — a train going off the
  rails, "where do the wagons end up" — and it turns out to be the *minimal inside-the-robot
  case*: a tumbling wagon is a body whose orientation changes dynamically, its interior tilting
  through the tumble (walls become floors), a passenger riding a nested tumbling frame. The
  dynamics frontier, scoped to a plausible rest and built deterministic:
  **[`design/DYNAMICS.md`](design/DYNAMICS.md).**

## Breakable couplings — grip, decouple, and the colossus

A **coupling** is a breakable joint. "Wagons not fixed together" are independent bodies joined
by couplings that can attach and detach; **gripping a colossus is the same primitive** — a
breakable coupling between the player-body and a moving part that **breaks when the part's
acceleration exceeds grip strength**, at which point the player becomes a free body flung by
the residual velocity. Being thrown off a colossus and a wagon breaking off a train are one
mechanism: *decouple under force* — which is destruction applied to a joint.

**The articulated vehicle — a wagon behind a car, truck, or train — is the worked case**: a
chain of separate bodies joined by couplings, each trailing body *following* through derived
trailer kinematics (its wheels' rolling constraint is what makes it swing to the pull and stay
in line), with correct wheel turning (rotation = travel/radius, front wheels steering), rendered
at its own pose, colliding at its own proxy, and detachable. Full design, including the honest
hard cases (jackknife, reversing): **[`design/VEHICLES.md`](design/VEHICLES.md).**

## Wall features and the layer stack

A wall is stored as a strip of edges in **two not-equal directions** (three along a lattice
line, a spread for an arc). Openings — doors, windows, loopholes — are placed *inside* that
wall, and a wall carries a **stack of layers**: storage → surface → material → feature
intervals → dressing. The load-bearing rule is that **a feature is an interval on the fitted
surface, and the two-direction edge strip is storage the author never sees** — the mantra made
concrete. Clear width is a surface quantity, a door annotates its edges (never deletes), a
window overrides opacity but not `solid` and carries a vertical `[sill, head]` interval the
scalar height cannot. Full design, the concrete measured end-result, the chokepoint, and the
gates: **[`design/FEATURES.md`](design/FEATURES.md).**

## Orientation, and the editor that shows it

A building is authored **once** and **never mirrored** — orientation is achieved by keeping the
same building (topology, layout, features, handedness: all details) and **morphing its two axes
minimally** to fit the lattice at the target angle. The morph is the bridge from the 6 exact
rotations to *many* orientations while staying lattice-exact (so proxies, features, and
destruction all survive it), it is bounded (zero at the 6 exact rotations, gated in % at the
worst angle), and it deletes the mirror's handedness residual entirely at the cost of true
mirror-symmetry. Because a feature is `(side, t)` — a ratio, which an affine morph preserves
exactly — a feature added once appears correctly in every morphed orientation *for free*.

That is what makes the **editor** possible: the developer edits one canonical building and sees
it live in every orientation it will ship in, side by side, single-authored, with the residual
flagged as a correctable punch-list — the mantra delivered (*seal the mechanism, expose the
outcome*). Full design: **[`design/EDITOR.md`](design/EDITOR.md).**

**Seating on terrain is the *second* morph** — the first morphs the building to the lattice
angle, this morphs the *hill* to seat the building on uneven ground: an exact best-height solve
(the earthwork minimiser) plus a repose-bounded, draining terrain morph. Cellars are a clean
special case (a storey designed below grade — not hard to model; the work is presenting the
hidden part in the editor). Full design: **[`design/PLACEMENT.md`](design/PLACEMENT.md).**

## Destruction models — derived, field-native, mass-aware

Destruction is *field mutation + re-derivation*, and each model is **derived from the intact
body**, never a separate authored ruin-asset. All three mutate `Heights` / `EdgeSet` /
`Labels`, and after any of them the **proxy re-derives from the new geometry** — so the body's
collision follows its damage for free.

- **Ruins from houses.** A *ruination pass* over an intact house: drop the roof layer, lower a
  fraction of wall-edges to broken stubs, scatter rubble as raised `Heights` patches in the
  footprint, open the floor. Parameterised by a decay amount, *derived* from the intact model —
  you author the house, not the ruin.
- **Walls that crumble.** A wall (an `EdgeSet` entry with height) → a **base mound**: the
  wall's mass falls into a debris prism at its foot. Mass-aware — the volume removed from the
  wall is the volume added to the rubble — so a crumbled wall is a believable heap, not a
  vanished one.
- **Floors that become hill planes.** A flat-`Heights` floor region → a perturbed
  **heightfield**: the collapsed floor heaves into a slope or mound. This is where destruction
  meets terrain — a wrecked building's floor becomes *ground*, a hill plane you can walk over.

**What destruction forces that the static geometry deferred:** breaking a wall genuinely
*fragments* its run (one wall → two), so destruction is where the **run-id / connectivity**
system (deferred in the drawing spec) has to be built — a coherent wall must survive being cut
into cleanly-fragmented runs, not silently merge or vanish.

## Verification — the temporal / mutation instrument

Static geometry is gated *measure-once* (a house is correct from one snapshot). Everything
dynamic here breaks that: correctness is a property **over time, over frame rates, and over
sequences of mutation**, and the state after N destructions is one no fixture enumerated. So
the gate discipline generalises to **invariant-preservation under change**: fuzz random
motions and destruction sequences, and assert the field invariants survive — walls stay closed
loops *or* cleanly-fragmented runs, roofs don't pond, `clear_height` holds where cells remain,
passability still reads from edges, a fast swept volume never tunnels. A negative control in
every gate, and *state what would have to break for the control to go red* — a control that
cannot fire is not a check.

## Roadmap — bricks, then the arch

| step | what | proves |
|---|---|---|
| **done** | `housedraw` + `housetest` — floor/walls/openings/roof at 12 orientations | the static body, equivariant |
| **bodytest + wheel** | a 2-part body, one revolute joint; wheel angle = travel/radius; each part carries its derived proxy | derived motion + per-part proxy, gated |
| **proxy + bound** | derive the clean box from the footprint; gate `proxy ⊇ shape, overshoot ≤ X m` across 12 orientations | the proxy contract |
| **swept interaction** | two bodies of different scale, shared occupancy, run past at varying speed/`dt` | the one chokepoint; no tunnelling |
| **destruction models** | ruins / crumble / floor-to-hill, each re-deriving the proxy; run-ids | field mutation + re-derivation |
| **authored motion + plant** | a house-part moved by a 2-keyframe track (a stomp); swept proxy between frames; derived ground-plant | the geometry×motion blend |
| **breakable couplings** | attach/detach a wagon; decouple-under-force | grip / throw-off |
| **I-CROSS in a moving frame** | the crossing test in a part's local frame while the part moves | the one genuinely new algorithm |
| **the derailment** | a coupled train run off the rails: wagons tumble, collide, pile up, interiors rolling through the tumble, couplings snapping | **the first full-stack acceptance test — un-fakeable; showing it *is* proving it** |
| **the colossus** | a procedural, destructible body you climb in its moving frame, that crushes buildings and can lose a decoupled limb | **the larger capstone — every piece, at scale** |

`bodytest` + one wheel is the first brick; **the derailment is the first full-stack proof**
(un-fakeable — showing it is proving it, and it is the minimal inside-the-robot case,
[`design/DYNAMICS.md`](design/DYNAMICS.md)); the colossus is the larger capstone beyond it.
