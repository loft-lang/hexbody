# `lib-split` — make hexbody consumable: the library split

**Issue:** `SPEC` **G-LIB** *(pre-tracker; no `PLAN.md` milestone — this is not a capability, it is
the seam every capability ships through)* · **Value:** `F` · **Effort:** `MH`

## Status

**`G-LIB` is not met, and it gates everything downstream.** Measured 2026-07-24: `loft.toml` has
**no `[library]` entry**, and **no consumer references hexbody** across `../crawler` and `../moros`.
The only way in is `--lib` at a sibling working tree — the same unpinned-tree fragility that broke
this suite the same day, and it would break a consumer's the same way.

**Nothing here is built.** The split is *designed* ([`DESIGN.md`](DESIGN.md)) and the design surfaced
two structural findings that must land before any packaging:

| finding | what it is |
|---|---|
| **`Plan` is misfiled** | `hexbox` and `hexsurf` depend on `housedraw` almost entirely for the **`Plan` type** and its accessors — an *object* living inside the `draw` map. Moving it removes the only awkward edge in the graph |
| ~~**three modules are not ours**~~ **EXTRACTED** | `hex_edge`/`hex_way`/`hex_roof` are libraries in `loft-libs-world` and hexbody consumes them. ⚠ **crawler still carries its copies** — the migration is designed for them in [`CRAWLER-HANDOFF.md`](CRAWLER-HANDOFF.md) and is theirs to run or decline. Until they do, the honest state is *two sources, deliberately* |

## Goal

A consumer — known or unknown — can depend on hexbody's geometry through declared libraries with a
stable seam, without pointing `--lib` at a working tree.

## Anchors

- **[`../../SPEC.md`](../../SPEC.md)** — advances **`G-LIB`**; governed by **`I-EXTEND`** (a
  published seam grows and never shrinks, and is designed for users you will never meet) and
  **`L11`** (the library owns the shared table — the reason the crawler copies must leave).
- **[`../../ROUNDTRIP.md`](../../ROUNDTRIP.md)** §2 *Objects* and §3 *Maps* — **the split is derived
  from these**, not from a consumer survey. See [`DESIGN.md`](DESIGN.md) §1.
- **Prior art analysed**: `../moros` (5 libs, layered, `moros_*`), `loft-libs-world` (4 libs,
  `hex_*`), the 22-package loft registry. [`DESIGN.md`](DESIGN.md) §0.
- `loft-ship` skill — the cross-target parity half (interpreter / native / wasm / html).

## Blueprint gate

- **Concrete end-result:** a scratch consumer package that declares a path dependency on the split
  libraries, `use`s them, and builds — with hexbody's own 23 gates still green through the same
  libraries rather than through `--lib src/`.
- **Invariant:** **the seam grows and never shrinks** (`I-EXTEND`, `A₂` one level up). Every public
  name that leaves is a name that cannot come back.
- **Control:** the split must be shown to be **acyclic and layered** — a library that imports a
  later layer fails the check. And a consumer built against layer *n* must not need layer *n+1*.
- **Medium:** the real packages. The primitives exist; a model of them would prove nothing.

## Phases

| Phase | Effort | Verify | Status |
|---|---|---|---|
| **0a** ◑ — extract `hexedge`/`hexway`/`hexroof` to `loft-libs-world` | M | crawler and hexbody both consume one source; no byte drift | **hexbody half DONE** 2026-07-24 (`loft-libs-world` `9e8021c`, hexbody `79e23b8`): three libraries, 14 tests, in CI; hexbody's `src/` 20 → 17 modules. **crawler half is theirs** — designed and handed off in [`CRAWLER-HANDOFF.md`](CRAWLER-HANDOFF.md), not performed |
| **0b** ✅ — **`hex_field` is warning-clean and in the CI matrix** | M | `LOFT_DENY_WARNINGS=1 loft --interpret --tests tests` → **47 passed, 6 files** | **DONE 2026-07-24** (`loft-libs-world` `6bef19b`, `b61a735`). 126 warning lines → 0; 15 sites, all pure substitutions. Consumers verified: hexbody 23/23, moros_map 76/11. ⚠ **Publishing itself is still open** — CI green is the precondition, not the act |
| **0c** — conform to the library rules | M | `[library] entry`, per-library `README.md`, SPDX headers, repo `LICENSE`, `tests/NN-*.loft` in the **library form**, `LOFT_DENY_WARNINGS=1`, `loft test --deps` | not started. hexbody conforms to **none** of these today; the test-form gap is the one that costs thinking ([`DESIGN.md`](DESIGN.md) §4b) |
| **1** — move `Plan` and its accessors out of `housedraw` into the model layer | S | the dependency graph loses the `shape → draw` edge; 23 gates unchanged | not started |
| **2** — declare the libraries, one `[library]` entry each | M | each builds standalone; the layering check passes | not started |
| **3** — hexbody's own gates consume the libraries, not `--lib src/` | S | 23/23 still green, byte-identical output | not started |
| **4** — a scratch consumer proves the seam; cross-target parity | M | `loft-ship`'s matrix: interpreter / native / wasm / html | not started |

⚠ **Phase order is not negotiable.** Declaring libraries before phase 0/1 publishes a seam with a
known-wrong shape, and `I-EXTEND` says a published seam cannot be taken back.

## Risks

- **⚠ Publishing early is the expensive mistake.** `𝕄*` grows and never shrinks; so does an API.
  Every phase before 2 is free to redo, and everything after 2 is not.
- ~~**The naming family is a one-way door**~~ **DECIDED** — `hex_*`, and the prefix is a *rule*: a library that depends on hex code carries it, one that does not must not ([`DESIGN.md`](DESIGN.md) §3). All six names verified free in the registry.
- **`formcensus` may not belong in a shipped library at all** — [`DESIGN.md`](DESIGN.md) §4.

## See also

[`DESIGN.md`](DESIGN.md) *(the split itself, and the reasoning)* · [`../../SPEC.md`](../../SPEC.md)
**G-LIB**, **I-EXTEND**, **L11** · [`../m1-moving-body/`](../m1-moving-body/) *(the next capability,
which ships through this seam)*
