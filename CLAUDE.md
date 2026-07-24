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

**T1 holds `X1`, `X2`, `X19`–`X22`, `X24`–`X64`** — eight of them re-measured *here*, and
`X26`–`X31` **discovered here**. Everything else the design leans on is still a try or a schema
(the foxel **palette**, `X12`/`X13` — the schema's *storage* half is now T1 via `X63`), and the
census is where the rest gets re-measured. Citing a T2 number as settled is
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
| **`ROUNDTRIP.md`** | the **settled formal core** — the lattice, objects, the foxel, maps, the `D`/`E₂` contract with its **proved** propositions, the two recovery regimes, and the constraints `X1`–`X64` **with trust tiers** | **authoritative** on any object or map |
| **`plans/m0-roundtrip/DESIGN.md`** | the **in-flight half** — proposed laws, the grammar, `fits?`, the seam, the corpus, the method, the gates, and the **open decisions**. Everything here is a proposal or a question | **cite nothing from it as fact** |
| **`SPEC.md`** | goals **G**, limits **L**, invariants **I**, contracts **K** — short, falsifiable, each with a control | authoritative on *what must be achieved* |
| `VISION` · `ARCHITECTURE` · `design/*` | *why* — reference only | **never the build input** |
| `PLAN.md` | milestone through-line (P, M0–M7); the synthesis layer, not a plan index | — |
| **`ASSESSMENT.md`** | the project **measured against its goals** (editor-readiness, game-asset readiness, the frontier). Every claim marked **[G]** gated / **[B]** built-ungated / **[J]** judgement | **synthesis, not authority** — never cite a **[J]** as fact |
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

- **Discharge a text parse AT the cast, unparenthesised** — `s as integer ?? 0`. Wrapping it,
  `(s as integer) ?? 0`, is rejected: loft wants the fallible parse and its default as one
  expression, not a `??` applied to an already-parenthesised cast.
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
make test    # form, wall, box, census, text, house, surface, arc, trip
make shot    # contact sheet -> /tmp/house12.png
```

Needs `../loft` and `../loft-libs-world` as siblings. **`--lib` reads the WORKING TREE**, so
check that `loft-libs-world` is on branch `dev` before debugging anything strange.

## State (2026-07-24)

> **`M0`'s round trip is CLOSED, `G2` is done, and the foxel is gated — 19 green gates.** For where
> the project stands against its goals and what to do next, read **[`ASSESSMENT.md`](ASSESSMENT.md)**:
> the editor foundation is largely built and the **body** half (`G1`/`G3`/`G4`/`G6`) is not built at
> all. The risk that file named as largest — *the foxel schema is still T4* — **was gated the same
> day** (`X63`, `X64`); what is left of it is the **palette** (`X12`/`X13`), a vocabulary question
> rather than a mechanism.

- **The FOXEL is gated — `X63`, `X64`, the last T4 mechanism.** All six slots cross a write/read
  exactly (footprint→`OCCU`, `height`→`HGHT`, `material`→`LABL`, `wall1..3`→`EDGE` (the halo grid,
  ×3 per cell), `item`+rotation→a named `LAYR`), and **`layer*` — the STOREY sense — is N documents,
  not a section**. The prize: **`write(rebuild(load(store(draw(read(T)))))) = T` byte-for-byte, 6/6**
  in-between directions, with `Draft` as the vehicle because it is the only model whose recovery
  reads **both** cells and edges. The rim survives too (46/46 halo edges).
- **`X15`'s lossy writer is now a LIVE CONTROL** — moros admitted its writer *"never builds an
  `EdgeSet`"*; reproduced (`has_e = false`) it returns **0 of 38** edges and **breaks the trip**,
  while still carrying the footprint, so it is the *documented* loss and not a broken write. That is
  the control moros's own test could not fire.
- ⚠ **Cite the SPLIT, never "the foxel is gated".** `X63` does **not** touch the **palette**: `X12`
  (`wd_body`, `wd_thickness`) and `X13` (`ItemDef`/`MaterialDef` categories) stay **T4**, and
  `X14`'s *5-bit, 0–23* is still a moros claim even though the rotation slot round-trips.
- ⚠ **`doc_write` APPENDS (`X64`, `SPEC` L12)** — a reused path leaves the second document
  unreachable and the reader returns the **first** with `doc_code == HXF_OK`. Write to a **fresh
  path**, always; `tools/run_tests.sh` clears `/tmp/hexbody-foxel-*.hxf` before the gate.
- ⚠ **`file().content()` returns EMPTY for non-UTF-8 bytes, silently** (loft, both backends — filed
  as `crawler/LOFT-HANDOFF.md` **H7**). So **a byte length is not an available instrument** for any
  binary artefact: the natural append check reads `0` and `0`, and `0 == 0 * 2` is a **vacuously
  true** *"it appended"* — which this gate PRINTED before it was caught. Measure by content the
  format defines (a cell count, a digest), never by file size.
- **`G2` is DONE (`X61` + `X62`).** The wall renders as **ONE flat quad per side** — its analytic
  surface — not one strip per stored edge: **38 stored edges → 4 quads**, `eave_spread(fitted)` is
  **exactly 0**, and `make shot` straightens (features draw as **intervals on the surface**, which is
  `FEATURES`' own model). Control: the strip it replaces spreads by `X47`'s band (0.866 / 0.5 wu).
- **The corners MITER, and the `SURFACE_LANDED` tripwire is cashed in (`X62`).** The fit made the
  missing miter visible; `I-CORNER` parts 2/4 then closed it. **Part 2** — adjacent surfaces differ
  by heading `3` (unmirrored) or `9` (mirrored), **exactly 90°**, 48/48, in integer indices with no
  float. **Part 4** — `surface_quad` cuts both quads at the line intersection and the outline gap is
  **exactly 0**, 48/48; control, the un-mitered spans leave **11.592 wu**. `hexform::SURFACE_LANDED`
  is now `true`.
- ⚠ **Part 4's spec wording was WRONG and is corrected** — it said the miter *"sits on the exact
  model corner"*. Drift is `0.4794643` at **every** corner, spread `1.33e-15`: a **uniform bias, not
  scatter**, the tell that it is a definition difference. `Plan` is continuous-then-rasterised, so
  its corner is **quantised away** (`I-QUANT`/`X50`); the miter recovers the **cell-region** corner,
  the only one the field holds.
- ⚠ **Fourth consecutive step whose red was MY measurement** — part 2 first tested only difference
  `3` and failed 24/48, because mirrored orientations wind the other way. Same rule: a count off an
  established one by a clean factor (here exactly half) is a bug in the counter.
- **`plans/m0-roundtrip/shots/house12.png` was regenerated** — a review image (`L9`), not a gated
  baseline; `make test` never checked it.

- **Nineteen gates, all green** — `make test` runs `tools/run_tests.sh`.
  Form, wall (~3 min), box, census, text, house, surface, arc (A6 + A7), combine (A8), seam
  (A8 frame seam), arb (A8 nearest surface), line (A8 linework), censusb (domain B),
  flip (law G, ~16 s), level (A8 bridge guarantee), terrain (A8, OD-4), embed (OD-13),
  foxel (the schema as storage), trip.
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
- **Corner parts 2 and 4 WERE a tripwire, and it worked** — they needed the fitted surface, so
  `SURFACE_LANDED` stayed `false` and the gate printed them PENDING until `G2` existed. Flipping it
  did fail the gate, the real checks replaced the pending branch, and it is now `true` (`X62`). The
  deviation from `DESIGN.md` §10.4's literal *"write them red"* was deliberate and is vindicated: a
  permanently red suite stops being a signal, whereas the tripwire fired on the exact step it was
  aimed at. **Use this pattern for the next requirement that outruns its machinery.**
- **Green:** `tests/census.loft` (**S5**) — `rt_census_a` at n=1. **660 proposed, law J admits 30,
  3 distinct shapes, 183 collisions, 0 unexplained: law F HOLDS at level 1** (**X38**). The digest
  quotients by orientation and translation (law I) and is **exact**, never hashed — a hash
  collision in a census looks exactly like a law F violation.
- **Found by the census, for S6:** the canonical text must fix the starting **CORNER**, not just
  the winding. `[2,5,5]`/`[5,5,2]`/`[5,2,5]` are one cycle walked from three corners.
- **`h0` parity does NOT classify a form** into the edge/vertex class — sides run `h0`, `h0+t₀`,
  `h0+t₀+t₁`, so turns `2,5,5` from `h0=0` mix both classes. Assuming otherwise produced 72
  confident false "law F violations" before it was caught.
- **Green:** `tests/text.loft` (**S6**) — the canonical text. `write(read(T)) = T` **byte-for-byte**
  over every admitted form; the start corner is fixed by taking the lexicographically smallest
  `(turns, lens, h0)` over the cyclic starts. **30 spellings collapse to 10 canonical texts**
  (10 cycles × 3 corners), and what remains differs only in `h0` (**X39**). The parser **refuses**
  a reordered field rather than repairing it — a lenient reader would void the byte diff.
- **Green:** `corpus/a1/` + `tests/trip.loft` (**S7**) — 10 committed entries. `rt_trip` is **RED
  on purpose** until `rebuild` lands, and `run_red` in the runner **asserts** that redness: it must
  not print OK and must print `TRIP RED: rebuild absent`. If it ever goes green by accident the
  runner **fails**. The legs that exist are green against committed bytes — `write(read(T)) = T`,
  and `draw()` still reproduces the committed `.f` (the regression anchor).
- **`src/corpusgen.loft` is NOT in `make test` by design** — a gate that regenerates its own
  baseline always passes (`X15`). Re-running it is a decision: read the diff and judge.
- **Two digests, two questions** (**X40**): the census's `field_digest` quotients by orientation
  (*how many shapes?*); law F needs `field_exact` (*is `draw` injective?*). Using the census one on
  the corpus reported 17 false law F failures.
- **THE ROUND TRIP CLOSES** (**S8**, **X41**): `write(rebuild(draw(read(T)))) = T` **byte-for-byte**
  over all 10 committed corpus entries, 0 diffs, every one **R1 with ρ = 0 and exactly one match**.
  Recovery is an exact match against the enumerated set — **no tolerance anywhere** — licensed by
  the census having decided level 1 finite and injective. `rebuild` counts its matches rather than
  assuming uniqueness.
- **The R2 door stays shut**: a non-grammar footprint returns **R2 with ρ > 0** and `rebuild_text`
  gives **empty**, so an R2 guess can never be spelled as an authored stencil.
- **Three digests, three questions** — `field_digest` (orientation+translation → how many shapes?),
  `field_exact` (nothing → is `draw` injective?), `field_norm` (translation → which stencil?).
  Conflating two of them produced 17 false law F failures once already (**X40**).
- **Rungs A1 and A2 are complete.** `rt_trip` covers **32 committed entries across `corpus/a1`
  and `corpus/a2`**, all byte-for-byte, all R1 with `ρ = 0`.
- **A2's answer (X42): length alone never collides** — `draw` is injective at levels 1–3 (10/10,
  32/32, 60/60). What unequal sides add is **chirality**: a form and its mirror are different texts
  drawing mirror-image fields, sharing a *shape* digest because the flip is one of the 12
  orientations. **Impossible at level 1**, where equal sides make every form achiral.
- **`corpusgen` refuses to overwrite a level that already has entries** — never-regenerate enforced,
  not trusted. Bump `LEVEL`, run once, commit.
- **Rung A3 is complete too.** Side count grows cleanly — `draw` injective at 3/4/5/6 sides
  (10/21/30/36 forms). `rt_trip` covers **119 committed entries** across `corpus/a1` + `a2` + `a3`.
- **A3's finding (X43): the frontier is now COST, not correctness.** The two axes MULTIPLY —
  `sides × maxlen` is 1442 forms and ~66 s to enumerate at maxlen 2. **Today's house `[4,5,4,5]`
  needs `maxlen 5` ≈ 1.2 M proposals, so enumerate-and-match cannot reach it.** Law F has not
  failed; *deciding* it exhaustively is what stops being affordable.
- **Indexed recovery is DONE (X44)** — `index_build` draws each candidate once into a
  `digest → form` map; recovery is a probe. **119 fills instead of 14 161**, 0 collisions, and the
  index is checked to agree with the scan on every entry. Law F is now verified **once over the
  whole space** at build time rather than per lookup.
- ⚠ **The index does NOT reach the house, and A3's doc wrongly said it would.** It fixes the
  *per-lookup* cost, not the cost of *enumerating* the space — an index is built by that same walk.
  The house needs **constructive** recovery (boundary → corners → turtle, `hexmatch`-shaped,
  `X21`), not a faster table.
- **Constructive recovery is DONE (X45)** — the form is read off the field, enumerating nothing.
  Every admitted form is **convex** (law J: positive turns summing to one revolution), every vertex
  is a hex centre, so **the convex hull of the filled cells IS the turtle polygon**. `O(cells)`,
  all-integer, and it proposes-then-verifies by re-drawing. **119/119** corpus entries, 0 diffs.
- **It reaches past the enumeration**: today's house `[4,5,4,5]` is **R2 by enumeration
  (ρ = 22)** and **R1 with ρ = 0 constructively** — gated, with the miss asserted so the
  comparison is not vacuous.
- **A4 is done, and it moved the DOORSTEP rather than the recovery (X46).** Law J constrains only
  closure, and admits non-simple walks *and* non-convex forms — and **non-convex forms violate
  law F**: 0 of 94 recover at any scale, and 86/66/60 (scale 1/3/5) draw a field that **another
  form also draws**, with `ρ = 0`. `draw` is not injective there, so **no recovery method can
  separate them**. The admissible (convex ∧ simple) set: 138 forms, 0 failures.
- **`form_admissible` = closed ∧ simple ∧ convex**, and the enumerations call it instead of
  `form_closes` — the rule is single-sourced, not implied by a turn range. `fits?` must refuse
  non-convex/non-simple at authoring time (**K-FIT**).
- ⚠ **I had guided A4 toward boundary tracing; the measurement inverted that.** Tracing would
  rescue only the *refused* minority — the rest are ambiguous **in the model**. When recovery
  fails, first ask whether the information is in the field at all, not which algorithm to reach
  for.
- **The L-shaped house is NOT admissible** under this grammar: `I3` makes the wall the boundary of
  the fill, so a reflex corner enclosing no distinct cells is invisible to the field. A real limit
  on what can be authored, written down rather than left to be discovered.
- **S4b is done (X47)** — the wall surface by averaging. The summed edge vector is **exactly
  parallel** to a heading (zero cross product, 24/24 runs); position is an exact **rational**.
  §6.2's corner bands confirmed exactly (`1/2 u`, `√3/2 u`, ratio `√3`), and the widening
  `(√3−1)/2` lands exactly on the larger band. **New fact:** the *midpoint* band is **0** on the
  east family (the mean line passes through every midpoint) but the full `√3/2` on the north — the
  row stagger. Control: the scatter a fit would threshold is 0 east / 0.9167 north, so
  *averaging vs fitting* is measured, not rhetorical.
- **Still unverified**: that the band matches the triangle subdivision (`X10`, T2). The gate prints
  it as pending rather than asserting it.
- **A5 is done (X48).** The `surf`-slot question was already answered — `place_opening` writes
  `edge_set_mat`, so a feature IS the material (`OD-9` closed). What A5 adds: **a feature's `t` is
  exact only at an edge centre `(2i+1)/2n`**; every other `t` **snaps silently**, so `fits?` must
  refuse it (same rule as line endpoints, §10.10). A door at `7/20` recovers exactly; a 3-edge
  window at `1/2` recovers as `7,9,11`.
- **`I1` measured both ways**: re-materialling leaves **38 edges / 0 dangling ends**; deleting the
  edge gives **37 / 2**. The averaged surface is untouched — a feature is a material, not geometry.
  The doored-tower defect cannot arise from this path.
- **A run is NOT stored in `t` order** — index a feature by its exact `t` numerator, never by its
  position in the `SideRun`.
- ⚠ **Three consecutive steps had a failing gate that was MY measurement, not the subject** (S4b
  twice, A5 once) — zero real defects among them. Rule: **a count that disagrees with an
  already-gated number by a clean factor is a bug in the counter.** Check a new measurement against
  an established one before believing it.
- **A6 is done, `OD-10` resolved (X49).** An arc's **centre is exact**; its **radius is not** —
  it quantises to *shells*, the realisable `3k²+m²`. Out to 64: `0, 12, 36, 48`. `hexarc` is
  **float-free** (membership is the integer test `N' ≤ N`).
- **The `Sep`/`X7` fork I flagged was narrower than it looked**: `Sep` is *recoverability* (answered
  — the shell grid); `X7` is a *choice policy* (which shell to snap a nominal radius to). The
  policy cannot affect the round trip, so A6 was never blocked.
- **X50 / SPEC I-QUANT — the unifying rule, measured three times independently:** *a continuous
  model parameter must be quantised to what the field distinguishes.* Endpoints → hex vertices;
  feature `t` → edge centres `(2i+1)/2n`; arc radius → shells. **Off the grid a value is silently
  snapped, not rejected**, so `fits?` must refuse it at the doorstep.
- **A7 is done, `X51`.** The doored tower: a door is a **material annotation on the wall's boundary
  edges** (`arc_door_wedge`), and arc recovery (`arc_recover_centre`/`arc_shell_max`) takes only the
  **cells** — so the doored tower's centre and shell come back **byte-identical** and the door reads
  straight off storage (17 annotated, 17 recovered). The named defect ("3 arcs instead of 1") is
  **unreachable through the door API** — it can only re-material — so the controls have to reach
  around it: deleting the 3 spans gives **3 arcs** (6 chain ends), notching the disk's cells **loses
  the arc**. `N = 1`: the door API is the only writer, and the arc recovery *cannot see* the edges.
- **The "arc unchanged after annotate" check is vacuous alone** — true by construction — so it is a
  check that cannot go red. **CONTROL B (notch the cells) makes it live**: the recovery *is*
  sensitive to the disk, so "unchanged" is a result, not a tautology.
- **A8's adjacency axis is done, `X52` — and most of it was already in crawler.** *Who owns the
  shared edge of two adjacent stencils?* **Nobody.** Combining is **"mark all, THEN cut once"**
  (crawler's `cut_arb`, `EXTRACTION.md`; re-measured here `T2 → T1`): union the footprints, then cut
  the boundary of the **union** once, tagging each edge by its cell's source. The shared edge is
  interior to the union → never cut → adjacent stencils **fuse**. Order-free **by construction**
  (reads the finished union + fixed source map, never stamp order); overlap tie-break is the **lower
  id**, intrinsic, so it holds for overlapping stencils too. `combine_cut` / `tests/combine.loft`.
- **Distinguishability lands exactly right (A8):** the authoring split is NOT recoverable — merged
  composite == the single stencil of the union (canonical rep, `P1`) — but a **behavioural**
  difference (a sealed interior wall) **is** field-distinct. That is the narrow, true law F for
  composites (`DESIGN.md` §8.0.1), not "all composites are distinguishable" (false).
- **The naive per-body overlay is the control, and it fires both ways:** order-dependent (7 edges)
  and it marks a spurious seam wall (7 edges). It is *fine for one stencil* and breaks for two —
  which is the whole point of the rung.
- **A8's frame-seam axis is done, `X53` — the one axis with NO crawler prototype.** crawler's
  collision is all single-frame; a **posed body against the world** (two frames, a continuous pose)
  was a T3 design, never built. hexbody's first measurement closes the two constants `DESIGN.md` §7
  left OPEN. The **pose transform is the sole float step** (`src/hexframe.loft`); everything else is
  integer (`X1`–`X62`), so `ε_seam` is the whole error budget.
- **The instrument is a Pythagorean pose** (cos 4/5, sin 3/5): the transform maps rationals to
  rationals, so an **exact integer oracle** exists and the float pipeline's disagreement with it IS
  the seam band. `ε_seam ≈ 7.1e-15` (machine ε); a routed query agrees with the oracle on all 1681
  grid points (interiors exact). The **forbidden fix** — snapping a body's wall to the world lattice
  — displaces it 0.4 and misclassifies **12 interior cells** (routed: 0): it trades a machine-ε seam
  for real interior error, voiding **D**. That control makes "0 disagreements" a result, not a
  tautology.
- **κ is a counter measured on SWEEPS.** κ≥3 is rare at a point (10/841) but a swept segment touches
  4 frames where no point sees more than 3 — the design's warning, with numbers. Arbitration is
  **order-free** (owner = lowest id among the solids) and **fail-safe** (a world gap under a body
  solid → solid, no fall-through, `I4`). Controls: a world-blind κ counter undercounts (113); a
  first-solid-wins owner diverges by order (2 vs 5).
- **A8's nearest-surface axis is done, `X54` — gating existing-but-ungated code.** crawler's
  `cut_arb` was already **copied byte-identically into `hexway`** but no hexbody test exercised it;
  this rung gates it. It tags each boundary edge with its **nearest analytic surface** (the collision
  proxy, via `surf_distance`), order-free by construction, ties to the **lower id** — the geometric
  half of the union cut, where X52 gave material-by-source. Two overlapping towers: **66/66** edges
  get the true nearest, a fixed "always lower id" rule mis-tags **31** (the far rim), both stamp
  orders agree, duplicate surfaces all take the lower id. `tests/arb.loft`.
- **A8's linework axis is done, `X55` — and it needed NOTHING NEW.** The cut already **spans domains
  A and B**: a tower (stencil) on a flat-topped world run (linework, `d ∈ D`) is one `cut_arb` pass —
  112/112 edges take the nearest, the top → the world line (30/30), the rim → the arc (26/26), both
  build orders agree. "Nearest analytic surface" never asked which domain a surface came from, so
  A/B mixing was free. The domains do not bleed into each other.
- **A world line recovers EXACTLY straight.** Both the NE and NW boundary edge of a top-row cell have
  midpoint `y = 0.75` — the strip zigzags in *x* but its edge midpoints share one `y`, so an E–W
  world line is exactly collinear: **eave_spread = 0**, the phase-B verify. **The control matters
  here**: the same ruler over the curved rim reads **6.75**, so 0 is a result and not a dead
  instrument.
- **Phase B is CLOSED, `X56` — the domain-B census, and the in-between vector is SETTLED at
  `N = 39`.** `D` was closed by `X3`, so the open constant was **cost**. Three classes: 6 directions
  at `√3` wu (1.5 m) and 6 at `1` wu (0.866 m), both **angle-exact**; **12** in-between at `√39` wu =
  **5.408 m**, `1.1021°` off nominal.
- ⚠ **`δ = (tri_a − tri_b) mod 3` is the LINKING axis, and the ladder never had it.** A run of `p`
  periods from a vertex of class `c` ends on class `(c + p·δ) mod 3`; class 0 is a hex **centre**,
  which the doorstep refuses. `δ = 0` **preserves** the class (every multiple admissible, from
  either); `δ ≠ 0` **cycles** it (1 in 3 refused, shortest run depends where you started). A house
  wall can leave you on **either** class, so `δ` is exactly whether linework links to the house
  angles unconditionally. **18 directions do, 6 do not** (the `N=1` house family, 30/90/150°).
- ⚠ **That REVERSED `X31`'s verdict.** §10.9 called the old `N = 21` "dominated outright" — on the
  linking axis it was **on the frontier** (only `N = 21, 39, 291` have `δ = 0`). So the vector went to
  **`N = 39` `(7,−2)`**, not the finer-looking `N = 13`: both give the same `3.7×` accuracy, but
  `N = 13` is `δ = 2` and would spend the linking, exactly where two domains meet. `N = 39` pays
  2.29 m of period to keep it. Exhaustive over `N ≤ 400`: **no vector improves the angle while
  keeping both today's grid and `δ = 0`.** Switched while domain B had **no stored content** (the
  corpus is all `H₁₂` stencils), so it cost nothing; later it would be unmigratable (`A₂`).
- ⚠ **The census also corrected §10.9's period column by exactly 3×** (`√N/3` → `√N`). A clean factor
  between two numbers is the signature of a counter bug — here the bug was in the doc, caught by the
  gate. `X29`'s stated value moved with the vector (`4.1066°` → `1.1021°`); what it actually gates is
  that the bias is **uniform, not scatter**, which survives a change of vector.
- **A census that only prints a table cannot go red** — `DESIGN.md` §9 listed `rt_census_b`'s control
  as "—". Three were written: a **conditional** direction must exist with a class-dependent `min_p`
  (else "unconditional" is vacuous); `N = 13` must genuinely beat `N = 39` on period (else nothing
  was traded); and the measured period must **not** equal `√N/3`.
- **Law G (`rt_flip`) is gated at last, `X57` — and `rt_orient`'s green was narrower than it looked.**
  `rt_orient` covered **houses**, drawn by `draw_walls` (exact combinatorial boundary); **world
  linework goes through `wall_write`** (a band around a line) and *no* gate had touched that path
  under the orientations. `tests/flip.loft` closes it, comparing edges by their exact triangle-lattice
  corners — integer, no tolerance.
- **A wall is an UNDIRECTED SEGMENT, and its mirror REVERSES TRAVERSAL.** `wall_write`'s band sits to
  one side of the centreline *by traversal direction*, so:
  `mirror(wall(d,A,p)) = wall(−d, mirror(farend), p)`. The naive `d → 12−d` at the mirrored **start**
  is wrong — and only the two directions the mirror **fixes** (90°, 270°) expose it, because
  everywhere else the two rules agree. **Measured: 96/96 mirror cases exact, 48 of them in-between**,
  so the in-between directions survive every orientation and a stencil *may* carry one.
- **The flip gate FOUND AND FIXED a real defect — a false comment, and a float sign test.** It first
  reported 18 `N=1` rotation mismatches. `wall_separates`'s own comment claimed *"for a wall anchored
  on a vertex it never fires, because a vertex is never at the same offset as a cell centre"* — **it
  does**: `d=2` from vertex `(3,0)` at `p=3` puts cell `(1,1)` exactly on the line. That offset is
  mathematically **0**, but in float it is **`−1.39e-16`** in one orientation and a clean **`0`** in
  the rotation of the same wall, so `oc >= 0.0` sorted one cell onto **opposite sides** and the
  rasterisation was not rotation-covariant. Fixed by comparing against `−WALL_EPS`. **Not a `P4`
  tolerance**: the quantity is exactly zero; the epsilon only removes rounding noise from a **sign**
  test. Rotation is now exact for all three families.
- ⚠ **A comment asserting "this case never happens" is a claim like any other — measure it.** That
  one was load-bearing, wrong, and had been sitting under a green suite because nothing exercised
  `wall_write` under the orientations.
- **The fix SHARPENED the control rather than breaking it**: the naive mirror rule now fails on the
  whole chiral `N=1` family (6 of 6, no other family), where float noise had masked four of six. A
  control's failure set moving after a fix is worth re-deriving, not re-baselining.
- **`OD-13`'s CORE IS CLOSED, `X60`.** `Draft` = form + embedded run (`src/hexdraft.loft`):
  `write(rebuild(draw(read(T)))) = T` **byte-for-byte over all 12 in-between directions**, and —
  the point — **dropping the run FAILS the trip in 12 of 12**. The design named `rebuild` as the one
  site whose omission is *silent*; it now reads the run, so a missing wall is a text diff instead of
  a quiet success. **The doorstep refuses what would not round-trip** (`draft_fits`): a **named** reason
  per restriction, an **offer** of the nearest shorter run that fits (`K-FIT`), and — the contract
  that matters (law **C₁**) — **0 disagreements and 0 false accepts** against the trip itself.
  Remaining: **one** run per stencil; several need the interior edges split into components first.
- ⚠ **`Draft` (description) vs `hex_field::Stencil` (field) are `OD-6`'s two halves** — *"is a stencil
  a field or a generative description?"* Both exist and must not share a name; that is why this one
  is `Draft`.
- **superseded — the load-bearing half alone:** An embedded wall is a
  **material on INTERIOR edges** (both cells in the footprint), so the footprint and `rebuild` are
  untouched — 127 cells, authored text back, chain well-formed (2 ends, 0 branches), control fires
  (the same wall as a *gap* breaks the trip). **`rebuild` still does not READ that chain**, so an
  embedded wall is **silently dropped and `rt_trip` does not notice** — the exact site the design
  flagged. It is closed when dropping the wall makes `rt_trip` FAIL.
- **The READER is done and exact (`X60`, `wall_read_run`):** a run's two chain **ends** ARE its
  endpoints (`X32` gives one chain; the doorstep put the authored ends on hex vertices), so
  `(d, anchor, p)` comes back by a **degree count and one integer division** — no fit, no tolerance.
  6/6 over the whole pipeline; a fragmented marking is **refused** (`P4`).
- ⚠ **ONE ROOT CAUSE BEHIND FOUR FAILURES — `SPEC` L11, `X26`'s exact mode.** Three wrong reader
  instruments, then a broken interior extraction *after* the reader was right, all from mixing
  **`nb_q`/`nb_r`** (hex_field order) with **`hex_edge_corners`** (hex_grid order). Same six
  neighbours, **different order**, so "directions 0..2" is a different canonical set and the corner
  lookup reads a different edge. **Use `hex_neighbor` with `hex_edge_corners`, always.**
- ⚠ **It also produced a FALSE FINDING that got recorded as fact:** *"only 4 of 12 in-between
  directions fit — structural, unexplained."* With one convention throughout, **all 12 fit** — and
  that claim had been "confirmed" by an 8.5-minute widened search which shared the broken helper.
  **A slow, expensive confirmation of a bad measurement is still a bad measurement: when a result
  surprises you, re-derive the INSTRUMENT before confirming the NUMBER.**
- **`OD-13` — THE IN-BETWEEN 12 MUST BE FIRST CLASS.** User, 2026-07-24: *"the normal 12 directions
  are fine but a city/castle needs more directions to be believable so the other 12 need to be first
  class."* This is a **requirement**, not an open question — and it **contradicts `ROUNDTRIP` §2.2**
  (*"`D` is never an authoring palette… a road is never a stencil"*), which is the sentence that has
  to move. It moves when the replacement is built, not asserted.
- **Geometry ≠ permission — the geometry half is DONE** (`X56` angle + linking, `X57` orientations).
  What is missing is the **grammar** (a stencil is footprint-only), **`draw`**, **`rebuild`** (it
  returns the turtle form alone, so embedded linework would be silently dropped and `rt_trip` would
  not notice), and **`fits?`**. And **roads were never tested**: `hexway`'s `Track` is a float
  world-space curve with no lattice anchoring — treat "stencils carry roads" as unexamined.
- **The 5.408 m in-between quantum is accepted on ONE condition, from the user (2026-07-24): the
  longer minimal stretches are fine *"as long as they are clearly visible inside the editor"*.** So
  the coarse quantum is a **presentation** obligation, not a geometry problem — recorded in `SPEC`
  **K-FIT**. The mechanism already exists and is gated (`tests/wall.loft` §8): `wall_snap_p` offers a
  different admissible length when one is refused, `snap_run_d24`/`snap_run_p` take an arbitrary
  point to a legal line, and `run_end_dist` is the residual to display. What remains is the editor
  *showing* it — consumer side of the `L6` seam, not hexbody's to build.
- **A8's LEVEL axis is done, `X58` — the bridge guarantee.** A **level** is the topological *sheet*
  (OSM's `layer`; the foxel's `layer*` axis; moros's `cy`) — **not a height**, which comes from the
  surface/feature interval. The mechanism: **a level FILTERS BEFORE THE CUT**, it is not an
  arbitration rule after it, so different sheets never fuse, arbitrate or contend — doing work `κ`
  would otherwise have to (`X4`). Re-measured from crawler's `bridgetest` (`T2 → T1`) with its own
  framing: **one pair of overlapping stencils drawn twice, only the level integer different**.
  Same level → fused (shared edges 0, `X52`), `κ = 2`. Different levels → 30 edges on each sheet,
  `κ = 1` at *both*, shared boundary becomes **7 real wall edges**. **Level 0 is byte-identically
  free** vs the level-blind path — the common case pays nothing.
- **A8's TERRAIN axis is done, `X59` — and A8 is COMPLETE, all six axes.** `OD-4`'s storage half was
  already settled (terrain *is* the `height` slot); the open half was **seating**. The answer:
  **seating writes the `height` slot and nothing else**, so a stencil round-trips identically on flat
  ground and on a slope — 0 cell diffs, 0 edge diffs, the authored text back either way. Recovery
  reads **cells**; seating writes **heights**. The slope's cost is a **residual**, *returned* not
  absorbed (`1.650` sloped, `0` flat) per `SPEC` **G5**; the seat height is a **policy** (low/mean/
  high) that moves the residual and never the recovery — the `A6` `Sep`-vs-`X7` split again.
- ⚠ **THE PATTERN, now seen three times — worth reaching for FIRST on any new feature:** a door is a
  **material** not a hole (`X51`); a level is a **filter before the cut** not an arbitration after it
  (`X58`); terrain is a **height** not a change of footprint (`X59`). **The round trip survives a new
  feature exactly when that feature lands in a slot the recovery does not read.** Each time the
  tempting design changed the cells, and each time the control was to do exactly that and watch
  recovery break.
- **Terrain GENERATION is still unbuilt** (crawler's plan #8 is *"Future — nothing built"*) — but it
  is a **producer**, not a round-trip question, so it does not block anything here.
- Already gated and not to be re-derived: the 24 directions (`X26`–`X32`), the averaged surface
  (`X47`), the line doorstep (`tests/wall.loft` §8).
- **The foxel schema is the limit** (`ROUNDTRIP.md` §2.4): `layer* × point → (height, material,
  wall1, wall2, wall3, item)`. A model is admissible **iff it draws into that exactly**, which
  makes `fits?` syntactic and finite. It closed OD-2/3/4/6/7/8 — roofs and terrain are `height`,
  trees are `item`, walls are the three edge slots, layers are in, the foxel is the stored truth.
  **And it is now measured as a storage format** (`X63`) — that limit is only a limit if the schema
  really stores what it claims, which is `SPEC` **G-FOXEL**.
- **Still open** (`plans/m0-roundtrip/DESIGN.md` §10): **OD-1** the morph (narrowed to "probably
  unnecessary" by free poses) · **OD-5** is the flip exact (`X2` says yes) · **OD-9** does a door
  survive as an *annotation* when an edge has one `material` slot — the doored-tower defect
  relocated into the schema, and rung A5's real question.
- **Constraints are in `ROUNDTRIP.md` §7 (X1–X64) with trust tiers.** T1 now holds `X1`, `X2`,
  `X19`–`X22`, `X24`–`X64`; do not re-derive those. Everything else is still a try or a schema.
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
- **Three loft defects this project filed are FIXED and verified on 2026.7.2** — H4 (inline struct
  in an argument list), H5 (binary op with two forward-declared operands), H6 (a file read
  invalidating a live `list_dir`). Reproducers re-run green; loft even carries a guard test for H6.
  The workarounds in the tree (hoisted structs, helpers above callers, snapshotting a listing) are
  kept as ordinary style, **not** as warnings — do not re-derive them as constraints.
- **Every gate carries a control that must fire.** A check that cannot go red is not a check.
