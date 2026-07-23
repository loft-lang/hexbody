# EDITOR — authoring by intent, orientation by morph, and the transparent side-by-side

**hexbody design.** How a developer authors and orients a building, and the editor that makes
the engine's work *visible* without ever making the developer responsible for it. This is the
mantra's delivery mechanism ([`../VISION.md`](../VISION.md)): the guts are engineered and
sealed, and the editor **shows the outcome so the developer trusts it** — not the machinery so
they have to run it.

The one principle everything here serves:

> **Seal the mechanism, expose the outcome.** The developer manipulates *intent* (point, click
> a door), sees *outcome* (the house standing in every orientation it will ship in), and never
> touches *mechanism* (the lattice, the `(side, t)`, the morph, the two-direction edge strip).

This is not a breach of *"customers never worry about the storage layers"* — it is how you keep
that promise honestly. **Worry ≠ see.** You show the developer their house is right in every
orientation *without* making them get the storage right. That is the strongest trust you can
give, and no other engine's editor gives it (§6).

---

## 1. Placement — direct manipulation is the interface, parametric is the storage

The two approaches are not rivals; they are two layers of the same thing.

- **Interface: direct, in-engine.** The developer moves the mouse over a wall and the editor
  **shows the valid placements live under the cursor** — where a door could land, at what
  width — and they click. No coordinates, no `t`, no edge indices. This *is* the mantra at the
  input.
- **Storage: parametric `(side, t)`.** The click resolves to the `(side, t)` anchor from
  [`FEATURES.md`](FEATURES.md) and is stored there. This is **non-negotiable**: parametric
  storage is what makes orientation, the morph, and the side-by-side view all work *by
  construction*. Storing the raw result (which edges opened) would make every reorientation an
  edge-remapping problem and break equivariance.

Point and click (interface); store `(side, t)` (storage); the developer sees neither.

---

## 2. Orientation — the morph, never the mirror

A building is authored **once**, in one form, one chirality, every detail. It is never
mirrored. Orientation — including any "flipped" placement — is achieved by keeping that one
building and **morphing it minimally to fit the lattice at the target angle.**

- **Semantically invariant** — topology, layout, features, handedness, every detail: identical.
  It is the *same* building.
- **Metrically morphed, minimally** — a small affine deformation of the two axes (u, v) snaps
  the footprint to exact lattice cells and the walls to their two available edge directions.

**Why the morph, and why it is a win rather than a hack:** the bare lattice offers 6 exact
rotations and nothing between. A minimal two-axis morph is the **bridge from 6 exact
orientations to many** — the snapped result stays *lattice-exact*, so every exact-lattice
benefit survives (proxies, destruction, feature correctness), and you pay only a small
deformation for orientation freedom. Placing off-lattice at a true continuous angle would
instead *lose* exactness. The morph keeps it.

**And it deletes the mirror's whole problem.** A true mirror flips chirality, which mirrors the
*assets* — backwards text, hinges on the wrong side, reversed asymmetric props — a residual
that is perceptually bad and unfixable without mirrored variants. Never mirroring means none of
that exists. The building is always itself.

The honest costs, stated so they are not discovered in a frame:

- **The morph is bounded.** Zero morph at the 6 exact rotations (snap, don't morph); the
  morph is largest ~30° off an exact one. **Gate the max deformation there in real % terms;**
  beyond the tolerance, don't offer that angle, or accept a visible stretch. That bound is a
  parameter to *measure*, not guess.
- **True mirror is given up.** Genuine mirror-symmetric pairs (a formal matched plaza) are not
  reachable by rotate-and-morph. For "a building facing the other way," rotate+morph suffices;
  only deliberate chirality is lost — and that is the right thing to trade for no handedness
  residual.
- **It is a new algorithm** — the minimal affine best-fit of the building onto the lattice at
  a target orientation (least deformation subject to exact placement).
- **A subtlety:** a general two-axis morph turns a *circular* arc into an ellipse. Straight
  walls do not care (affine maps lines to lines); curved architecture needs the morph
  constrained to a similarity, or the fit taught to accept ellipses.

---

## 3. Why the side-by-side is free — the parametric foundation

This is the payoff of `(side, t)` cashing in. **A feature is a ratio, and a ratio survives an
affine morph exactly:** a door at `t = 0.5` is at `t = 0.5` on the morphed wall, correct width,
correct position. So a feature added to the canonical building appears — correctly placed — in
**every** morphed variant *for free*, always in sync, because the variants are **derived, never
authored.**

You author once. There is only one building. Every other view is a *view of it*, so they cannot
drift — there is nothing to keep in sync, because there is nothing else to keep.

---

## 4. The editor — two (or N) buildings side by side, single-authored

You edit the canonical building; every edit re-renders live in all morphed variants beside it.
Add a door to the left; it appears, morphed to fit, in each one on the right, the instant you
place it.

**It is the live verification instrument.** This is exactly `houseshot`'s 12-orientation
contact sheet — the sheet this project already renders — plus `housetest`'s equivariance gate,
turned *interactive* and *single-authored*. The developer watches the invariant hold on every
edit, instead of running a gate after the fact.

**The residual becomes a visible punch-list.** Where the morph cannot be perfect — its slight
stretch, or an asymmetric asset whose handedness reads oddly at some orientation — it shows up
*side by side*, a small, correctable list on the right, not a hidden defect that surfaces in the
shipped game. The "not totally possible" of the orientation model stops being an apology and
becomes two or three things the developer fixes by eye.

**Extend it past two:** show the strip of orientations the building will *actually* appear in on
its sites — a live, editable contact sheet. Author once, watch every placement update as you
work, catch any that break the moment they break.

---

## 5. What this makes true

This shows you your building in *every orientation it will ship in*, morphed to fit, residual
flagged, **from one authoring pass** — **author once, ship any orientation, trust it**, the
indie-ship path made concrete on screen, and part of the gold. It is possible because the
geometry is derived from structured field data, so the variants are computable and the collision
follows for free; where all you have is an opaque mesh, each orientation is authored and its
collision re-fitted by hand.

It is also the concrete form of the whole promise: the developer manipulates intent, sees
outcome, never touches mechanism — and *sees*, live, that the sealed engine got it right.

---

## 6. Honest placement and gates

This is the **end** of the pipeline, not the first brick. It needs the morph, the parametric
model, and live re-derivation all working, so the order is `bodytest` → proxy → features →
morph → **this**. It is the right north-star for the editor, and everything the
`(side, t)`-plus-morph design reaches for lands here.

The gates it rides on:

| gate | control |
|---|---|
| **equivariance is live** — a feature added to the canonical is the morphed preimage in every variant, every edit | select edges by strip order, not surface-projection → the variant is not the interval's preimage (FEATURES §6) |
| **morph is bounded** — max deformation at the worst orientation ≤ the tolerance, stated in % | an orientation 30° off an exact one whose morph exceeds tolerance must be refused or flagged, not silently stretched |
| **derived, never authored** — editing a variant directly is impossible; only the canonical is editable | expose a variant as editable → two sources of truth, drift returns |
| **residual is shown, not hidden** — every handedness/deformation clash appears in the side-by-side | an asymmetric asset that reads wrong at some orientation must surface in the editor, not only in the shipped frame |
