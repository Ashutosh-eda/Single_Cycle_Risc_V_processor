// control.v  -- Main Control Unit for 32-bit RV32 Single-Cycle Processor
// ----------------------------------------------------------------------------
// * Decodes opcode[6:0] into control signals for datapath.
// * Supports: R-type (add/sub/and/or), lw, sw, beq
// * Produces:
//     RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp[1:0]
// ----------------------------------------------------------------------------

`timescale 1ns / 1ps

module control (
    input  wire [6:0] opcode,     // instr[6:0]
    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemtoReg,
    output reg        Branch,
    output reg [1:0]  ALUOp       // to ALU control
);

    // Combinational decode
    always @* begin
        // Default values (safe NOP): no writes, ALU = ADD
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            // ----------------------------------------------------------------
            // R-type (opcode = 0110011)
            // ----------------------------------------------------------------
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;      // use funct to decide
                // MemRead/MemWrite remain 0
            end

            // ----------------------------------------------------------------
            // lw (opcode = 0000011)
            // ----------------------------------------------------------------
            7'b0000011: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00;      // ADD for address calc
            end

            // ----------------------------------------------------------------
            // sw (opcode = 0100011)
            // ----------------------------------------------------------------
            7'b0100011: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;      // ADD for address calc
            end

            // ----------------------------------------------------------------
            // beq (opcode = 1100011)
            // ----------------------------------------------------------------
            7'b1100011: begin
                ALUSrc   = 1'b0;
                Branch   = 1'b1;
                ALUOp    = 2'b01;      // SUB for comparison
            end

            default: begin
                // All control signals already zero (NOP)
            end
        endcase
    end

endmodule

