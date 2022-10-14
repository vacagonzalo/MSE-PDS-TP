# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../src/ctpe.vhdl

SIM_ARGS ?= --vcd=ctpe.vcd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ctpe

# MODULE is the basename of the Python test file
MODULE = test_ctpe

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim