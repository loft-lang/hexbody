<!--
A handoff FROM hexbody TO crawler.  Nothing in `../crawler` was changed to produce it — every
number below was measured by reading crawler, and the migration is crawler's to perform, on
crawler's schedule, or to decline.
-->

# For crawler — `hexedge` / `hexway` / `hexroof` are libraries now

**What changed on our side, 2026-07-24:** the three modules you and hexbody both carried as
byte-identical copies were extracted into `loft-libs-world` as **`hex_edge`**, **`hex_way`** and
**`hex_roof`**. hexbody has already deleted its copies and consumes the libraries; its 23 gates are
green. **Yours are untouched, and stay untouched until you decide otherwise.**

This document is the migration as *you* would do it, with the costs stated honestly — including the
one that is genuinely yours to weigh.

---

## 1. What you get

| | |
|---|---|
| **1558 lines you stop maintaining** | `hexedge` 660 + `hexway` 377 + `hexroof` 521, currently duplicated between your `src/` and (until today) ours. Every fix had to be mirrored by hand or the copies drifted |
| **26 lines of warning fixes, free** | `hexway`'s `L`/`L2` UPPER_CASE locals (42 sites) and `hexroof`'s unused `pass` counter (24). You do not set `LOFT_DENY_WARNINGS`, so these were never failing for you — they are simply noise you stop seeing |
| **14 tests and CI you do not have today** | each library ships `tests/01-*.loft` in the library form and runs in `loft-libs-world`'s `library-ci.yml` matrix under `LOFT_DENY_WARNINGS=1`, on every push. These modules currently have no tests of their own in your tree — they are exercised only through your gates |
| **fixes flow both ways** | today a hexbody fix reaches you only if someone remembers to copy it. `SPEC` **L11**: *two tables that agree today diverge silently later* |

## 2. What it costs you, and this is the real one

> ⚠ **You lose direct control of three files you currently own outright.** After migrating, a
> change to `hexedge` is a `loft-libs-world` commit, not a `crawler` commit — a second repo, a
> second review, and a second push before your build sees it.

`hexedge` reaches 29 of your files including `sim.loft`; this is load-bearing game code, not a
utility corner. **If you iterate on it often, that friction is a real tax and this migration may
not be worth it yet.** We are not in a position to judge that — you are. Everything below assumes
you have decided it is.

The other costs are small and stated for completeness: the three become an external dependency, so
a broken `loft-libs-world` `dev` breaks your build (you already take that risk — `hex_grid`,
`hex_terrain` and `hex_field` are all consumed from there today).

## 3. What the migration actually is — measured, not estimated

**No plumbing change.** Your `Makefile` already carries `--lib ../loft-libs-world/` in `LIB_DEPS`,
which is how you reach `hex_grid` and `hex_terrain`. The new libraries resolve through exactly that.

**No call sites change.** We diffed the public surface — `pub fn`, `pub struct`, `pub const` —
between your copies and the libraries:

```
hexedge -> hex_edge    0 public-surface differences
hexway  -> hex_way     0 public-surface differences
hexroof -> hex_roof    0 public-surface differences
```

**The only content differences are the warning fixes**, all local-variable renames, no logic:

```
hexedge   0 differing lines   (identical)
hexway   20 differing lines   (L -> seg_l, L2 -> len2)
hexroof   6 differing lines   (for pass -> for _)
```

So the whole migration is **an import rename and three deletions**:

| | |
|---|---|
| files to touch | **36 distinct** (`use hexedge;` in 29, `use hexway;` in 24, `use hexroof;` in 4 — overlapping) |
| the edit | `use hexedge;` → `use hex_edge;` · `use hexway;` → `use hex_way;` · `use hexroof;` → `use hex_roof;` |
| then | delete `src/hexedge.loft`, `src/hexway.loft`, `src/hexroof.loft` |
| optionally | add the three to `loft.toml` `[dependencies]` beside `hex_grid` / `hex_terrain`, so the manifest states what the build already resolves |

## 4. Do it in three steps, not one — the risk is not evenly spread

`hexedge` is **byte-identical** to the library, so migrating it alone cannot change behaviour. Take
that step first and let your gates confirm the plumbing before anything with a real diff moves.

| step | files | content risk | your gates that exercise it |
|---|---|---|---|
| **1 — `hexedge`** | 29 | **none** — 0 differing lines | `edgetest`, `sweeptest`, `sighttest`, `crossingtest`, `pointstest`, `matrixtest`, `cachetest`, `feattest` |
| **2 — `hexway`** | 24 | 20 lines, all local renames | `waytest`, `linktest`, `wheeltest`, `hingetest`, `jointest`, `matchtest`, `bridgetest`, `stairtest`, `spiraltest`, `platformtest`, `levelxtest` |
| **3 — `hexroof`** | 4 | 6 lines, all local renames | `rooftest`, `roofmatchtest`, `vaulttest`, `propgentest` |

**25 of your 87 gates exercise this code.** That is a strong verification set — stronger than
anything we could offer you — which is the main reason this handoff is a design rather than a patch.

Each step is independently revertible: `git revert` the rename commit and restore the deleted file
from history. Nothing in `loft-libs-world` needs to change to back out.

## 5. If you would rather not

**Then don't, and tell us** — because the copies are byte-identical *today* and that is the whole
value at risk. If crawler keeps its own, the honest state is *"two sources, deliberately"*, and it
should be written down on both sides so the next person does not assume the extraction happened.
What must not happen is the copies drifting while everyone believes they are one file — that is
exactly the failure `L11` was written after (`X26`: five of six edges misfiled because a private
table sat beside the library's, and every gate stayed green).

## 6. Where things are

- The libraries: `loft-libs-world/hex_edge`, `hex_way`, `hex_roof` — branch `dev`, commit `9e8021c`.
- Their READMEs state each library's contract, including two API facts worth knowing:
  **`surfaces_new()` reserves id 0** for *"no surface"*, so the first real surface is id **1**; and
  **`roof_cone`'s `(cx, cy)` is in world units**, not cell indices.
- hexbody's side: `plans/lib-split/`, commit `79e23b8`.
- Questions, or a request that we do it instead: we can, but your gates are the ones that decide it,
  so the review would land on you anyway.
