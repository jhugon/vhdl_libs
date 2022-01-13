# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/pulse_prescaler.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = pulse_prescaler

# MODULE is the basename of the Python test file
MODULE = test_pulse_prescaler

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
