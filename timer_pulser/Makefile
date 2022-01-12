# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/../simple_timer/simple_timer.vhd $(PWD)/../programmable_timer/programmable_timer.vhd $(PWD)/timer_pulser.vhd $(PWD)/timer_pulsers.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = timer_pulser

# MODULE is the basename of the Python test file
MODULE = test_timer_pulser

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
