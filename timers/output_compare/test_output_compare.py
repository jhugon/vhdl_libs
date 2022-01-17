import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.handle import ModifiableObject
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np


@cocotb.test()
async def input_compare_test(dut):
    ## Test match and reset
    N = 20
    compare_val = 11
    inputs = {
        "compare": np.ones(N)*compare_val,
        "count": np.arange(N),
    }

    #inputs["reset"][:2] = 1

    exp = {
        "matched": NumpySignal(np.zeros(N),[1,1]),
    }

    exp["matched"][compare_val:] = 1

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()
