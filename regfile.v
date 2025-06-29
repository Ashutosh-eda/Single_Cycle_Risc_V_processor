// Code your design here
// regfile.v  -- 32‑register file for a 32‑bit single‑cycle RISC‑V processor (RV32)
// -----------------------------------------------------------------------------
// * 32 registers (x0‑x31), each 32‑bit wide
// * 2 asynchronous read ports, 1 synchronous write port
// * x0 is hardwired to 0; writes to x0 are ignored
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module regfile (
    input  wire        clk,        // system clock
    input  wire        reset,      // asynchronous active‑high reset (clears regs)
    // Read port 1
    input  wire [4:0]  rs1,        // register index to read (source 1)
    output wire [31:0] rd1,        // data from rs1
    // Read port 2
    input  wire [4:0]  rs2,        // register index to read (source 2)
    output wire [31:0] rd2,        // data from rs2
    // Write port
    input  wire        we,         // write enable (RegWrite)
    input  wire [4:0]  rd,         // destination register index
    input  wire [31:0] wd          // data to be written
);

    // -----------------------------------------------------------------
    // Register array (x0‑x31).  x0 is hardwired to 0.
    // -----------------------------------------------------------------
    reg [31:0] regs [0:31];

    integer i;
    // Optional reset logic: clear all registers to 0 on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'h0000_0000;
        end else if (we && (rd != 5'd0)) begin
            regs[rd] <= wd;          // write on rising edge if rd ≠ x0
        end
    end

    // -----------------------------------------------------------------
    // Asynchronous combinational read ports.  x0 always returns 0.
    // -----------------------------------------------------------------
    assign rd1 = (rs1 == 5'd0) ? 32'h0000_0000 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'h0000_0000 : regs[rs2];

endmodule
