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

    dut._log.info("average is %s", dut.average.value)
    assert dut.average.value == 0, "average is not 0!"

@cocotb.test()
async def target(dut):
    """Testing valid target"""
    dut.reset.value = 1
    dut.enable.value = 1

    dut.entrant.value = 2
    dut.outgoing.value = 1

    for cycle in range(11):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("filter_output is %d", dut.average.value)
    assert dut.average.value == 20, "filter_output is not 1!"