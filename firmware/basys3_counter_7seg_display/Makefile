# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
SIM_ARGS+=-gTICKPRESCALE=1 -gLED_PORT_WIDTH=4

VHDL_SOURCES += $(PWD)/../../reset_controller/*/*.vhd $(PWD)/../../timers/*/*.vhd $(PWD)/../../switches/*/*.vhd $(PWD)/../../edges/*/*.vhd $(PWD)/top.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = top

# MODULE is the basename of the Python test file
MODULE = test_top

# Outputs waveform
#SIM_ARGS+=--vcd=waveform_counter_blink_leds.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

vivado_output/basys3_counter_blink_leds.bit: $(VHDL_SOURCES)
	vivado -mode batch -notrace -source run.tcl

vivado: vivado_output/basys3_counter_7seg_display.bit

.PHONY: vivado
