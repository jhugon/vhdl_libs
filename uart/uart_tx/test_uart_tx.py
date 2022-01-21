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

    tx = NumpySignal(np.ones(N))
    sending = NumpySignal(np.zeros(N))
    ready_for_in_data = NumpySignal(np.ones(N))
    data_reg = None

    iCycle = None
    next_frame_latched = False

    for i in range(N):
        if reset[i]:
            tx.dontcaremask[i] = 1
            sending.dontcaremask[i] = 1
    for i in range(1,N):
        if latch_in_data[i-1]:
            if iCycle is None:
                data_reg = int(in_data[i-1])
                iCycle = 0
            else:
                iBit = int((iCycle-1)//bit_len)-1
                iTick = int((iCycle-1) % bit_len)
                #print(f"Trying to latch in data i: {i} iCycle={iCycle+1}, iBit: {iBit} iTick: {iTick}")
                if (iBit == 8) and (not next_frame_latched):
                    #print(f"Latched in data during stop bit iCycle={iCycle}, iBit: {int((iCycle-2)//bit_len)-1} iTick: {int((iCycle-2) % bit_len)}")
                    data_reg = int(in_data[i-1])
                    next_frame_latched = True 
        if iCycle is None: # before latch in
            tx[i] = 1
            sending[i] = 0
            ready_for_in_data[i] = 1
        else:
            iCycle += 1
            iBit = int((iCycle-2)//bit_len)-1
            iTick = int((iCycle-2) % bit_len)
            #print(f"i: {i} iCycle: {iCycle} iBit: {iBit} iTick: {iTick}")
            if iCycle < 2: # haven't started start bit yet, but latched
                sending[i] = 1
                ready_for_in_data[i] = 0
                tx[i] = 1
            elif iBit < 0: # start bit
                next_frame_latched = False
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
                #print(f"i={i}, iCycle={iCycle}, iBit={iBit}, data_reg={data_reg}, tx[i]={tx[i]}")
            elif iBit < 9: # stop bit
                if iTick == bit_len-1: # last one swaps
                    sending[i] = 1 if next_frame_latched else 0
                    if next_frame_latched:
                        iCycle = 1
                    else:
                        iCycle = None
                else:
                    sending[i] = 1
                ready_for_in_data[i] = 0 if next_frame_latched else 1
                tx[i] = 1
            else: # after stop bit/idle
                sending[i] = 0
                ready_for_in_data[i] = 1
                tx[i] = 1
    return {"tx":tx, "sending":sending, "ready_for_in_data":ready_for_in_data}

@cocotb.test()
async def uart_tx_test(dut):
    bit_len = 4 # clock ticks
    ## Test with a simple byte
    #print(f"First simple byte test")
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
    await nptest.run()

    ## Test with 2 bytes
    for offset in range(-10,10):
        #print(f"offset: {offset}")
        #N = bit_len*25
        N = bit_len*25
        inputs = {
            "reset": np.zeros(N),
            "latch_in_data": np.zeros(N),
            "in_data": np.zeros(N),
        }

        inputs["latch_in_data"][bit_len] = 1
        inputs["in_data"][bit_len] =  0x1A+offset
        inputs["latch_in_data"][bit_len*11+offset] = 1
        inputs["in_data"][bit_len*11+offset] = 0x1A-offset

        exp = model(inputs,bit_len)

        nptest = NumpyTest(dut,inputs,exp,"clock")
        await nptest.run()

