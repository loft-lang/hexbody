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

table <<'EOF'
tests/form.loft|FORM OK|/tmp/hexbody_form.log|headings|[1/9] the 12 headings, the exact rotation and reflection (S0/S1) ...
tests/wall.loft|WALL OK|/tmp/hexbody_wall.log|walls|[2/9] the 24-direction wall: edge table, foxel write, mesh evaluation ...
tests/box.loft|BOX OK|/tmp/hexbody_box.log|boxes|[3/9] the box in 12 directions, thin wall and thick wall ...
tests/census.loft|CENSUS OK|/tmp/hexbody_census.log|census|[4/9] the census, grown by level: law F decided at levels 1-3 ...
tests/text.loft|TEXT OK|/tmp/hexbody_text.log|text|[5/9] the canonical text: write(read(T)) = T byte-for-byte ...
tests/house.loft|HOUSE OK|/tmp/hexbody_house.log|house|[6/9] floor/walls/openings/roof at all 12 orientations ...
tests/surface.loft|SURFACE OK|/tmp/hexbody_surface.log|wall surface|[7/9] the wall surface by averaging: exact direction, exact bands ...
tests/arc.loft|ARC OK|/tmp/hexbody_arc.log|arcs|[8/9] the round tower + the doored tower: centre exact, radius a shell, a door is one arc ...
tests/trip.loft|TRIP OK|/tmp/hexbody_trip.log|round trip|[9/9] rt_trip: write(rebuild(draw(read(T)))) == T over corpus a1+a2 ...
EOF

echo "  PASS"
