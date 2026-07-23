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
to a weak point. *Shadow of the Colossus* reached it beautifully with hand-authored set-pieces
in controlled arenas. hexbody's difference is architectural: because the platforms are *produced
field geometry*, a colossus can be procedural — it can crush your (produced) buildings and derive
the wreckage, and a decoupled limb becomes a free falling body. Those are combinatorial things a
fixed set of hand-made set-pieces isn't reaching for.

"An enemy changes into the platform" is the architectural claim that **one moving body is read
by many systems at once** — combat sees a hurtbox, traversal sees a standable surface, AI sees
an actor — unified by the fact that they all consume the current pose and proxy. It never
*changes*; it was always both.

## The hero demo: a train going off the rails

Everything above is a promise; this is the one thing you *show* to prove it, and it is chosen
for a precise reason: **for a derailment, showing it and proving it are the same act.** You
cannot fake a real one — a canned animation would not tumble, pile, or roll the interior over
correctly — so if it looks right, the stack *is* right. The demo and the acceptance test are the
same event, which is rare: most impressive demos can be Potemkin set-pieces, this one cannot.

And one legible crash exercises the whole promise — the four-step gold (create → stitch →
animate → traverse inside) in a single scene: produced-geometry wagons, stitched into a coupled
train, animated on the rails and then tumbling with collisions, their interiors rolling over as
they go, couplings snapping. It needs no onboarding — everyone already knows what a derailing
train looks like — and it proves the *art-is-not-the-value* thesis in passing: placeholder
houses tumbling down an embankment still read unmistakably as a train wreck.

So it plays three roles at once — a **demo** that sells the capability breadth in one image
(disaster game, physics toy, mecha game); an **acceptance test**, because if it works the stack
integrates; and a **forcing function**, because you cannot fake it, so building it forces every
piece to exist and compose. It is the diorama that both drives and proves the substrate — and
it is where the case for hexbody is *made*, by showing it, not argued in prose.

It is the **first full-stack target**, deliberately *ahead* of the colossus: smaller — one
train, one embankment, one tumble, versus a whole procedural climbable colossus — but exercising
the same stack end to end, including the inside-the-robot case at wagon scale (a tumbling
wagon's interior tilting is the minimal instance of walls-become-floors; see
[`design/DYNAMICS.md`](design/DYNAMICS.md)). Build toward the derailment first; the colossus is
the later, larger capstone.

## The frontier — and why it is smaller than it first looks

The indie path depends on **produced geometry reaching *shippable aesthetic quality* in 3D**,
and stated baldly that sounds like the least-proven claim in the thesis — as if it needed a
whole new 3D art-craft invented from nothing.

It doesn't, and the reason is **kitbashing**. The difference between a *shipped* open-world house
and our current model is not sculpting — it is **set dressing**: a house's massing is snapped
together from a *modular kit* (walls, corners, doorways, trims) and then dressed with props.
That modular-kit workflow is how large open-world environments ship — and it is **produced, not
stored**: the content bill scales with the *kit* (a few dozen reusable pieces), not with the
house. It is the same thesis as everything else here, applied to appearance, and
**we have already designed and started it** — the props system, the stencils, the part-tree,
the bundles are the kit vocabulary.

So the real gap from our model to a shippable one is: **author a modular set-dressing kit, and
let the editor kitbash it onto the massing.** That is a bounded, on-thesis job, not an
open-ended craft-invention — and the tool that delivers it is the **in-world editor**, where a
two-person team drags kit pieces onto a wall and dresses a room without touching code.

The residual bet is honest and much narrower: the kit pieces still have to be *authored*, and
made to *read* as quality — that craft is real (the 2D sprite stack shows what it costs: a
`draw` skill, references, critics). But it is a kit of a few dozen pieces reused across a whole
world, not per-house sculpting. **That is the indie dream made concrete:** the produced geometry
is the structure, a small authored kit is the dressing, the editor is the pipeline — and a team
with no art department ships a world that today needs a studio. This reframes the editor from
"a second consumer that proves a library seam" to *the indie's entire art pipeline*, and
probably its real priority.

## Why building this is safe, not a speculative product bet

hexbody is its own **first consumer**. Every piece — the body model, the derived proxies, the
swept interaction, the breakable couplings, the destruction models — is needed for crawler's
own colossus *regardless* of whether any outside studio ever adopts the harness. The
"prototyping harness for other teams" is the *packaging* of work that has to be done anyway,
and it is proven the moment crawler builds its colossus on it. If no studio ever shows up,
crawler still needed all of it. The harness framing is pure upside on top of load-bearing
substrate.
