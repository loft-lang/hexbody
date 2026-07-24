# `m1-moving-body` — the first brick of the body half

**Issue:** [`PLAN.md`](../../PLAN.md) M1 *(pre-tracker; renumber to a `loft-lang/hexbody` issue
when one exists)* · **Value:** `F` · **Effort:** `MH`

## Status

**The first brick is in.** `src/hexjoint.loft` (`G1`): a pose is a **pure function of joint values**
(`I6`), a wheel's angle is `travel/radius`, and a joint value refuses-with-an-offer at its limits.
`tests/joint.loft` — red since morning by design — is **green** (gate 23 of 24). `G3`/`G4`/`G6`
remain unstarted.

| | |
|---|---|
| **done** | [`../../tests/joint.loft`](../../tests/joint.loft) ✅ — pose purity by two paths (byte-identical), the rolling identity (machine-ε), the joint doorstep. `src/hexjoint.loft` |
| **decided** | a body is a **rig** (`⟨bones, joint limits⟩`, never a pose) · **flex is joints**, not deformation · the game's state is not the world's (`L15`) · **now** is the only tense |
| **found by building** | the roll is **not bit-exact** — `travel → value → travel` is a float round-trip, so skid is machine-ε (the body's `ε_seam`), not the algebraic 0 the plan first claimed. Phase C, corrected |
| **next** | the **proxy** (phase D) — the last of the four phases; then `G1` ships as a `hex_*` library |

**This plan exists because the in-flight tier had no file.** `m0-roundtrip/DESIGN.md` held M0's
open decisions and M0 is closed, so the body's decisions were landing in `SPEC` rows and in
`ASSESSMENT.md` — the formal and synthesis tiers — which is how `SPEC`'s **L15** reached 3 KB while
`SPEC`'s own preamble asks for items that are *short, falsifiable, each with a control*.
[`DESIGN.md`](DESIGN.md) is now that file; `SPEC` states the limit and points here for the why.

## Goal

`bodytest` green: a `Body` with one revolute joint moves by **derived** motion and carries an
**error-bounded proxy**, across all 12 orientations.

## Anchors

- **[`../../SPEC.md`](../../SPEC.md)** — advances **`G1`**; must preserve **`I6`** (pose is a pure
  function of joint values), **`I4`** (proxy ⊇ shape, overshoot ≤ ε), **`I-POSE`** (a body is
  `⟨original, pose, joints⟩` and is never stamped into the world field); must not cross **`L1`**
  (derive the consequence, never simulate the impulse), **`L5`** (the compute boundary), **`L15`**
  (the game's state is not the world's, and *now* is the only tense).
- **[`../../ROUNDTRIP.md`](../../ROUNDTRIP.md)** — `X53` already measured the frame seam a posed
  body meets the world across: `ε_seam ≈ 7.1e-15`, the pose transform is the **sole float step**.
- **`../crawler`** — `bodytest`, and `hexpart`'s *"two levels, no more: an anchor, and parts in the
  anchor's frame"* (`X17`, still **T3**). **Read it before designing; re-measure before trusting.**
- [`DESIGN.md`](DESIGN.md) — the in-flight half: the decisions, their consequences, the open fork.

## Blueprint gate (exact-invariant — a pose is exact in its own frame)

- **Concrete end-result:** a wheel of radius `r` rolled a distance `d` is at angle `d/r`, and the
  contact point does not slip — `skid = |r·θ − d| = 0` exactly, no tolerance.
- **Invariant:** `I6` — the pose is a **pure function of current joint values**. Under `L15` this
  is not a testability nicety, it **is** the scope boundary: a pose that depends on anything but
  the joints now has smuggled in a future state.
- **Control:** the spec's own — drive `θ` and `d` independently and require `skid > 0`; and an
  accumulating implementation (`pose += delta`) must fail the two-path purity check.
- **Medium:** the real gate. [`../../tests/joint.loft`](../../tests/joint.loft) — ✅ **green now**:
  it was written red (`run_red`) before its subject, its tripwire fired the moment `src/hexjoint.loft`
  landed, and its §1/§2 became real checks. Promoted from `run_red` into the runner's table (gate
  23 of 24). `src/hexjoint.loft` is the workshop form; it ships as a `hex_*` library once `G1` is
  complete, the way the geometry did.

## Phases

| Phase | Effort | Verify | Status |
|---|---|---|---|
| **A** — the rig: `⟨bones, joint limits⟩`, its canonical text, its doorstep | M | `write(read(R)) = R` byte-for-byte; a joint value outside its limit is refused **with an offer** (`K-FIT`, and a joint value is *ordinal* so an offer is owed) | ✅ **DONE** — `Rig` = a tree of bones (parent, offset, length, joint limits); `rig_write`/`rig_read` round-trip **byte-for-byte incl. floats** (loft's float↔text is exact), a malformed text is **refused** not repaired, and `rig_admissible` is the whole-rig doorstep (topological + ordered limits). The joint doorstep half (`joint_fits`/`offer`/`residual`) was done in phase C's commit. `tests/joint.loft` §3–§4 |
| **B** — forward kinematics: pose from joints | M | `tests/joint.loft` §1 — purity by two paths; control: an accumulating pose fails | ✅ **DONE** — `pose_of` is a pure function; two paths to a value give a **byte-identical** pose, an accumulator differs (`src/hexjoint.loft`) |
| **C** — rolling: wheel angle `= travel/radius` | S | `tests/joint.loft` §2 — skid bounded; control: spin off-travel → `skid > 0` | ✅ **DONE** — ⚠ **and it corrected the spec**: skid is **machine-ε, not exactly 0** — the roll is a float round-trip (`travel → value → travel`), so it is the body's **sole float step** (the wheel's `ε_seam`, `I-FSEAM`/`X53`), not a `P4`-exact integer quantity. Worst 1 ulp of travel; control skids by whole units |
| **D** — the proxy: `proxy ⊇ footprint`, overshoot ≤ ε, 12 orientations | M | `I4`'s control: shrink the proxy below the footprint → a real overlap is missed | not started |

Phase A is the one that inherits M0 wholesale: a rig is a **description**, the same kind of object
as a stencil's `Form`, so it gets a canonical text, a census if the space needs deciding, and a
doorstep. Phases B–D are the genuinely new work.

## Risks

- **⚠ The reflex to reach for skinning.** A flexing wing is **more bones**, not a soft bone
  ([`DESIGN.md`](DESIGN.md) §2). Vertex deformation would break `I6` and is not needed.
- **⚠ The reflex to build "the vehicle abstraction".** `L15` rejects it outright — the same
  geometry is a train, a robot, an aeroplane or a dock, and no honest abstraction spans them.
  `tests/scope.loft` enforces the naming half on `src/`.
- **M0's method does not transfer unmodified.** Every M0 gate compares committed bytes; a moving
  part has no corpus. What transfers is the *shape* of the claim — see [`DESIGN.md`](DESIGN.md) §1.

## See also

[`DESIGN.md`](DESIGN.md) *(the in-flight half)* · [`../../SPEC.md`](../../SPEC.md) ·
[`../../ROUNDTRIP.md`](../../ROUNDTRIP.md) *(settled core)* · [`../../PLAN.md`](../../PLAN.md) M1 ·
[`../m0-roundtrip/`](../m0-roundtrip/) *(closed — the method this inherits)*
