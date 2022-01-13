import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time

NBITS = 10
MAXCOUNT = (1 << NBITS)-1

@cocotb.test()
async def simple_timer_test(dut):
    count_to_reset = dut.count_to_reset
    reset = dut.reset
    count_to_reset.value = 15
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    for i in range(16):
        await FallingEdge(dut.clock)
        assert reset.value == 1, f"failed on i={i}"
    for i in range(100):
        await FallingEdge(dut.clock)
        assert reset.value == 0, f"failed on i={i}"
