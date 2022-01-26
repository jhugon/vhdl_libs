#
# A Vivado script that demonstrates a very simple RTL-to-bitstream non-project batch flow
#
# NOTE:  typical usage would be "vivado -mode batch -notrace -source run.tcl" 
# 
###########################
# Configuration
###########################
# config the FPGA part
set part xc7a35tcpg236-1
# config the top level VHDL name:
set top neorv32_test_setup_bootloader
# config the firmware filename
set bitfilename basys3_neorv32.bit
###########################
# Other configuration
###########################
set_msg_config -id "Synth 8-7080" -new_severity "INFO"
###########################
#
# STEP#0: define output directory area.
#
set outputDir ./vivado_output
file mkdir $outputDir
#
# STEP#1: setup design sources and constraints
#
#read_vhdl -library bftLib [ glob ./Sources/hdl/bftLib/*.vhdl ]         
#read_verilog  [ glob ./Sources/hdl/*.v ]
read_vhdl -library neorv32 [ glob ./neorv32/rtl/core/*.vhd ]
read_vhdl -library neorv32 [ glob ./neorv32/rtl/core/mem/*.vhd ]
read_vhdl ./neorv32_test_setup_bootloader.vhd
read_xdc ./io_constraints.xdc
#
# STEP#2: run synthesis, report utilization and timing estimates, write checkpoint design
#
synth_design -top $top -part $part
write_checkpoint -force $outputDir/post_synth
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_power -file $outputDir/post_synth_power.rpt
report_utilization -file $outputDir/post_synth_util.rpt
#
# STEP#3: run placement and logic optimzation, report utilization and timing estimates, write checkpoint design
#
opt_design
place_design
phys_opt_design
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
#
# STEP#4: run router, report actual utilization and timing, write checkpoint design, run drc, write verilog and xdc out
#
route_design
write_checkpoint -force $outputDir/post_route
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
report_methodology -file $outputDir/post_route_meth.rpt
write_verilog -force $outputDir/impl_netlist.v
write_xdc -no_fixed_only -force $outputDir/impl.xdc
#
# STEP#5: generate a bitstream
# 
write_bitstream -force $outputDir/$bitfilename
#
# Exiting
#
exit
