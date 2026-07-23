# VISION — what hexbody is for

Written for a person, not a build. The mechanism is [`ARCHITECTURE.md`](ARCHITECTURE.md);
this is the *why*, the goals, and — deliberately — the honest frontier where the thesis is a
bet rather than a settled capability.

---

## The thesis

Game systems — combat, traversal, vehicles, destructible environments, an enemy you can
climb — are usually impossible to test until you have animated art, and art is the slowest,
most expensive thing a small team owns. So the system and the art are stuck in a
chicken-and-egg: you can't validate the system without art, and you don't want to commit art
until the system works.

hexbody breaks that. It hands a team **structured placeholder geometry** (houses, moved and
rotated as bodies) with **collision proxies derived from that geometry**, and it **computes
every interaction from the model**. A team validates their *system* against real, provided
bounding volumes — before a single mesh exists.

This is greyboxing raised to a first-class discipline: the placeholder isn't just a visual
stand-in, it's *computationally structured* so the collision comes free, the destruction is
derived, and the motion is either derived or plugged in.

## The two exit paths — one system, no fork

Because a system consumes a **proxy**, never a mesh, the same validated system ships two
different ways:

- **Studio path** — a team with artists swaps the placeholder for authored meshes. The
  system is unchanged; only the proxy's *source* changes. A **conformance gate** confirms the
  mesh's proxy stays inside the error bound the system was validated against (see the proxy
  contract in `ARCHITECTURE.md`), and the validation transfers *provably*, not on faith.
- **Indie path — the mission** — a team **without** an art department refines the *produced
  geometry itself* until it ships. No mesh, no swap. And this path is **lower-risk on the
  system side**: there is no swap discontinuity, so as the geometry is tuned the proxy
  re-derives continuously and *never leaves the validated bound*. Refining the art cannot
  break the validated system, because the art is what the proxy is derived from.

The indie path is not an alternative feature — it is the *point*. The whole "produced, not
stored" bet exists so a two-person team can ship a world that today needs a studio with world
builders, level designers and an art department. The studio path is the general form; the
indie path is the reason.

## What we compute, and what we don't

State the boundary honestly, or the pitch over-promises:

- **Computed — everything derivable from the model:** which bodies occupy which space
  (coexistence), whether their swept volumes cross (interaction, frame-rate-independent),
  derived motion (wheels, pistons, linkages), destruction (mutate the field, re-derive the
  dependents), the proxies themselves, breakable couplings.
- **Not computed — the authored kernel stays the team's:** authored motion tracks (a gait, an
  attack), and the *feel-tuning* that depends on final geometry. hexbody de-risks the
  **mechanism** — does the interaction register, does the coupling break under force, does the
  swept test refuse to tunnel — **not the *feel***, which still needs final art. Claiming it
  validates the *feel* of climbing would be over-reach; it validates the *system* of climbing,
  which is exactly true.

## The north star: Shadow of the Colossus

The target is a body that is **an enemy and a platform at once** — you stand on a moving,
articulated creature, grip its shaking arm, are thrown off when it shakes hard enough, climb
to a weak point. Team Ico did it the bespoke way: sixteen hand-authored set-pieces in
controlled arenas. hexbody's divergence is exactly the axis they couldn't touch — because the
platforms are *produced field geometry*, a colossus can be procedural, it can crush your
(produced) buildings and derive the wreckage, and a decoupled limb becomes a free falling
body. Those are combinatorial things sixteen hand-made set-pieces can never be.

"An enemy changes into the platform" is the architectural claim that **one moving body is read
by many systems at once** — combat sees a hurtbox, traversal sees a standable surface, AI sees
an actor — unified by the fact that they all consume the current pose and proxy. It never
*changes*; it was always both.

## The honest frontier — where this is a bet, not a capability

The indie path depends on **produced geometry reaching *shippable aesthetic quality* in 3D**,
and that is the least-proven claim in the whole thesis. The 2D sprite stack (in crawler and
the `draw` skill) is the *existence proof* that produced → shippable is possible — but look at
what it cost: a whole authoring skill, reference plates, recognition critics, a technique
library, years of craft. The 3D-geometry equivalent of that craft mostly **does not exist
yet**: today the geometry is *exact but plain*. "Tune the houses up until they ship" is a real
bet on building the 3D produced-aesthetic craft that the 2D side already earned.

And the tool that makes *"tune them up yourself"* real — for someone who will not hand-edit
stencils in code — is the **in-world editor**. That reframes the editor from "a second
consumer that proves a library seam" to *the indie's entire art pipeline*, and probably its
real priority.

## Why building this is safe, not a speculative product bet

hexbody is its own **first consumer**. Every piece — the body model, the derived proxies, the
swept interaction, the breakable couplings, the destruction models — is needed for crawler's
own colossus *regardless* of whether any outside studio ever adopts the harness. The
"prototyping harness for other teams" is the *packaging* of work that has to be done anyway,
and it is proven the moment crawler builds its colossus on it. If no studio ever shows up,
crawler still needed all of it. The harness framing is pure upside on top of load-bearing
substrate.
