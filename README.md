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

Why this is possible here and not in a AAA engine: **our geometry is structured field data,
not an opaque mesh, so the collision proxy is *computable* from it.** FromSoft and Team Ico
author every collision volume by hand because a bag of triangles can't be reasoned about;
hexbody derives them all from one representation, so arbitrary, procedurally-placed bodies of
any scale — a person, a cart, a blimp, a colossus — get proxies for free.

The **why and the goals** are in [`VISION.md`](VISION.md); the **how** — the mechanism, the
proxy contract, the destruction models, the roadmap — is in
[`ARCHITECTURE.md`](ARCHITECTURE.md).

## Lineage

- **Built on `hex_field`** (the exact-integer field core: `HexSet`, `EdgeSet`, `Heights`,
  `Labels`, `Stencil`) in the sibling repo `../loft-libs-world`, branch `dev`.
- **Split out of `crawler`** (2026-07-23), which is the **first consumer and the proof**: if
  crawler can build its own colossus on hexbody, the harness thesis is demonstrated. crawler
  still holds its own copies of these files pending migration — see *Status*.

## Status

Seeded from crawler's plan-#11 P5 geometry work, verified running standalone here:

| file | what it is |
|---|---|
| `src/housedraw.loft` | the drawing routines — `draw_floor`, `draw_walls` (thin, edge-based), `place_opening` (doors/windows), `draw_roof` |
| `src/housetest.loft` | the gate: one house at all **12 orientations**, cells + edges equivariant, openings, roof, eave; every check has a control that fires |
| `src/houseshot.loft` | the 12-orientation contact sheet → `/tmp/house12.png` |
| `src/hexedge`, `src/hexway`, `src/hexroof` | supporting geometry algorithms (edges, tracks, roof profiles) copied from crawler; they belong to this project's *"more algorithms"* remit |

**Migration status (2026-07-23):**

- **`housedraw` / `housetest` / `houseshot` are now hexbody-only.** crawler's game never called
  them (they were only self-referential), so crawler deleted its copies and dropped the
  `housetest` row from its gate; hexbody owns them and gates them here.
- **`hexedge` / `hexway` / `hexroof` are still duplicated** (crawler + hexbody). They are
  load-bearing in crawler's game — `hexedge` alone has 28 users including `sim.loft` — so
  crawler keeps them. hexbody's copies are a stopgap. Their proper home is the shared
  low-level library `loft-libs-world` (like `hex_field`); extracting them there, so both
  crawler and hexbody consume one source, is the follow-up that ends the duplication.

## Run

```sh
make test    # the headless gate (housetest, 12 orientations)
make shot    # render the contact sheet -> /tmp/house12.png
```

Needs the loft toolchain at `../loft` and the `hex_field` family at `../loft-libs-world`
(both siblings under `workspace/`). `--lib` reads the **working tree**, so confirm
`loft-libs-world` is on branch `dev` before debugging anything strange.
