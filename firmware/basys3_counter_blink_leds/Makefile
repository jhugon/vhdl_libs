# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
SIM_ARGS+=-gTICKPRESCALE=1 -gLED_PORT_WIDTH=4

#VHDL_SOURCES += $(PWD)/../../reset_controller/reset_timer/reset_timer.vhd $(PWD)/../../timers/programmable_timer/programmable_timer.vhd $(PWD)/../../switches/switch_debouncer/switch_debouncer.vhd $(PWD)/../../switches/double_flip_flop/double_flip_flop.vhd $(PWD)/../../edges/edge_detector/edge_detector.vhd $(PWD)/../../edges/edge_maker/edge_maker.vhd $(PWD)/../../switches/switch_input/switch_input.vhd $(PWD)/../../switches/button_toggler/button_toggler.vhd $(PWD)/top.vhd
VHDL_SOURCES += $(PWD)/../../reset_controller/*/*.vhd $(PWD)/../../timers/*/*.vhd $(PWD)/../../switches/*/*.vhd $(PWD)/../../edges/*/*.vhd $(PWD)/top.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = top

# MODULE is the basename of the Python test file
MODULE = test_top

# Outputs waveform
#SIM_ARGS+=--vcd=test_top.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

vivado_output/basys3_counter_blink_leds.bit: $(VHDL_SOURCES)
	vivado -mode batch -notrace -source run.tcl

vivado: vivado_output/basys3_counter_blink_leds.bit

.PHONY: vivado
