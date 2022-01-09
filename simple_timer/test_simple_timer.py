import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time

def log_everything(dut):
    dut._log.info(f"At {get_sim_time('ns'):4.0f} ns: clock: {dut.clock.value} reset: {dut.reset.value} enable: {dut.enable.value} count: {dut.count.value}")

NBITS = 10
MAXCOUNT = (1 << NBITS)-1

@cocotb.test()
async def simple_timer_test(dut):
    enable = dut.enable
    reset = dut.reset
    count = dut.count
    enable.value = 0
    reset.value = 1
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count == 0, "count wasn't reset to 0"
    reset.value = 0
    ## Reset complete
    await FallingEdge(dut.clock)
    assert count.value == 0, "with enable 0, count should still be 0"
    await FallingEdge(dut.clock)
    assert count.value == 0, "with enable 0, count should still be 0"
    enable.value = 1
    await FallingEdge(dut.clock)
    assert count.value == 1, "with enable 1, count should advance"
    await FallingEdge(dut.clock)
    assert count.value == 2, "with enable 1, count should advance"
    reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "After reset, count should be 0"
    reset.value = 0
    for i in range(2*MAXCOUNT + 100):
        assert count.value == (i & MAXCOUNT), f"Unexpected count value when i = {i}"
        await FallingEdge(dut.clock)
    future_count = count.value
    enable.value = 0
    for i in range(MAXCOUNT//2):
        assert count.value == future_count, f"Unexpected count value when i = {i}"
    
