# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/output_compare.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = output_compare

# MODULE is the basename of the Python test file
MODULE = test_output_compare

# Outputs waveform
#SIM_ARGS+=--vcd=waveform_for_output_compare.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
