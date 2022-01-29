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

## UART1 Hookup

UART1 is hooked up to two pins in Pmode "JA" (the upper left one).

- Tx is pin JA1 (bottom upper pin)
- Rx is pin JA2 (the one next to it on the upper row)

They both use 3V3 I/O.

See [Basys3 reference manual](https://digilent.com/reference/programmable-logic/basys-3/reference-manual#pmod_ports) for details.
