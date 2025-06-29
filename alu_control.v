// Code your design here
// alu_control.v  -- ALU Control Unit for 32‑bit RV32 Single‑Cycle Processor
// -------------------------------------------------------------------------
// Inputs :
//     - ALUOp  [1:0] : high‑level operation code from main control unit
//     - funct7 [6:0] : instruction bits 31:25 (only bit 30 needed here)
//     - funct3 [2:0] : instruction bits 14:12
// Output :
//     - ALUCtl[3:0]  : selects the specific operation in the ALU
//                       (matches encoding in alu.v)
// -------------------------------------------------------------------------
// Encoding (per Patterson & Hennessy Fig. 4.13):
//   ALUOp = 00 → ADD  (for load/store address calc)
//   ALUOp = 01 → SUB  (for BEQ comparison)
//   ALUOp = 10 → R‑type, decoded via funct7 & funct3
//                      funct7 funct3 | Operation | ALUCtl
//                      0000000 000   | ADD       | 0010
//                      0100000 000   | SUB       | 0110
//                      0000000 111   | AND       | 0000
//                      0000000 110   | OR        | 0001
// -------------------------------------------------------------------------

`timescale 1ns / 1ps

module alu_control (
    input  wire [1:0] ALUOp,     // from main control unit
    input  wire [6:0] funct7,    // instr[31:25]
    input  wire [2:0] funct3,    // instr[14:12]
    output reg  [3:0] ALUCtl     // to ALU
);

    always @* begin
        case (ALUOp)
            2'b00: ALUCtl = 4'b0010; // ADD for load/store (LW/SW)
            2'b01: ALUCtl = 4'b0110; // SUB for branch compare (BEQ)
            2'b10: begin             // R‑type decoding
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: ALUCtl = 4'b0010; // ADD
                    {7'b0100000, 3'b000}: ALUCtl = 4'b0110; // SUB
                    {7'b0000000, 3'b111}: ALUCtl = 4'b0000; // AND
                    {7'b0000000, 3'b110}: ALUCtl = 4'b0001; // OR
                    default:               ALUCtl = 4'b0000; // default AND/NOP
                endcase
            end
            default: ALUCtl = 4'b0000; // safe default
        endcase
    end

endmodule
