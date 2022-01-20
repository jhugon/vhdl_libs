import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs):
    reset = inputs["reset"]
    latch_in_data = inputs["latch_in_data"]
    in_data = inputs["in_data"]
    N = len(reset)

    tx = np.zeros(N)
    sending = np.zeros(N)
    line_state = np.zeros(N)

    return {"tx":tx, "sending":sending}

@cocotb.test()
async def uart_tx_test(dut):
    ## Test pulses and enable
    N = 200
    inputs = {
        "reset": np.zeros(N),
        "latch_in_data": np.zeros(N),
        "in_data": np.zeros(N),
    }

    inputs["reset"][:2] = 1
    inputs["latch_in_data"][5] = 1
    inputs["in_data"][5] = 135

    exp = model(inputs)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run(True)
