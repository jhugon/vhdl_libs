# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl

VHDL_SOURCES += $(PWD)/../../timers/simple_timer/simple_timer.vhd $(PWD)/../../edges/edge_detector/edge_detector.vhd $(PWD)/../../edges/edge_detector/edge_detector_rising.vhd $(PWD)/pulse_counter.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = pulse_counter

# MODULE is the basename of the Python test file
MODULE = test_pulse_counter

# Outputs waveform
SIM_ARGS+=--vcd=waveform_for_pulse_counter.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
