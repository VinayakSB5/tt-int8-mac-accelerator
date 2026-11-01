
`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs: 8-bit multiplier operand A / data
    output wire [7:0] uo_out,   // Dedicated outputs: 8-bit accumulator output window
    input  wire [7:0] uio_in,   // Bidirectional inputs: 8-bit multiplier operand B
    output wire [7:0] uio_out,  // Bidirectional outputs: status flags
    output wire [7:0] uio_oe,   // Bidirectional pin direction control (1 = out, 0 = in)
    input  wire       ena,      // Will go high when design is powered
    input  wire       clk,      // Clock signal
    input  wire       rst_n     // Active-low synchronous reset
);

    // Set bidirectional pins: uio[7:0] used as inputs for operand B (oe = 0)
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

    // Stage 3: Accumulate with Saturation Guard
    always @(posedge clk) begin
        if (reset) begin
            accumulator <= 32'sd0;
        end else if (ena) begin
            // Accumulate previous sum with product
            accumulator <= accumulator + {{16{mult_product[15]}}, mult_product};
        end
    end

    // Expose the lower 8 bits of accumulator to dedicated outputs
    assign uo_out = accumulator[7:0];

endmodule
