#!/usr/bin/env bash
# The headless gate. `make test` delegates here — one table row per gate, same shape as
# crawler's tools/run_tests.sh so the convention reads the same across the org.
#
# Every gate is a loft program that prints a single "<NAME> OK" line and nothing else on
# success. The marker is grepped, not the exit code: a loft program that fails a check
# still exits 0, so the marker IS the pass/fail signal.
#
# Args: $1 = loft binary   $2 = loft flags (word-split: --path/--lib …)
set -u
trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }
LOFT="$(trim "${1:?loft binary required}")"
FLAGS="${2-}"

# run <src-file> <ok-marker> <log> <fail-text> <label>
run() {
  echo "  $5"
  # shellcheck disable=SC2086  # FLAGS must word-split into --path/--lib
  "$LOFT" --interpret $FLAGS "$1" | tee "$3"
  grep -q "$2" "$3" || { echo "    FAIL: $4"; exit 1; }
}

# run_red <src-file> <red-marker> <ok-marker> <log> <label>
#
# A gate written BEFORE its subject exists (DESIGN.md 8.0: `rt_trip` is written before `rebuild`).
# It must be RED — and red for the STATED reason, not because it crashed — until the step that
# turns it green. Asserting the redness means the gate still RUNS every time (it cannot rot), and
# if it ever goes green by accident the runner FAILS and demands the row be promoted to the table.
run_red() {
  echo "  $5"
  # shellcheck disable=SC2086
  "$LOFT" --interpret $FLAGS "$1" | tee "$4"
  if grep -q "$3" "$4"; then
    echo "    FAIL: this gate is GREEN — move its row from run_red into the table"; exit 1
  fi
  grep -q "$2" "$4" || { echo "    FAIL: red for the WRONG reason (expected: $2)"; exit 1; }
  echo "    RED, as expected — $2"
}

# table <<EOF — file|marker|log|fail-text|label  (order = execution order)
table() {
  while IFS='|' read -r file marker log fail label; do
    [ -n "$file" ] || continue
    run "$file" "$marker" "$log" "$fail" "$label"
  done
}

# tests/foxel.loft writes HXF documents to /tmp. `doc_write` APPENDS (the gate's section 0 gates
# exactly this), so a file left by a previous run would be read INSTEAD of the one just written.
# Clearing them here keeps that hazard confined to the section that measures it.
rm -f /tmp/hexbody-foxel-*.hxf

table <<'EOF'
tests/form.loft|FORM OK|/tmp/hexbody_form.log|headings|[1/21] the 12 headings, the exact rotation and reflection (S0/S1) ...
tests/wall.loft|WALL OK|/tmp/hexbody_wall.log|walls|[2/21] the 24-direction wall: edge table, foxel write, mesh evaluation ...
tests/box.loft|BOX OK|/tmp/hexbody_box.log|boxes|[3/21] the box in 12 directions, thin wall and thick wall ...
tests/census.loft|CENSUS OK|/tmp/hexbody_census.log|census|[4/21] the census, grown by level: law F decided at levels 1-3 ...
tests/text.loft|TEXT OK|/tmp/hexbody_text.log|text|[5/21] the canonical text: write(read(T)) = T byte-for-byte ...
tests/house.loft|HOUSE OK|/tmp/hexbody_house.log|house|[6/21] floor/walls/openings/roof at all 12 orientations ...
tests/surface.loft|SURFACE OK|/tmp/hexbody_surface.log|wall surface|[7/21] the wall surface by averaging: exact direction, exact bands ...
tests/arc.loft|ARC OK|/tmp/hexbody_arc.log|arcs|[8/21] the round tower + the doored tower: centre exact, radius a shell, a door is one arc ...
tests/combine.loft|COMBINE OK|/tmp/hexbody_combine.log|combine|[9/21] two stencils adjacent: union-then-cut is order-free, the shared edge fuses (A8) ...
tests/seam.loft|SEAM OK|/tmp/hexbody_seam.log|frame seam|[10/21] the frame seam: ε_seam is machine-ε and confined, κ counted, arbitration order-free (K1/K2) ...
tests/arb.loft|ARB OK|/tmp/hexbody_arb.log|nearest surface|[11/21] cut_arb: each boundary edge → its nearest analytic surface, order-free, ties to lower id (A8) ...
tests/line.loft|LINE OK|/tmp/hexbody_line.log|linework|[12/21] stencil against linework: the cut spans domains A/B, a world line recovers eave_spread 0 (A8) ...
tests/level.loft|LEVEL OK|/tmp/hexbody_level.log|levels|[13/21] the bridge guarantee: different levels never fuse, arbitrate or contend (A8) ...
tests/terrain.loft|TERRAIN OK|/tmp/hexbody_terrain.log|terrain|[14/21] seating on terrain: the height slot is orthogonal, the residual is flagged (A8, OD-4) ...
tests/embed.loft|EMBED OK|/tmp/hexbody_embed.log|embedded linework|[15/21] OD-13: a stencil carrying an in-between wall — footprint and rebuild untouched ...
tests/censusb.loft|CENSUSB OK|/tmp/hexbody_censusb.log|domain-B census|[16/21] rt_census_b: the period cost table over D — 3 classes, 3 axes, and delta decides linking ...
tests/flip.loft|FLIP OK|/tmp/hexbody_flip.log|orientations|[17/21] linework under the 12 orientations: the segment mirror rule, in-between included (law G) ...
tests/fit.loft|FIT OK|/tmp/hexbody_fit.log|doorstep|[18/21] the doorstep for features, arcs, levels and terrain: accepts exactly what recovers (K-FIT) ...
tests/palette.loft|PALETTE OK|/tmp/hexbody_palette.log|palette|[19/21] the palette seam: moros's schema checked every run, and an opening is never 'no wall' ...
tests/foxel.loft|FOXEL OK|/tmp/hexbody_foxel.log|foxel storage|[20/21] the foxel as a STORAGE format: all six slots cross, X15's lossy path is the control ...
tests/trip.loft|TRIP OK|/tmp/hexbody_trip.log|round trip|[21/21] rt_trip: write(rebuild(draw(read(T)))) == T over corpus a1+a2+a3, 119 entries ...
EOF

echo "  PASS"
