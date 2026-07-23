# plans/ — hexbody's plan structure

hexbody organizes multi-phase work the way **loft** and **crawler** do, so one convention
spans every repo in the org. This file is the **binding** — the conventions and where hexbody
differs. The *method* it serves lives elsewhere and is not restated here:

- **`../crawler/DESIGN-PROTOCOL.md`** — the blueprint phase (concrete plotted end-result → name
  the invariant → pin each step → only then code). Shared across the org; it is what a plan's
  phases should be *made of*.
- Branch/commit policy: same as the org — commits end with the `Co-Authored-By` trailer; push
  only when asked. loft is an upstream **consumer** relationship (hexbody never fixes loft) —
  defects go to crawler's `LOFT-HANDOFF.md` / `FILING.md`, never into a hexbody plan.

## The rule — docs vs plans

- A **reference doc** ([`VISION.md`](../VISION.md), [`ARCHITECTURE.md`](../ARCHITECTURE.md),
  [`design/*`](../design/)) describes **how the thing works** — the durable truth, updated in
  place as the code changes.
- A **plan** describes **a change we intend to make** — phases, ordering, verification. It is
  temporary: when a phase ships, its reference content **moves out** to the doc that owns it,
  and the plan keeps only the closure record.

If you cannot say what *changes* when the plan is done, it is a doc, not a plan.

**`PLAN.md` is the synthesis layer** — the milestone through-line from the first brick to the
derailment demo — the hexbody equivalent of crawler's `ROADMAP.md`. It is **not** a plan index
and must not grow one; the tracker is the index (below).

## Pick the lightest workflow that fits

| Work shape | Path |
|---|---|
| **Bug fix** (one root cause, one commit) | Fix + a `src/<x>test.loft` case + commit. No plan. |
| **Upstream (loft) defect** | crawler's `LOFT-HANDOFF.md` → file per `FILING.md`. **Never a hexbody plan.** |
| **Tiny deliverable** | Nothing, or one line in the relevant doc. |
| **Light TODO** *(the default)* | An `## Open work` section in the reference doc that owns the area. Same lifecycle as a plan, one row — row and design share a file. |
| **Plan** | A directory here. Earns it only when the work is genuinely **multi-phase** *and* benefits from its own document space. Cap active plans at **2–3**. |

Most work is not a plan. A one-row TODO in `design/FEATURES.md § Open work` beats a plan
directory that only points back at it.

## Identity — the issue number, claimed first

The org convention is that a plan's identity is its **`loft-lang/hexbody` issue number**, not a
local integer — open the issue first, then name the directory after the number it returns; never
pick the number by scanning `plans/`.

> **hexbody has no remote tracker yet.** Until one exists, a plan directory is named by its
> **`PLAN.md` milestone slug** (e.g. `plans/m1-moving-body/`, `plans/m0-fit/`), and is
> **renumbered to the issue** once the repo has a tracker. Everything else in this convention
> applies as written.

- Directory: `plans/<id>-<slug>/README.md` — **flat**. No `future/` / `finished/`
  subdirectories: lifecycle state is a **label**, not a path.
- **Small plans live in the issue/milestone alone.** A directory is for work that needs a
  document space (phases, sub-files, a `probes/` dir).
- **No hand-maintained index here.** The overview is the tracker (or, pre-tracker, `PLAN.md`'s
  milestone list).

## Labels

| Dimension | Values | Rule |
|---|---|---|
| kind | `plan` | on every plan issue |
| status | `status:future` · `status:active` · `status:finished` · `status:declined` | **exactly one** |
| value | `val:S` `val:R` `val:G` `val:F` `val:U` `val:C` `val:Q` `val:N` | one, see below |

**A closed issue must carry `status:finished` or `status:declined`** — never a live status.

## Value categories — what KIND of value

Same letters as loft/crawler, so the convention reads the same across repos; the examples are
hexbody's. Read top-down; pick from the highest category with open work.

| Tag | Meaning | hexbody examples |
|---|---|---|
| **S** | **Silent failure / wrong result with no error** — highest priority | a proxy that misses a real overlap; a non-deterministic derailment breaking replay |
| **R** | **Regression / gate-blocker** — `make test` red, or a toolchain bump that breaks the build | a loft upgrade breaking `housetest` |
| **G** | **Goal-enabling** — directly advances the demo path | the moving body, the train, the derailment |
| **F** | **Foundation** — unblocks 2+ downstream plans | the fit, the Body/joint model, the proxy contract |
| **U** | **Presentation** — how it reads: the editor, rendering, seating clarity | the side-by-side editor, the fitted wall render |
| **C** | **Clean seam** — keeps the library/consumer boundary honest | extracting a mechanism to the shared lib |
| **Q** | **Internal quality** — perf, refactor, cleanup with a clear payoff | de-duplicating `hexedge`/`hexway`/`hexroof` into the shared lib |
| **N** | **Niche / opportunistic** — small, low-priority | one-off tools, conveniences |

**Effort letters, never calendar time** — `XS / S / M / MH / H / VH`.

## Files here

| File | Purpose |
|---|---|
| `_TEMPLATE.md` | the standard plan skeleton — copy to `<id>-<slug>/README.md` |
| `_INVESTIGATION_TEMPLATE.md` | for plans whose first phase is *characterize the problem*, not *design + build* |
| `_LIFECYCLE.md` | the close / defer checklist (including the link-rewrite step) |

**Length budget: 100–300 lines per plan README.** Longer means reference content is leaking in —
extract it to the doc that owns it.

The milestones in [`PLAN.md`](../PLAN.md) (P, M0–M7) are the current plan candidates; each earns
a directory here from `_TEMPLATE.md` when it is *started*.
