import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,digit_len):
    in_num = inputs["in_num"]
    N = len(in_num)

    Ndigits = 2

    out_segments = np.zeros(N)
    digit_enables = np.zeros(N,dtype=np.uint32)
    converted = np.zeros(N)

    for i in range(1,N):
        num_str = "{:02}".format(in_num[i-1])
        bcd = 0
        for j in range(Ndigits):
            bcd += int(num_str[Ndigits-j-1]) << 4*j
        print(f"i={i} in_num={in_num[i-1]} num_str={num_str} bcd={bcd:02X}")
        converted[i] = bcd
    return {"out_segments":out_segments, "digit_enables":digit_enables, "converted":converted}

@cocotb.test()
async def seven_seg_num_display_test(dut):
    digit_len = 4 # clock ticks
    N = digit_len*8
    inputs = {
        "in_num": np.concatenate([
            np.ones(N,dtype=np.uint32)*i for i in range(8,12)
        ]),
    }

    exp = model(inputs,digit_len)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()
