// Code your design here
// alu.v  -- Arithmetic Logic Unit for a 32‑bit single‑cycle RISC‑V processor (RV32)
// ------------------------------------------------------------------------------
// * Input operands : 32‑bit A and B
// * Control input  : 4‑bit ALUCtl as defined by the ALU control unit
// * Operations supported (per Figure 4.13 / book):
//     0000 : AND
//     0001 : OR
//     0010 : ADD
//     0110 : SUB
//     0111 : SLT (set‑less‑than, signed)
//     1100 : NOR  (optional but included for completeness)
// * Outputs :
//     - Result  (32‑bit)
//     - Zero flag (asserted when Result == 0)
// ------------------------------------------------------------------------------

`timescale 1ns / 1ps

module alu (
    input  wire [31:0]  A,        // operand A (rs1)
    input  wire [31:0]  B,        // operand B (rs2 or immediate)
    input  wire [3:0]   ALUCtl,   // operation select
    output reg  [31:0]  Result,   // operation result
    output wire         Zero      // asserted when Result == 0
);

    // Combinational ALU operations
    always @* begin
        case (ALUCtl)
            4'b0000: Result = A & B;                 // AND
            4'b0001: Result = A | B;                 // OR
            4'b0010: Result = A + B;                 // ADD
            4'b0110: Result = A - B;                 // SUB
            4'b0111: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'b1100: Result = ~(A | B);              // NOR
            default: Result = 32'h0000_0000;         // Undefined code → 0
        endcase
    end

    // Zero flag (combinational)
    assign Zero = (Result == 32'h0000_0000) ? 1'b1 : 1'b0;

endmodule
