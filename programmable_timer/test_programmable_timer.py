import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time

def log_everything(dut):
    dut._log.info(f"At {get_sim_time('ns'):4.0f} ns: clock: {dut.clock.value} reset: {dut.reset.value} enable: {dut.enable.value} max_value: {dut.max_value.value} count: {dut.count.value}")

NBITS = 10
MAXCOUNT = (1 << NBITS)-1

@cocotb.test()
async def programmable_timer_test(dut):
    enable = dut.enable
    reset = dut.reset
    count = dut.count
    max_value = dut.max_value
    enable.value = 0
    max_value.value = MAXCOUNT
    reset.value = 1
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    reset.value = 0
    ## Reset complete

    ## try MAXCOUNT
    enable.value = 1
    max_value.value = MAXCOUNT
    for i in range(2*MAXCOUNT + 100):
        assert count.value == (i % (max_value.value+1)), f"Unexpected count value when i = {i}"
        await FallingEdge(dut.clock)
    ## try 10
    reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    reset.value = 0
    max_value.value = 10
    for i in range(200):
        assert count.value == (i % (max_value.value+1)), f"Unexpected count value when i = {i}"
        await FallingEdge(dut.clock)
    ## try 1
    reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    reset.value = 0
    max_value.value = 1
    for i in range(20):
        assert count.value == (i % (max_value.value+1)), f"Unexpected count value when i = {i}"
        await FallingEdge(dut.clock)
    ## try 0
    reset.value = 1
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    reset.value = 0
    max_value.value = 0
    for i in range(10):
        assert count.value == 0, f"Unexpected count value when i = {i}"
        await FallingEdge(dut.clock)
