# hexbody

*(working name — rename with one `mv` + one `loft.toml` line.)*

**A system-prototyping harness built on produced geometry.** Real, exact geometry —
houses, walls, floors — becomes movable, rotatable, breakable **Bodies** whose collision
**proxies are *derived from the geometry itself***, not hand-authored. So a small team can
**live-test a game system** — combat, traversal, vehicles, a *Shadow of the Colossus*-class
enemy-that-is-also-a-platform — **before any art exists**, then take one of two exit paths:

- **studio path** — swap the placeholder geometry for authored meshes; the validated system
  carries over unchanged, because it consumes a *proxy*, not a mesh.
- **indie path (the mission)** — refine the produced geometry itself until it ships. No art
  department, no mesh pipeline, no swap. The produced geometry *is* the shippable art.

Why this is possible: **our geometry is structured field data, not an opaque mesh, so the
collision proxy is *computable* from it.** Where all you have is a mesh, collision volumes are
authored by hand because a bag of triangles can't be reasoned about; hexbody derives them all
from one representation, so arbitrary, procedurally-placed bodies of any scale — a person, a
cart, a blimp, a colossus — get proxies for free.

The **why and the goals** are in [`VISION.md`](VISION.md); the **how** — the mechanism, the
proxy contract, the destruction models, the roadmap — is in
[`ARCHITECTURE.md`](ARCHITECTURE.md); and **what to build, in what order** — the milestones from
the first brick to the derailment hero demo — is in [`PLAN.md`](PLAN.md).

**[`SPEC.md`](SPEC.md) is the checkable build target** — the goals (G), limits (L), invariants
(I) and contracts (K) as short, formal, falsifiable items. **Build and verify against `SPEC.md`,
not the prose;** the prose says *why*, the spec says *what*, checkably.

**[`ROUNDTRIP.md`](ROUNDTRIP.md) is the settled formal core** — the objects (`𝕄*` the fitting
model, `𝕋` its canonical text, `𝔽` the field), the maps (`snap`, `write`/`read`, `draw`/`rebuild`),
the `D`/`E₂` contract with its **proved** propositions, and the constraints already measured in
`../crawler`. **Only what is not in dispute.** Everything still being designed or decided — the
grammar, the censuses, the open decisions — lives in
[`plans/m0-roundtrip/DESIGN.md`](plans/m0-roundtrip/DESIGN.md) — a proposal or a question, never
a fact to cite.

The thesis both serve: the exact world model is drawn onto the field and **rebuilt from it
exactly**; `snap` is the only lossy step and it reports its residual. `SPEC` says *what must be
achieved*, `ROUNDTRIP` *what the objects are* — and on any question about an object or a map,
`ROUNDTRIP` is authoritative.

## Lineage — and the reservoir still in `../crawler`

- **Built on `hex_field`** (the exact-integer field core: `HexSet`, `EdgeSet`, `Heights`,
  `Labels`, `Stencil`) in the sibling repo `../loft-libs-world`, branch `dev`.
- **Split out of `crawler`** (2026-07-23), which is the **first consumer and the proof**: if
  crawler can build its own colossus on hexbody, the harness thesis is demonstrated.

> **This is the fourth implementation of these hex routines — after a Python, a C++ and a Rust
> version — and the first with a solid base for features.** The earlier three are not a source to
> mine (the C++ and Rust ones live on GitHub and are not worth chasing); the point is that three
> attempts did not reach a foundation, which is what the gate-with-a-control discipline is
> protecting.

> **Most of this project's substance originated in `../crawler`, and far more of it is still
> there than has been moved.** hexbody is a young extraction of a long-running body of design and
> prototyping. **Read crawler before building anything here** — the odds are good that the problem
> has already been characterised, and often already prototyped.

**Design docs still in crawler, directly on hexbody's remit:**

| doc | what it holds |
|---|---|
| `plans/5-geometry/` | the geometry plan hexbody was seeded from — **plus Python prototypes**, below |
| `plans/11-3d-world/` | `BUILDING.md` (§4 the wall run vs the wall), `HOUSE.md`, `DRAWING.md`, `DRAWING-API.md`, `RESULTS.md` — ~2 400 lines |
| `WALLS.md` | the **triangle-subdivision wall model** — the exact construction, not an approximation |
| `STENCILS.md` | layered, composable stencils → castles |
| `FORMS.md` | a kit of exact, interlocking hex parts — no seams by construction |
| `PROPS.md` | small detail without a library of model files *(bears on `DESIGN.md` OD-3, trees)* |
| `plans/9-canopy-trees/` | `TREES.md` — canopy-first trees *(OD-3)* |
| `plans/8-landform-morphogenesis/` | terrain *(OD-4)* |
| `SCALE.md` | the scale contract behind `SPEC` **L8** |
| `EXTRACTION.md` | the library-extraction seam — where shared code is meant to land |
| `DESIGN-PROTOCOL.md` | the blueprint-phase method `plans/README.md` binds to |
| `LOFT-HANDOFF.md` · `FILING.md` · `LOFT-NOTES.md` | toolchain defect filing and the loft survival guide |

**Prototypes in `crawler/plans/5-geometry/` — read these before building M0:**

| file | what it prototypes |
|---|---|
| `matcher.py` | **recover surfaces from a traced cell boundary** — boundary loop → straights + arcs. This is `rebuild` for domain A |
| `directions.py` | **can a wall/road run in all 24 directions?** — a hex grid has 12 natural directions (6 edge, 6 vertex, 30° apart), so 12 of the 24 are off-axis by 15°. Substantially the domain-B census |
| `deviation.py` | per-point distance from an emitted outline to the ideal form — the residual `ρ` |
| `roundness.py` · `collision_fit.py` | tower footprints chosen by **best collision match**, not best shape match |
| `road_arcs.py` · `ways.py` | road arcs by the same collision-match ladder; ways as an exact centreline **plus offsets**, never a rasterised band |
| `hexforms.py` | the blueprint-phase test bench — validated exact vector maps |

**Code duplicated, not yet extracted:** `hexedge` / `hexway` / `hexroof` are byte-identical copies
of crawler's. Their proper home is `loft-libs-world` — see *Status*.

## Status

Seeded from crawler's plan-#11 P5 geometry work, verified running standalone here:

| file | what it is |
|---|---|
| `src/housedraw.loft` | the drawing routines — `draw_floor`, `draw_walls` (thin, edge-based), `place_opening` (doors/windows), `draw_roof` |
| `src/hexform.loft` | **the 12 headings of `H₁₂`** as exact lattice steps, in doubled `(k,m)` — parity-free, so nothing downstream branches on `r & 1` |
| `tests/house.loft` | the gate: one house at all **12 orientations**, cells + edges equivariant, openings, roof, eave; every check has a control that fires |
| `tests/form.loft` | the gate for `hexform`: the involution, the two length classes, and the **exact rotation and reflection re-measured here** (`X1`/`X2`, now T1) |
| `src/houseshot.loft` | the 12-orientation contact sheet → `/tmp/house12.png` |
| `src/hexedge`, `src/hexway`, `src/hexroof` | supporting geometry algorithms (edges, tracks, roof profiles) copied from crawler; they belong to this project's *"more algorithms"* remit |

**Migration status (2026-07-23):**

- **`housedraw` / `housetest` / `houseshot` are now hexbody-only.** *(`housetest` has since
  become [`tests/house.loft`](tests/house.loft).)* crawler's game never called
  them (they were only self-referential), so crawler deleted its copies and dropped the
  `housetest` row from its gate; hexbody owns them and gates them here.
- **`hexedge` / `hexway` / `hexroof` are still duplicated** (crawler + hexbody). They are
  load-bearing in crawler's game — `hexedge` alone has 28 users including `sim.loft` — so
  crawler keeps them. hexbody's copies are a stopgap. Their proper home is the shared
  low-level library `loft-libs-world` (like `hex_field`); extracting them there, so both
  crawler and hexbody consume one source, is the follow-up that ends the duplication.

## Run

```sh
make test    # all 23 headless gates in tests/, ~4 min — the table is tools/run_tests.sh
make shot    # render the contact sheet -> /tmp/house12.png
```

Gates live in **`tests/`**, modules in `src/`; the `Makefile` passes `--lib src/` so a gate can
`use` them.

**The toolchain is the *installed* loft** (`--path /usr/local/share/loft/`), not the `../loft`
working tree: loft reads its codegen support from `--path` while the code it generates links the
*installed* rlib, so aiming it at a live tree pairs a new source with a stale library — which broke
every `hex_field` gate on 2026-07-24. hexbody consumes loft releases, not loft's desk. Override
with `make test LOFT_PATH=../loft/` after reinstalling, if you mean to test an unreleased one.

**Two sibling working trees still feed the gates and neither is pinned:** the `hex_field` family at
`../loft-libs-world`, and **`../moros`** — whose source `tests/palette.loft` reads directly, because
`SPEC` **L13** makes moros's voxel the storage of record. `--lib` reads the **working tree**, so
confirm `loft-libs-world` is on branch `dev` before debugging anything strange; the palette gate
prints which moros revision it read, but cannot see whether that tree is dirty.
