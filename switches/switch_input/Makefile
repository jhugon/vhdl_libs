# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/../switch_debouncer/switch_debouncer.vhd $(PWD)/../double_flip_flop/double_flip_flop.vhd $(PWD)/../../edges/edge_detector/edge_detector.vhd $(PWD)/switch_input.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = switch_input

# MODULE is the basename of the Python test file
MODULE = test_switch_input

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
