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


@cocotb.test()
async def target(dut):
    """Testing valid target"""
    dut.reset.value = 1
    dut.enable.value = 1

    dut.cfar_selector.value = 0
    dut.scale_factor.value = 1

    dut.ape_left.value = 0xa
    dut.ape_right.value = 0xa
    dut.filter_input.value = 0xf

    for cycle in range(10):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("filter_output is %s", dut.filter_output.value)
    assert dut.filter_output.value == 1, "filter_output is not 1!"

@cocotb.test()
async def no_target(dut):
    """Testing no target"""
    dut.reset.value = 1
    dut.enable.value = 1

    dut.cfar_selector.value = 0
    dut.scale_factor.value = 1

    dut.ape_left.value = 0xa
    dut.ape_right.value = 0xa
    dut.filter_input.value = 0x9

    for cycle in range(10):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("filter_output is %s", dut.filter_output.value)
    assert dut.filter_output.value == 0, "filter_output is not 0!"