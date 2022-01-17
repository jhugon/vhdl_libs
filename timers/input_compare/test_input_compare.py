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
    pulse_at = 5
    reset_at = 8
    pulse2_at = 12
    inputs = {
        "reset": np.zeros(N),
        "enable": np.ones(N),
        "count": np.arange(N),
        "sig_in": np.zeros(N),
    }

    inputs["reset"][:2] = 1
    # for pulse
    inputs["sig_in"][pulse_at] = 1
    # for reset_at
    inputs["reset"][reset_at] = 1
    # for pulse2
    inputs["sig_in"][pulse2_at] = 1

    exp = {
        "matched": NumpySignal(np.zeros(N),[1,1]),
        "match_count": NumpySignal(np.ones(N),np.ones(N)),
    }

    # for pulse
    exp["matched"][pulse_at+1:] = 1
    exp["match_count"][pulse_at+1:] = inputs["count"][pulse_at]
    exp["match_count"].dontcaremask[pulse_at+1:] = 0
    # for reset_at
    exp["matched"][reset_at+1:] = 0
    exp["match_count"].dontcaremask[reset_at+1:] = 1
    # for pulse2
    exp["matched"][pulse2_at+1:] = 1
    exp["match_count"][pulse2_at+1:] = inputs["count"][pulse2_at]
    exp["match_count"].dontcaremask[pulse2_at+1:] = 0

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()
