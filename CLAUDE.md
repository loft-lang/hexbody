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
  and record the fork where it belongs (`ROUNDTRIP.md` §11.1 is the pattern) rather than
  stalling on it or quietly picking one.
- **loft is upstream and consumer-only** — hexbody never fixes loft. Toolchain defects go to
  crawler's `LOFT-HANDOFF.md` / `FILING.md`, never into a hexbody plan. The
  `stores not freed at program exit` warning on every run is one of these: known, loft-side.
- **Commit and push only when asked.** Commit messages end with the org `Co-Authored-By` trailer.

## The doc hierarchy — build from the formal files, not the prose

| file | role | authority |
|---|---|---|
| **`ROUNDTRIP.md`** | the **formal model**: objects (`𝕄*`, `𝕋`, `𝔽`, `P`, `O`, `H₁₂`, `D`), maps (`snap`, `write`/`read`, `draw`/`rebuild`), **laws A–K₂** | **authoritative** on any object, map, or law |
| **`SPEC.md`** | goals **G**, limits **L**, invariants **I**, contracts **K** — short, falsifiable, each with a control | authoritative on *what must be achieved* |
| `VISION` · `ARCHITECTURE` · `design/*` | *why* — reference only | **never the build input** |
| `PLAN.md` | milestone through-line (P, M0–M7); the synthesis layer, not a plan index | — |
| `plans/README.md` | plan conventions, lightest-workflow table, value categories | — |

**Build and verify against `ROUNDTRIP` + `SPEC`.** If building needs a fact, it belongs there as
a checkable item — not in a paragraph. A gate defending no spec item, or a spec item no gate
defends, is the thing to fix.

## Run

```sh
make test    # the headless gate — housetest, 12 orientations
make shot    # contact sheet -> /tmp/house12.png
```

Needs `../loft` and `../loft-libs-world` as siblings. **`--lib` reads the WORKING TREE**, so
check that `loft-libs-world` is on branch `dev` before debugging anything strange.

## State (2026-07-23)

- **Green:** `G0` / law **I** — `housetest`, 12/12 equivariant in cells *and* edges, `eave_spread
  0.0000`, every control fires. `make shot` reproduces the committed baseline byte-identically.
- **Everything else is open.** No `body.loft`, no `proxy.loft`, no `rebuild`. Of the round-trip
  gates only `rt_orient` exists.
- **Two open decisions** (`ROUNDTRIP.md` §11.1) block freezing the grammar: **OD-1** the morph
  (`design/EDITOR.md` §2 vs free poses) and **OD-2** roofs (`hexroof.loft:493` `roof_match` takes
  a `tol: float`, which law **P4** forbids).
- **Two unmeasured constants:** `ε_seam` and the `κ≥3` contention rate (`ROUNDTRIP.md` §8).
- `hexedge` / `hexway` / `hexroof` are byte-identical copies of crawler's. No drift yet; their
  proper home is `loft-libs-world`.

## The traps that bite

- **"Fit" is the wrong word and the wrong instinct.** This is an exact-invariant domain: the
  construction already exists and must be **recovered**, not approximated. An `ε` in a round-trip
  comparison is a defect signal, never a tuning knob (law **P4**).
- **Imprecision is allowed only on the seam between frames** (law **K₁**) — never inside one.
  Closing a crack by moving geometry is the forbidden fix.
- **Jank is not licence for nondeterminism.** `L7`/`I9` need byte-identical replay, so seam error
  and arbitration must be deterministic functions of their inputs.
- **Every gate carries a control that must fire.** A check that cannot go red is not a check.
