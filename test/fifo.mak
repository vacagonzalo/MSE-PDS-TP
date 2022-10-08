# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../src/fifo.vhdl

SIM_ARGS ?= --vcd=fifo.vcd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = fifo

# MODULE is the basename of the Python test file
MODULE = test_fifo

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim