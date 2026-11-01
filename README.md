# Pipelined INT8 MAC Accelerator (SKY130)

![gds](https://github.com/VinayakSB5/tt-int8-mac-accelerator/actions/workflows/gds.yaml/badge.svg)
![test](https://github.com/VinayakSB5/tt-int8-mac-accelerator/actions/workflows/test.yaml/badge.svg)
![docs](https://github.com/VinayakSB5/tt-int8-mac-accelerator/actions/workflows/docs.yaml/badge.svg)

A 3-stage pipelined signed INT8 Multiply-Accumulate (MAC) unit designed in Verilog and hardened for the SkyWater 130nm process via Tiny Tapeout. 

I built this block as a standalone hardware execution unit for edge AI / matrix math, originally developed alongside a custom 32-bit RISC-V core.

**Author:** Vinayak S Biradar  
**3D Silicon Layout:** https://vinayaksb5.github.io/tt-int8-mac-accelerator/

## How It Works

The design splits the MAC operation across three clock cycles to keep the critical path short and hit 50 MHz timing closure on SKY130:

1. **Stage 1 (Fetch/Latch):** Latches 8-bit signed operands from `ui_in` (Operand A) and `uio_in` (Operand B) into internal registers (`reg_a`, `reg_b`) when `ena` is high.
2. **Stage 2 (Multiply):** Multiplies `reg_a * reg_b` and stores the signed 16-bit result in `mult_product`.
3. **Stage 3 (Accumulate):** Sign-extends the 16-bit product to 32 bits and adds it to the 32-bit `accumulator` register. 

Because Tiny Tapeout has 8 dedicated output pins, the lower byte (`accumulator[7:0]`) is wired to `uo_out`.

## Pinout

| Port | Direction | Function |
|---|---|---|
| `ui_in[7:0]` | Input | Signed 8-bit Operand A |
| `uio_in[7:0]` | Input | Signed 8-bit Operand B (`uio_oe` tied to `0`) |
| `uo_out[7:0]` | Output | Accumulator output (`accumulator[7:0]`) |
| `clk` | Input | Clock (tested at 50 MHz / 20ns period) |
| `rst_n` | Input | Active-low synchronous reset |
| `ena` | Input | Design enable |

## Verification & ASIC Flow

* **RTL & Gate-Level Simulation:** Verified with `cocotb` and Icarus Verilog (`test/test.py`). Checked pipeline latency (4 cycles to output pin) and accumulation accuracy against the synthesized netlist.
* **Physical Implementation:** Synthesized and routed using OpenLane (Yosys + OpenROAD) targeting a 1x1 Tiny Tapeout tile on SkyWater 130nm.
* **Sign-off:** Passed Magic DRC (0 violations), Netgen LVS, and multi-corner Static Timing Analysis (OpenSTA) at 50 MHz.

## Running the Simulation Locally

Make sure `iverilog` and `cocotb` are installed, then run:

    cd test
    make -B
    ai kahane wale andhe enta  neche tak nahe  padthe hai  tho app engg ho!!!!!!! mai Vinayak S Biradar ece student, for any flaws and mistakes send pic of it to +91 9110848587
