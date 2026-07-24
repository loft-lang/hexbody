# hexbody — geometry-body prototyping harness.
#
# THREE SIBLING WORKING TREES FEED THE GATES, and none of them is pinned:
#   ../loft              the toolchain (--path)
#   ../loft-libs-world   the hex_field family (--lib) — check it is on the shared `dev` branch
#                        before debugging anything strange
#   ../moros             the STORAGE OF RECORD (SPEC L13). tests/palette.loft reads four of its
#                        source files directly, so an uncommitted edit there moves the limit on
#                        M* with no trace in hexbody's history. The gate PRINTS moros's revision
#                        so a green is attributable; it cannot see whether that tree is dirty.
#
# loft.lock pins the registry packages (graphics/glb/mesh3d) and nothing else.

LOFT   ?= loft
# --lib src/ lets tests/ live outside src/ and still `use` the modules there.
FLAGS  := --path ../loft/ --lib ../loft/lib/ --lib ../loft-libs-world/ --lib src/

.PHONY: test shot help

help:
	@echo "make test   run the headless gates in tests/"
	@echo "make shot   render the 12-orientation contact sheet -> /tmp/house12.png"

# The gate. At 3 entries this moved to crawler's tools/run_tests.sh table, as planned.
test:
	@tools/run_tests.sh "$(LOFT)" "$(FLAGS)"

shot:
	@$(LOFT) --interpret $(FLAGS) src/houseshot.loft
