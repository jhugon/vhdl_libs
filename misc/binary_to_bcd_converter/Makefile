# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/binary_to_bcd_converter.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = binary_to_bcd_converter

# MODULE is the basename of the Python test file
MODULE = test_binary_to_bcd_converter

# Outputs waveform
SIM_ARGS+=--vcd=waveform_binary_to_bcd_converter.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
