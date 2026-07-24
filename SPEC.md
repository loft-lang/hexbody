# SPEC — hexbody, formally

The **checkable** statement of what hexbody must do (**G**oals), must not do (**L**imits), must
always hold (**I**nvariants), and the interfaces that must not change shape (**K** contracts).

**Build and verify against this file.** The prose docs (`VISION`, `ARCHITECTURE`, `design/*`)
say *why*; this says *what*, checkably. On disagreement, the spec is authoritative for building
— reconcile the prose to it.

**[`ROUNDTRIP.md`](ROUNDTRIP.md) is the formal peer** — the objects (`𝕄`, `𝕄*`, `𝕋`, `𝔽`), the maps
(`snap`, `write`/`read`, `draw`/`rebuild`) and the laws **A₁–K₂** that hold between them. This file
says *what must be achieved*; `ROUNDTRIP` says *what the objects are and which equations hold*. On
disagreement about an object, a map, or a law, **`ROUNDTRIP` is authoritative**; the items below
cite it by law letter.

**Every item has a CHECK** — the gate or control that makes it falsifiable. An item without a
check is not in the spec. `IDs are stable`; cite them in a plan's Blueprint gate and in each
`tests/*.loft` gate, so a test names the spec item it defends.

---

## G — Goals (measurable acceptance, in build order)

| ID | target | check |
|---|---|---|
| **G0** ✅ | `housedraw`: floor/walls/openings/roof at all 12 orientations, cells **and** edges equivariant | `tests/house.loft` green |
| **G1** | moving body: a part on a revolute joint moves by derived motion; wheel angle `= travel/radius`; each part carries a bounded proxy | `bodytest` |
| **G2** ✅ | the fit: every wall renders as **one** flat quad (its analytic surface), not the strip | **`eave_spread(fitted)=0` GATED** (`X61`, `tests/surface.loft` §8): 38 stored edges → **4** fitted quads, spread exactly 0, control = the strip's own band is non-zero. **`make shot` straightens** — it now draws the fitted quad, features as intervals on it. **The corners now MITER** (`X62`, `tests/form.loft` §17): adjacent surfaces meet at exactly 90° and the mitered outline has **0 gap** at all 48 corners (12 orientations × 4), control = the un-mitered spans leave `11.592` wu |
| **G3** | interaction: two bodies of different scale interact iff swept volumes cross, at any `dt` | interaction gate |
| **G4** | the train: a coupled car+wagon follows a curve, wheels `= travel/radius`, wagon in line, detaches on decouple | vehicle gates |
| **G-FOXEL** ✅ | **the foxel schema is the storage limit, and a model that draws into it must SURVIVE it** — `𝕄*` is bounded by *"a model is admissible iff it draws into this schema exactly"* ([`ROUNDTRIP.md`](ROUNDTRIP.md) §2.4), which is only a limit if the schema actually stores what it claims | **GATED** (`X63`, `tests/foxel.loft`): all six slots cross a write/read exactly, and `write(rebuild(load(store(draw(read(T)))))) = T` byte-for-byte, 6/6 in-between directions. Control = `X15`'s documented lossy writer (`has_e = false`), which returns 0 of 38 edges and **breaks the trip** while still carrying the footprint. ⚠ The **palette** (`X12`/`X13`) is *not* covered and stays T4 |
| **G5** ◑ | editor: a building in every orientation from **one authoring pass**, seated on terrain, residual flagged | editor + placement gates. **The seating half is gated** (`X59`, `tests/terrain.loft`): the `height` slot is orthogonal to the footprint so the round trip is untouched, and the residual is **returned**, not absorbed — control: a seating that clips the footprint breaks the trip |
| **G6** | destruction: ruins/crumble/floor-to-hill re-derive the proxy; a wall becomes a floor under tilt (two-patch) | destruction gates |
| **G★** | **DEMO (first full-stack acceptance):** a coupled train off the rails tumbles, piles, settles to a **deterministic** rest, interiors rolling; a cold viewer reads it as a train wreck | dynamics gates + human read |
| **G✦** | capstone: the colossus — procedural, climbable, crushes buildings, loses a decoupled limb | full-stack, at scale |

## L — Limits (deliberate boundaries; violating one is a defect even when it "works")

| ID | the boundary | violated when |
|---|---|---|
| **L1** | **bounded simulation** — derive the consequence, never simulate the impulse. Full rigid-body dynamics **only** where a feature earns it; earned set = {**G★** derailment} | Newtonian response added anywhere outside the earned set |
| **L2** | **dynamics scope** — simulate to a *plausible rest*, not frame-perfect physics | chasing joule-accuracy or a general constraint solver |
| **L3** | **two layers, split by consumer** — **layer 1** is the **foxel**: compact, uniform, stored, and the **only** representation the *editor* works on. **Layer 2** is everything the *game* derives from it — collision structures, meshes, water flow, air flow, sound, the patch-atlas, `K-PROXY`'s proxy: **derived on demand, never persisted, never a branch in a hot-path op**. *(The patch-atlas is one member of layer 2, not a special case.)* [`ROUNDTRIP.md`](ROUNDTRIP.md) §2.4.2 | any layer-2 structure is stored, a layer-1 op branches on a layer-2 concern, the editor grows a second **authored** representation, or **a single-cell edit dirties an unbounded region of layer 2** (the in-world editor runs with the game live, so re-derivation must be local and incremental — `I7` generalised from the proxy to all of layer 2) |
| **L4** ⚠ | ~~**no mirror**~~ — **SUPERSEDED** by [`ROUNDTRIP.md`](ROUNDTRIP.md) laws **G**/**H**. The flip exists (`hex_field::stencil_mirror`; `tests/house.loft`'s 12 = 6 × 2) and is governed by *commutation* + *no drift under repetition*, not forbidden. **OD-5 is now all but closed**: lattice reflection is **exact** (`k → −k`, **X2**), and `X57` measured the flip exact on **linework** too — 96/96 wall segments, in-between directions included. So "mutates by approximation" names the *morph* (OD-1) or the *handedness residual*, **not** the flip. What survives regardless: beyond tolerance a plot is **flagged**, never silently stretched | a flip that fails to commute, drifts under `φ¹²`, or a silent over-tolerance stretch |
| **L5** | **compute boundary** — hexbody computes only what is *derivable from the model*; authored motion tracks and feel-tuning stay the consumer's | hexbody authors gaits, or claims to validate "feel" |
| **L6** | **the seam** — hexbody owns the geometry/body/seating **mechanism**; the world/consumer owns placement and content; the seam runs one way | settlement/world/placement logic inside hexbody |
| **L7** | **determinism** — all simulation is deterministic (fixed timestep, reproducible math): same input → **byte-identical** result. Built from line one | any frame-rate-dependent or non-reproducible step |
| **L8** | **scale** — 1 hex step `= 1.5 m`, 1 world unit `= 0.866 m`; every new length is stated in metres | an unconverted threshold (it cannot be checked) |
| **L9** | **validation ≠ golden** — validation images are human-review (`plans/*/shots/`); golden/regression images live with their gate | conflating them, or pixel-diffing a `shots/` image |
| **L10** | **no unchecked window** — a count or ratio measured over a sub-window of the field must be **shown** not to clip: a larger window finds the same count. A window that truncates does not error, it silently returns less, and every number built on it is then wrong by an unknown amount | size a field by eye and report a ratio over it — `tests/wall.loft` §3b is the check (25×25 vs 45×45, identical slot counts) |
| **L11** | **the library owns the shared table** — where a sibling library already owns a lattice table (`hex_grid`'s corners, edges, neighbours; `hex_field`'s lattice), hexbody **consults it** and never keeps a private copy. Two tables that agree today diverge silently later | `hexwall` carried its own 30° corner table beside `hex_field`'s neighbours — the two direction orders differ and **five of six edges were misfiled while every gate stayed green** (`ROUNDTRIP.md` **X26**) |
| **L12** | **a write is not a truncate, and a read is not a measurement** — `doc_write` **APPENDS**, so writing twice to one path leaves the second document unreachable and `doc_read` returns the **first** with `doc_code == HXF_OK` (`X64`). And `file().content()` returns **empty for non-UTF-8 bytes**, silently (loft, both backends — `crawler/LOFT-HANDOFF.md` **H7**), so a byte length is **not an available instrument** for any binary artefact. Every storage check must therefore write to a **fresh path** and measure by **content the format defines** (a cell count, a digest), never by file size | a gate reuses a path and compares stale bytes to themselves · a check reads `0 == 0 * 2` and reports "it appended" — which `tests/foxel.loft` printed before it was caught |

## I — Invariants (always hold; each is a gate whose control must fire)

| ID | invariant | control that must fire |
|---|---|---|
| **I1** | a door/window is an interval on the **analytic surface**, and is **stored as a material on the wall slot** — the edge is never removed, so a run is never fragmented, on a **straight** wall (`X48`) or a **curved** one (`X51`, the doored tower: it round-trips as one arc). **Its `t` is admissible only at an edge centre `(2i+1)/2n`** — any other value snaps and cannot be recovered (`ROUNDTRIP.md` **X48**), so the doorstep refuses it ([`ROUNDTRIP.md`](ROUNDTRIP.md) §2.4.1). The 2/3-direction edge strip is storage the feature never indexes | select edges by strip order → clear width wobbles between the zigzag and staircase sides · delete an edge instead of re-materialling it → the run fragments into 3 arcs (the doored-tower defect) |
| **I2** | placement is `(side, t)`, which is **affine-invariant** → a feature survives orientation-morph exactly | store the raw opened edges → the morphed house's feature moves |
| **I3** | a wall is the **boundary of a filled region**, closed by construction *(gap-fill)*, stored in the **three wall slots a point owns** (foxel schema, [`ROUNDTRIP.md`](ROUNDTRIP.md) §2.4). *(OD-7 resolved: `WALLS.md`'s triangle-subdivision band needs sub-cell resolution the schema has no slot for — it may still serve render/collision, but it cannot be stored.)* | the buffer-band rule → 2 components, 0 enclosed (a wall with a hole), yet still "12/12 equivariant" |
| **I4** | a proxy **⊇** its shape (never misses an overlap) **and** overshoot `≤ ε` metres | shrink the proxy below the footprint → a real overlap is missed |
| **I5** | two bodies interact **iff** swept volumes cross, `dt`-independent, through **one** function | an instantaneous-position test → a fast pass tunnels |
| **I6** | a part's pose is a **pure function of its joint values**; wheel angle `= travel/radius` | spin a wheel off-travel → it skids |
| **I7** | after any field mutation the **proxy re-derives**; crumble conserves mass | keep the old proxy → collision doesn't follow the damage |
| **I8** | the eave is level on the long sides — `eave_spread` on the **fitted** line `= 0` | read the wall top at the strip → ±0.43 m |
| **I9** | same derailment → **byte-identical** rest on replay | a frame-rate-dependent integrator → two runs diverge |
| **I10** | a coupling point stays **coincident** every tick; decouple → free body with the residual velocity | let the drawbar-eye drift free → it detaches geometrically without a decouple |
| **I11** | the forward trailer-follow is **stable** — a drifted wagon returns to the drawbar, does not snake | overshoot gain → it oscillates (and isolates that reverse is the only unstable case) |

**Round-trip items** — defined formally in [`ROUNDTRIP.md`](ROUNDTRIP.md); the law letter is the definition.
**Prior art:** [`ROUNDTRIP.md`](ROUNDTRIP.md) **§7** lists the constraints `X1`–`X29` **with their
trust tier**. **T1 now holds `X1`, `X2`, `X19`–`X22`, `X24`–`X29`**, eight of them re-measured *here*
by `tests/form.loft` and `tests/wall.loft`. Everything still below the line is a design try (T2/T3)
or a shape read from untested code (T4) — notably the **whole foxel schema** (`X11`–`X15`):
*indicative, to be re-measured here*, never cited as settled.
[`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) **§10** carries the open decisions;
items marked ⚠ below depend on one.

| ID | invariant | law | control that must fire |
|---|---|---|---|
| **I-RT** | `rebuild(draw(m)) = m` for every fitting model — the field is invertible, not approximated | **D** | a non-fitting model bypassing `snap` → the text diff fires |
| **I-TOTAL** | `rebuild` is **total** and never fails; **exact** (`ρ = 0`) on undamaged fields, **approximate with a reported residual** on damaged ones — a ruin yields a *new original*, not a recovered one | **E₁**,**E₂**,**E₃** | hand-corrupt an `EdgeSet` → still lands in `𝕄*` · crumble a wall → `ρ > 0` is surfaced, not swallowed |
| **I-POSE** | a body is `⟨original, pose, joints⟩` — original and pose **stored**, local field **derived**, and a body is **never stamped into the world field**. A robot's limb and a derailed wagon are the same case: an exact original at an arbitrary continuous pose | §1.2 | stamp a free-posed body into the world lattice → it can only land on one of the 12 |
| **I-FSEAM** | *(the **FRAME** seam — not crawler's `I-SEAM`, which is the **chunk** seam and is exactly `d = 0`)* collision reads many frames at once (base world + each posed body). Imprecision — cracks, jank — is allowed **only on the seam between frames**, bounded by `ε_seam` metres and **deterministic**; inside any frame the error is **exactly 0**, and **between chunks it is exactly 0**. **MEASURED (`X53`):** the pose transform is the sole float step, `ε_seam ≈ 7.1e-15` (machine ε), and a routed query agrees with an exact integer oracle on all 1681 grid points | **K₁** | "fix" a crack by snapping a body's wall onto the world lattice → 12 interior cells misclassified, and law **D** is void for that body (`tests/seam.loft` §2) |
| **I-ARBIT** | frames that disagree are arbitrated **deterministically over a total order**, failing safe toward *solid*. Exact at `κ ≤ 1`, arbitrated at `κ = 2`, conservative **and counted** at `κ ≥ 3` — the "3+ is rare" claim is a measured rate, never an assumption. **Same-level overlap is order-free by construction** — "mark all, then cut once" (`X52`, `tests/combine.loft`). **Posed-body arbitration MEASURED (`X53`):** order-free (owner = lowest id among the solids) and fail-safe toward solid; `κ ≥ 3` is rare at a point (10/841) but a swept segment straddles more (`tests/seam.loft`). **Overlap by nearest SURFACE MEASURED (`X54`):** `cut_arb` tags each boundary edge with its nearest analytic surface, order-free, ties to lower id (`tests/arb.loft`). **LEVELS do work `κ` would otherwise have to (`X58`):** different sheets never contend, because a level filters *before* the cut — `κ` is counted per level (`tests/level.loft`) | **K₂** | tie-break on iteration order instead of frame identity → replay diverges (`I9`); a per-body overlay marks a spurious seam and depends on order; a world-blind κ counter undercounts; a fixed "lower id always" mis-tags the far rim |
| **I-FLIP** | the flip commutes with the round trip and does not drift under repetition. **GATED for linework** (`X57`, `tests/flip.loft`): the 24 directions are closed under the 12 orientations (0/24 on rotation, reflection and six-rotations-identity), and a wall segment mirrors **exactly** — 96/96 cases, 48 of them in-between — under `mirror(wall(d,A,p)) = wall(−d, mirror(farend), p)`. **A wall is an undirected segment, so its mirror REVERSES traversal**; the naive `d → 12−d` at the mirrored start is wrong and only 90°/270° expose it. Lattice reflection itself is **exact** (`k → −k`, `X2`), so the "drift under repetition" half is a theorem, not a measurement — see `OD-5`. Rotation is exact for all three period families; the gate **found and fixed** a real non-covariance in `wall_separates` on the way (a float sign test on a mathematically-zero offset) | **G**, **H** | the naive mirror rule must fail, on exactly the chiral `N=1` family and no other; inject a rounding step → `φ¹²` diverges |
| **I-EXACT** | round-trip equality is **byte equality**; no `ε` in the comparison — **for regime R1** (recovering a stencil *we authored*, where the grammar is the prior). **R2** (recovering arbitrary cell-authored content, no grammar) is genuinely a fit with a pinned tolerance, licensed by **E₃** ([`ROUNDTRIP.md`](ROUNDTRIP.md) §6) | **P4** | an `ε` in an **R1** comparator means `𝕄*` is wider than `draw` is injective on |
| **I-CLOSE** | a stencil boundary is a closed turtle cycle over `H₁₂`, exact in `ℤ²`, and **closure alone is not admission**: it must also be **simple** (no repeated vertex) and **convex** (every turn positive). Law J constrains only the turn sum, and non-convex forms **violate law F** — two distinct forms drawing one field, which no recovery can separate (`ROUNDTRIP.md` **X46**) | **J** | drop one turn → the vector sum is non-zero · admit a non-convex form → it recovers as a *different* form with `ρ = 0` (`tests/census.loft` §7) |
| **I-EXTEND** | the model is **built out like a language**: new verbs, shape types and parameters are added without breaking the old ones. An existing canonical text keeps the **same bytes**, model and field across an extension; `𝕄*` grows, never shrinks. **A₂ alone is not sufficient** — every extension re-opens the census, because a newly admitted form may **collide** with an existing one under law **F** even while every text keeps its bytes; on collision the **new** form is refused, never the old ([`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) §4.1) | **A₂**, **F** | sort `kind` alphabetically instead of by registry position → adding one verb re-spells every existing text · admit a shape type that rasterises identically to an existing one at small size → `rebuild` cannot tell them apart |
| **I-CLOSED-OPS** | what is admitted survives **everything later done to it** — `Ops = {flip, place, combine, damage, seat}` | **C₂** | admit a form whose `flip` leaves `𝕄*` → it breaks after placement, not at the door |
| **I-DOMAIN** | `O` (placing a stencil), `H₁₂` (a stencil's sides), `D` (world linework) are three distinct sets; no grammar production crosses them. **The split is not a convention but a measurement**: the even 12 of `D` are exact to `0.0000°`, the odd 12 are off by a uniform `4.1066°` (`ROUNDTRIP.md` **X29**), so a house — which must close and meet corners — uses only the even 12 | §1.1 | a stencil placed at one of the 24 → unparseable · the in-between offset measured as zero → the even-only rule would defend nothing (`tests/wall.loft` §2) |
| **I-EDGE** | **a mark names a real edge** — the corner pair (`hex_grid::hex_edge_corners`) and the neighbour (`hex_grid::hex_neighbor`) identify the **same** edge, in all six directions. Nothing downstream can detect a violation: a consistently misfiled edge is still written once, still idempotent, still non-empty | §2.4 | misfile by one direction → the edge midpoint sits `0.866` wu from the midpoint between the cells it separates (`tests/wall.loft` §2b) |
| **I-WIDTH** | **a wall is a line primitive, not a set of cells** — `(anchor on a lattice point, exact primitive lattice direction, length, width)`, its two faces the real lines at `±w/2`. **Width is one model constant** (`√3/6 wu = 0.25 m`) for all 24 directions, never a count of lattice rows — counting rows *provably cannot* equalise them (`ROUNDTRIP.md` **X30**). The cells are the band's **rasterisation** and are never the truth; only 6 of the 24 directions can have faces on lattice edges at all (**X28**) | **D**, §2.4 | make width an integer row count → two directions differ by `√3` and no integer choice fixes it (`tests/wall.loft` §7) |
| **I-ALONG** | **a wall marks the edges ALONG the line, not across it** — the marked edges are those that **separate** the wall's two sides (`wall_separates`: the centre line has the two cell centres on opposite sides), which is the boundary between two half-planes and therefore **one connected chain** (two degree-1 ends, no branch), not a comb of perpendicular pickets (`ROUNDTRIP.md` **X28**, **X32**) | **D**, §2.4 | mark the edges the band *crosses* → a due-east wall is a disconnected comb of vertical pickets (18 chain-ends, `\|C→N·dir\|=1`); `tests/wall.loft` §6, control is the hand-built comb |
| **I-CORNER** | **where two wall runs meet, the corner is precise** — four parts (`DESIGN.md` §10.4): (1) the boundary is **one closed loop**, no gap; (2) the corner **angle is exact**; (3) the corner edge is claimed by **exactly one** side run; (4) the **miter point** of the two fitted surfaces closes the outline exactly. **all four are gated** — 1 and 3 by `X35`/`X36`, and **2 and 4 by `X62`**: the angle is exact in **integer headings** (difference `3` or `9` = 90°, both windings, 48/48) and the **miter point closes the outline with 0 gap**. `hexform::SURFACE_LANDED` is now `true`, the tripwire cashed in. ⚠ Part 4 originally read *"sits on the exact model corner"*; it **does not** — `Plan` is continuous-then-rasterised, so that corner is quantised away (`I-QUANT`). The miter recovers the **cell-region** corner, the only one the field holds | **I3** | punch an interior cell → the boundary becomes 2 loops · drop a side → three runs cover 28 of 38 (`tests/form.loft` §14, §16) · **un-miter the quads → 11.592 wu of gap** (§17) |
| **I-QUANT** | **every continuous model parameter is quantised to what the field distinguishes** — a value off that grid is **silently snapped, not rejected**, so `fits?` must refuse it at authoring time. Measured on three independent parameters (`ROUNDTRIP.md` **X50**): line **endpoints** → hex vertices (§10.10), feature **`t`** → edge centres `(2i+1)/2n` (**X48**), arc **radius** → shells `3k²+m²` (**X49**) | **D**, **K-FIT** | author a value between grid points → it round-trips as a *different* value with `ρ = 0`, i.e. success is reported on a model nobody wrote (`tests/surface.loft` §6, `tests/arc.loft` §3) |
| **I-EVAL** | **the stored field is evaluated back to geometry by the library's own emitter**, never by a private one — `hex_edge_corners` + `moros_render::emit_hex_walls` (`ROUNDTRIP.md` **X26**) — and its **stray from the authored line is measured, never assumed**. The stray is the quantity `rebuild` must undo; it may not be silently absorbed by a tolerance (**P4**) | **D**, **P4** | the stray measured as zero → the recovery step would be vacuous, the same failure mode as `X15`'s green-for-the-wrong-reason test (`tests/wall.loft` §6) |

## K — Contracts (interfaces that must not change shape)

| ID | contract |
|---|---|
| **K-PROXY** | a `Body` provides a **proxy**; the proxy is the interface — field-derived in the prototype, mesh/authored in a shipped game; its error bound is stated; a consumer runs a conformance gate on their mesh |
| **K-JOINT** | the **joint value** is the interface; downstream (proxy, collision, render) is blind to whether it came from a constraint (derived) or a track (authored) |
| **K-SEAT** | `seat(stencil, terrain) → (z0, T', residual)`; `z0` minimises the chosen earthwork objective; `T'` drains; `residual` flags an unseatable plot |
| **K-FIT** | `fits?(m) → bool` and `snap(m) → (m*, residual)` are **one chokepoint**, consulted by the round-trip gate *and* by the editor. **The limit sits at the doorstep: the editor refuses at authoring time** — never a warning, never a downstream check. `authorable ⊆ { m : fits?(m) }`, and `𝕄*` is **closed under `Ops = {flip, place, combine, damage, seat}`** (law **C₂**), so what is admitted survives everything later done to it. A refusal **names its restriction** and offers the nearest fitting alternative with its residual — never a silent snap, never a blank rejection ([`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) §5.2). **For a line this is closed-form** (§10.10): endpoints are hex **vertices** separated by a whole number of the direction's period, `nearest_vertex` snaps the anchor and `snap_run_d24`/`snap_run_p` the far end over all 24 directions, and `run_end_dist` is the residual the editor must show. **The in-between 12 carry the coarsest quantum — `√39` wu = `5.408 m` per period (`X56`) — and a coarse quantum is acceptable ONLY because it is VISIBLE: the editor must show the admissible run lengths and the residual, never snap silently.** `δ = 0` there, so *every* multiple is offered from any vertex; the conditional families (30/90/150°, one in three refused) are the ones whose refusals must be named rather than merely skipped |

---

## How this drives the process

1. **A plan's Blueprint gate names the spec items it touches** — the invariants it must preserve
   (`I*`), the limits it must not cross (`L*`), the goal it advances (`G*`).
2. **Every `tests/*.loft` gate maps to a spec item** and asserts its control. A gate that
   defends no spec item, or a spec item no gate defends, is the thing to fix.

   | gate · section | defends |
   |---|---|
   | `house.loft` | **G0**, **I1**, **I3**, **I8** |
   | `form.loft` §1–§8 | **I-CLOSE**, **I-DOMAIN** *(`H₁₂`)* |
   | `form.loft` §9–§10 | `X24`, `X25` — the basis of **I-WIDTH** and of OD-11's resolution |
   | `form.loft` §12, §13 | **I3** *(fill then boundary)*, **I-CLOSE** *(a non-closing cycle is refused)* |
   | `form.loft` §12b | `X34` — the boundary convention, via the area identity |
   | `form.loft` §14, §16 | **I-CORNER** parts 1 and 3 (`X35`, `X36`) |
   | `form.loft` §15 | **I3** — the band rule eats the floor (`X37`) |
   | `form.loft` §17 | **I-CORNER** parts 2 and 4 — the angle and the miter (`X62`) |
   | `census.loft` §1 | **I-CLOSE** — law J as the admission filter (660 proposed, 30 admitted) |
   | `census.loft` §2–§3 | law **F** decided at level 1 (`X38`); **I-EXTEND**'s census obligation |
   | `census.loft` §7 | **I-CLOSE**, **K-FIT** — non-convex forms break law F, so the doorstep refuses them (`X46`) |
   | `surface.loft` | **G2** (the analytic surface), **I-EXACT** — averaging, no tolerance (`X47`) |
   | `foxel.loft` | **G-FOXEL**, **L12** — the schema as a storage format (`X63`, `X64`) |
   | `surface.loft` §6–§7 | **I1**, **I2**, **K-FIT** — a feature is a material at an edge centre; deleting an edge fragments the run (`X48`) |
   | `arc.loft` §1–§4 | **I-QUANT**, **K-FIT** — centre exact, radius quantised to a shell (`X49`, `X50`) |
   | `arc.loft` §5 | **I1**, **I-RT** — the doored tower: a door is a material annotation, so it round-trips as **one** arc; deleting fragments it (`X51`) |
   | `combine.loft` | **I-ARBIT**, **I-CLOSED-OPS** — two stencils adjacent: "mark all, then cut once" is order-free, the shared edge fuses, only a behavioural difference is field-distinct (`X52`) |
   | `seam.loft` | **I-FSEAM**, **I-ARBIT** — the frame seam: `ε_seam` ≈ machine ε and confined (the forbidden fix moves it inside), κ counted, arbitration order-free + fail-safe (`X53`) |
   | `arb.loft` | **I-ARBIT**, **K-PROXY** — overlap arbitration by nearest surface (`cut_arb`): each boundary edge → its nearest analytic surface, order-free, ties to lower id (`X54`) |
   | `line.loft` | **I-DOMAIN**, **I-ARBIT** — stencil against linework: the cut spans domains A/B, and an E–W world line recovers exactly straight, eave_spread 0 (`X55`) |
   | `censusb.loft` | **I-DOMAIN**, **I-QUANT**, **K-FIT** — the domain-B cost table on three axes: period classes (6/6/12), the angle split, and **`δ` — whether a direction links to the house angles unconditionally** (`X56`) |
   | `embed.loft` | **I-RT**, **I-DOMAIN** — `OD-13`'s load-bearing half: a stencil carries an in-between wall as interior-edge material, footprint and `rebuild` untouched (`X60`) |
   | `terrain.loft` | **G5**, **I-RT** — seating on terrain: the `height` slot is orthogonal to the footprint, so `rebuild` is untouched; the residual is returned and flagged (`X59`) |
   | `level.loft` | **I-ARBIT**, **I-DOMAIN** — the bridge guarantee: a level filters before the cut, so different sheets never fuse, arbitrate or contend; level 0 is free (`X58`) |
   | `flip.loft` | **I-FLIP**, **I-CLOSED-OPS** — linework under the 12 orientations: the 24 directions are closed, and a wall segment's mirror reverses traversal (`d → −d` at the mirrored far end); in-between directions included (`X57`) |
   | `text.loft` | **I-EXACT** — `write(read(T)) = T` as a byte diff, no ε (`X39`); **C1–C5** |
   | `trip.loft` | **I-RT**, **I-EXACT**, **I-TOTAL** — `write(rebuild(draw(read(T)))) = T` byte-for-byte over the **committed** corpus (`X41`); control: a non-grammar footprint → R2 with `ρ > 0` |
   | `wall.loft` §1, §2, §5 | **I-DOMAIN** *(`D`; the even/odd split, measured)* |
   | `wall.loft` §2b | **I-EDGE**, **L11** |
   | `wall.loft` §3, §4 | **I3** *(three slots, an edge stored once by its owner)* |
   | `wall.loft` §3b | **L10** |
   | `wall.loft` §6 | **I-ALONG**, **I-EVAL** |
   | `wall.loft` §7 | **I-WIDTH** |
   | `wall.loft` §8 | **K-FIT** *(the doorstep: which endpoints exist at all)* |
   | `wall.loft` §9 | **K-FIT** *(the snap, and that a refusal carries its residual)* |
3. **The prose docs become reference-only** — read for *why*, never the build input. If building
   needs a fact, it belongs here as a checkable item, not in a paragraph.
4. **Gaps are visible:** an unstarted `G*` with no gate, an `L*` with no enforcing check, is
   open work — not silently assumed done.
