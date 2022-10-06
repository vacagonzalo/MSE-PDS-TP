import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def reset(dut):
    """Testing reset condition."""
    # Common control signals
    dut.reset.value = 0
    dut.enable.value = 1

    # Input
    dut.cfar_selector.value = 0
    dut.scale_factor.value = 0
    dut.entrant.value = 1

    fifo_size = 32 + 16 + 1
    for cycle in range(fifo_size):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("filter_output is %s", dut.filter_output.value)
    assert dut.filter_output.value == 0, "filter_output is not 0!"


@cocotb.test()
async def no_target(dut):
    """Testing no target condition."""
    # Common control signals
    dut.reset.value = 0
    dut.enable.value = 1

    # Reset from previos test
    dut.clock.value = 0
    await Timer(1, units="ns")
    dut.clock.value = 1
    await Timer(1, units="ns")

    dut.reset.value = 1

    # Input
    dut.cfar_selector.value = 0
    dut.scale_factor.value = 0

    dut.entrant.value = 0

    dut.clock.value = 0
    await Timer(1, units="ns")
    dut.clock.value = 1
    await Timer(1, units="ns")

    dut.entrant.value = 0xf

    fifo_size = 32 + 16
    for cycle in range(fifo_size):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("filter_output is %s", dut.filter_output.value)
    assert dut.filter_output.value == 0, "filter_output is not 0!"


@cocotb.test()
async def target_detected(dut):
    """Testing no target condition."""
    # Common control signals
    dut.reset.value = 0
    dut.enable.value = 1

    # Reset from previos test
    dut.clock.value = 0
    await Timer(1, units="ns")
    dut.clock.value = 1
    await Timer(1, units="ns")

    dut.reset.value = 1

    # Input
    dut.cfar_selector.value = 0
    dut.scale_factor.value = 0
    dut.entrant.value = 0xf

    # Insert value at front
    dut.clock.value = 0
    await Timer(1, units="ns")
    dut.clock.value = 1
    await Timer(1, units="ns")

    dut.entrant.value = 0xe

    fifo_size = 32 + 16
    for cycle in range(fifo_size):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("filter_output is %s", dut.filter_output.value)
    assert dut.filter_output.value == 1, "filter_output is not 1!"
