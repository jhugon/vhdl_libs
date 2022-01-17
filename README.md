# Learn VHDL

Uses python cocotb package to write test/validation in python. Use the LLVM backend to GHDL, it's easier.

## Installation

    sudo apt-get install make gcc g++ python3 python3-dev python3-pip iverilog ghdl-llvm

In a python virtualenv:

    pip install cocotb[bus] pytest

You also need cocotb-numpy, which isn't on pypi:

    git clone https://github.com/jhugon/cocotb-numpy.git
    cd cocotb-numpy
    pip install .
    cd ..

## Running

    make
