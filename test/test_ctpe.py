import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def reset(dut):
    """Testing reset condition."""
    dut.reset.value = 0
    for cycle in range(10):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("filter_output is %s", dut.filter_output.value)
    assert dut.filter_output.value == 0, "filter_output is not 0!"