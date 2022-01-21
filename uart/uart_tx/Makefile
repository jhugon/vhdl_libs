# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
SIM_ARGS+=-gUART_FREQ=100 -gCLOCK_FREQ=400 -gUART_PERIOD_N_CLOCK=4 -gTIMER_BIT_WIDTH=2
COMPILE_ARGS+=--std=08

VHDL_SOURCES += $(PWD)/../../timers/simple_timer/simple_timer.vhd  $(PWD)/../../timers/programmable_timer/programmable_timer.vhd $(PWD)/uart_tx.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = uart_tx

# MODULE is the basename of the Python test file
MODULE = test_uart_tx

# Outputs waveform
SIM_ARGS+=--vcd=waveform_uart_tx.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
