// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module pc_tb;

    // Inputs to DUT
    reg clk;
    reg reset;
    reg [31:0] next_pc;

    // Output from DUT
    wire [31:0] pc;

    // Instantiate DUT
    pc dut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Test counters
    integer tests_passed = 0;
    integer tests_failed = 0;

    // Task: check expected PC value
    task check_pc(input [31:0] expected, input [31:0] cycle);
        begin
            if (pc !== expected) begin
                $display("FAIL [Cycle %0d] PC = %h, expected = %h", cycle, pc, expected);
                tests_failed = tests_failed + 1;
            end else begin
                $display("PASS [Cycle %0d] PC = %h", cycle, pc);
                tests_passed = tests_passed + 1;
            end
        end
    endtask

    // Main test process
    initial begin
        $display("=== Starting PC Testbench ===");
        clk = 0;
        reset = 1;
        next_pc = 32'hABCD1234;
        #2;

        // 1. Reset behavior
        check_pc(32'h00000000, 0);  // async reset sets PC to 0

        #8; // wait for clk edge
        reset = 0;

        // 2. First update
        next_pc = 32'h00000004;
        #10;
        check_pc(32'h00000004, 1);

        // 3. Next update
        next_pc = 32'h00000008;
        #10;
        check_pc(32'h00000008, 2);

        // 4. Reset during valid next_pc
        reset = 1;
        next_pc = 32'h12345678;
        #10;
        check_pc(32'h00000000, 3);

        // 5. Come out of reset and update
        reset = 0;
        next_pc = 32'h0000000C;
        #10;
        check_pc(32'h0000000C, 4);

        // Summary
        $display("\n=== TEST SUMMARY ===");
        $display("Tests passed : %0d", tests_passed);
        $display("Tests failed : %0d", tests_failed);
        if (tests_failed == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("SOME TESTS FAILED.");

        $finish;
    end

endmodule
