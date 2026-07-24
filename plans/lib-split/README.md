# `lib-split` — make hexbody consumable: the library split

**Issue:** `SPEC` **G-LIB** *(pre-tracker; no `PLAN.md` milestone — this is not a capability, it is
the seam every capability ships through)* · **Value:** `F` · **Effort:** `MH`

## Status

**✅ DONE — `G-LIB` is met.** The geometry is **published** as nine `hex_*` libraries in
`loft-lang/registry` (`0114376`), the chunk's first inter-dependent family, signed and verified as
a real consumer (`hex_fit` + its whole DAG installs and runs with **no `--lib`**). hexbody is the
**workshop** — it ships no library itself; `src/` went **20 modules → 2 tools**.

*Original status kept below, because what the design got right and had to correct is the useful
part. The design surfaced two structural findings that landed before packaging:*

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
| **0b** ✅ — **`hex_field` + the nine are PUBLISHED** | M | each resolves and installs from the registry | **DONE 2026-07-24** (`loft-lang/registry` `0114376`). 10 releases cut, index signed with the tuxedo trust-root key, all three validate.py gates green (schema, sha256/size, reproducible-build). Verified: a consumer with **no `--lib`** installs `hex_fit` and the full DAG resolves and runs. ⚠ CDN `@latest` lags ~1h; pinned installs work now |
| **0c** ◑ — conform to the library rules | M | `[library] entry`, per-library `README.md`, SPDX headers, repo `LICENSE`, `tests/NN-*.loft` in the **library form**, `LOFT_DENY_WARNINGS=1`, `loft test --deps` | **the warning half is DONE** 2026-07-24: `src/` **134 → 0** warning lines, 12 sites, all pure substitutions. **SPDX headers (40 files) and the repo `LICENSE` (LGPL-3.0-or-later, matching the chunk) are DONE too.** Remaining: per-library `README.md` and library-form `tests/NN-*.loft`, which are per-library and land with phase 2 |
| **1** ✅ — move `Plan` and its accessors out of `housedraw` into the model layer | S | the dependency graph loses the `shape → draw` edge; 23 gates unchanged | **DONE 2026-07-24.** Both edges gone: `hexbox` and `hexsurf` now import `hexform` only. `housedraw` 368 → 187 lines. It also found a **duplicate of `hex_grid::HEX_LEN`** (see [`DESIGN.md`](DESIGN.md) §6) |
| **2** ✅ — declare the libraries, one `[library]` entry each | M | each builds standalone; the layering check passes | **DONE 2026-07-24** (`loft-libs-world` `8186b4a`). Six libraries, all nine load in isolation, layering acyclic. ⚠ Intra-chunk deps are **documented, not declared** — a transitive path dep does not resolve its own path deps; the fix is bottom-up publication, which folds into 0b |
| **3** ✅ — hexbody's own gates consume the libraries, not `--lib src/` | S | 23/23 still green, byte-identical output | **DONE 2026-07-24**: `src/` is two tools; all 23 gates run against the libraries. `tests/scope.loft` and `tests/scale.loft` both had to FOLLOW THE CODE — they now scan the nine libraries plus `src/`, because the seam and the scale ladder are claims about the code, not about a directory |
| **4** ◑ — a scratch consumer proves the seam; cross-target parity | M | `loft-ship`'s matrix: interpreter / native / wasm / html | **the seam is PROVEN** 2026-07-24: a scratch package outside both repos built the editor path (author→fits?→draw→recover, R1 ρ=0) and the game path (geometry→proxy→query). All nine libraries carry README + USAGE + conformance tests, in CI, 39 tests green. ⚠ **`loft api` cannot see them** — publication (0b's other half) is the last edge, and cross-target parity is unrun |

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
