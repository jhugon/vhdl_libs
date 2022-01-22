# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/seven_seg_decoder.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = seven_seg_decoder

# MODULE is the basename of the Python test file
MODULE = test_seven_seg_decoder

# Outputs waveform
#SIM_ARGS+=--vcd=waveform_seven_seg_decoder.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
