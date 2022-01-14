# Basys3 Blink LEDs to a Counter

This should blink a series of LEDs one twice as fast as the last

## Making

To run GHDL-based compilation checks and tests:

    make

To compile to a bitstream with Vivado:

    make vivado

The bitstream is at `vivado_output/basys3_counter_blink_leds.bit`.
Intermediate reports are in that directory with a `.rpt` suffix. You can
inspect intermediate states in Vivado by running `vivado vivado_output/<x>.dcp`
