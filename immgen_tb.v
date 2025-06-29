// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module immgen_tb;

    // DUT I/O
    reg  [31:0] instr;
    wire [31:0] imm;

    // Instantiate DUT
    immgen dut (
        .instr(instr),
        .imm  (imm)
    );

    // Pass / fail counters
    integer pass = 0, fail = 0;

    task check;
        input [31:0] in_instr;
        input [31:0] exp_imm;
        begin
            instr = in_instr;
            #1;               // allow combinational delay
            if (imm === exp_imm) begin
                $display("PASS: instr = 0x%08h  imm = 0x%08h", in_instr, imm);
                pass = pass + 1;
            end
            else begin
                $display("FAIL: instr = 0x%08h  imm = 0x%08h (exp 0x%08h)",
                         in_instr, imm, exp_imm);
                fail = fail + 1;
            end
        end
    endtask

    // ------------------------------------------------------------------
    // Pre-encoded test instructions
    // ------------------------------------------------------------------
    // 1) lw  x1, 4(x2)
    localparam [31:0] LW_X1_4_X2  = 32'h00412083;   // opcode 0000011
    // 2) sw  x3, -8(x5)
    localparam [31:0] SW_X3_M8_X5 = 32'hFE32AC23;   // opcode 0100011
    // 3) beq x1, x2, 16
    localparam [31:0] BEQ_X1_X2_16 = 32'h00208863;  // opcode 1100011
    // 4) unsupported opcode (should give imm = 0)
    localparam [31:0] UNKNOWN      = 32'hFFFFFFFF;

    // Expected immediates
    localparam [31:0] IMM_LW  = 32'h00000004;         // +4
    localparam [31:0] IMM_SW  = 32'hFFFFFFF8;         // -8 (sign-extended)
    localparam [31:0] IMM_BEQ = 32'h00000010;         // 16 (already shifted)
    localparam [31:0] IMM_DEF = 32'h00000000;         // default

    // ------------------------------------------------------------------
    initial begin
        $display("=== Immediate Generator Testbench ===");

        check(LW_X1_4_X2 , IMM_LW );  // I-type
        check(SW_X3_M8_X5, IMM_SW );  // S-type
        check(BEQ_X1_X2_16, IMM_BEQ); // SB-type
        check(UNKNOWN     , IMM_DEF); // default path

        $display("\n=== TEST SUMMARY ===");
        $display("Passed: %0d  Failed: %0d", pass, fail);
        if (fail == 0) $display("ALL TESTS PASSED.");
        else           $display("SOME TESTS FAILED.");
        $finish;
    end

endmodule
