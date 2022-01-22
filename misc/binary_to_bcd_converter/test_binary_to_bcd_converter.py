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

    out_digits = np.zeros(N)

    for i in range(1,N):
        num_str = ("{:0"+str(Ndigits)+"}").format(in_num[i-1])
        bcd = 0
        for j in range(Ndigits):
            bcd += int(num_str[Ndigits-j-1]) << 4*j
        #print(f"i={i} in_num={in_num[i-1]} num_str={num_str} bcd={bcd:02X}")
        out_digits[i] = bcd
    return {"out_digits":out_digits}

@cocotb.test()
async def binary_to_bcd_converter_test(dut):
    digit_len = 4 # clock ticks
    N = digit_len
    inputs = {
        "in_num": np.concatenate([
            np.ones(N,dtype=np.uint32)*i for i in range(100)
        ]),
    }

    exp = model(inputs,digit_len)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run()
