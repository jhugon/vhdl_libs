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
    N = 30
    compare_val = 7
    inputs = {
        "compare": np.ones(N)*compare_val,
        "count": np.arange(N),
    }

    inputs["count"][N//3:2*N//3] = np.arange(N//3)
    inputs["count"][2*N//3:] = np.arange(N//3,0,-1)

    exp = {
        "matched": NumpySignal(np.zeros(N),[1]),
    }

    exp["matched"][compare_val+1:N//3+1] = 1
    exp["matched"][N//3+compare_val+1:-compare_val+2] = 1

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()
