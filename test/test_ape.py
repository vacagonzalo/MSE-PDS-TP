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
async def entrada_con_valor(dut):
    """Testing valid target"""

    dut.reset.value = 1
    dut.enable.value = 1    

    dut.entrant.value =  20#<--
    dut.outgoing.value = 0

    for cycle in range(16):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("el promedio es %d", dut.average.value)
    assert dut.average.value == 20, "filter_output is not 20!"

@cocotb.test()
async def entrada_mixta(dut):
    """Testing valid target"""
    dut.reset.value = 0
    for cycle in range(10):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut.reset.value = 1
    dut.enable.value = 1    

    dut.entrant.value =  20#<--
    dut.outgoing.value = 0

    for cycle in range(8):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut.entrant.value =  10#<--
    dut.outgoing.value = 0

    for cycle in range(8):
        dut.clock.value = 0
        await Timer(1, units="ns")
        dut.clock.value = 1
        await Timer(1, units="ns")

    dut._log.info("el promedio es %d", dut.average.value)
    assert dut.average.value == 15, "filter_output is not 15!"
