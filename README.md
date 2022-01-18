# Learn VHDL

Uses python cocotb package to write test/validation in python.

## Installation

 Use the LLVM backend to GHDL, it's easier than GCC and works well.

    sudo apt-get install make gcc g++ python3 python3-dev python3-pip iverilog ghdl-llvm

On Ubuntu 20.04, the ghdl version doesn't work with VHDL-2008, which is needed
for uart_tx. You may need to install from source. See
https://ghdl.github.io/ghdl/development/building/LLVM.html#build-llvm for
instructions.

In a python virtualenv:

    pip install cocotb[bus] pytest

You also need cocotb-numpy, which isn't on pypi:

    git clone https://github.com/jhugon/cocotb-numpy.git
    cd cocotb-numpy
    pip install .
    cd ..

## Running

    make
