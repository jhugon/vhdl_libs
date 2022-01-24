import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.handle import ModifiableObject
from cocotb.utils import get_sim_time
from cocotbnumpy.test import NumpyTest
from cocotbnumpy.signal import NumpySignal
import numpy as np

def model(inputs):
    sig_in = inputs["sig_in"]
    rst_i = inputs["wb_rst_i"]
    sel_i = inputs["wb_sel_i"]
    stb_i = inputs["wb_stb_i"]
    we_i = inputs["wb_we_i"]
    dat_i = inputs["wb_dat_i"]
    N = len(sig_in)
    ack_o = NumpySignal(np.zeros(N),[1])
    dat_o = NumpySignal(np.zeros(N),[1])
    # internal
    enable_reg = NumpySignal(np.zeros(N)*50,[1])
    count = NumpySignal(np.zeros(N)*50,[1])
    reset_reg = NumpySignal(np.zeros(N)*50,[1])

    for i in range(N):
        #####################
        # wb model
        #####################
        ack_o[i] = stb_i[i-1]
        if rst_i[i-1]:
            reset_reg[i] = 0
            enable_reg[i] = 0
            count[i] = 0
        if stb_i[i-1]:
            if not (sel_i[i-1] == 1 or sel_i[i-1] == 2):
                raise Exception(f"Invalid dut input sel_i for i={i-1}")
            if we_i[i-1] and sel_i[i-1] == 2: # write
                reset_reg[i] = (int(dat_i[i-1]) >> 1) & 1
                enable_reg[i] = int(dat_i[i-1]) & 1
            else:
                reset_reg[i] = reset_reg[i-1]
                enable_reg[i] = enable_reg[i-1]
            if not we_i[i-1]: # read
                if sel_i[i-1] == 2: # ctrl/status
                    dat_o[i] = 2*reset_reg[i-1]+enable_reg[i-1]
        else:
            reset_reg[i] = reset_reg[i-1]
            enable_reg[i] = enable_reg[i-1]
        #####################
        # pulse counter model
        #####################
        if i > 1:
            rising_edge = 0
            if sig_in[i-3] == 0 and sig_in[i-2] == 1 and reset_reg[i-2] != 1:
                rising_edge = 1
            if reset_reg[i-1]:
                count[i] = 0
            else:
                count[i] = count[i-1] + rising_edge*enable_reg[i-1]
        #####################
        # wb model--come back and do count datat output after count is setup
        #####################
        if stb_i[i-1] and not we_i[i-1] and sel_i[i-1] == 1:
            print(f"It's a count: {count[i-1]}")
            dat_o[i] = count[i]


    exp = {
        "wb_ack_o": ack_o,
        "wb_dat_o": dat_o,
        "count": count,
        "enable_reg" : enable_reg,
        "reset_reg": reset_reg,
    }
    return exp

@cocotb.test()
async def pulse_counter_test(dut):
    ## Test pulses and enable
    N = 40
    pulses_at = [3,6,9,12,15,18,21,25,30,35]
    inputs = {
        "sig_in": np.zeros(N),
        "wb_rst_i": np.zeros(N),
        "wb_cyc_i": np.zeros(N),
        "wb_sel_i": np.zeros(N),
        "wb_stb_i": np.zeros(N),
        "wb_we_i": np.zeros(N),
        "wb_dat_i": np.zeros(N),
    }

    inputs["wb_rst_i"][:2] = 1
    inputs["sig_in"][pulses_at] = 1
    # write 1 to enable and 0 to reset in ctrl/status reg
    inputs["wb_cyc_i"][10] = 1
    inputs["wb_stb_i"][10] = 1
    inputs["wb_sel_i"][10] = 2
    inputs["wb_we_i"][10] = 1
    inputs["wb_dat_i"][10] = 1
    # read count a few times
    inputs["wb_cyc_i"][[5,13,25,35]] = 1
    inputs["wb_stb_i"][[5,13,25,35]] = 1
    inputs["wb_sel_i"][[5,13,25,35]] = 1
    inputs["wb_we_i"][[5,13,25,35]] = 0

    exp = model(inputs)

    nptest = NumpyTest(dut,inputs,exp,"wb_clk_i")
    await nptest.run(True)
