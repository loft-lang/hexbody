# CLAUDE.md — hexbody quick reference

**A system-prototyping harness built on produced geometry.** Exact geometry — houses, walls,
roofs, roads — becomes movable, breakable **Bodies** whose collision **proxies are derived from
the geometry itself**. Split out of `crawler` 2026-07-23; `crawler` is its first consumer.

## Working with me — read this first

- **Ask questions as plain text, never with a question UI.** The widget's fixed option list is
  too narrow for this project's decisions, which are usually design forks with real trade-offs
  and answers that are often *"none of those, because…"*. State the fork in prose — the options,
  what each costs, a recommendation — and let the reply go wherever it goes. Several open
  questions in one message is fine.
- **Keep working while a question is open.** Do everything that does not depend on the answer,
  and record the fork where it belongs (`ROUNDTRIP.md` §11.2 is the pattern) rather than
  stalling on it or quietly picking one.
- **loft is upstream and consumer-only** — hexbody never fixes loft. Toolchain defects go to
  crawler's `LOFT-HANDOFF.md` / `FILING.md`, never into a hexbody plan. The
  `stores not freed at program exit` warning on every run is one of these: known, loft-side.
- **Commit and push only when asked.** Commit messages end with the org `Co-Authored-By` trailer.

## Check `../crawler` first — it is the reservoir, not just the origin

hexbody was split out of crawler on 2026-07-23 and is a **young extraction of a long-running body
of work**. Far more design and prototyping is still in crawler than has been moved.

> **Before designing or building anything here, look in crawler.** The problem has usually been
> characterised there already, and often prototyped. Specifying from scratch what already exists
> is the most likely way to waste effort in this repo.

- **`crawler/plans/5-geometry/`** — the plan hexbody was seeded from, **plus Python prototypes
  that cover much of M0**: `matcher.py` (recover surfaces from a traced boundary → `rebuild`),
  `directions.py` (the 24-direction question: a hex grid has 12 natural directions, so 12 of the
  24 are off-axis by 15°), `deviation.py` (the residual `ρ`), `roundness.py` / `collision_fit.py`
  / `road_arcs.py` (footprints by **best collision match**, not best shape match), `ways.py`
  (centreline + offsets, never a rasterised band), `hexforms.py` (the test bench).
- **`crawler/plans/11-3d-world/`** — `BUILDING.md` §4, `HOUSE.md`, `DRAWING.md`, `RESULTS.md`.
- **`crawler/WALLS.md`** — the triangle-subdivision wall model, the exact construction.
- **`STENCILS.md` · `FORMS.md` · `PROPS.md` · `SCALE.md` · `EXTRACTION.md`** — stencils, the
  exact-parts kit, props (bears on OD-3), the L8 scale contract, the extraction seam.
- **`plans/9-canopy-trees/TREES.md`** (OD-3) · **`plans/8-landform-morphogenesis/`** (OD-4).
- **`DESIGN-PROTOCOL.md`** — the blueprint-phase method `plans/README.md` binds to.

Full map with one-liners: [`README.md`](README.md) § *Lineage*.

## The doc hierarchy — build from the formal files, not the prose

| file | role | authority |
|---|---|---|
| **`ROUNDTRIP.md`** | the **formal model**: objects (`𝕄*`, `𝕋`, `𝔽`, `P`, `O`, `H₁₂`, `D`), maps (`snap`, `write`/`read`, `draw`/`rebuild`), **laws A–K₂** | **authoritative** on any object, map, or law |
| **`SPEC.md`** | goals **G**, limits **L**, invariants **I**, contracts **K** — short, falsifiable, each with a control | authoritative on *what must be achieved* |
| `VISION` · `ARCHITECTURE` · `design/*` | *why* — reference only | **never the build input** |
| `PLAN.md` | milestone through-line (P, M0–M7); the synthesis layer, not a plan index | — |
| `plans/README.md` | plan conventions, lightest-workflow table, value categories | — |

**Build and verify against `ROUNDTRIP` + `SPEC`.** If building needs a fact, it belongs there as
a checkable item — not in a paragraph. A gate defending no spec item, or a spec item no gate
defends, is the thing to fix.

## Run

```sh
make test    # the headless gate — housetest, 12 orientations
make shot    # contact sheet -> /tmp/house12.png
```

Needs `../loft` and `../loft-libs-world` as siblings. **`--lib` reads the WORKING TREE**, so
check that `loft-libs-world` is on branch `dev` before debugging anything strange.

## State (2026-07-23)

- **Green:** `G0` / law **I** — `housetest`, 12/12 equivariant in cells *and* edges, `eave_spread
  0.0000`, every control fires. `make shot` reproduces the committed baseline byte-identically.
- **Everything else is open.** No `body.loft`, no `proxy.loft`, no `rebuild`. Of the round-trip
  gates only `rt_orient` exists.
- **Eight open decisions** (`ROUNDTRIP.md` §11.2). OD-1 the morph · OD-2 roofs · OD-3 trees ·
  OD-4 terrain · **OD-5** is the flip exact? · **OD-6** is a stencil a *field* or a *generative
  description*? · **OD-7** which wall model? · **OD-8** when do layers enter? OD-5–8 are conflicts
  with **settled crawler prior art**, and **OD-6 is the deepest — it probably orders the rest**.
- **Established constraints from crawler are in `ROUNDTRIP.md` §11.1 (X1–X10)** — measured or
  gated already; do not re-derive them.
- **Two unmeasured constants:** `ε_seam` and the `κ≥3` contention rate (`ROUNDTRIP.md` §8).
  `D` is **closed** — all 24 headings are representable (**X3**).
- `hexedge` / `hexway` / `hexroof` are byte-identical copies of crawler's. No drift yet; their
  proper home is `loft-libs-world`.

## The traps that bite

- **"Fit" is the wrong word and the wrong instinct — *in regime R1*.** For a stencil **we
  authored**, the grammar is the prior and recovery is an exact match; an `ε` there is a defect
  signal, never a knob (law **P4**). But **R2** — recovering *arbitrary cell-authored* content
  with no grammar behind it — genuinely **is** a fit with a pinned tolerance, licensed by law
  **E₃** and prototyped in crawler's `matcher.py`. Know which regime you are in
  (`ROUNDTRIP.md` §5.1.1); using R2's machinery where R1 applies throws away an exact answer.
- **Width-normalise before ranking anything by heading** (**X9**). A fixed nominal width yields
  different cell counts per direction, so raw spread measures *width, not heading* — in crawler
  this **inverted** the conclusion before it was caught.
- **Imprecision is allowed only on the seam between frames** (law **K₁**) — never inside one.
  Closing a crack by moving geometry is the forbidden fix.
- **Jank is not licence for nondeterminism.** `L7`/`I9` need byte-identical replay, so seam error
  and arbitration must be deterministic functions of their inputs.
- **Every gate carries a control that must fire.** A check that cannot go red is not a check.
