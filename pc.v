// Code your design here
// pc.v  -- Program Counter for a 32‑bit single‑cycle RISC‑V processor
// ----------------------------------------------------------------
// Verilog‑2001 implementation (no SystemVerilog keywords)
// * Width  : 32‑bit (RV32 address space)
// * Reset  : asynchronous, active‑high → PC = 0x0000_0000
// * Update : on every positive clock edge, PC <= next_pc
// ----------------------------------------------------------------

`timescale 1ns / 1ps

module pc (
    input wire        clk,       // system clock
    input wire        reset,     // asynchronous active‑high reset
    input wire [31:0] next_pc,   // next PC value (PC+4 or branch target)
    output reg [31:0] pc         // current PC value
);

// ----------------------------------------------------------------
// Program Counter register with asynchronous reset
// ----------------------------------------------------------------

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 32'h0000_0000;     // initial address after reset
    else
        pc <= next_pc;          // normal update
end

endmodule
