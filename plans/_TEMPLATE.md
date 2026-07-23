# Plan template

Copy this file to `plans/<id>-<slug>/README.md`. The `<id>` is the **`loft-lang/hexbody` issue
number** — claimed *before* the directory exists — or, until hexbody has a tracker, the
**`PLAN.md` milestone slug** (see [`README.md`](README.md) § Identity). Delete the guidance
blocks (marked *(delete)*) as you fill it in. Closing or deferring: [`_LIFECYCLE.md`](_LIFECYCLE.md).

**Before you copy — is this actually a plan?** If it fits in one row of a reference doc's
`## Open work` table with one sentence of design, it isn't. Add the row instead. If the first
phase is *characterize the problem* rather than *design + build*, use
[`_INVESTIGATION_TEMPLATE.md`](_INVESTIGATION_TEMPLATE.md).

---

# `<id>` — `<Plan title>`

**Issue:** `loft-lang/hexbody#<N>` *(or: PLAN.md milestone `<M?>`, pre-tracker)* ·
**Value:** `<S|R|G|F|U|C|Q|N>` · **Effort:** `<XS|S|M|MH|H|VH>`

## Status (REQUIRED)

*(delete)* The **single source of truth** for what is shipped / open / deferred / blocked. One
paragraph: the state of the world today and what this plan changes.

## Goal (REQUIRED)

*(delete)* One sentence — what ships when this plan is complete. No strategy or advertising.

## Anchors (REQUIRED)

*(delete)* The reference docs this plan implements or extends (`VISION.md`, `ARCHITECTURE.md`,
`design/*`) and the source files it touches. A plan never restates its anchors — it links.

## Blueprint gate (REQUIRED for exact-invariant work)

*(delete)* Geometry, caching, serialization, store-lifetime, protocols and round-trips are
**exact invariants, not open spaces** — `../crawler/DESIGN-PROTOCOL.md` applies and the
cheap-medium prototype comes BEFORE the loft code. State per phase: the **concrete plotted
end-result** (the exact target output for one specific input), the **invariant** it pins
(collision → *interaction iff swept volumes cross*), and the medium (a throwaway prototype, a
headless dump, a round-trip test). But if the primitives already exist in the tree, the cheapest
medium is the engine itself — write the real gate, not a model of it.

**Cite the `../../SPEC.md` items this phase touches** — the invariants (`I*`) it must preserve,
the limits (`L*`) it must not cross, the goal (`G*`) it advances. Each gate should defend a named
spec item; a gate defending none, or a spec item no gate defends, is the thing to fix.

Say so in one line if a phase has no exact-invariant surface. Silence reads as "gate done", not
"gate N/A".

## Phases (REQUIRED if multi-phase)

*(delete)* One row per phase. **Verify** is how you see it works — name the gate: `make test`
(a `src/<x>test.loft` case), `make shot` (a rendered PNG to eyeball), or a blueprint plot.

| Phase | Effort | Verify | Status |
|---|---|---|---|
| **A** — short title | S | `make test` / `<x>test.loft` | Open |
| **B** — short title | M | `make shot` / a rendered frame | Blocked on A |

Every gate carries a **control that must fire** (STATE lesson: a check that can't go red proves
nothing) — state it beside the gate.

## Order + risks (OPTIONAL)

*(delete)* The dependency order, and the known traps — loft idioms to avoid (crawler's
`LOFT-NOTES.md` survival guide), the library/consumer seam rules, anything gated on an upstream
loft fix (crawler's `LOFT-HANDOFF.md`; never block hexbody on it).

## Open design questions (OPTIONAL)

*(delete)* Numbered. Each resolution becomes a decision recorded in the anchor doc or absorbed
into this plan's design.

## See also (REQUIRED)

*(delete)* Reference docs this implements · sibling plans that block or cooperate · the tracker
issue (or `PLAN.md` milestone).

---

## Authoring notes *(delete this whole section)*

- **Length budget 100–300 lines.** Longer means reference content is leaking in — move it to the
  doc that owns it (`design/*`).
- **`README.md` is required**; add sub-files only for distinct concerns, one concern each.
- **Validation images** (contact sheets, before/after, `make shot` frames) go in a `shots/`
  subdirectory, committed for human review — *not* golden images ([`README.md`](README.md)
  § Validation images).
- **Never calendar time** — effort letters only.
- **The library/consumer seam is re-checked** if the plan touches the boundary between hexbody
  and the shared lib or a consumer.
- **Upstream (loft) defects never become hexbody plans** — crawler's `LOFT-HANDOFF.md` + `FILING.md`.
- **On opening:** claim the issue (or take the `PLAN.md` milestone) → label `plan` +
  `status:*` + `val:*` → create the directory → fill Status + Goal first.
