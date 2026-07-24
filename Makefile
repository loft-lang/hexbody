# hexbody — geometry-body prototyping harness.
#
# THE TOOLCHAIN IS THE *INSTALLED* LOFT, NEVER ../loft.
#
# `--path` is not just a search path: loft reads its codegen support from there, so the emitted
# Rust matches THAT tree while the generated code links `/usr/local/share/loft/deps/libloft.rlib`
# — the INSTALLED one.  Pointing --path at the ../loft working tree therefore pairs a live source
# with a stale rlib, and the two drift apart the moment loft is edited without being reinstalled.
#
# That is not hypothetical: on 2026-07-24 a loft commit (13:39) added `ops::op_eq_text` while the
# installed rlib was still the 09:34 build.  Every gate touching hex_field died in rustc with
# "cannot find function op_eq_text in module ops" — including gates nobody had touched — and the
# suite had been passing only because a cached .so masked it until a new gate forced a rebuild.
# hexbody is a CONSUMER of loft (see CLAUDE.md); it should track loft's releases, not its desk.
#
# Override for a deliberate test against an unreleased toolchain, and expect to reinstall first:
#   make test LOFT_PATH=../loft/
#
# TWO SIBLING WORKING TREES STILL FEED THE GATES, and neither is pinned:
#   ../loft-libs-world   the hex_field family (--lib) — check it is on the shared `dev` branch
#                        before debugging anything strange
#   ../moros             the STORAGE OF RECORD (SPEC L13). tests/palette.loft reads four of its
#                        source files directly, so an uncommitted edit there moves the limit on
#                        M* with no trace in hexbody's history. The gate PRINTS moros's revision
#                        so a green is attributable; it cannot see whether that tree is dirty.
#
# loft.lock pins the registry packages (graphics/glb/mesh3d) and nothing else.

LOFT      ?= loft
LOFT_PATH ?= /usr/local/share/loft/
# --lib src/ lets tests/ live outside src/ and still `use` the modules there.  ../loft/lib is NOT
# on the path: nothing in src/ or tests/ imports from it (tests/scope.loft gates exactly that).
FLAGS  := --path $(LOFT_PATH) --lib ../loft-libs-world/ --lib src/

.PHONY: test shot help

help:
	@echo "make test   run the headless gates in tests/"
	@echo "make shot   render the 12-orientation contact sheet -> /tmp/house12.png"

# The gate. At 3 entries this moved to crawler's tools/run_tests.sh table, as planned.
test:
	@tools/run_tests.sh "$(LOFT)" "$(FLAGS)"

shot:
	@$(LOFT) --interpret $(FLAGS) src/houseshot.loft
