// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module alu_control_tb;

    // DUT Inputs
    reg  [1:0] ALUOp;
    reg  [6:0] funct7;
    reg  [2:0] funct3;

    // DUT Output
    wire [3:0] ALUCtl;

    // Instantiate DUT
    alu_control dut (
        .ALUOp(ALUOp),
        .funct7(funct7),
        .funct3(funct3),
        .ALUCtl(ALUCtl)
    );

    // Test control
    integer tests_passed = 0, tests_failed = 0;

    // Check task
    task check;
        input [1:0] op;
        input [6:0] f7;
        input [2:0] f3;
        input [3:0] expected;
        begin
            ALUOp  = op;
            funct7 = f7;
            funct3 = f3;
            #1;
            if (ALUCtl !== expected) begin
                $display("FAIL: ALUOp=%02b funct7=%07b funct3=%03b => ALUCtl=%04b (exp %04b)",
                         ALUOp, funct7, funct3, ALUCtl, expected);
                tests_failed = tests_failed + 1;
            end else begin
                $display("PASS: ALUOp=%02b funct7=%07b funct3=%03b => ALUCtl=%04b",
                         ALUOp, funct7, funct3, ALUCtl);
                tests_passed = tests_passed + 1;
            end
        end
    endtask

    initial begin
        $display("=== ALU Control Unit Testbench ===");

        // ADD (LW/SW)
        check(2'b00, 7'bxxxxxxx, 3'bxxx, 4'b0010);  

        // SUB (BEQ)
        check(2'b01, 7'bxxxxxxx, 3'bxxx, 4'b0110);

        // R-type ADD
        check(2'b10, 7'b0000000, 3'b000, 4'b0010);

        // R-type SUB
        check(2'b10, 7'b0100000, 3'b000, 4'b0110);

        // R-type AND
        check(2'b10, 7'b0000000, 3'b111, 4'b0000);

        // R-type OR
        check(2'b10, 7'b0000000, 3'b110, 4'b0001);

        // Unknown funct combo (default = AND)
        check(2'b10, 7'b1111111, 3'b101, 4'b0000);

        // Undefined ALUOp
        check(2'b11, 7'b0000000, 3'b000, 4'b0000);

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
