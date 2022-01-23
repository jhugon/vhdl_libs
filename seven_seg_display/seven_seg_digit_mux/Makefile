# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
SIM_ARGS+=-gClockFreq=4000

VHDL_SOURCES += $(PWD)/../../timers/simple_timer/simple_timer.vhd $(PWD)/seven_seg_digit_mux.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = seven_seg_digit_mux

# MODULE is the basename of the Python test file
MODULE = test_seven_seg_digit_mux

# Outputs waveform
SIM_ARGS+=--vcd=waveform_seven_seg_digit_mux.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
