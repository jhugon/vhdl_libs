import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time

def log_everything(dut):
    dut._log.info(f"At {get_sim_time('ns'):4.0f} ns: clock: {dut.clock.value} reset: {dut.reset.value} count: {dut.count.value} last_count_reg: {dut.last_count_reg.value} trigger: {dut.trigger.value}")

NBITS = 10
MAXCOUNT = (1 << NBITS)-1

@cocotb.test()
async def triggerable_timer_test(dut):
    reset = dut.reset
    count = dut.count
    trigger = dut.trigger
    count.value = 0
    reset.value = 1
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    assert trigger.value == 0, "trigger wasn't reset to 0"
    reset.value = 0
    ## Reset complete
    for i in range(20):
        log_everything(dut) 
        assert trigger.value == 0, "shouldn't trigger yet"
        count.value = i
        await FallingEdge(dut.clock)
    log_everything(dut) 
    assert trigger.value == 0, "shouldn't trigger yet"
    count.value = 0
    await FallingEdge(dut.clock)
    log_everything(dut) 
    assert trigger.value == 1, "should trigger"
    count.value = 0
    await FallingEdge(dut.clock)
    log_everything(dut) 
    assert trigger.value == 0, "shouldn't trigger"

@cocotb.test(fail=True)
async def triggerable_timer_reset_test(dut):
    """
    Shouldn't trigger on/after reset
    """
