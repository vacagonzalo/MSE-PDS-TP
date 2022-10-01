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
    dut.reset.value = 0
    dut.enable.value = 0  
    for cycle in range(1):
        dut.clock.value = 1
        await Timer(1, units="ns")
        dut.clock.value = 0
        await Timer(1, units="ns")

    dut.clock.value = 0
    dut.reset.value = 1
    dut.enable.value = 1    

    dut.entrant.value =  30#<--
    dut.outgoing.value = 15

    dut.clock.value = 1
    await Timer(1, units="ns")
    dut.clock.value = 0
    await Timer(1, units="ns")
    dut.clock.value = 1
    await Timer(1, units="ns")
    dut.clock.value = 0
    await Timer(1, units="ns")

    dut._log.info("el promedio es %d", dut.average.value)
    assert dut.average.value == 7, "filter_output is not 20!"