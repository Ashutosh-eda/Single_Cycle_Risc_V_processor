// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module imem_tb;

  // DUT interface
  reg  [31:0] addr;
  wire [31:0] instr;

  // Instantiate the DUT (device under test)
  imem #(.MEM_DEPTH(256)) dut (
    .addr(addr),
    .instr(instr)
  );

  // Test statistics
  integer tests_passed = 0;
  integer tests_failed = 0;

  // Compare actual vs expected instruction
  task check_instr;
    input [31:0] test_addr;
    input [31:0] expected_instr;
    begin
      addr = test_addr;
      #1;  // wait for asynchronous read
      if (instr !== expected_instr) begin
        $display("FAIL: addr = 0x%08h → instr = 0x%08h (expected 0x%08h)", test_addr, instr, expected_instr);
        tests_failed = tests_failed + 1;
      end else begin
        $display("PASS: addr = 0x%08h → instr = 0x%08h", test_addr, instr);
        tests_passed = tests_passed + 1;
      end
    end
  endtask

  // Run the test
  initial begin
    $display("=== Instruction Memory Testbench Start ===");

    // Use addresses in word-aligned steps
    check_instr(32'h00000000, 32'h08002083); // lw   x1, 128(x0)
    check_instr(32'h00000004, 32'h08402103); // lw   x2, 132(x0)
    check_instr(32'h00000008, 32'h002081B3); // add  x3, x1, x2
    check_instr(32'h0000000C, 32'h08802223); // sw   x3, 136(x0)
    check_instr(32'h00000010, 32'h00000063); // beq  x0, x0, 0

    $display("\n=== TEST SUMMARY ===");
    $display("Tests passed: %0d", tests_passed);
    $display("Tests failed: %0d", tests_failed);

    if (tests_failed == 0)
      $display("ALL TESTS PASSED.");
    else
      $display("SOME TESTS FAILED.");

    $finish;
  end

endmodule
