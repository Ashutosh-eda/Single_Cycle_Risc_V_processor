// Code your testbench here
// or browse Examples
// dmem_tb.sv -- Self-checking testbench for dmem.v

`timescale 1ns / 1ps

module dmem_tb;

    // Parameters
    localparam MEM_DEPTH = 256;

    // DUT Inputs
    reg         clk;
    reg         MemRead;
    reg         MemWrite;
    reg  [31:0] addr;
    reg  [31:0] write_data;

    // DUT Output
    wire [31:0] read_data;

    // Instantiate DUT
    dmem #(MEM_DEPTH) dut (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Testbench control
    integer tests_passed = 0, tests_failed = 0;

    task check_read;
        input [31:0] read_val, expected;
        begin
            if (read_val !== expected) begin
                $display("FAIL: Read 0x%08h (expected 0x%08h)", read_val, expected);
                tests_failed = tests_failed + 1;
            end else begin
                $display("PASS: Read 0x%08h", read_val);
                tests_passed = tests_passed + 1;
            end
        end
    endtask

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $display("=== Data Memory Testbench ===");
        $readmemh("data_init.hex", dut.ram); // Optional: preload memory

        // Initial values
        clk = 0;
        MemRead = 0;
        MemWrite = 0;
        addr = 0;
        write_data = 0;

        @(negedge clk);

        // --- Write to address 0x00000010 ---
        addr = 32'h00000010;
        write_data = 32'hdeadbeef;
        MemWrite = 1;
        @(negedge clk);
        MemWrite = 0;

        // --- Read from address 0x00000010 ---
        MemRead = 1;
        @(negedge clk);
        check_read(read_data, 32'hdeadbeef);
        MemRead = 0;

        // --- Write to address 0x00000020 ---
        addr = 32'h00000020;
        write_data = 32'h12345678;
        MemWrite = 1;
        @(negedge clk);
        MemWrite = 0;

        // --- Read from address 0x00000020 ---
        MemRead = 1;
        @(negedge clk);
        check_read(read_data, 32'h12345678);
        MemRead = 0;

        // --- Read with MemRead = 0 (should return 0) ---
        addr = 32'h00000010;
        MemRead = 0;
        @(negedge clk);
        check_read(read_data, 32'h00000000);

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
