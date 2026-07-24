# `lib-split` — DESIGN: the split, derived from the objects

**Cite nothing from this file as fact.** This is a proposal. What is settled lives in
[`../../SPEC.md`](../../SPEC.md) and [`../../ROUNDTRIP.md`](../../ROUNDTRIP.md).

---

## 0. What the siblings already do — measured, not assumed

| repo | libraries | naming | entry | size range |
|---|---|---|---|---|
| `loft-libs-world` | `hex_grid`, `hex_field`, `hex_terrain`, `hex_world` | **domain-named**, no repo prefix | `src/<name>.loft` | 226 – 1517 lines |
| `../moros` | `moros_map`, `moros_editor`, `moros_render`, `moros_sim`, `moros_ui` | **repo-prefixed** | `src/<name>.loft` | 371 – 1372 lines |
| the registry | 22 packages (`shapes`, `mesh3d`, `random`, `crypto`, …) | domain-named | — | — |

**The house style, in three facts.** One library is **one concern** at **300–1500 lines** with a
**single entry file**. moros layers them strictly — `map` (the model) is the base, `editor`/`render`
sit on it, `sim` on those, `ui` on top — and **no library imports a later layer**. `loft-libs-world`
splits by *object* (`hex_grid` = geometry, `hex_field` = storage) and its libraries have **no
dependencies on each other at all**.

**The distinction that matters for us:** `loft-libs-world` is a *library collection*, so its names
are domain names. `moros` is an *application* that happens to be split, so its names carry the repo.
`SPEC` **G-LIB** puts hexbody in the first category.

## 1. The principle — the split comes from the OBJECTS

`SPEC` **I-EXTEND**, as the user put it: *"we are pretty much a programming language — it doesn't
define who can use them. Many consumers are there, some known some unknown."* **A language defines
its primitives from its own semantics and lets users come.** So the seam is derived from
[`../../ROUNDTRIP.md`](../../ROUNDTRIP.md) §2 (objects) and §3 (maps), which are settled — and *not*
from what the editor, crawler and moros happen to need. Designing for the three you know is how you
get a seam that breaks the fourth.

`ROUNDTRIP`'s maps are the natural seams, because a map is exactly what a consumer calls:

```
snap  : 𝕄 → 𝕄* × ℝ≥0      the doorstep
write : 𝕄* → 𝕋   read     the text
draw  : 𝕄* → 𝔽             the field
rebuild : 𝔽 → 𝕄* × ℝ≥0     recovery
place : 𝕄* × P → world      the pose
```

## 2. The proposed split — six libraries, strictly layered

Sizes exclude the two tools (`houseshot`, `corpusgen`, which stay tools) and the three modules that
are not ours (§5).

| # | library | modules | lines | object / map it owns | depends on |
|---|---|---|---|---|---|
| 1 | **`hex_form`** | `hexform`, `formtext`, **+ `Plan`** (§6) | ~900 | `Λ`, `H₁₂`, the turtle form in `𝕄*`, and `𝕋` via `write`/`read` | `hex_field`, `hex_grid` |
| 2 | **`hex_shape`** | `hexwall`, `hexbox`, `hexarc` | 1387 | the rest of `𝕄*` — the line primitive `D`, the box, the arc | 1 |
| 3 | **`hex_draw`** | `housedraw`, `hexsurf` | ~700 | `draw`, and the analytic surface read back off the field | 1, `hex_ways` (§5) |
| 4 | **`hex_recover`** | `formfit`, `formcensus` | 770 | `rebuild` — indexed, constructive, and the census that licenses it | 1 |
| 5 | **`hex_fit`** | `hexfit`, `hexdraft` | 474 | `snap` / `fits?` — the doorstep, and the `Draft` composite | 1, 2, 3, 4 |
| 6 | **`hex_place`** | `hexframe`, `hexseat`, `hexcombine` | 349 | `place`, and `Ops = {combine, seat}` | 1 |

**Layering, verified against the real import graph:** 1 → nothing internal · 2, 4, 6 → 1 ·
3 → 1 · 5 → 1,2,3,4. **Acyclic, and no library imports a later layer** — the moros property.

**Why `hex_form` carries `𝕋`.** `formtext` is 160 lines, below the family's smallest, and
`write`/`read` are meaningless without the form they spell. Splitting it would be a package for a
map with one operand.

**Why `hex_fit` is last.** The doorstep must know everything that can be authored — that is what
`K-FIT` *is*. Its position at the top of the layering is a property of the contract, not an
accident of the code.

## 3. ✅ DECIDED — `hex_*`, and the prefix is a RULE, not a brand

> *"The `hex_` prefix is informative for our users. If we depend on hex code (the moros voxels) we
> adopt it."* — user, 2026-07-24

So the answer is the `hex_*` family, and it comes with a **criterion** rather than a house style:

> **A library that depends on hex code carries `hex_`. One that does not, does not.**

That has teeth. All six proposed libraries depend on the lattice — directly on `hex_field`/`hex_grid`
or transitively through `hex_form` — so all six take the prefix. But if hexbody ever produces
something lattice-agnostic (a `L15` container keyed by an opaque location, say, or a pure-arithmetic
helper), **it must not** take it: the prefix tells a user *"this is hex code, and it brings the
lattice with it"*, and a prefix that means nothing tells them nothing.

**The family framing is already upstream's**, which is the strongest confirmation available:
`hex_terrain`'s own registry description reads *"the OVERLAND terrain layer of the `hex_*` family"*.
These libraries join a family that already exists and already advertises itself as one.

**Namespace checked, 2026-07-24** — `hex_form`, `hex_shape`, `hex_draw`, `hex_recover`, `hex_fit`,
`hex_place` and `hex_ways` are **all free** in the 22-package registry.

### 3.1 ⚠ But the check found a real blocker: `hex_field` is NOT PUBLISHED

The registry carries `hex_grid`, `hex_terrain` and `hex_world` — **and not `hex_field`**, which is
the one hexbody's entire geometry stands on. It exists in `loft-libs-world` with a `[library]` entry
and is consumed by `--lib` at the working tree, exactly as hexbody is.

**So hexbody cannot publish above its own foundation.** A consumer installing `hex_form` from the
registry would need `hex_field`, which is not there. Three ways out, and it is `loft-libs-world`'s
call, not ours:

| | cost |
|---|---|
| **publish `hex_field`** *(recommended)* | it already has the shape; it is the smallest change and it fixes the same problem for `moros`, which depends on it too |
| **path dependencies** | works for siblings in one workspace, and fails the moment a consumer is not a sibling — which is the whole point of `G-LIB` |
| **vendor it** | violates `L11` outright: two copies of the lattice table that agree today and diverge silently later |

**This moves in the phase order**: publishing `hex_field` is a *phase 0* item alongside extracting
the crawler copies, and both are cross-repo.

## 4. `formcensus` is TWO THINGS — measured, and the split follows the same rule

The question *"does `formcensus` ship?"* was the wrong shape, and one grep showed why. Of its 20
public functions:

| | functions | verdict |
|---|---|---|
| **used by a library** (`formfit`) | `field_norm`, `field_norm_text`, `forms_upto` | must ship |
| **gate-only** | `digest_text`, `form_key`, `form_key_noturn`, `count_digest`, `turns_cyclic_eq`, `turns_reverse_eq`, `forms_sides` | must not |
| the enumerations themselves | `census_a`, `census_b` | **called only by `tests/`** |

So `formcensus` holds a **digest/normalisation** half and an **exhaustive-enumeration** half, and
they belong on opposite sides of the seam:

- **The digests are library material.** `X40`'s *three digests, three questions* —
  `field_digest` (how many shapes?), `field_exact` (is `draw` injective?), `field_norm` (which
  stencil?) — are what `rebuild` is built on. They go to `hex_recover` with `formfit`.
- **The enumeration is METHOD material.** `census_a`/`census_b` are how law **F** was *decided* at
  levels 1–3 (`X38`, `X42`, `X43`). A consumer never re-decides law F; the corpus already did.
  They belong beside the gates, not in a published surface.

⚠ **The one entanglement, and it is decidable on the project's own evidence.** `formfit` uses
`forms_upto` for **indexed recovery** (`index_build` draws each candidate once). But `X44` recorded
that the index *"does NOT reach the house"* — it fixes per-lookup cost, not enumeration cost — and
`X45`'s **constructive** recovery reaches strictly further, `O(cells)` and all-integer, with the miss
asserted so the comparison is not vacuous. **So indexed recovery is a superseded path**, and
shipping it drags the whole enumeration into the library with it.

**Recommendation: `hex_recover` ships constructive recovery and the digests; indexed recovery and
the censuses stay with the gates.** That sheds ~378 lines and the heaviest code path from a
published surface, and it is `I-EXTEND`-safe in the only direction that matters — a name never
published can still be published later, and one that ships can never be withdrawn.

⚠ **Still a decision, not a measurement**: removing a working code path from what consumers get is a
scope call. The evidence says the path is superseded; whether that is enough is the user's.

## 4b. The library RULES — inspected, not assumed

> *"We must adhere to the same library rules as all other libraries of `../loft`."* — user,
> 2026-07-24

Inspected `loft-libs-world`'s canonical `library-ci.yml` and its four packages. **hexbody conforms
to none of it today**, and two of the gaps are load-bearing.

| rule | what it is | hexbody today |
|---|---|---|
| **`[library] entry`** | `loft.toml` carries `[package] name/version/loft = ">=0.8"` and `[library] entry = "src/<name>.loft"` | ✗ no `[library]` at all |
| **per-library `README.md`** | every package has one | ✗ |
| **SPDX header on every source file** | `// Copyright (c) 2026 Jurjen Stellingwerff` + `// SPDX-License-Identifier: LGPL-3.0-or-later` | ✗ hexbody uses a purpose block and has **no `LICENSE`** — `CLAUDE.md` records that as the *application* convention, which `G-LIB` has now overturned |
| **repo `LICENSE`** | LGPL-3.0-or-later, one per chunk repo | ✗ |
| **⚠ the library TEST FORM** | `tests/NN-name.loft` with `fn main()` + `fn test_*()` and `assert(cond, "msg")`, run by `loft --interpret --tests tests` | ✗ **hexbody's 23 gates are the *application* form** — programs printing `=== NAME OK ===`, grepped by `tools/run_tests.sh`. They will not run under `loft --tests` |
| **⚠ `LOFT_DENY_WARNINGS=1`** | CI sets it unless the package carries a `.allow_warnings` file | ✗ hexbody's own modules emit warnings today |
| **`loft test --deps`** | transitive-dependency tests, to catch API drift in a dep | ✗ |

### 4b.1 The test-form gap is the one that costs thinking

hexbody's gate form is not a stylistic choice — it **is** the method: *a gate is a program that
prints its evidence and ends in a marker*, with a control that must fire. Converting 23 gates to
bare `assert()` would throw away the printed evidence that makes a red gate diagnosable.

**Proposal: both, and they are not redundant.** Each published library gets `tests/NN-*.loft` in the
library form — thin, asserting the *same* invariants — so CI runs green and a consumer can see the
package is tested. The evidence-printing gates stay in hexbody's `tests/` and keep running under
`make test`, because they are what actually finds defects (`X26`, `X28`, `X57` were all found by a
gate printing a number nobody expected). The library test is the **conformance** statement; the gate
is the **measurement**.

### 4b.2 ⚠ And this explains why `hex_field` is unpublished

`library-ci.yml`'s matrix is `[hex_world, hex_grid, hex_terrain]` — **`hex_field` is not in it**, and
it carries no `.allow_warnings`. Measured from hexbody's own suite output: `hex_field` produces
**126 warning lines** per run. So the chain is causal, not coincidental:

> `hex_field` emits warnings → cannot pass `LOFT_DENY_WARNINGS=1` → left out of the CI matrix →
> never published → **hexbody cannot publish above its own foundation** (§3.1).

**And we are now allowed to fix it.** The user, same day: *"for our work — a fully functioning
library for editors/games — we are allowed to mutate the current library, with care."* So publishing
`hex_field` is not a request to another team; it is **our phase 0**, and the work is: clear its
warnings, add it to the CI matrix, publish. *"With care"* is `L11` and `I-EXTEND` — the lattice table
has one owner and a published name never comes back.

## 5. Prerequisite — three modules that are not ours

`hexedge` (660), `hexway` (377) and `hexroof` (521) are **byte-identical copies of crawler's**, and
their proper home is `loft-libs-world` — recorded in `README.md` long before this plan, and required
by **`L11`** (*the library owns the shared table; two tables that agree today diverge silently
later*). `housedraw` imports `hexway` and `hexroof`, so `hex_draw` cannot be declared until they
move.

Provisional name for their home: **`hex_ways`** — but that is `loft-libs-world`'s decision, not
hexbody's, and it is cross-repo work with crawler as the other stakeholder.

## 6. The finding the split surfaced — `Plan` is misfiled

`hexbox` and `hexsurf` both import `housedraw`, which reads as *a shape depending on the drawer*.
Measured, that is not what they use it for:

| module | what it takes from `housedraw` |
|---|---|
| `hexsurf` | `Plan` ×12, `side_edges` ×9, `side_run_len` ×6 — and `draw_walls`/`place_opening` once each |
| `hexbox` | `Plan` ×4, `plan_to_local`, `draw_walls`, `draw_floor` once each |

**`Plan` is an object, not a map.** `OD-11` resolved *"what IS a house?"* to **`Plan`, not the turtle
cycle** — so it is a member of `𝕄*`, and it is living inside the `draw` map's module. Moving `Plan`
and its accessors (`side_edges`, `side_run_len`, `plan_to_local`) into `hex_form` removes the only
awkward edge in the whole graph and makes layers 2 and 3 independent of each other.

**[J] This is the same class of finding as `X26`** — a table living in the wrong module, invisible
while everything is one compilation unit, and structural the moment a seam runs through it. It is
also the argument for doing this analysis *before* publishing rather than after.

## 7. What does NOT become a library

`houseshot` (the contact sheet) and `corpusgen` (the corpus writer) are **tools**: they have `main`,
they write files, and no consumer would import them. They stay in `src/` or move to `tools/` —
either way they are outside the seam, and `corpusgen` in particular must never be importable, since
`X15` is the whole reason it is kept out of `make test`.
