# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/edge_detector_rising.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = edge_detector_rising

# MODULE is the basename of the Python test file
MODULE = test_edge_detector_rising

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
