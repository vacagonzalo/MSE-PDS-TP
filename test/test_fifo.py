import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def reset(dut):
    """Testing reset condition."""
    dut.reset.value = 0

    dut.entrant.value = 1

    fifo_size = 32 + 16 + 1
    for cycle in range(fifo_size):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("left_half_entering is %s", dut.left_half_entering.value)
    assert dut.left_half_entering.value == 0, "left_half_entering is not 0!"

    dut._log.info("left_half_outgoing is %s", dut.left_half_outgoing.value)
    assert dut.left_half_outgoing.value == 0, "left_half_outgoing is not 0!"

    dut._log.info("evaluated is %s", dut.evaluated.value)
    assert dut.evaluated.value == 0, "evaluated is not 0!"

    dut._log.info("right_half_entering is %s", dut.right_half_entering.value)
    assert dut.right_half_entering.value == 0, "right_half_entering is not 0!"

    dut._log.info("right_half_outgoing is %s", dut.right_half_outgoing.value)
    assert dut.right_half_outgoing.value == 0, "right_half_outgoing is not 0!"


@cocotb.test()
async def evaluated_position(dut):
    """Testing evaluated position in fifo"""
    dut.reset.value = 1
    dut.enable.value = 1

    dut.entrant.value = 1

    eval_pos = 16 + 8 + 1
    for cycle in range(eval_pos):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("evaluated is %s", dut.evaluated.value)
    assert dut.evaluated.value == 1, "evaluated is not 1!"