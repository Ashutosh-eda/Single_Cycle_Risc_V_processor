`timescale 1ns / 1ps

module regfile_tb;

    // DUT signals
    reg         clk = 0;
    reg         reset;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] wd;
    reg         we;
    wire [31:0] rd1, rd2;

    // Instantiate DUT
    regfile uut (
        .clk(clk), .reset(reset),
        .rs1(rs1), .rd1(rd1),
        .rs2(rs2), .rd2(rd2),
        .we(we),   .rd(rd), .wd(wd)
    );

    // 10 ns period clock
    always #5 clk = ~clk;

    // Counters
    integer pass = 0, fail = 0;

    task check;
        input [4:0] r1, r2; input [31:0] e1, e2;
        begin
            rs1 = r1; rs2 = r2; #1;
            if (rd1 === e1 && rd2 === e2) begin
                $display("PASS: x%0d=0x%08h  x%0d=0x%08h", r1, rd1, r2, rd2);
                pass = pass + 1;
            end else begin
                $display("FAIL: x%0d=0x%08h(exp 0x%08h)  x%0d=0x%08h(exp 0x%08h)",
                         r1, rd1, e1, r2, rd2, e2);
                fail = fail + 1;
            end
        end
    endtask

    initial begin
        $display("=== Register File Testbench ===");

        // --- Reset all regs ---
        reset = 1; we = 0; rd = 0; wd = 0; rs1 = 0; rs2 = 0;
        @(negedge clk); reset = 0;      // release reset on a negedge
        @(posedge clk); #1;
        check(0, 1, 32'h0, 32'h0);

        // --- Write x1 ---
        @(negedge clk); we = 1; rd = 1; wd = 32'hAAAABBBB;
        @(posedge clk); #1;
        check(1, 0, 32'hAAAABBBB, 32'h0);

        // --- Write x2 ---
        @(negedge clk); rd = 2; wd = 32'h12345678;
        @(posedge clk); #1;
        check(1, 2, 32'hAAAABBBB, 32'h12345678);

        // --- Attempt write to x0 (ignored) ---
        @(negedge clk); rd = 0; wd = 32'hFFFFFFFF;
        @(posedge clk); #1;
        check(0, 1, 32'h0, 32'hAAAABBBB);

        // --- Overwrite x1 ---
        @(negedge clk); rd = 1; wd = 32'hDEADBEEF;
        @(posedge clk); #1;
        check(1, 2, 32'hDEADBEEF, 32'h12345678);

        // ------------------------------------------------------------
        // Edge-sensitive test:
        //   • Set write on negedge → value must NOT appear yet
        //   • Verify after same negedge
        //   • Then after posedge it must appear
        // ------------------------------------------------------------
        $display("\n-- Edge-sensitive write test --");

        @(negedge clk);
        we = 1; rd = 3; wd = 32'hCAFEBABE;
        #1;                               // still at negedge
        check(3, 0, 32'h0, 32'h0);        // expect old value (0)

        @(posedge clk);                   // write takes effect
        #1;
        check(3, 0, 32'hCAFEBABE, 32'h0);

        // --- Summary ---
        $display("\n=== TEST SUMMARY ===");
        $display("Passed: %0d  Failed: %0d", pass, fail);
        if (fail == 0) $display("ALL TESTS PASSED.");
        else           $display("SOME TESTS FAILED.");
        $finish;
    end

endmodule
