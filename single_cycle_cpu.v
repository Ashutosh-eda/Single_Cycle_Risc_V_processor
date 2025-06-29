// Code your design here
// single_cycle_cpu.v  -- Top-level 32‑bit Single‑Cycle RISC‑V Processor (RV32)
// ---------------------------------------------------------------------------
// Instantiates all datapath and control modules to execute:
//   * R‑type  (add, sub, and, or)
//   * I‑type  (lw)
//   * S‑type  (sw)
//   * SB‑type (beq)
// ---------------------------------------------------------------------------

`timescale 1ns / 1ps

`include "pc.v"
`include "imem.v"
`include "control.v"
`include "regfile.v"
`include "immgen.v"
`include "alu_control.v"
`include "alu.v"
`include "dmem.v"
`include "pc_mux.v"

module single_cycle_cpu (
    input wire clk,
    input wire reset
);

    // -----------------------------------------------------------------------
    // Wires (declared in roughly top‑down datapath order)
    // -----------------------------------------------------------------------
    wire [31:0] pc, next_pc, pc_plus4, branch_target;
    wire [31:0] instr;

    // Instruction fields
    wire [6:0]  opcode  = instr[6:0];
    wire [4:0]  rd      = instr[11:7];
    wire [2:0]  funct3  = instr[14:12];
    wire [4:0]  rs1     = instr[19:15];
    wire [4:0]  rs2     = instr[24:20];
    wire [6:0]  funct7  = instr[31:25];

    // Control signals
    wire        RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0]  ALUOp;
    wire        PCSrc;  // derived later

    // Register file wires
    wire [31:0] reg_rs1, reg_rs2, write_data;

    // Immediate
    wire [31:0] imm;

    // ALU wires
    wire [31:0] alu_in_B, alu_result;
    wire [3:0]  ALUCtl;
    wire        Zero;

    // Data memory
    wire [31:0] dmem_read_data;

    // -----------------------------------------------------------------------
    // Module instantiations
    // -----------------------------------------------------------------------

    // Program Counter
    pc PC0 (
        .clk   (clk),
        .reset (reset),
        .next_pc(next_pc),
        .pc    (pc)
    );

    // Instruction Memory (ROM)
    imem IMEM0 (
        .addr  (pc),
        .instr (instr)
    );

    // Main Control Unit
    control CTRL0 (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .ALUOp    (ALUOp)
    );

    // Register File
    regfile RF0 (
        .clk   (clk),
        .reset (reset),
        .rs1   (rs1),
        .rd1   (reg_rs1),
        .rs2   (rs2),
        .rd2   (reg_rs2),
        .we    (RegWrite),
        .rd    (rd),
        .wd    (write_data)
    );

    // Immediate Generator
    immgen IMM0 (
        .instr (instr),
        .imm   (imm)
    );

    // ALU Control
    alu_control ALUCTL0 (
        .ALUOp  (ALUOp),
        .funct7 (funct7),
        .funct3 (funct3),
        .ALUCtl (ALUCtl)
    );

    // ALU operand B MUX
    assign alu_in_B = (ALUSrc) ? imm : reg_rs2;

    // ALU
    alu ALU0 (
        .A       (reg_rs1),
        .B       (alu_in_B),
        .ALUCtl  (ALUCtl),
        .Result  (alu_result),
        .Zero    (Zero)
    );

    // Data Memory
    dmem DMEM0 (
        .clk        (clk),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .addr       (alu_result),
        .write_data (reg_rs2),
        .read_data  (dmem_read_data)
    );

    // Write‑back MUX
    assign write_data = (MemtoReg) ? dmem_read_data : alu_result;

    // Branch decision logic
    assign PCSrc = Branch & Zero;

    // Adder: PC + 4 (sequential)
    assign pc_plus4 = pc + 32'd4;

    // Adder: PC + immediate (for branch target)
    assign branch_target = pc + imm;   // imm already shifted (for SB‑type)

    // Next PC MUX
    pc_mux PCMUX0 (
        .pc_plus4      (pc_plus4),
        .branch_target (branch_target),
        .PCSrc         (PCSrc),
        .next_pc       (next_pc)
    );

endmodule
