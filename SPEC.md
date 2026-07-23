# SPEC — hexbody, formally

The **checkable** statement of what hexbody must do (**G**oals), must not do (**L**imits), must
always hold (**I**nvariants), and the interfaces that must not change shape (**K** contracts).

**Build and verify against this file.** The prose docs (`VISION`, `ARCHITECTURE`, `design/*`)
say *why*; this says *what*, checkably. On disagreement, the spec is authoritative for building
— reconcile the prose to it.

**Every item has a CHECK** — the gate or control that makes it falsifiable. An item without a
check is not in the spec. `IDs are stable`; cite them in a plan's Blueprint gate and in each
`src/*test.loft` gate, so a test names the spec item it defends.

---

## G — Goals (measurable acceptance, in build order)

| ID | target | check |
|---|---|---|
| **G0** ✅ | `housedraw`: floor/walls/openings/roof at all 12 orientations, cells **and** edges equivariant | `housetest` green |
| **G1** | moving body: a part on a revolute joint moves by derived motion; wheel angle `= travel/radius`; each part carries a bounded proxy | `bodytest` |
| **G2** | the fit: every wall renders as **one** flat quad (its analytic surface), not the strip | `eave_spread(fitted)=0` + `make shot` straightens |
| **G3** | interaction: two bodies of different scale interact iff swept volumes cross, at any `dt` | interaction gate |
| **G4** | the train: a coupled car+wagon follows a curve, wheels `= travel/radius`, wagon in line, detaches on decouple | vehicle gates |
| **G5** | editor: a building in every orientation from **one authoring pass**, seated on terrain, residual flagged | editor + placement gates |
| **G6** | destruction: ruins/crumble/floor-to-hill re-derive the proxy; a wall becomes a floor under tilt (two-patch) | destruction gates |
| **G★** | **DEMO (first full-stack acceptance):** a coupled train off the rails tumbles, piles, settles to a **deterministic** rest, interiors rolling; a cold viewer reads it as a train wreck | dynamics gates + human read |
| **G✦** | capstone: the colossus — procedural, climbable, crushes buildings, loses a decoupled limb | full-stack, at scale |

## L — Limits (deliberate boundaries; violating one is a defect even when it "works")

| ID | the boundary | violated when |
|---|---|---|
| **L1** | **bounded simulation** — derive the consequence, never simulate the impulse. Full rigid-body dynamics **only** where a feature earns it; earned set = {**G★** derailment} | Newtonian response added anywhere outside the earned set |
| **L2** | **dynamics scope** — simulate to a *plausible rest*, not frame-perfect physics | chasing joule-accuracy or a general constraint solver |
| **L3** | **efficiency preservation** *(gap-fill)* — the 2.5-D field is the **stored truth**; the tiltable/complex (patch-atlas) model is a **derived, on-demand overlay**: never persisted, never a branch in a hot-path op | the atlas is stored, or a field/proxy/collision op branches on "tiltable" |
| **L4** | **no mirror** — orientation is a minimal affine **morph**, never a mirror (gives up true mirror-symmetry); morph = 0 at the 6 exact rotations, bounded elsewhere; beyond tolerance the plot is **flagged**, not stretched | a mirror path, or a silent over-tolerance stretch |
| **L5** | **compute boundary** — hexbody computes only what is *derivable from the model*; authored motion tracks and feel-tuning stay the consumer's | hexbody authors gaits, or claims to validate "feel" |
| **L6** | **the seam** — hexbody owns the geometry/body/seating **mechanism**; the world/consumer owns placement and content; the seam runs one way | settlement/world/placement logic inside hexbody |
| **L7** | **determinism** — all simulation is deterministic (fixed timestep, reproducible math): same input → **byte-identical** result. Built from line one | any frame-rate-dependent or non-reproducible step |
| **L8** | **scale** — 1 hex step `= 1.5 m`, 1 world unit `= 0.866 m`; every new length is stated in metres | an unconverted threshold (it cannot be checked) |
| **L9** | **validation ≠ golden** — validation images are human-review (`plans/*/shots/`); golden/regression images live with their gate | conflating them, or pixel-diffing a `shots/` image |

## I — Invariants (always hold; each is a gate whose control must fire)

| ID | invariant | control that must fire |
|---|---|---|
| **I1** | a door/window is an interval on the **analytic surface**; the 2/3-direction edge strip is storage the feature never indexes | select edges by strip order → clear width wobbles between the zigzag and staircase sides |
| **I2** | placement is `(side, t)`, which is **affine-invariant** → a feature survives orientation-morph exactly | store the raw opened edges → the morphed house's feature moves |
| **I3** | a wall is the **boundary of a filled region**, closed by construction *(gap-fill)* | the buffer-band rule → 2 components, 0 enclosed (a wall with a hole), yet still "12/12 equivariant" |
| **I4** | a proxy **⊇** its shape (never misses an overlap) **and** overshoot `≤ ε` metres | shrink the proxy below the footprint → a real overlap is missed |
| **I5** | two bodies interact **iff** swept volumes cross, `dt`-independent, through **one** function | an instantaneous-position test → a fast pass tunnels |
| **I6** | a part's pose is a **pure function of its joint values**; wheel angle `= travel/radius` | spin a wheel off-travel → it skids |
| **I7** | after any field mutation the **proxy re-derives**; crumble conserves mass | keep the old proxy → collision doesn't follow the damage |
| **I8** | the eave is level on the long sides — `eave_spread` on the **fitted** line `= 0` | read the wall top at the strip → ±0.43 m |
| **I9** | same derailment → **byte-identical** rest on replay | a frame-rate-dependent integrator → two runs diverge |
| **I10** | a coupling point stays **coincident** every tick; decouple → free body with the residual velocity | let the drawbar-eye drift free → it detaches geometrically without a decouple |
| **I11** | the forward trailer-follow is **stable** — a drifted wagon returns to the drawbar, does not snake | overshoot gain → it oscillates (and isolates that reverse is the only unstable case) |

## K — Contracts (interfaces that must not change shape)

| ID | contract |
|---|---|
| **K-PROXY** | a `Body` provides a **proxy**; the proxy is the interface — field-derived in the prototype, mesh/authored in a shipped game; its error bound is stated; a consumer runs a conformance gate on their mesh |
| **K-JOINT** | the **joint value** is the interface; downstream (proxy, collision, render) is blind to whether it came from a constraint (derived) or a track (authored) |
| **K-SEAT** | `seat(stencil, terrain) → (z0, T', residual)`; `z0` minimises the chosen earthwork objective; `T'` drains; `residual` flags an unseatable plot |

---

## How this drives the process

1. **A plan's Blueprint gate names the spec items it touches** — the invariants it must preserve
   (`I*`), the limits it must not cross (`L*`), the goal it advances (`G*`).
2. **Every `src/*test.loft` gate maps to a spec item** and asserts its control. A gate that
   defends no spec item, or a spec item no gate defends, is the thing to fix.
3. **The prose docs become reference-only** — read for *why*, never the build input. If building
   needs a fact, it belongs here as a checkable item, not in a paragraph.
4. **Gaps are visible:** an unstarted `G*` with no gate, an `L*` with no enforcing check, is
   open work — not silently assumed done.
