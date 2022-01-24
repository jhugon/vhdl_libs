# Basys3 Count button presses and display counter on 7-segment display

## Making

To run GHDL-based compilation checks and tests:

    make

To compile to a bitstream with Vivado:

    make vivado

The bitstream is at `vivado_output/basys3_button_press_counter_7seg_display.bit`.
Intermediate reports are in that directory with a `.rpt` suffix. You can
inspect intermediate states in Vivado by running `vivado vivado_output/<x>.dcp`

## Inspecting Vivado Output

The following commands may be helpful to inspect the log:

    sed /^INFO/d vivado.log | less
    grep encountered vivado.log
