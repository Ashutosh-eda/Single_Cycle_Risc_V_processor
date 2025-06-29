// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module pc_mux_tb;

  // Test inputs
  reg  [31:0] pc_plus4;
  reg  [31:0] branch_target;
  reg         PCSrc;

  // Output to monitor
  wire [31:0] next_pc;

  // Instantiate the Unit Under Test
  pc_mux dut (
    .pc_plus4      (pc_plus4),
    .branch_target (branch_target),
    .PCSrc         (PCSrc),
    .next_pc       (next_pc)
  );

  integer pass = 0, fail = 0;

  task check;
    input [31:0] in_pc_plus4;
    input [31:0] in_branch_target;
    input        in_PCSrc;
    input [31:0] expected;
    begin
      pc_plus4 = in_pc_plus4;
      branch_target = in_branch_target;
      PCSrc = in_PCSrc;
      #1; // allow propagation

      if (next_pc === expected) begin
        $display("PASS: PCSrc=%b => next_pc=0x%08h", PCSrc, next_pc);
        pass = pass + 1;
      end else begin
        $display("FAIL: PCSrc=%b => next_pc=0x%08h (exp 0x%08h)", PCSrc, next_pc, expected);
        fail = fail + 1;
      end
    end
  endtask

  initial begin
    $display("\n=== PC MUX Testbench ===");

    // Test: PCSrc = 0 => choose pc_plus4
    check(32'h0000_0004, 32'h0000_00C0, 1'b0, 32'h0000_0004);
    check(32'hDEAD_BEEF, 32'h1234_5678, 1'b0, 32'hDEAD_BEEF);

    // Test: PCSrc = 1 => choose branch_target
    check(32'h0000_0004, 32'h0000_00C0, 1'b1, 32'h0000_00C0);
    check(32'h1111_1111, 32'h0000_0BAD, 1'b1, 32'h0000_0BAD);

    $display("\n=== TEST SUMMARY ===");
    $display("Tests passed: %0d", pass);
    $display("Tests failed: %0d", fail);

    if (fail == 0)
      $display("ALL TESTS PASSED.");
    else
      $display("SOME TESTS FAILED.");

    $finish;
  end

endmodule
