`timescale 1ns / 1ps

module control_tb;

  reg  [6:0] opcode;
  wire       RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
  wire [1:0] ALUOp;

  control dut (
    .opcode    (opcode),
    .RegWrite  (RegWrite),
    .ALUSrc    (ALUSrc),
    .MemRead   (MemRead),
    .MemWrite  (MemWrite),
    .MemtoReg  (MemtoReg),
    .Branch    (Branch),
    .ALUOp     (ALUOp)
  );

  integer pass = 0, fail = 0;

  task check;
    input [6:0] op;
    input exp_RegWrite, exp_ALUSrc, exp_MemRead, exp_MemWrite;
    input exp_MemtoReg, exp_Branch;
    input [1:0] exp_ALUOp;
    begin
      opcode = op;
      #1; // allow combinational logic to settle
      if (
        RegWrite  === exp_RegWrite  &&
        ALUSrc    === exp_ALUSrc    &&
        MemRead   === exp_MemRead   &&
        MemWrite  === exp_MemWrite  &&
        MemtoReg  === exp_MemtoReg  &&
        Branch    === exp_Branch    &&
        ALUOp     === exp_ALUOp
      ) begin
        $display("PASS: opcode=%b", op);
        pass = pass + 1;
      end else begin
        $display("FAIL: opcode=%b", op);
        $display("  Got:    RW=%b AS=%b MR=%b MW=%b M2R=%b B=%b ALUOp=%b",
                 RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
        $display("  Expect: RW=%b AS=%b MR=%b MW=%b M2R=%b B=%b ALUOp=%b",
                 exp_RegWrite, exp_ALUSrc, exp_MemRead, exp_MemWrite,
                 exp_MemtoReg, exp_Branch, exp_ALUOp);
        fail = fail + 1;
      end
    end
  endtask

  initial begin
    $display("\n=== Control Unit Testbench ===");

    // opcode = 0110011 → R-type
    check(7'b0110011, 1, 0, 0, 0, 0, 0, 2'b10);

    // opcode = 0000011 → lw
    check(7'b0000011, 1, 1, 1, 0, 1, 0, 2'b00);

    // opcode = 0100011 → sw
    check(7'b0100011, 0, 1, 0, 1, 0, 0, 2'b00);

    // opcode = 1100011 → beq
    check(7'b1100011, 0, 0, 0, 0, 0, 1, 2'b01);

    // unknown opcode → NOP/default
    check(7'b1111111, 0, 0, 0, 0, 0, 0, 2'b00);

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
