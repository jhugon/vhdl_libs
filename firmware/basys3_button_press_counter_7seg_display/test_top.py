import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,N):

    butC = inputs["butC"]
    butU = inputs["butU"]

    count = np.zeros(N,dtype=np.uint32)
    print(butC)

    c = 0
    for i in range(N):
        print(butC[i],butC[i-1])
        if int(butC[i-2]) == 0 and int(butC[i-1]) == 1:
            print("butC pulse detected!")
            c += 1
        butC[i] = c

    return {"count":count}

@cocotb.test()
async def fw_button_press_7seg_display_test(dut):
    """
    Dummy test, b/c real hardware is the test of the display
    """
    ## Test with a simple byte
    N = 100
    inputs = {
        "butC": np.zeros(N,dtype=np.uint32),
        "butU": np.zeros(N,dtype=np.uint32),
    }

    inputs["butC"][10:30] = 1
    inputs["butU"][30:40] = 1

    exp = model(inputs,N)

    nptest = NumpyTest(dut,inputs,exp,"clk")
    await nptest.run()
