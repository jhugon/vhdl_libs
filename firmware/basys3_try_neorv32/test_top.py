import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,N):

    led = NumpySignal(np.zeros(N,dtype=np.uint32),[1]*N)
    RsTx = NumpySignal(np.ones(N,dtype=np.uint32),[1]*N)

    return {"led":led,"RsTx":RsTx}

@cocotb.test()
async def fw_neorv32_test(dut):
    """
    Dummy test, b/c real hardware is the test of the display
    """
    ## Test with a simple byte
    N = 1000
    inputs = {
        "rstn_i": np.ones(N,dtype=np.uint32),
        "RsRx": np.ones(N,dtype=np.uint32),
    }

    inputs["rstn_i"][:100] = 0

    exp = model(inputs,N)

    nptest = NumpyTest(dut,inputs,exp,"clk")
    await nptest.run()
