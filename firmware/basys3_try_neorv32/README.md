# Basys3 Test out NeoRV32

Should blink LED 0, use switch 0 to reset (reset low)

## Making

To run GHDL-based compilation checks and tests:

    make

To compile to a bitstream with Vivado:

    make vivado

The bitstream is at `vivado_output/basys3_neorv32.bit`.
Intermediate reports are in that directory with a `.rpt` suffix. You can
inspect intermediate states in Vivado by running `vivado vivado_output/<x>.dcp`

## Inspecting Vivado Output

The following commands may be helpful to inspect the log:

    sed /^INFO/d vivado.log | less
    grep encountered vivado.log
