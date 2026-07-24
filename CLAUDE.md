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
- **PUSHING IS ALWAYS ALLOWED — it is a SAFETY FEATURE, not a commitment.** (User, 2026-07-24,
  replacing the old *"commit and push only when asked"*.) Work that is pushed is backed up,
  reviewable and revertible; work sitting in a dirty tree is none of those. So push when a step is
  green rather than waiting to be told. What still needs asking is anything **hard to reverse** —
  rewriting history, force-pushing, deleting a branch — and anything that changes what the project
  *claims*, which is a decision rather than a save. Commit messages end with the org
  `Co-Authored-By` trailer.

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

**T1 holds `X1`, `X2`, `X19`–`X22`, `X24`–`X70`** — eight of them re-measured *here*, and
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
| **`ROUNDTRIP.md`** | the **settled formal core** — the lattice, objects, the foxel, maps, the `D`/`E₂` contract with its **proved** propositions, the two recovery regimes, and the constraints `X1`–`X70` **with trust tiers** | **authoritative** on any object or map |
| **`plans/m0-roundtrip/DESIGN.md`** | the **in-flight half** — proposed laws, the grammar, `fits?`, the seam, the corpus, the method, the gates, and the **open decisions**. Everything here is a proposal or a question | **cite nothing from it as fact** |
| **`SPEC.md`** | goals **G**, limits **L**, invariants **I**, contracts **K** — short, falsifiable, each with a control | authoritative on *what must be achieved* |
| `VISION` · `ARCHITECTURE` · `design/*` | *why* — reference only | **never the build input** |
| `PLAN.md` | milestone through-line (P, M0–M7); the synthesis layer, not a plan index | — |
| **`ASSESSMENT.md`** | the project **measured against its goals** (editor-readiness, game-asset readiness, the frontier). Every claim marked **[G]** gated / **[B]** built-ungated / **[J]** judgement | **synthesis, not authority** — never cite a **[J]** as fact |
| `plans/README.md` | plan conventions, lightest-workflow table, value categories | — |
| **this file** | orientation, conventions, the **user's decisions**, and facts about **this tree** — plus the traps. It is loaded every session, so it is a **pointer, not a ledger** | **never authority** — every fact here must exist in one of the files above |

**Build and verify against `ROUNDTRIP` + `SPEC`; design in `DESIGN.md`.** If building needs a fact, it belongs there as
a checkable item — not in a paragraph. A gate defending no spec item, or a spec item no gate
defends, is the thing to fix.

⚠ **A new measurement lands in `ROUNDTRIP.md` §7 as an `X`, and a new limit in `SPEC.md` — not
here.** This file was allowed to become a per-commit running log once: it grew from 24 KB to 56 KB
in a single day, 82% of it restating constraints that `ROUNDTRIP` §7 already held with trust tiers,
and it is read in full on **every** session. It was cut back on 2026-07-24. **If you find yourself
appending a finding to the State section, that is the signal it belongs somewhere else** — the only
things that live here are the ones the formal files structurally cannot hold: what the *user*
decided, and what is true of *this checkout*.

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
make test    # all 23 gates, ~4 min (the table is tools/run_tests.sh; wall alone is ~3 min)
make shot    # contact sheet -> /tmp/house12.png
```

**THE TOOLCHAIN IS THE *INSTALLED* LOFT — `--path /usr/local/share/loft/`, NEVER `../loft`.**
`--path` is not just a search path: loft reads its **codegen support** from it, while the code it
generates links the **installed** `libloft.rlib`. Pointing it at the `../loft` working tree pairs a
live source with a stale rlib, and they drift the moment loft is edited without being reinstalled.
On 2026-07-24 that killed every gate touching `hex_field` in rustc (*"cannot find function
`op_eq_text`"*) — including gates nobody had touched — and a cached `.so` had been masking it until
a new gate forced a rebuild. **hexbody is a consumer of loft; it tracks loft's releases, not its
desk.** To test against an unreleased toolchain, reinstall it first, then
`make test LOFT_PATH=../loft/`.

**TWO SIBLING WORKING TREES STILL FEED THE GATES, AND NEITHER IS PINNED** — `../loft-libs-world`
(`--lib`) and **`../moros`**, whose *source* `tests/palette.loft` reads because `L13` makes it the
schema of record. `loft.lock` pins only the registry packages (`graphics`/`glb`/`mesh3d`). So:

- **`--lib` reads the WORKING TREE** — check `loft-libs-world` is on branch `dev` before debugging
  anything strange.
- **An uncommitted edit in `../moros` moves the limit on `𝕄*` with no trace in hexbody's history.**
  The palette gate **prints moros's revision** so a green is attributable; it cannot see whether
  that tree is dirty, so check `git -C ../moros status` before trusting a surprising palette result.

## State (2026-07-24)

> **`M0` IS CLOSED** — the round trip, `G2`, the foxel as a storage format, the doorstep and the
> palette. **23 green gates, ~4 min**, every one carrying a control that fires.
>
> **This section deliberately does not restate them.** For where the project stands against its
> goals and what to do next, read **[`ASSESSMENT.md`](ASSESSMENT.md)** (with its coverage ledger:
> 56 spec items, 35 defended, and **zero** checkable-today-and-unchecked). For what is gated,
> **[`ROUNDTRIP.md`](ROUNDTRIP.md) §7** — `X1`–`X70` with trust tiers, 55 at T1, and the 15 below
> the line **all inherited** from crawler or moros. For the gate↔spec map, **[`SPEC.md`](SPEC.md)**.
>
> What is left here is only what those files cannot carry: **the user's decisions**, and the facts
> about **this tree** that are not derivable from the formal core.

### The decisions — the user's, not findings. Do not re-open or re-derive

A measurement cannot overturn any of these. They bound the design.

- **THE VOXEL IS THE CEILING ON PERMANENT WORLD STATE** (2026-07-24 → `SPEC` **L13**/**L14**).
  *"I will never want to add more world information than in the limited moros voxels. We can have
  other tables outside that for limited areas but those should also be time limited."* So moros's
  `Hex` is the **storage of record**, `𝕄*` is bounded by **seven integers per hex per storey**, and
  where moros's cell and `hex_field`'s arrays disagree **the narrower one binds**. Representing a
  slot differently is fine (`item` rides a named `LAYR` — that *is* `h_item`); **there is no eighth
  slot.** Richer structure only as an **area-limited AND time-limited** overlay — a third category
  beside `L3`'s two: **stored, local, and mortal**.
- **AN OPENING IS NEVER "NO WALL"** (→ `SPEC` **I1**, `X70`). A door *"is not a gap in the wall, it
  is something that can be a collider or not"*; a **real gap** — *"the door itself is missing
  completely, but the wall continues like normal"* — is a distinct fourth thing, `OPEN_GAP`. The
  rationale is what makes it structural rather than stylistic: *"a gap/door will never be rendered
  as a missing wall, there will be something like a door-frame or ragged stone opening there."*
  **An opening has geometry of its own** — a frame, a lintel, a ragged jamb. Absence has none.
- **THE IN-BETWEEN 12 MUST BE FIRST CLASS** (→ `DESIGN.md` §10, `OD-13`). *"the normal 12 directions
  are fine but a city/castle needs more directions to be believable so the other 12 need to be first
  class."* A **requirement**, not an open question — and it contradicts `ROUNDTRIP` §2.2, which is
  the sentence that has to move. It moves when the replacement is built, not asserted.
- **THE COARSE QUANTUM IS A PRESENTATION OBLIGATION** (→ `SPEC` **K-FIT**). The 5.408 m in-between
  period is accepted *"as long as they are clearly visible inside the editor"*. The mechanism is
  gated (`wall_snap_p` offers an admissible length, `run_end_dist` is the residual); the **showing**
  is consumer-side and unbuilt — a promise hexbody has made and cannot itself keep.

### Facts about THIS TREE that the formal docs do not carry

- **`make test` runs on the INSTALLED loft and two unpinned sibling trees** — see *Run* above.
  `../moros` is the one easy to forget, because `L13` made it the schema of record rather than
  background reading. `../loft` was a third until it broke the suite; it is now consumed as a
  release, which is what a consumer-only dependency should always have been.
- **`src/corpusgen.loft` is NOT in `make test`, by design** — a gate that regenerates its own
  baseline always passes (`X15`). It also **refuses to overwrite a level that already has entries**,
  so never-regenerate is enforced rather than trusted. Bump `LEVEL`, run once, commit. Re-running it
  is a *decision*: read the diff and judge.
- **`hexedge` / `hexway` / `hexroof` are byte-identical copies of crawler's.** No drift yet; their
  proper home is `loft-libs-world`.
- **`Draft` (a description) and `hex_field::Stencil` (a field) are `OD-6`'s two halves** and must not
  share a name — which is why the embedded-run model is called `Draft`.
- **`plans/m0-roundtrip/shots/house12.png` is a review image** (`SPEC` **L9**), regenerated when `G2`
  landed. `make test` never looks at it; do not pixel-diff it.

### Still open

- **`OD-1`** the morph — narrowed to *probably unnecessary* by free poses.
- **`OD-5`** is the flip exact — `X2` and `X57` both say yes at T1; **closeable by inspection**.
- **`OD-9`** does a door survive as an *annotation* when an edge has one `material` slot — the
  doored-tower defect relocated into the schema, and rung A5's real question.
- **Where a door's OPEN/CLOSED state lives** (`DESIGN.md` §10.28) — two wall ids (**recommended**:
  free, round-trips today) vs an `L14` overlay. No round-trip consequence either way.
- **M0's remainders:** **one** embedded run per stencil (several need the interior edges split into
  connected components first); `wd_body` has **no opening body** — moros's to add, since `L13` makes
  it the palette's owner; and `draw_roof` writes 27 heights and **0 materials**, so a roof cell is
  indistinguishable from terrain at that height (`X69`, §10.28) — costs nothing today.
- **Not round-trip questions, so they block nothing here:** terrain *generation* is unbuilt
  (crawler's plan #8), and `hexway`'s `Track` is a float world-space curve with no lattice
  anchoring — treat *"stencils carry roads"* as **unexamined**.

## The traps that bite

### Method — each earned by a red gate that turned out to be mine

- **REACH FOR THIS FIRST ON ANY NEW FEATURE: the round trip survives exactly when the feature lands
  in a slot the recovery does not read.** A door is a **material**, not a hole (`X51`); a level is a
  **filter before the cut**, not an arbitration after it (`X58`); terrain is a **height**, not a
  change of footprint (`X59`); an embedded run is a **material on interior edges** (`X60`). Every
  time the tempting design changed the cells — and every time the control was to do exactly that and
  watch recovery break.
- **A count that disagrees with an already-gated number by a clean factor is a bug in the counter.**
  Earned five times (S4b twice, A5, `X62` part 2 at exactly half, the domain-B period column at
  exactly 3×) — **zero real defects among them**. Check a new measurement against an established one
  before believing it.
- **When a result surprises you, re-derive the INSTRUMENT before confirming the NUMBER.** An
  8.5-minute widened search once *"confirmed"* a false finding because it shared the broken helper
  (`X60`). A slow, expensive confirmation of a bad measurement is still a bad measurement.
- **A comment asserting "this case never happens" is a claim like any other — measure it.**
  `wall_separates`'s was load-bearing, wrong, and had been sitting under a green suite because
  nothing exercised that path under the orientations (`X57`).
- **When recovery fails, first ask whether the information is in the field at all**, not which
  algorithm to reach for. A4's tracing plan would have rescued only the *refused* minority; the rest
  are ambiguous **in the model**, where no algorithm can help (`X46`).
- **A control's failure set moving after a fix is worth re-deriving, not re-baselining.** Fixing
  `wall_separates` *sharpened* the naive-mirror control rather than breaking it — float noise had
  been masking four of six cases (`X57`).
- **The tripwire beats both a permanently red suite and a forgotten TODO.** `SURFACE_LANDED` sat
  `false` from S4 to `G2`, printing PENDING, and fired on exactly the step it was aimed at (`X62`).
  Use it for the next requirement that outruns its machinery. **One is armed now**:
  `tests/joint.loft` states `SPEC` **I6** and is held red by the runner's `run_red` until `G1`
  lands — it fails if it prints `JOINT OK`, fails if it is red for any other reason, and flips to
  `JOINT BLOCKED` the moment a body verb is declared in `src/`.

### Rules a specific defect paid for

- **"Fit" is the wrong word and the wrong instinct — *in regime R1*.** For a stencil **we
  authored**, the grammar is the prior and recovery is an exact match; an `ε` there is a defect
  signal, never a knob (law **P4**). But **R2** — recovering *arbitrary cell-authored* content
  with no grammar behind it — genuinely **is** a fit with a pinned tolerance, licensed by law
  **E₃** and prototyped in crawler's `matcher.py`. Know which regime you are in
  (`ROUNDTRIP.md` §6); using R2's machinery where R1 applies throws away an exact answer.
- **Use `hex_neighbor` with `hex_edge_corners`, ALWAYS** (`SPEC` **L11**, `X26`'s exact mode).
  Mixing them with `hex_field`'s `nb_q`/`nb_r` gives the same six neighbours in a **different
  order**, so *"directions 0..2"* is a different canonical set and the corner lookup reads a
  different edge. **One root cause behind four separate failures**, one of which was recorded as
  fact before it was caught.
- **Width-normalise before ranking anything by heading** (**X9**). A fixed nominal width yields
  different cell counts per direction, so raw spread measures *width, not heading* — in crawler
  this **inverted** the conclusion before it was caught.
- ⚠ **`OPEN_NONE = 0` is a naming hazard in hexbody's OWN source** — it reads as *"no opening"* and
  means *"no wall"*. Its comment now says so; reach for `OPEN_GAP`, never `0` (`X70`).
- **Write every binary artefact to a FRESH path, and never measure one by file size**
  (`SPEC` **L12**). `doc_write` **APPENDS**, so a reused path leaves the second document unreachable
  and the reader returns the **first** with `doc_code == HXF_OK` (`X64`); and `file().content()`
  returns **empty for non-UTF-8 bytes, silently** (loft, both backends — `crawler/LOFT-HANDOFF.md`
  **H7**), so the natural append check reads `0 == 0 * 2` — a vacuously true *"it appended"* that
  `tests/foxel.loft` **printed** before it was caught.
- **A doorstep that refuses more than the field distinguishes is WORSE than none** (`X66`) — it
  makes legal models unauthorable. And **`K-FIT` owes an offer only for an ORDINAL parameter**: for
  a nominal one (a material id) it names its restriction and stops (`X68`).
- **`h0` parity does NOT classify a form** into the edge/vertex class — sides run `h0`, `h0+t₀`,
  `h0+t₀+t₁`, so turns `2,5,5` from `h0=0` mix both classes. Assuming otherwise produced **72
  confident false "law F violations"** before it was caught.
- **Three digests, three questions** — `field_digest` (orientation + translation → *how many
  shapes?*), `field_exact` (nothing → *is `draw` injective?*), `field_norm` (translation → *which
  stencil?*). Conflating two of them reported **17 false law F failures** (`X40`).
- **A run is NOT stored in `t` order** — index a feature by its exact `t` numerator, never by its
  position in the `SideRun`.
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
