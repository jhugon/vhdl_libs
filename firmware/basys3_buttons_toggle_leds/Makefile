# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/../../switches/switch_debouncer/switch_debouncer.vhd $(PWD)/../../switches/double_flip_flop/double_flip_flop.vhd $(PWD)/../../edges/edge_detector/edge_detector.vhd $(PWD)/../../edges/edge_maker/edge_maker.vhd $(PWD)/../../switches/switch_input/switch_input.vhd $(PWD)/../../switches/button_toggler/button_toggler.vhd $(PWD)/top.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = top

# MODULE is the basename of the Python test file
MODULE = test_top

# Outputs waveform
SIM_ARGS+=--vcd=test_top.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
