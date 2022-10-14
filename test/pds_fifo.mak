# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../src/pds_fifo.vhdl

SIM_ARGS ?= --vcd=pds_fifo.vcd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = pds_fifo

# MODULE is the basename of the Python test file
MODULE = test_pds_fifo

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim