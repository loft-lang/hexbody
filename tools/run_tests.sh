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

# table <<EOF — file|marker|log|fail-text|label  (order = execution order)
table() {
  while IFS='|' read -r file marker log fail label; do
    [ -n "$file" ] || continue
    run "$file" "$marker" "$log" "$fail" "$label"
  done
}

table <<'EOF'
tests/form.loft|FORM OK|/tmp/hexbody_form.log|headings|[1/3] the 12 headings, the exact rotation and reflection (S0/S1) ...
tests/wall.loft|WALL OK|/tmp/hexbody_wall.log|walls|[2/3] the 24-direction wall: edge table, foxel write, mesh evaluation ...
tests/house.loft|HOUSE OK|/tmp/hexbody_house.log|house|[3/3] floor/walls/openings/roof at all 12 orientations ...
EOF

echo "  PASS"
