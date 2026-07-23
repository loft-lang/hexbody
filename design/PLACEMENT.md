# PLACEMENT — seating a stencil on uneven terrain: the best height, and morphing the hill

**hexbody design.** The **second morph.** [`EDITOR.md`](EDITOR.md) §2 morphs the *building* to
fit the lattice at an angle; this morphs the *terrain* to seat the building on uneven ground.
It is the **common case** — every outdoor building on a non-flat plot needs it, where the
tiltable-interior frontier is exotic — and it is sealed: **drop a house on a hill and it seats
itself.** The developer never computes cut-and-fill.

One placement produces two coupled outputs: **the best height** `z0` the stencil sits at, and
the **morphed terrain** `T'` that meets it.

Design-protocol order: the concrete target first, then the invariants, then the honest hard
parts and the seam, then gates with controls. The numbers in §0 are the *predicted* target —
there is no seating code yet, so they are the shape to pin with a probe, not measurements
(unlike `FEATURES.md`, whose numbers came from `tests/house.loft`).

---

## 0. The concrete target (the shape to pin, not yet measured)

The 5 × 4 house (27-cell footprint, 7.5 m × 6.0 m, flat floor) placed on a hillside that rises
**2.0 m linearly across its 6.0 m depth** — a ~33 % grade, a real slope.

- **Best height** `z0 = 1.0 m` (the floor sits 1.0 m up). For a symmetric ramp the two objectives
  below coincide here; on skewed terrain they diverge.
- **Earthwork:** the uphill cells are **cut** (down to 1.0 m), the downhill cells **filled** (up
  to 1.0 m), a max of **±1.0 m** at the two ends, tapering to 0 at the centre line.
- **The skirt:** a graded apron ring around the footprint blends `z0` back to the untouched
  hillside — an embankment on the fill side (at the soil's angle of repose), a shorter cut face
  uphill.
- **The result drains** (no trapped basin at the wall foot) and its **proxy re-derives**, so you
  can walk up the skirt onto the floor.

The house reads as *seated into the hill* — not floating on stilts, not buried to the windows.

---

## 1. The two invariants

> **A. Best height.** `z0` is the exact minimiser of the chosen earthwork objective over the
> footprint — not a fitted guess. The answer already exists; recover it.
>
> **B. Compliance.** The morphed terrain `T'` equals `z0 + floor_i` on the footprint, blends
> monotonically back to the original terrain over a skirt whose grade never exceeds the angle of
> repose (or becomes a retaining wall), **drains**, and leaves a walkable proxy.

---

## 2. Part A — the best height is an exact solve

The floor has a profile `floor_i` (0 for a flat floor, non-zero for split levels); the terrain
under footprint cell `i` is `T_i`; the earthwork at that cell is `|z0 + floor_i − T_i|`. Then:

- **Minimise total cut-and-fill (least dirt moved, L1):** `z0 = median{ T_i − floor_i }`.
- **Minimise the worst single cut or fill (flattest transition, L∞):** `z0 = midrange =
  (max + min)/2` of `{ T_i − floor_i }`.

These **diverge on skewed terrain**, and choosing between them is a real design decision, not a
detail: the median moves the least earth (cheapest); the midrange caps the worst embankment and
excavation (no one giant cut or fill). A building usually wants the midrange or a blend — you do
not want a 3 m embankment on one corner just because the median said so.

**Cut and fill are not symmetric, and that weights the solve.** Fill needs an embankment built
at the angle of repose (more material, more skirt); cut is a more stable face and can be
steeper. If fill is the costlier side, bias `z0` **down** — more cut, less fill — i.e. a
*weighted* median. So the objective carries a cut/fill weight, and it is honest to expose it
rather than hard-code symmetric earthwork.

---

## 3. Part B — morphing the hill into compliance

Given `z0`, deform the terrain `Heights` field:

1. **Flatten the footprint** — set `T'_i = z0 + floor_i` for every footprint cell.
2. **Grade a skirt** — over a ring outside the footprint, blend monotonically from `z0 + floor_i`
   at the wall back to the original `T` at the ring's outer edge. The skirt is the foundation /
   embankment / cut face.
3. **Bound the skirt grade** — a *fill* skirt slumps if steeper than the terrain's **angle of
   repose**, which crawler already models (`talus`, the angle-of-repose talus system). So the
   skirt width is `rise / tan(repose)` on the fill side; steeper than that needs a **retaining
   wall** — a structural object, not a graded slope. A *cut* face can be steeper.

Two invariants the morph must hold:

- **It drains.** A flattened floor with a raised skirt can trap a basin at the wall foot. This
  is the dual of the roof's ponding check — reuse `hexroof::roof_ponds`'s spirit on the morphed
  terrain: `roof_ponds(T') == 0` over the seated region.
- **The proxy re-derives.** After the morph, the terrain proxy is recomputed from `T'`, so the
  skirt is walkable — you can climb the embankment onto the floor, and collision follows the new
  ground for free.

**Reversibility:** the morph is applied to the world's `Heights`, so removing the building later
needs the original terrain patch stored to restore it — the same reconciliation destruction
needs when it mutates the field.

---

## 3b. Special case — cellars: a storey designed below grade

A cellar is not a seating *failure* to correct; it is a storey **designed** to sit below the
surface. The model already carries it — a storey is `{floor, soffit}` (HOUSE.md), so a cellar is
just a storey whose floor and soffit are **below `z0`** — and it is *not hard to model*, because
for the cellar the seating does the opposite of the normal case:

- **The terrain is not morphed up to the cellar floor.** The above-grade storeys seat normally
  (floor at `z0`, terrain graded to meet it); the cellar is placed *below* `z0`, and the morphed
  surface flows **over** it. The cellar interior is an excavated void beneath the ground.
- **A below-grade wall is a retaining wall** — it holds back the hill, the same object the skirt
  reaches for when a fill exceeds the angle of repose (§3). The cellar wall's structure is
  already in the vocabulary; it is a retaining wall by role.
- **Drainage matters doubly.** Below grade is where water collects, so the ponding gate
  (`roof_ponds` dual) applies to the cellar floor with teeth: a cellar that does not drain
  floods. Not a new mechanism — the same drainage invariant, at the depth where it bites hardest.

**The real work is presentation, not modelling.** A below-grade cellar is *hidden under the
hill*, so the editor must **expose** it — a cutaway, ghosted terrain, or a below-grade view mode
— or the developer cannot author what they cannot see. This is the transparency principle again
([`EDITOR.md`](EDITOR.md): *expose the outcome*), extended downward: the seating already knows
where the cellar sits; the editor's job is to let the developer look under the ground, edit it,
and watch the terrain close back over it.

---

## 4. The honest hard parts

- **Flatten vs terrace.** A single `z0` + flatten is the common case and the core of this
  design. A building that **steps down a steep slope** — a terraced foundation following the
  grade, split floor levels — is the *extension*: multiple seated heights joined by internal
  steps, not one `z0`. Reach for it when the single-height earthwork exceeds tolerance.
- **The residual: too steep to seat.** Past some grade, no single height seats cleanly — the
  earthwork or the embankment blows the budget. That plot is **flagged, not silently botched**
  (it surfaces in the editor as a punch-list item, §6), and the fix is terrace, retaining wall,
  or "don't build here" — the world's call, not a silent stretch.
- **Cut/fill weighting** (§2) is a tuning surface, not a fixed rule.

---

## 5. The seam — the world owns placement, hexbody owns seating

Crawler's `overland` **owns settlement placement** (STATE decision 7: *"we integrate with it;
we never rewrite it"*). So the boundary runs one way:

- **The world** decides *where* a building goes and hands over the terrain patch under it.
- **hexbody** owns the **seating mechanism**: given a stencil (footprint + floor profile) and a
  terrain patch, return `(z0, T')` — the best height and the morphed terrain — plus the residual
  flag when it cannot seat cleanly.

No settlement logic in hexbody, no terrain generation; just the exact seating of a given stencil
onto given ground. That keeps it reusable (any consumer with a stencil and a heightfield) and
respects the seam.

---

## 6. The mantra, and the editor

Seating is **sealed**: the developer drops a building on a hill and it seats itself — best
height, morphed terrain, graded skirt — without ever seeing cut-and-fill. And it rides the
**same side-by-side editor** as the orientation morph ([`EDITOR.md`](EDITOR.md)): the building
shows *seated on the actual terrain* live, and the residual — a slope too steep to seat cleanly
— appears as a flagged, correctable item, not a defect discovered in the shipped frame. Two
morphs, one transparent editor: *seal the mechanism, expose the outcome.*

---

## 7. Gates — each with a control that must fire

| gate | control |
|---|---|
| **best height is the minimiser** — `z0` minimises the chosen objective over the footprint | perturb `z0` by ε → the earthwork total (or worst gap) increases |
| **the seated terrain drains** — `roof_ponds(T') == 0` over the region | seat on a bowl-shaped patch without a drain channel → a basin forms at the wall foot |
| **a cellar drains and is presented** — a below-grade storey does not flood, and the editor exposes it | a cellar with no drain path ponds; or the editor hides it under the terrain so it cannot be authored |
| **the skirt respects repose** — no fill skirt steeper than the angle of repose | grade a 2 m fill over a 1 m skirt → the slope exceeds repose and must convert to a retaining wall, or the gate fires |
| **the proxy is walkable** — the skirt proxy connects the hillside to the floor | drop the proxy re-derive after the morph → the embankment is a wall you cannot climb |
| **earthwork reported in metres** — cut and fill volumes stated, cut/fill weight honoured | hard-code symmetric earthwork → a costlier-fill plot picks the wrong `z0` |
| **too-steep is flagged, not botched** — a plot past tolerance raises the residual | feed a 45° slope → it must flag "cannot seat: terrace or retaining wall," not emit a 3 m embankment silently |
| **features survive seating** — a door's `(side, t)` and clear width are unchanged by the seat | seating alters the wall's `(side, t)` → the door moves off its opening |

---

## 8. What exists, and the gaps this closes

**Exists:** `Heights` (hex_field); the ponding and level-surface patterns (`hexroof::roof_ponds`,
`eave_spread`); the **angle-of-repose talus** system (crawler `talus`) for the embankment grade;
the stencil model (hex_field `Stencil`).

**Gaps this design names:**
1. **The best-height solve** — the weighted median/midrange over the footprint, with the cut/fill
   weight exposed.
2. **The skirt morph** — flatten + graded blend, repose-bounded, draining, proxy re-deriving.
3. **The seam function** — `seat(stencil, terrain) -> (z0, T', residual)`, the one entry point the
   world calls.
4. **The terrace extension** — multi-height seating on steep grade (deferred; single-height first).

## 9. Order

| | | depends on |
|---|---|---|
| **P1** | `best_height(footprint, floor, terrain, cut_fill_weight)` — the exact solve | `Heights` |
| **P2** | the skirt morph — flatten + repose-bounded graded blend | P1, `talus` |
| **P3** | drainage + proxy gates on `T'` | P2, `roof_ponds`, the proxy |
| **P4** | `seat(...)` — the seam entry point + the residual flag | P1–P3 |
| **P5** | the editor shows the building seated on live terrain (§6) | P4, the editor |
| **P6** | the terrace extension — multi-height seating | P4 |

P1 is a one-line solve; the work is P2 (the repose-bounded skirt) and P3 (drainage). This is the
common-case placement path — earlier on the critical path than the tiltable-interior frontier,
and needed the moment a building meets a slope.
