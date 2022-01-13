# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/reset_timer.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = reset_timer

# MODULE is the basename of the Python test file
MODULE = test_reset_timer

# Outputs waveform
#SIM_ARGS+=--vcd=test_reset_timer.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
