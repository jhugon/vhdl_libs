import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock

def log_everything(dut):
    dut._log.info(f"clock: {dut.clock.value} reset: {dut.reset.value} sig_in: {dut.sig_in.value} sig_out: {dut.sig_out.value}")

@cocotb.test()
async def edge_detector_rising_test(dut):
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    dut.clock.value = 0
    dut.reset.value = 0
    dut.sig_in.value = 0
    dut.trig_on_rising.value = 1
    dut.trig_on_falling.value = 0
    dut.reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "sig_out wasn't reset to 0"
    dut.reset.value = 0
    ## Reset complete
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't changed from 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't changed from 0"
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"

@cocotb.test()
async def edge_detector_falling_test(dut):
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    dut.clock.value = 0
    dut.reset.value = 0
    dut.sig_in.value = 0
    dut.trig_on_rising.value = 0
    dut.trig_on_falling.value = 1
    dut.reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "sig_out wasn't reset to 0"
    dut.reset.value = 0
    ## Reset complete
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't changed from 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't changed from 0"
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't fallen yet"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't fallen yet"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't fallen yet"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't fallen yet"
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"

@cocotb.test()
async def edge_detector_rising_and_falling_test(dut):
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    dut.clock.value = 0
    dut.reset.value = 0
    dut.sig_in.value = 0
    dut.trig_on_rising.value = 1
    dut.trig_on_falling.value = 1
    dut.reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "sig_out wasn't reset to 0"
    dut.reset.value = 0
    ## Reset complete
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't changed from 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was detected when in hasn't changed from 0"
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge wasn't detected"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge was already detected, sig_out didn't go back to 0"
