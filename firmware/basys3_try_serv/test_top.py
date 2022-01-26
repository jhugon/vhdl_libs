import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,N):

    btnC = inputs["btnC"]
    btnU = inputs["btnU"]

    count = np.zeros(N,dtype=np.uint32)

    c = 0
    for i in range(N):
        if int(btnC[i-9]) == 0 and int(btnC[i-8]) == 1:
            c += 1
        if int(btnU[i-5]) == 0 and int(btnU[i-4]) == 1:
            c += 1
        count[i] = c

    return {"count":count}

@cocotb.test()
async def fw_try_serv_test(dut):
    """
    Dummy test, b/c real hardware is the test of the display
    """
    ## Test with a simple byte
    N = 100
    inputs = {
        "btnC": np.zeros(N,dtype=np.uint32),
        "btnU": np.zeros(N,dtype=np.uint32),
    }

    inputs["btnC"][10:15] = 1
    inputs["btnU"][20:25] = 1
    #inputs["btnC"][[30,32,34]] = 1
    #inputs["btnU"][[36,38,40]] = 1

    exp = model(inputs,N)

    nptest = NumpyTest(dut,inputs,exp,"clk")
    await nptest.run()
