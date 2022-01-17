# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/input_compare.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = input_compare

# MODULE is the basename of the Python test file
MODULE = test_input_compare

# Outputs waveform
#SIM_ARGS+=--vcd=waveform_for_input_compare.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
