import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.handle import ModifiableObject
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs):
    reset = inputs["reset"]
    sig_in = inputs["sig_in"]
    enable = inputs["enable"]
    N = len(sig_in)
    result = NumpySignal(np.zeros(N),[1])
    count = 0
    for i in range(2,N):
        rising_edge = 0
        if sig_in[i-3] == 0 and sig_in[i-2] == 1 and reset[i-2] != 1:
            rising_edge = 1
        if reset[i-1]:
            count = 0
        else:
            count += rising_edge*enable[i-1]
        result[i] = count
    exp = {
        "count": result
    }
    return exp

@cocotb.test()
async def pulse_counter_test(dut):
    ## Test pulses
    N = 40
    pulses_at = [5,6,7,9,15,20,30,35]
    inputs = {
        "reset": np.zeros(N),
        "enable": np.ones(N),
        "sig_in": np.zeros(N),
    }

    inputs["reset"][:1] = 1
    inputs["sig_in"][pulses_at] = 1

    exp = model(inputs)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()

    ## Test pulses and reset

    N = 50
    pulses_at = [5,10,15,20,25,30,35,40,45]
    inputs = {
        "reset": np.zeros(N),
        "enable": np.ones(N),
        "sig_in": np.zeros(N),
    }

    inputs["reset"][:1] = 1
    for iEl,i in enumerate(pulses_at):
        inputs["sig_in"][i] = 1
        inputs["reset"][i+iEl-4] = 1

    exp = model(inputs)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()

    ## Test pulses and enable

    N = 50
    pulses_at = [5,10,15,20,25,30,35,40,45]
    inputs = {
        "reset": np.zeros(N),
        "enable": np.zeros(N),
        "sig_in": np.zeros(N),
    }

    inputs["reset"][:1] = 1
    for iEl,i in enumerate(pulses_at):
        inputs["sig_in"][i] = 1
        inputs["enable"][i+iEl-4] = 1

    exp = model(inputs)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()
