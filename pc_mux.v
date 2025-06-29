// Code your design here
// pc_mux.v  -- 2‑to‑1 MUX for selecting the next PC value
// ------------------------------------------------------------------
// * Selects between sequential PC (PC+4) and branch target.
// * Control input : PCSrc (0 → sequential, 1 → branch target)
// * Implemented as a single combinational assign statement.
// ------------------------------------------------------------------

`timescale 1ns / 1ps

module pc_mux (
    input  wire [31:0] pc_plus4,       // PC + 4 (sequential)
    input  wire [31:0] branch_target,  // PC + imm (from Adder2)
    input  wire        PCSrc,          // control: 0 = sequential, 1 = branch
    output wire [31:0] next_pc         // mux output to Program Counter
);

    // Simple combinational select
    assign next_pc = (PCSrc) ? branch_target : pc_plus4;

endmodule
