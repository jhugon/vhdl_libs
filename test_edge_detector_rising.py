import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock

def log_everything(dut):
    dut._log.info(f"clock: {dut.clock.value} reset: {dut.reset.value} sig_in: {dut.sig_in.value} sig_out: {dut.sig_out.value}")

@cocotb.test()
async def edge_detector_basic_test(dut):
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    dut.clock.value = 0
    dut.reset.value = 0
    dut.sig_in.value = 0
    dut.reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    dut.reset.value = 0
    ## Reset complete
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
    dut.sig_in.value = 1
    await FallingEdge(dut.clock)
    log_everything(dut)
    dut.sig_in.value = 0
    await FallingEdge(dut.clock)
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
    await FallingEdge(dut.clock)
    log_everything(dut)
