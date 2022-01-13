import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge
from cocotb.clock import Clock
from cocotb.handle import ModifiableObject
from cocotb.utils import get_sim_time

class Representation:
    def __init__(self, dut, in_names: list,out_names: list,clock_name: str):
        self.dut = dut
        self.in_names = in_names
        self.out_names = out_names
        self.clock_name = clock_name
        self.in_sigs = []
        self.out_sigs = []
        self.internal_sigs = []
        self.clock_sig = None
        for attr_name in dir(dut):
            attr = getattr(dut,attr_name)
            if not isinstance(attr,ModifiableObject):
                continue
            if attr_name == clock_name:
                self.clock_sig = attr
            elif attr_name in in_names:
                self.in_sigs.append(attr)
            elif attr_name in out_names:
                self.out_sigs.append(attr)
            else:
                self.internal_sigs.append(attr)

    def format_sig(self,sig):
        if True:
            try:
                return sig.value.integer
            except ValueError:
                return sig.value
        else:
            return sig.value

    def __str__(self):
        return self.get_str(show_internal=False)

    def get_str(self,show_internal=False):
        result = ""
        result += self.clock_sig._name + ": {0}".format(self.format_sig(self.clock_sig))
        for sig in self.in_sigs:
            result += " " + sig._name + ": {0}".format(self.format_sig(sig))
        if show_internal:
            for sig in self.internal_sigs:
                result += " " + sig._name + ": {0}".format(self.format_sig(sig))
        for sig in self.out_sigs:
            result += " " + sig._name + ": {0}".format(self.format_sig(sig))
        return result

    def log(self,show_internal=False):
        self.dut._log.info(f"At {get_sim_time('ns'):4.0f} ns {self.get_str(show_internal)}")
        

@cocotb.test()
async def switch_debouncer_test(dut):
    rep = Representation(dut,["clock", "reset", "sig_in"],["sig_out"],"clock")
    clock = dut.clock
    reset = dut.reset
    sig_in = dut.sig_in
    sig_out = dut.sig_out
    cocotb.start_soon(Clock(clock, 10, units="ns").start())
    sig_in.value = 0
    reset.value = 1
    await FallingEdge(clock)
    await FallingEdge(clock)
    dut.reset.value = 0
    assert sig_out.value == 0
    ## Reset complete
    sig_in.value = 0
    for i in range(10):
        await FallingEdge(clock)
        assert sig_out.value == 0
    sig_in.value = 1
    for i in range(16):
        await FallingEdge(clock)
        assert sig_out.value == (0 if i < 1 else 1)
    sig_in.value = 0
    for i in range(16):
        await FallingEdge(clock)
        assert sig_out.value == (1 if i < 1 else 0)
    for i in range(20):
        sig_in.value = 1
        await FallingEdge(clock)
        assert sig_out.value == 0
        sig_in.value = 0
        await FallingEdge(clock)
        assert sig_out.value == 1
