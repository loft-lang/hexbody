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
  and record the fork where it belongs (`plans/m0-roundtrip/DESIGN.md` §10 is the pattern) rather than
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

**Trust is by EVIDENCE KIND, not by repo** (`ROUNDTRIP.md` §7). The distinction that matters:
crawler's prototypes and design docs are **design tries** — input, not authority.

| tier | what it is | how to use it |
|---|---|---|
| **T1 · gated** | a green gate **with a control that must fire**, in a repo's `make test` | **authoritative** |
| **T2 · measured by a try** | a prototype produced a number | indicative — **re-measure here** |
| **T3 · designed** | a doc argues a construction | **input to design, never truth** |
| **T4 · schema** | a shape read from **untested** code (`../moros`) | shape real, behaviour unverified — cherry-pick, then gate here |

**Exactly one prior-art item is T1.** Everything else the design leans on is a try or a schema,
and the census is where it gets re-measured under our own gates. Citing a T2 number as settled is
the specific mistake to avoid — in either direction: re-deriving what is genuinely gated wastes
effort, and trusting a try forfeits what this project is for.

hexbody is the **strictest** of the three: every gate carries a control that must fire, every
constant is measured, every claim is falsifiable. **Adopting moros code without re-gating it
forfeits exactly the thing this project is for.** moros is a source, never a foundation.

**Why the rigor, historically.** There have been **three earlier implementations** of these hex
routines — one Python, one C++, one Rust — and **this is the first with a solid base for
features**. The C++ and Rust versions live somewhere on GitHub and are **not worth chasing**;
don't go looking. What *is* in-workspace and useful: `crawler/tools/wallproto/` (the Python
reference behind `X10`'s 2D validation) and `crawler/plans/5-geometry/*.py`.

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
| **`ROUNDTRIP.md`** | the **settled formal core** — the lattice, objects, the foxel, maps, the `D`/`E₂` contract with its **proved** propositions, the two recovery regimes, and the inherited constraints `X1`–`X19` **with trust tiers** | **authoritative** on any object or map |
| **`plans/m0-roundtrip/DESIGN.md`** | the **in-flight half** — proposed laws, the grammar, `fits?`, the seam, the corpus, the method, the gates, and the **open decisions**. Everything here is a proposal or a question | **cite nothing from it as fact** |
| **`SPEC.md`** | goals **G**, limits **L**, invariants **I**, contracts **K** — short, falsifiable, each with a control | authoritative on *what must be achieved* |
| `VISION` · `ARCHITECTURE` · `design/*` | *why* — reference only | **never the build input** |
| `PLAN.md` | milestone through-line (P, M0–M7); the synthesis layer, not a plan index | — |
| `plans/README.md` | plan conventions, lightest-workflow table, value categories | — |

**Build and verify against `ROUNDTRIP` + `SPEC`; design in `DESIGN.md`.** If building needs a fact, it belongs there as
a checkable item — not in a paragraph. A gate defending no spec item, or a spec item no gate
defends, is the thing to fix.

## Conventions — verified against `../crawler`, `../moros`, `loft-libs-*`

**Two project kinds, two test conventions. hexbody is the *application* kind**, like crawler.

| | **library** (`gridmesh`, `hex_field`) | **application** (crawler, hexbody) |
|---|---|---|
| layout | `loft.toml` `[library] entry`, `src/<name>.loft`, `tests/<topic>.loft` | `src/*.loft`, no `tests/` |
| a test is | `fn test_*()` + `assert(cond, "msg")` | a **program**: `ok` flag, printed counts, final `=== NAME OK ===` |
| run by | the package test harness | a runner that **greps the marker** |
| header | `// Copyright …` + `// SPDX-License-Identifier: LGPL-3.0-or-later` | a purpose block, no copyright (hexbody has no `LICENSE`) |

- **Module names**: `hex*` for geometry algorithms (`hexedge`, `hexway`, `hexroof`, `hexform`);
  `house*` for the building layer. **The test drops the `hex` prefix** — `hexedge` → `edgetest`,
  `hexroof` → `rooftest`, so `hexform` → **`formtest`**.
- **Struct field prefixes**: a 2-letter tag from the struct name, on *every* field —
  `HexSet`→`hs_`, `Plan`→`pl_`, `Chunk`→`ck_`, `SideRun`→`sr_`, `Surfaces`→`sf_`,
  `WallDef`→`wd_`, `Skeleton`→`sk_`. Universal across all four repos.
- **Gate runner**: hexbody's `Makefile` inlines the single-gate form. crawler scales it with
  `tools/run_tests.sh` — a table of `file|marker|log|fail-text|label` and `[n/N]` labels.
  **Adopt that table once hexbody has 3+ gates**, which `STEPS.md` reaches at S5.

### loft rules most likely to bite the S0–S8 code

- **`v[i]` with a negative `i` reads from the END — it does not return null.** A running heading
  `h = h0 + Σ turn` goes negative routinely (turns are `−5..6`), so `table[h]` silently returns the
  wrong vector. **Normalise to `0..11` first**: `((h % 12) + 12) % 12`.
- **Loop variables must be distinctly named per function** — two loops over different element
  types sharing a name is a compile error, and same-type reuse across a function is one slot.
- **UPPER_CASE locals warn** unless declared `const`. File-scope constants are `UPPER_CASE`.
- `text`, never `string`. Match arms use `=>`, never `->`. No nested `fn`.
- Scalars and vectors are **non-null by default**; write `?` only where null is genuinely wanted,
  and never write the retired `not null`.

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
- **The foxel schema is the limit** (`ROUNDTRIP.md` §2.4): `layer* × point → (height, material,
  wall1, wall2, wall3, item)`. A model is admissible **iff it draws into that exactly**, which
  makes `fits?` syntactic and finite. It closed OD-2/3/4/6/7/8 — roofs and terrain are `height`,
  trees are `item`, walls are the three edge slots, layers are in, the foxel is the stored truth.
- **Still open** (`plans/m0-roundtrip/DESIGN.md` §10): **OD-1** the morph (narrowed to "probably
  unnecessary" by free poses) · **OD-5** is the flip exact (`X2` says yes) · **OD-9** does a door
  survive as an *annotation* when an edge has one `material` slot — the doored-tower defect
  relocated into the schema, and rung A5's real question.
- **Established constraints from crawler are in `ROUNDTRIP.md` §7 (X1–X10)** — measured or
  gated already; do not re-derive them.
- **Two unmeasured constants:** `ε_seam` and the `κ≥3` contention rate (`plans/m0-roundtrip/DESIGN.md` §7).
  `D` is **closed** — all 24 headings are representable (**X3**).
- `hexedge` / `hexway` / `hexroof` are byte-identical copies of crawler's. No drift yet; their
  proper home is `loft-libs-world`.

## The traps that bite

- **"Fit" is the wrong word and the wrong instinct — *in regime R1*.** For a stencil **we
  authored**, the grammar is the prior and recovery is an exact match; an `ε` there is a defect
  signal, never a knob (law **P4**). But **R2** — recovering *arbitrary cell-authored* content
  with no grammar behind it — genuinely **is** a fit with a pinned tolerance, licensed by law
  **E₃** and prototyped in crawler's `matcher.py`. Know which regime you are in
  (`ROUNDTRIP.md` §6); using R2's machinery where R1 applies throws away an exact answer.
- **Width-normalise before ranking anything by heading** (**X9**). A fixed nominal width yields
  different cell counts per direction, so raw spread measures *width, not heading* — in crawler
  this **inverted** the conclusion before it was caught.
- **Imprecision is allowed only on the seam between frames** (law **K₁**) — never inside one.
  Closing a crack by moving geometry is the forbidden fix.
- **Jank is not licence for nondeterminism.** `L7`/`I9` need byte-identical replay, so seam error
  and arbitration must be deterministic functions of their inputs.
- **Every gate carries a control that must fire.** A check that cannot go red is not a check.
