# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
#SIM_ARGS+=-gCLK_FREQ=4000 -gDEBOUNCE_TICK_FREQ=2000

VHDL_SOURCES_neorv32 += $(PWD)/neorv32/rtl/core/mem/*.vhd $(PWD)/neorv32/rtl/core/*.vhd
VHDL_SOURCES += $(PWD)/../../misc/*/*.vhd $(PWD)/../../timers/*/*.vhd $(PWD)/../../switches/*/*.vhd $(PWD)/../../edges/*/*.vhd $(PWD)/../../pulse_analysis/*/*.vhd $(PWD)/neorv32_test_setup_bootloader.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = neorv32_test_setup_bootloader

# MODULE is the basename of the Python test file
MODULE = test_top

# Outputs waveform
SIM_ARGS+=--vcd=waveform_neorv32.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

vivado_output/basys3_neorv32.bit: $(VHDL_SOURCES)
	vivado -mode batch -notrace -source run.tcl

vivado_output_rom/basys3_neorv32_rom_pulse_counter.bit: $(VHDL_SOURCES) neorv32_rom.vhd neorv32_asc_pulse_counter_image.vhd
	cp neorv32_asc_pulse_counter_image.vhd neorv32/rtl/core/neorv32_application_image.vhd
	vivado -mode batch -notrace -source run_rom.tcl

vivado: vivado_output/basys3_neorv32.bit

vivado_rom: vivado_output_rom/basys3_neorv32_rom_pulse_counter.bit

.PHONY: vivado vivado_rom
