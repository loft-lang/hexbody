# hexbody — geometry-body prototyping harness.
#
# Consumes the loft toolchain at ../loft and the hex_field family at
# ../loft-libs-world (both siblings). --lib reads the WORKING TREE, so check the
# loft-libs-world branch (shared `dev`) before debugging anything strange.

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
