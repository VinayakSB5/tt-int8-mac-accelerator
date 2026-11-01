/*
 * Copyright (c) 2026 Vinayak S Biradar
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs: Multiplier Operand A
    output wire [7:0] uo_out,   // Dedicated outputs: Accumulator output byte
    input  wire [7:0] uio_in,   // Bidirectional inputs: Multiplier Operand B
    output wire [7:0] uio_out,  // Bidirectional outputs (unused)
    output wire [7:0] uio_oe,   // Bidirectional output enables (set to 0 for inputs)
    input  wire       ena,      // Design enable signal
    input  wire       clk,      // Clock
    input  wire       rst_n     // Active-low synchronous reset
);

    // Configure bidirectional pins as inputs for Operand B
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;

    // Internal signed registers for pipelined INT8 MAC
    reg signed [7:0]  reg_a;
    reg signed [7:0]  reg_b;
    reg signed [15:0] mult_product;
    reg signed [31:0] accumulator;

    wire reset = !rst_n;

    // Stage 1: Input Latch
    always @(posedge clk) begin
        if (reset) begin
            reg_a <= 8'sd0;
            reg_b <= 8'sd0;
        end else if (ena) begin
            reg_a <= ui_in;
            reg_b <= uio_in;
        end
    end

    // Stage 2: Pipelined Multiplier
    always @(posedge clk) begin
        if (reset) begin
            mult_product <= 16'sd0;
        end else if (ena) begin
            mult_product <= reg_a * reg_b;
        end
    end

    // Stage 3: Accumulate with Sign-Extension
    always @(posedge clk) begin
        if (reset) begin
            accumulator <= 32'sd0;
        end else if (ena) begin
            accumulator <= accumulator + {{16{mult_product[15]}}, mult_product};
        end
    end

    // Expose lower 8 bits to the dedicated output pins
    assign uo_out = accumulator[7:0];

endmodule
