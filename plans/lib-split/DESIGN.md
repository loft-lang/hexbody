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

## 3. ⚠ OPEN — the naming family, and it is a one-way door

`I-EXTEND` says a published name cannot be taken back, so this is the decision I would not make
alone.

- **(a) join the `hex_*` family** — `hex_form`, `hex_shape`, `hex_draw`, … beside `hex_grid`,
  `hex_field`, `hex_terrain`, `hex_world`. **Recommended.** Consumers already import `hex_field`;
  these are the same lattice family and read as continuous with it. It also survives the repo being
  renamed, which `README.md` says is expected (*"working name — rename with one `mv`"*).
- **(b) prefix with the repo** — `hexbody_form`, … , as moros does. Honest about provenance, but it
  implies the libraries are about *bodies*, and five of the six are not. It also welds the seam to a
  name the README already calls provisional.
- **(c) one library, `hexbody`** — simplest to publish, and wrong: a consumer wanting only the
  turtle form would take the arc recovery, the census and the pose machinery with it.

⚠ **(a) has a collision risk worth checking before committing**: `hex_*` is a shared namespace in
`loft-libs-world` and the registry, and these libraries would live in a *different repo*. Confirm
with whoever owns that namespace that `hex_form` / `hex_shape` are free and welcome.

## 4. ⚠ OPEN — does `formcensus` ship?

`formfit` imports it, so today it must. But the census is the machinery that *decided* law F at
levels 1–3 (`X38`, `X42`, `X43`) — a **method**, not a runtime service — and `X45`'s constructive
recovery is the one that reaches real houses without enumerating anything.

If indexed recovery is a build-time/test-time tool rather than a consumer-facing one, `formcensus`
belongs in `tests/` or a tool, and `hex_recover` sheds 378 lines and its heaviest code path.
**Measure before deciding:** does any *consumer-shaped* call path reach `index_build`, or only the
gates? That is a half-hour of grep and it changes a published surface.

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
