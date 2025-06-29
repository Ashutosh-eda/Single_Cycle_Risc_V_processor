// imem.v  -- Instruction Memory (ROM) for a 32-bit single-cycle RISC-V processor
// -----------------------------------------------------------------------------
// * Interface :
//     - addr   : 32-bit byte address from PC
//     - instr  : 32-bit instruction word fetched from memory
// * Behavior  :
//     - Read‑only memory (ROM) initialized from an external hex file
//     - Asynchronous combinational read: instruction is available
//       in the same cycle the address is presented (suitable for
//       single‑cycle processors).
// * Notes     :
//     - Word‑aligned access: addr[1:0] are ignored.
//     - Parameter MEM_DEPTH can be adjusted; default = 256 words (1 KiB)
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

module imem #(
    parameter MEM_DEPTH = 256          // number of 32‑bit words in ROM
) (
    input  wire [31:0] addr,           // byte address from PC
    output wire [31:0] instr           // instruction word
);

    // -------------------------------------------------------------
    // Memory declaration
    // -------------------------------------------------------------
    reg [31:0] rom [0:MEM_DEPTH-1];

    // -------------------------------------------------------------
    // Initialize ROM contents from an external hexadecimal file.
    // Each line should contain one 32‑bit word in hex format.
    // -------------------------------------------------------------
    initial begin
        $readmemh("program.hex", rom);   // change filename as needed
    end

    // -------------------------------------------------------------
    // Asynchronous read (combinational).  We drop the two LSBs to
    // convert the byte address to a word index.
    // -------------------------------------------------------------
    assign instr = rom[addr[31:2]];     // word‑aligned access

endmodule
