import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge, Edge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,N):

    q = np.zeros(N,dtype=np.uint32)

    return {"q":q}

@cocotb.test()
async def fw_try_serv_test(dut):
    ## Test with a simple byte
    N = 1000
    inputs = {
        "wb_rst": np.zeros(N,dtype=np.uint32),
    }

    inputs["wb_rst"][0:100] = 1

    exp = model(inputs,N)

    nptest = NumpyTest(dut,inputs,exp,"wb_clk")
    await nptest.run(True)

    for i in range(10):
        await Edge(dut.q)
        print(f"At {get_sim_time('ns'):10.0f} ns q: {dut.q.value}")
