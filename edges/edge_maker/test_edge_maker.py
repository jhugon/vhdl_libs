import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock

def log_everything(dut):
    dut._log.info(f"clock: {dut.clock.value} reset: {dut.reset.value} sig_in: {dut.sig_in.value} reg_last_out: {dut.reg_last_out.value} next_last_out: {dut.next_last_out.value} sig_out: {dut.sig_out.value}")

@cocotb.test()
async def edge_maker_rising_test(dut):
    clock = dut.clock
    reset = dut.reset
    sig_in = dut.sig_in
    sig_out = dut.sig_out
    cocotb.start_soon(Clock(clock, 10, units="ns").start())
    sig_in.value = 0
    reset.value = 1
    await FallingEdge(clock)
    await FallingEdge(clock)
    assert dut.sig_out == 0, "sig_out wasn't reset to 0"
    dut.reset.value = 0
    ## Reset complete
    sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge made when no input yet"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge made when no input yet"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge made when no input yet"
    ####
    sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge not made"
    sig_in.value = 0
    for i in range(10):
        await FallingEdge(dut.clock)
        assert dut.sig_out == 1, "should have stayed at 1"
    sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge not made"
    sig_in.value = 0
    for i in range(10):
        await FallingEdge(dut.clock)
        assert dut.sig_out == 0, "should have stayed at 0"
    sig_in.value = 1
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge not made"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 0, "edge not made"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge not made"
    sig_in.value = 0
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge not made"
    await FallingEdge(dut.clock)
    assert dut.sig_out == 1, "edge not made"
