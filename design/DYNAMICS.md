# DYNAMICS — going off the rails, and the first inside-the-robot case

**hexbody design.** Everywhere else the rule is *derive the consequence, don't simulate the
impulse* — kinematics, exact constructions, no physics engine. **Derailment is the feature that
earns the impulse.** A train on track is kinematic and, as you said, boring
([`VEHICLES.md`](VEHICLES.md)); a train *off* the track is dynamic — the wagons break loose,
tumble, collide, pile up, and come to rest somewhere. "Where do the wagons end up" is a physics
simulation, and this doc is where hexbody crosses, deliberately and scoped, into one.

**And it is the *minimal* inside-the-robot case.** A tumbling wagon is a body whose orientation
changes *dynamically*; its interior tilts through the tumble — walls become floors — and anyone
or anything inside rides a nested, tumbling frame. That is the entire Robotech frontier
(dynamics + tiltable interior + body-in-body) at the scale of one wagon. So you build the
inside-the-robot capability *here*, on the smallest instance, before the mech.

§0's numbers are the predicted target; no dynamics code exists.

---

## 0. The concrete target

A train takes a curve too fast. The lead's coupling force exceeds its strength, couplings
**break** (decouple-under-force, already designed), and:

- each freed wagon becomes a **rigid body** carrying its velocity and spin at the instant it let
  go, and **tumbles** off the embankment under gravity, friction, and collision;
- wagons **collide** — with the terrain, and with each other — and **pile up**;
- they **settle to rest**, and *where they end up* is the simulation's answer;
- a wagon with an **interior** tilts through its tumble — its floor rolls up to a wall and over
  to the ceiling — and a passenger or cargo inside is thrown against whichever surface is "down"
  at that instant.

---

## 1. The line this crosses — and the discipline that keeps it from being infinite

Full rigid-body dynamics — momentum, restitution, friction, **resting contact** — is where
physics engines sink years, and it is exactly what the exact-lattice approach was *not* built
for. So crossing the line is allowed here (the feature earns it) **only with a scope**:

> **Simulate to a plausible rest, not to frame-perfect physics.** The goal is *where the wagons
> end up* — a believable pile — not a joule-accurate reconstruction. Fidelity is "reads right and
> settles," not "matches reality." That scope is what stops this becoming a Havok clone.

Everything below serves that scope.

---

## 2. The transition — kinematic → dynamic, at the break

On the rails, a wagon is the kinematic follow (VEHICLES). Off the rails it is a free rigid body.
The **derailment event** is the seam:

1. a **trigger** — too fast into a curve, a broken rail, a collision — pushes a coupling past its
   strength;
2. the coupling **breaks** (decouple-under-force — the same primitive as a wagon breaking off a
   train or a player thrown off a colossus);
3. each freed wagon **hands off** from kinematic to dynamic **carrying its current velocity and
   angular velocity** — the state is continuous across the break, so the tumble starts exactly
   where the follow left off.

The handoff being continuous is the gate: the wagon does not teleport or lose its motion at the
instant it derails.

---

## 3. The dynamics — detection is in hand, response is the new layer

A free wagon evolves under gravity + momentum + collision + friction. Split it honestly:

- **Detection is already designed.** Which cells, edges, and other bodies a swept wagon crosses
  this tick is the swept-volume interaction test (ARCHITECTURE) — lattice-based, exact, a
  deterministic broad-phase. A fast tumble does not tunnel, because the test is swept.
- **Response is the new layer.** Turning "they crossed" into "they bounce, scrape, and settle" —
  restitution, friction, and resting contact — is continuous physics the lattice does not do.

So the dynamics is a **hybrid: lattice detection + continuous response.** The lattice makes the
*detection* fast and deterministic; the *response* is the genuinely new, continuous, and
carefully-scoped piece.

---

## 4. Where they end up — tumble and settle

The answer you want is the **rest state**. Simulate the tumble under momentum and collision until
the wagons settle into a pile. The classic hard problem is **resting contact / stacking**: a heap
of wagons must rest *stably* — not jitter, not sink through each other, not slowly slide apart.
Scoped to "plausible rest," this is tractable (settle to a low-energy configuration and freeze
contacts that stop moving) without a full constraint solver — and freezing settled bodies is also
what keeps a big pile cheap.

---

## 5. Determinism — a hard requirement, not a nicety

Crawler runs a **deterministic** world (gameflow / replaytest — scene_key-identical replicas).
A physics simulation that is not deterministic breaks replay, multiplayer, and the intent seam:
**the same derailment must always produce the same pile.** That forces a **fixed timestep and
deterministic response math**. The exact-integer lattice already makes the *detection*
deterministic; the continuous *response* must be written to be reproducible (fixed order, no
frame-rate dependence). Design the dynamics deterministic from the first line — it cannot be
retrofitted.

---

## 6. The first inside-the-robot case — the reason this is worth doing now

This is the sharp part. Everything the tiltable interior needs, a derailing wagon exercises at
minimal scale:

| inside-the-robot ingredient | how a tumbling wagon provides it |
|---|---|
| a body whose orientation changes | the wagon tumbles — full 3-D orientation, *dynamically* driven |
| walls become floors | the interior's floor rolls to a wall to a ceiling through the tumble — the **tiltable-interior atlas**, now driven by the tumble pose instead of an authored transform |
| a body inside a moving body | a passenger / cargo rides the wagon's frame — a **nested frame**, dynamic |
| I-CROSS in a moving frame | becomes **I-CROSS in a tumbling frame** — resolve the passenger's collision in the wagon's local frame, compose the tumble on top |

So a **derailing passenger wagon is the smallest complete instance of the inside-the-robot
frontier.** It is far smaller than a transforming mech — one body, one tumble, one interior — and
it is where the atlas finally gets a *driver*: the tumble supplies the changing orientation that,
until now, only an authored transformation could. Build the capability here, prove it on the
wagon, and the mech is the same machinery scaled up. Design-protocol's smallest-concrete-instance,
applied to the hardest frontier.

---

## 7. The honest hard parts

- **Resting contact / stacking** — the classic physics sink; scoped to "plausible rest" it is
  tractable, unscoped it is infinite. Hold the scope.
- **Determinism** (§5) — fixed step, reproducible response, or replay breaks.
- **The lattice does not do the response** — continuous dynamics is a genuine departure from the
  exact-construction approach; only the detection stays on the lattice.
- **Performance** — many tumbling wagons plus pair collisions; freeze settled bodies, and the
  field partition bounds the pairs, but measure it.
- **Interior collision under tumble** — I-CROSS in a *tumbling* frame is the moving-frame case at
  its hardest (the frame's angular velocity is large); it is the frontier within the frontier.

---

## 8. Gates — each with a control that must fire

| gate | control |
|---|---|
| **continuous handoff** — a wagon enters dynamics with the velocity/spin it had on the rails | zero the wagon's motion at the break → it drops straight down instead of tumbling forward |
| **deterministic** — the same derailment produces a byte-identical rest state on replay | introduce frame-rate-dependent integration → two runs settle differently |
| **settles** — the pile comes to rest and stays | omit contact freezing → the heap jitters or slowly drifts forever |
| **no tunnelling** — a fast tumble collides via the swept test | test instantaneous position → a wagon passes through the embankment between ticks |
| **interior tilts through the tumble** — the atlas's active floor tracks the wagon's orientation | drive the interior from a fixed "down" → the passenger stays glued to the original floor as the wagon rolls |
| **nested frame** — a passenger's collision resolves in the tumbling wagon's local frame | resolve the passenger in world space → they clip through the tumbling interior walls |

---

## 9. Where it sits

This is the **deep frontier** — past the colossus. The colossus is a moving body you stand *on*;
this is a body you are *inside* that tumbles *dynamically*. It is **not** the first brick
(`bodytest` + a wheel is), and it depends on nearly everything: the swept proxy, the breakable
couplings, the tiltable-interior atlas, and I-CROSS-in-a-moving-frame. But it is the right **north
star for the dynamics-plus-interior capability**, exactly as the colossus is for moving bodies —
and its minimal instance (one wagon derails, tumbles, settles, its interior tilting through) is a
concrete, buildable target that proves the whole Robotech frontier at a scale you can actually
gate. Scope it to plausible-rest, build it deterministic, and guard the whole way against the
infinite-physics-engine sink.
