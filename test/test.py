import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting INT8 MAC Test")

    # Set clock period to 20ns (50 MHz)
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Hold reset for 2 cycles
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Test Case: 3 * 4 = 12
    # Stage 1: Feed inputs
    dut.ui_in.value = 3
    dut.uio_in.value = 4
    await ClockCycles(dut.clk, 1)

    # Clear inputs for subsequent cycles
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Wait for the remaining 2 pipeline cycles (Multiply + Accumulate)
    await ClockCycles(dut.clk, 2)

    # Lower 8 bits of 12 is 12 (0x0C)
    dut._log.info(f"Accumulator output: {int(dut.uo_out.value)}")
    assert dut.uo_out.value == 12, f"Expected 12, got {int(dut.uo_out.value)}"
