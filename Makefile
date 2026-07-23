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

# The gate. Grows with the roadmap; at 3+ entries adopt crawler's tools/run_tests.sh table.
test:
	@echo "  [form]  the 12 headings, the exact rotation and reflection (S0)"
	@$(LOFT) --interpret $(FLAGS) tests/form.loft | tee /tmp/hexbody_form.log
	@grep -q "FORM OK" /tmp/hexbody_form.log || { echo "  FAIL"; exit 1; }
	@echo "  [house] floor/walls/openings/roof at all 12 orientations"
	@$(LOFT) --interpret $(FLAGS) tests/house.loft | tee /tmp/hexbody_house.log
	@grep -q "HOUSE OK" /tmp/hexbody_house.log || { echo "  FAIL"; exit 1; }
	@echo "  PASS"

shot:
	@$(LOFT) --interpret $(FLAGS) src/houseshot.loft
