import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs,bit_len):
    reset = NumpySignal(inputs["reset"])
    latch_in_data = NumpySignal(inputs["latch_in_data"])
    in_data = NumpySignal(inputs["in_data"])
    N = len(reset)

    tx = NumpySignal(np.zeros(N))
    sending = NumpySignal(np.zeros(N))
    ready_for_in_data = NumpySignal(np.ones(N))
    data_reg = None

    for i in range(N):
        if reset[i]:
            tx.dontcaremask[i] = 1
            sending.dontcaremask[i] = 1
    for i in range(1,N):
        if latch_in_data[i-1]:
            data_reg = int(in_data[i-1])
            sending[i] = 0
            ready_for_in_data[i] = 0
            tx[i] = 1
        if data_reg is None: # before first latch in
            tx[i] = 1
            sending[i] = 0
            ready_for_in_data[i] = 1
        else:
            count_since_latch_in_data = None
            for iBack in range(1,i):
                if latch_in_data[i-iBack]:
                    count_since_latch_in_data = iBack
                    break
            iBit = int((count_since_latch_in_data-2)//bit_len)-1
            iTick = int((count_since_latch_in_data-2) % bit_len)
            #print(i,count_since_latch_in_data,iBit,bit_len)
            if count_since_latch_in_data is None: # before first latch in
                sending[i] = 0
                ready_for_in_data[i] = 1
                tx[i] = 1
            elif count_since_latch_in_data < 2: # haven't started start bit yet, but latched
                sending[i] = 1
                ready_for_in_data[i] = 0
                tx[i] = 1
            elif iBit < 0: # start bit
                sending[i] = 1
                ready_for_in_data[i] = 0
                tx[i] = 0
            elif iBit < 8: # data bits
                sending[i] = 1
                ready_for_in_data[i] = 0
                if iBit == 7 and iTick == bit_len-1: # last one swaps
                    ready_for_in_data[i] = 1
                else:
                    ready_for_in_data[i] = 0
                tx[i] = (data_reg >> iBit) & 1
                #print(f"i={i}, count_since_latch_in_data={count_since_latch_in_data}, iBit={iBit}, data_reg={data_reg}, tx[i]={tx[i]}")
            elif iBit < 9: # stop bit
                if iTick == bit_len-1: # last one swaps
                    sending[i] = 0
                else:
                    sending[i] = 1
                ready_for_in_data[i] = 1
                tx[i] = 1
            else: # after stop bit/idle
                sending[i] = 0
                ready_for_in_data[i] = 1
                tx[i] = 1
    return {"tx":tx, "sending":sending, "ready_for_in_data":ready_for_in_data}

@cocotb.test()
async def uart_tx_test(dut):
    bit_len = 4 # clock ticks
    ## Test pulses and enable
    N = bit_len*15
    inputs = {
        "reset": np.zeros(N),
        "latch_in_data": np.zeros(N),
        "in_data": np.zeros(N),
    }

    inputs["reset"][:2] = 1
    inputs["latch_in_data"][5] = 1
    inputs["in_data"][5] = 0b01010101

    exp = model(inputs,bit_len)

    nptest = NumpyTest(dut,inputs,exp,"clock")
    await nptest.run(True)
