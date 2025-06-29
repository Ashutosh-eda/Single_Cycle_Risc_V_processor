// alu_tb.v — Self-checking testbench for alu.v

`timescale 1ns / 1ps

module alu_tb;

    reg  [31:0] A, B;
    reg  [3:0]  ALUCtl;
    wire [31:0] Result;
    wire        Zero;

    integer     pass = 0, fail = 0;

    alu uut (
        .A(A),
        .B(B),
        .ALUCtl(ALUCtl),
        .Result(Result),
        .Zero(Zero)
    );

    task check;
        input [31:0] inA, inB;
        input [3:0]  ctl;
        input [31:0] expRes;
        input        expZero;

        begin
            A = inA;
            B = inB;
            ALUCtl = ctl;
            #1;
            if (Result !== expRes || Zero !== expZero) begin
                $display("FAIL: ctl=%b A=0x%08h B=0x%08h => R=0x%08h (exp 0x%08h), Z=%b (exp %b)",
                         ctl, inA, inB, Result, expRes, Zero, expZero);
                fail = fail + 1;
            end else begin
                $display("PASS: ctl=%b A=0x%08h B=0x%08h => R=0x%08h, Z=%b",
                         ctl, inA, inB, Result, Zero);
                pass = pass + 1;
            end
        end
    endtask

    initial begin
        $display("\n=== ALU Testbench ===");

        // AND
        check(32'hFFFF0000, 32'h0F0F0F0F, 4'b0000, 32'h0F0F0000, 0);
        check(32'h00000000, 32'h00000000, 4'b0000, 32'h00000000, 1);

        // OR
        check(32'h00000000, 32'h12345678, 4'b0001, 32'h12345678, 0);

        // ADD
        check(32'h00000001, 32'h00000002, 4'b0010, 32'h00000003, 0);
        check(32'hFFFFFFFF, 32'h00000001, 4'b0010, 32'h00000000, 1); // wraparound

        // SUB
        check(32'h00000005, 32'h00000003, 4'b0110, 32'h00000002, 0);
        check(32'h12345678, 32'h12345678, 4'b0110, 32'h00000000, 1);

        // SLT
        check(32'h00000001, 32'h00000002, 4'b0111, 32'h00000001, 0);
        check(32'h00000002, 32'h00000001, 4'b0111, 32'h00000000, 1);
        check(32'hFFFFFFFF, 32'h00000001, 4'b0111, 32'h00000001, 0); // -1 < +1

        // NOR
        check(32'h00000000, 32'h00000000, 4'b1100, 32'hFFFFFFFF, 0);
        check(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b1100, 32'h00000000, 1);
        // Unknown control (fallback to 0 → Zero must be 1)
        check(32'hAAAA5555, 32'h12345678, 4'b1111, 32'h00000000, 1);

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
