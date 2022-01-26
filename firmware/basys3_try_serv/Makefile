# Makefile

# defaults
#SIM = ghdl
TOPLEVEL_LANG = verilog
#SIM_ARGS+=-gCLK_FREQ=4000

VERILOG_SOURCES += $(PWD)/serv/rtl/*.v $(PWD)/serv/servant/*.v $(PWD)/top.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = top

# MODULE is the basename of the Python test file
MODULE = test_top

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

vivado_output/basys3_try_serv.bit: $(VHDL_SOURCES)
	vivado -mode batch -notrace -source run.tcl

vivado: vivado_output/basys3_try_serv.bit

.PHONY: vivado
