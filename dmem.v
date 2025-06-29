// dmem.v  -- Data Memory for a 32‑bit single‑cycle RISC‑V processor (RV32)
// ----------------------------------------------------------------------
// * Word‑addressable memory for loads and stores (lw / sw)
// * Synchronous write, asynchronous read (fits single‑cycle timing)
// * Byte‑addressed interface, but internally word‑aligned (addr[1:0] ignored)
// * Parameterizable depth; default 256 words (1 KiB)
// ----------------------------------------------------------------------

`timescale 1ns / 1ps

module dmem #(
    parameter MEM_DEPTH = 256                      // # of 32‑bit words
) (
    input  wire        clk,                        // system clock
    input  wire        MemRead,                    // read enable
    input  wire        MemWrite,                   // write enable
    input  wire [31:0] addr,                       // byte address from ALU
    input  wire [31:0] write_data,                 // data to write (rs2)
    output wire [31:0] read_data                   // data read (to register file)
);

    // --------------------------------------------------------------
    // Memory declaration: 32‑bit words
    // --------------------------------------------------------------
reg [31:0] ram [0:MEM_DEPTH-1];

    // --------------------------------------------------------------
    // Optional initialization from file (comment out if unused)
    // --------------------------------------------------------------
    initial begin
        $readmemh("data_init.hex", ram);           // provide file if desired
    end

    // --------------------------------------------------------------
    // Synchronous write (on rising edge) when MemWrite asserted.
    // Writes are word‑aligned; addr[1:0] are ignored.
    // --------------------------------------------------------------
    always @(posedge clk) begin
        if (MemWrite) begin
            ram[addr[31:2]] <= write_data;
        end
    end

    // --------------------------------------------------------------
    // Asynchronous read.  Output is valid in same cycle when MemRead=1.
    // If MemRead=0, read_data is driven to 0 to avoid X propagation.
    // --------------------------------------------------------------
    assign read_data = (MemRead) ? ram[addr[31:2]] : 32'h0000_0000;

endmodule
