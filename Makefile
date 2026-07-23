# hexbody — geometry-body prototyping harness.
#
# Consumes the loft toolchain at ../loft and the hex_field family at
# ../loft-libs-world (both siblings). --lib reads the WORKING TREE, so check the
# loft-libs-world branch (shared `dev`) before debugging anything strange.

LOFT   ?= loft
FLAGS  := --path ../loft/ --lib ../loft/lib/ --lib ../loft-libs-world/

.PHONY: test shot help

help:
	@echo "make test   run the headless body/geometry gates"
	@echo "make shot   render the 12-orientation contact sheet -> /tmp/house12.png"

# The gate. One test today (housetest, 12 orientations); grows with the roadmap.
test:
	@echo "  [house] floor/walls/openings/roof at all 12 orientations"
	@$(LOFT) --interpret $(FLAGS) src/housetest.loft | tee /tmp/hexbody_house.log
	@grep -q "HOUSE OK" /tmp/hexbody_house.log || { echo "  FAIL"; exit 1; }
	@echo "  PASS"

shot:
	@$(LOFT) --interpret $(FLAGS) src/houseshot.loft
