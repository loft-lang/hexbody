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

**T1 holds `X1`, `X2`, `X19`–`X22`, `X24`–`X38`** — eight of them re-measured *here*, and
`X26`–`X31` **discovered here**. Everything else the design leans on is still a try or a schema
(notably the whole foxel schema, `X11`–`X15`), and the census is where it gets re-measured. Citing a T2 number as settled is
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
| **`ROUNDTRIP.md`** | the **settled formal core** — the lattice, objects, the foxel, maps, the `D`/`E₂` contract with its **proved** propositions, the two recovery regimes, and the constraints `X1`–`X38` **with trust tiers** | **authoritative** on any object or map |
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

| | **library** (`gridmesh`, `hex_field`) | **application** (crawler) | **hexbody** |
|---|---|---|---|
| layout | `[library] entry`, `src/`, `tests/` | `src/*.loft`, no `tests/` | `src/` + **`tests/`** |
| a test is | `fn test_*()` + `assert(…)` | a **program**: `ok` flag, counts, `=== NAME OK ===` | **the program form** |
| run by | the package harness | a runner that **greps the marker** | `make test`, greps the marker |
| header | Copyright + SPDX | a purpose block | a purpose block (no `LICENSE`) |

**hexbody takes the library's `tests/` layout with the application's gate form** — gates are
programs that print their evidence and end in `=== NAME OK ===`, but they live in `tests/`, named
by topic without a `test` suffix (`tests/form.loft`, `tests/house.loft`), exactly as `gridmesh`
names `tests/segmesh.loft`. This works because the `Makefile` passes **`--lib src/`**: without it
a file in `tests/` cannot `use` a module in `src/` (*"Library 'hexform' not found"*).

- **Module names**: `hex*` for geometry algorithms (`hexedge`, `hexway`, `hexroof`, `hexform`);
  `house*` for the building layer. A gate is `tests/<topic>.loft` — the module's name with any
  `hex`/`house` prefix dropped: `hexform` → `tests/form.loft`, `housedraw` → `tests/house.loft`.
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
make test    # the headless gates in tests/ — form, wall, box, census, house
make shot    # contact sheet -> /tmp/house12.png
```

Needs `../loft` and `../loft-libs-world` as siblings. **`--lib` reads the WORKING TREE**, so
check that `loft-libs-world` is on branch `dev` before debugging anything strange.

## State (2026-07-23)

- **Five gates, all green** — `make test` runs `tools/run_tests.sh` (the crawler table form).
  Form, wall (~3 min), box, census, house.
- **Green:** `G0` / law **I** — `tests/house.loft`, 12/12 equivariant in cells *and* edges, `eave_spread
  0.0000`, every control fires. `make shot` reproduces the committed baseline byte-identically.
- **Green:** `tests/form.loft` (**S0**/**S1**) — the 12 headings; **`X1`**/**`X2`** re-measured to **T1**
  (625 cells, 0 non-integral rotation images, six rotations exactly the identity); **`X20`**, the
  heading table is parity-free in doubled `(k,m)`, checked against `hex_field`'s `nb_q`/`nb_r`;
  **`X24`** no square sublattice; **`X25`** isotropy is exactly `9/8`.
- **Green:** `tests/wall.loft` — the 24-direction wall. It produced **`X26`–`X32`**, the first
  constraints hexbody *discovered* rather than inherited, and **two defects every other gate was
  green through**: `X26` five of six edges misfiled (a private corner table beside `hex_field`'s
  neighbours — see **L11**), and `X28` the first write rule marked the edges *across* the wall
  (a comb of pickets). **`X32` fixed it (OD-12 resolved):** the wall marks the edges that
  **separate** its two sides — one connected chain **along** the line (§6: every wall is one
  chain, 2 ends, 0 branches, vs a picket comb's 18).
- **The width question is settled** (`DESIGN.md` §10.9): all 24 can be exactly straight and exactly
  the same width **iff** a wall is a *line primitive* with a constant width and the cells are its
  rasterisation. Counting lattice rows provably cannot equalise them (**X30**), and **no lattice
  vector points at 15°** (**X31**) — so the odd 12 are straight and equally wide but never at their
  nominal angle. The `4.107°` error is *not* forced: it buys a period of 0.882 wu; `N = 13` gives
  `1.102°` at 1.202 wu. **Changing it is a live proposal, not a decision.**
- **Green:** `tests/box.loft` — the box in 12 directions (30 deg steps, two non-interchangeable
  families), agreeing cell-for-cell with `housedraw`'s `Plan` on the even six; plus BOTH walls —
  the thin edge wall (houses) and the **thick ring of cells** (castles, town walls), the latter
  gated by flooding the outside and failing to get in.
- **The editor's doorstep for a line is closed-form** (`DESIGN.md` §10.10): endpoints are hex
  **vertices** a whole number of periods apart. Quantisation is **1.5 m** (0/60/120...),
  **0.866 m with one in three refused** (30/90/150...), **3.969 m** for the in-between 12 — which
  is a second, independent reason houses avoid them. `nearest_vertex` + `snap_run_d24`/`snap_run_p`
  take an arbitrary mouse point to a legal line; both gated against brute force.
- **Green:** `tests/form.loft` §12–13 (**S3**) — a closed turtle `Form` fills to its
  **closed-form** cell count: triangle `(n+1)(n+2)/2`, rhombus `(a+1)(b+1)`, hexagon `3n²+3n+1`,
  ten shapes exact (**X33**). The lattice holds these exactly where it provably cannot hold a
  rectangle (`X24`) — that is why both primitives exist. A non-closing cycle is **refused**.
- **`shoelace = 12×cells` is an identity, not a fill check** (**X34**) — true for any cell set,
  holes included. It checks the boundary *convention* (the `X26` class), and its control is a
  wrong corner pairing. Do not cite it as validating a fill; that would be the `X15` mistake.
- **Green:** `tests/form.loft` §14–17 (**S4**) — the boundary of a filled region is **one closed
  loop** (`ends 0, branches 0, loops 1`, seven shapes; a hole shows as 2 loops — **X35**), the four
  side runs **partition** it so a corner edge is claimed exactly once (**X36**), and a band wall
  eats the floor an edge wall keeps (**X37**, `I3`'s control).
- **Corner parts 2 and 4 are a TRIPWIRE, not a red suite** — they need the fitted surface (S8).
  `hexform::SURFACE_LANDED` is `false`; the gate prints them PENDING, and **flipping it at S8
  fails the gate** until the real checks are written. Deliberate reading of `DESIGN.md` §10.4,
  which says "write them red": a permanently red suite stops being a signal.
- **Green:** `tests/census.loft` (**S5**) — `rt_census_a` at n=1. **660 proposed, law J admits 30,
  3 distinct shapes, 183 collisions, 0 unexplained: law F HOLDS at level 1** (**X38**). The digest
  quotients by orientation and translation (law I) and is **exact**, never hashed — a hash
  collision in a census looks exactly like a law F violation.
- **Found by the census, for S6:** the canonical text must fix the starting **CORNER**, not just
  the winding. `[2,5,5]`/`[5,5,2]`/`[5,2,5]` are one cycle walked from three corners.
- **`h0` parity does NOT classify a form** into the edge/vertex class — sides run `h0`, `h0+t₀`,
  `h0+t₀+t₁`, so turns `2,5,5` from `h0=0` mix both classes. Assuming otherwise produced 72
  confident false "law F violations" before it was caught.
- **Everything else is open.** No `body.loft`, no `proxy.loft`, no `rebuild`, no corpus. Next step
  is **S6** (canonical text — and it must fix the starting corner) — see
  `plans/m0-roundtrip/STEPS.md`.
- **The foxel schema is the limit** (`ROUNDTRIP.md` §2.4): `layer* × point → (height, material,
  wall1, wall2, wall3, item)`. A model is admissible **iff it draws into that exactly**, which
  makes `fits?` syntactic and finite. It closed OD-2/3/4/6/7/8 — roofs and terrain are `height`,
  trees are `item`, walls are the three edge slots, layers are in, the foxel is the stored truth.
- **Still open** (`plans/m0-roundtrip/DESIGN.md` §10): **OD-1** the morph (narrowed to "probably
  unnecessary" by free poses) · **OD-5** is the flip exact (`X2` says yes) · **OD-9** does a door
  survive as an *annotation* when an edge has one `material` slot — the doored-tower defect
  relocated into the schema, and rung A5's real question.
- **Constraints are in `ROUNDTRIP.md` §7 (X1–X31) with trust tiers.** T1 now holds `X1`, `X2`,
  `X19`–`X22`, `X24`–`X38`; do not re-derive those. Everything else is still a try or a schema.
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
- **A binary op whose operands BOTH come from functions defined lower in the file resolves as
  `integer`.** loft is two-pass: a forward call is `Unknown` in pass 1, and operator overload
  resolution then picks the first candidate (`OpMinInt`/`OpMulInt`) when it can type NEITHER
  operand — locking the result to integer. Pass 2 re-resolves to float, and the assignment errors
  "cannot change type from integer to float" at a line that looks correct. A bare
  `fax = tri_x(...)` is FINE, and so is one known-typed operand (`fax - 1.0`, `fax - kf`); unary is
  already guarded (loft#592). Define helpers **above** their callers.
- **Never construct a struct inside an argument list** — `f(Mk(...), set)` in a loop is
  corrupted from the SECOND iteration when the call also takes a store-allocated value
  (`HexSet`/`EdgeSet`). Hoist it: `x = Mk(...); f(x, set)`. Silent, deterministic, and the
  symptom looks exactly like a geometry bug — wrong cell counts that vary per rotation. Filed as
  **H4** in crawler's `LOFT-HANDOFF.md`; reproducer in `plans/m0-roundtrip/probes/inline_struct.loft`.
- **Every gate carries a control that must fire.** A check that cannot go red is not a check.
