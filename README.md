# VHDL-Libs

All of the libraries use the python library cocotb to run tests/validation in
python. Firmware ready to build/flash to devices is found in `firmware/`, all
other directories are reusable modules.

## Installation

Use the LLVM backend to GHDL, it's easier than GCC and works well.

    sudo apt-get install make gcc g++ python3.9-dev python3-pip ghdl-llvm iverilog

On Ubuntu 20.04, the ghdl version doesn't work with VHDL-2008, which is needed
for uart_tx. You may need to install from source. See
https://ghdl.github.io/ghdl/development/building/LLVM.html#build-llvm for
instructions.

Install pipenv (which manages python dependencies)

    pip install --user pipenv

Run:

    pipenv install

## Running Tests

    pipenv shell
    make

or

    pipenv run make
