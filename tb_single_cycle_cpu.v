`timescale 1ns / 1ps

module tb_single_cycle_cpu;

    // --------------------------------------------------------
    // Clock and Reset
    // --------------------------------------------------------
    reg clk   = 0;
    reg reset = 1;

    always #5 clk = ~clk;  // 100 MHz

    // --------------------------------------------------------
    // DUT instantiation
    // --------------------------------------------------------
    single_cycle_cpu DUT (
        .clk(clk),
        .reset(reset)
    );

    // --------------------------------------------------------
    // Signal aliases for internal memory/register viewing
    // --------------------------------------------------------
    wire [31:0] x1  = DUT.RF0.regs[1];
    wire [31:0] x2  = DUT.RF0.regs[2];
    wire [31:0] x3  = DUT.RF0.regs[3];
    wire [31:0] mem_88 = DUT.DMEM0.ram[34];

    // --------------------------------------------------------
    // VCD dump setup
    // --------------------------------------------------------
    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, tb_single_cycle_cpu);  // dump all hierarchy
        $dumpvars(0, x1, x2, x3, mem_88);   // explicit wires for register/mem
    end

    // --------------------------------------------------------
    // Expected values
    // --------------------------------------------------------
    localparam [31:0] EXP_X1      = 32'h00000001;
    localparam [31:0] EXP_X2      = 32'h00000002;
    localparam [31:0] EXP_X3      = 32'h00000003;
    localparam [31:0] EXP_MEM_88  = 32'h00000003;
    localparam [31:0] EXP_PC_LOOP = 32'h00000010;

    // --------------------------------------------------------
    // Task for checking values
    // --------------------------------------------------------
    task check_equal(input [31:0] actual, input [31:0] expected, input string name);
        begin
            $display("Checking %-14s | Expected: 0x%08h | Actual: 0x%08h", name, expected, actual);
            if (actual !== expected)
                $fatal(1, "FAIL: %s mismatch. Expected 0x%08h, got 0x%08h", name, expected, actual);
        end
    endtask

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------
    initial begin
        $display("----- Resetting processor -----");
        repeat (2) @(posedge clk);
        reset <= 0;

        $display("----- Running instruction sequence -----");
        repeat (11) @(posedge clk);  // allow full execution

        $display("\n----- Verifying results -----\n");

        check_equal(x1,      EXP_X1,      "x1");
        check_equal(x2,      EXP_X2,      "x2");
        check_equal(x3,      EXP_X3,      "x3");
        check_equal(mem_88,  EXP_MEM_88,  "dmem[0x88]");
        check_equal(DUT.PC0.pc, EXP_PC_LOOP, "Program Counter");

        $display("\nTEST PASSED: All values matched expected outputs.\n");
        $finish;
    end

endmodule


