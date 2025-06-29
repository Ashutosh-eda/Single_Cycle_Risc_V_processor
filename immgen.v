// Code your design here
// immgen.v  -- Immediate Generator for RV32 single‑cycle processor
// -----------------------------------------------------------------------------
// * Generates a 32‑bit sign‑extended immediate based on the opcode field.
// * Supports I‑type (loads/ALU‑immediate), S‑type (stores), SB‑type (branch).
// * For SB‑type, the immediate is returned in **byte‑addressed** form
//   (i.e., already concatenated with a trailing 0 bit) so it can
//   be added directly to the PC without an explicit shift‑left‑by‑1.
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module immgen (
    input  wire [31:0] instr,   // full 32‑bit instruction word
    output reg  [31:0] imm      // sign‑extended immediate
);

    wire [6:0] opcode = instr[6:0];

    always @* begin
        case (opcode)
            7'b0000011: begin // I‑type (e.g., lw)
                imm = {{20{instr[31]}}, instr[31:20]};                 // imm[11:0]
            end

            7'b0100011: begin // S‑type (e.g., sw)
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};    // imm[11:0]
            end

            7'b1100011: begin // SB‑type (beq/bne)
                // imm[12|10:5|4:1|11|0]  -> {instr[31], instr[30:25], instr[11:8], instr[7], 1'b0}
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            default: begin
                imm = 32'h0000_0000; // default 0 for unsupported opcodes
            end
        endcase
    end

endmodule
