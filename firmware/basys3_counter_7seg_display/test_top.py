import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,N):

    seg = NumpySignal(np.zeros(N,dtype=np.uint32),[1]*N)
    an = NumpySignal(np.zeros(N,dtype=np.uint32),[1]*N)

    return {"seg":seg, "an":an}

@cocotb.test()
async def fw_counter_seven_seg_display_test(dut):
    """
    Dummy test, b/c real hardware is the test of the display
    """
    ## Test with a simple byte
    N = 100
    inputs = {
    }

    exp = model(inputs,N)

    nptest = NumpyTest(dut,inputs,exp,"clk")
    await nptest.run()
