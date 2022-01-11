import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.utils import get_sim_time

def log_everything(dut):
    dut._log.info(f"At {get_sim_time('ns'):4.0f} ns: clock: {dut.clock.value} reset: {dut.reset.value} count: {dut.count.value} count_reg: {dut.count_reg.value} last_count_reg: {dut.last_count_reg.value} trigger: {dut.trigger.value}")

NBITS = 10
MAXCOUNT = (1 << NBITS)-1

@cocotb.test()
async def timer_pulser_only_wrapapround_test(dut):
    reset = dut.reset
    count = dut.count
    trigger = dut.trigger
    trigger_only_wraparound = dut.trigger_only_wraparound
    count.value = 0
    reset.value = 1
    trigger_only_wraparound.value = 1
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    assert trigger.value == 0, "trigger wasn't reset to 0"
    reset.value = 0
    ## Reset complete
    for i in range(20):
        assert trigger.value == 0, "shouldn't trigger yet"
        count.value = i
        await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger yet"
    count.value = 0
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"
    count.value = 0
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger"

@cocotb.test()
async def timer_pulser_only_wraparound_reset_test(dut):
    """
    Shouldn't trigger on/after reset
    """
    reset = dut.reset
    count = dut.count
    trigger = dut.trigger
    trigger_only_wraparound = dut.trigger_only_wraparound
    count.value = 0
    reset.value = 1
    trigger_only_wraparound.value = 1
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger during reset"
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    assert trigger.value == 0, "shouldn't trigger during reset"
    reset.value = 0
    ## Reset complete
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger after reset"
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger after reset"
    for n_during_reset in range(0,5):
        reset.value = 0
        count.value = 1
        await FallingEdge(dut.clock)
        assert trigger.value == 0, "shouldn't trigger"
        reset.value = 1
        for tick in range(n_during_reset):
            await FallingEdge(dut.clock)
            assert trigger.value == 0, "shouldn't trigger during reset"
        reset.value = 0
        await FallingEdge(dut.clock)
        assert trigger.value == 0, "shouldn't trigger after reset"
        await FallingEdge(dut.clock)
        assert trigger.value == 0, "shouldn't trigger after reset"
        await FallingEdge(dut.clock)
        assert trigger.value == 0, "shouldn't trigger after reset"

@cocotb.test()
async def timer_pulser_not_only_wrapapround_test(dut):
    reset = dut.reset
    count = dut.count
    trigger = dut.trigger
    trigger_only_wraparound = dut.trigger_only_wraparound
    count.value = 0
    reset.value = 1
    trigger_only_wraparound.value = 0
    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())
    await FallingEdge(dut.clock)
    await FallingEdge(dut.clock)
    assert count.value == 0, "count wasn't reset to 0"
    assert trigger.value == 1, "should trigger after reset with count 0"
    reset.value = 0
    ## Reset complete
    count.value = 0
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"
    count.value = 1
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger"
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger"
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger"
    ################
    for i in range(20):
        count.value = i
        await FallingEdge(dut.clock)
        if i == 0:
            assert trigger.value == 1, f"should trigger for i={i} count: {count.value}"
        else:
            assert trigger.value == 0, f"shouldn't trigger for i={i} count: {count.value}"
    count.value = 0
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"
    count.value = 1
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger"
    ### Reset
    reset.value = 1
    count.value = 0
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"
    reset.value = 0
    await FallingEdge(dut.clock)
    assert trigger.value == 1, "should trigger"

    reset.value = 1
    count.value = 1
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger"
    reset.value = 0
    await FallingEdge(dut.clock)
    assert trigger.value == 0, "shouldn't trigger"
