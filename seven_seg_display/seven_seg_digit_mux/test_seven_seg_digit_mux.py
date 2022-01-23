import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,digit_len):
    in_segments = inputs["in_segments"]
    N = len(in_segments)

    Ndigits = 2

    digit_enables = np.zeros(N)
    iDigit_reg = np.zeros(N,dtype=np.uint32)
    timer_count = np.zeros(N)
    out_segments = np.zeros(N)

    for i in range(1,N):
        timer_count[i] = (timer_count[i-1]+1) % digit_len
        if timer_count[i-1] == 0:
            iDigit_reg[i] = (iDigit_reg[i-1]+1) % Ndigits
        else:
            iDigit_reg[i] = iDigit_reg[i-1]
    digit_enables = 2**iDigit_reg
    out_segments[1:] = np.right_shift(in_segments[:-1],iDigit_reg[1:]*7) & 0b1111111

    return {"out_segments":out_segments, "digit_enables":digit_enables, "iDigit_reg":iDigit_reg, "timer_count":timer_count}

@cocotb.test()
async def seven_seg_digit_mux_test(dut):
    digit_len = 4 # clock ticks
    ## Test with a simple byte
    #print(f"First simple byte test")
    N = digit_len*10
    inputs = {
        "in_segments": np.concatenate([
            np.ones(N,dtype=np.uint32)*0b10101010101010,
            np.ones(N+1,dtype=np.uint32)*1,
            np.ones(N,dtype=np.uint32)*0b11100010001011,
        ]),
    }

    exp = model(inputs,digit_len)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()
