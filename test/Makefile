# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../src/ape.vhdl
VHDL_SOURCES += $(PWD)/../src/cfar.vhdl
VHDL_SOURCES += $(PWD)/../src/ctpe.vhdl
VHDL_SOURCES += $(PWD)/../src/fifo.vhdl

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = cfar

# MODULE is the basename of the Python test file
MODULE = test_cfar

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim