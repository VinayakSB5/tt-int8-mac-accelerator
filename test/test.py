import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, ReadOnly

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting INT8 MAC Test")

    # Start 50 MHz clock (20ns period)
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize control pins and reset active-low
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Hold reset for 5 cycles to guarantee clean register states
    await ClockCycles(dut.clk, 5)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Apply Inputs: 3 * 4 = 12
    await RisingEdge(dut.clk)
    dut.ui_in.value = 3
    dut.uio_in.value = 4

    # Allow the inputs to propagate through the 3 pipeline stages:
    # Cycle 1: Latch inputs (reg_a, reg_b)
    # Cycle 2: Compute mult_product (16-bit)
    # Cycle 3: Accumulate into accumulator register
    # Cycle 4: Stable output on uo_out
    await ClockCycles(dut.clk, 4)
    await ReadOnly()

    out_val = int(dut.uo_out.value)
    dut._log.info(f"Observed accumulator output: {out_val}")

    assert out_val == 12, f"Pipeline latency mismatch: expected 12, got {out_val}"
