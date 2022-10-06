# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../src/ape.vhdl

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ape

# MODULE is the basename of the Python test file
MODULE = test_ape

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim