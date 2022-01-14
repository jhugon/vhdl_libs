# Basys3 Buttons, Toggle, LEDs

Simple test to see if I can use a button press to toggle an LED.

Excercises debouncing and timer.

## Making

To run GHDL-based compilation checks and tests:

    make

To compile to a bitstream with Vivado:

    make vivado

The bitstream is at `vivado_output/basys3_buttons_toggle_leds.bit`.
Intermediate reports are in that directory with a `.rpt` suffix. You can
inspect intermediate states in Vivado by running `vivado vivado_output/<x>.dcp`
