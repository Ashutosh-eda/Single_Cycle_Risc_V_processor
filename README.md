# Single_Cycle_Risc_V_processor
# Single-Cycle RISC-V Processor (RV32I)

This project implements a synthesizable **single-cycle 32-bit RISC-V processor** (RV32I base subset), written entirely in Verilog. It supports key instruction types and comes with a self-checking testbench and waveform tracing for functional verification.

## 🔧 Features

- ISA: RV32I (Base Integer ISA)
- Instruction support:
  - R-type: `add`, `sub`, `and`, `or`
  - I-type: `lw`
  - S-type: `sw`
  - SB-type: `beq`
- Fully synthesizable design (with minor adjustments)
- Modular design structure
- Self-checking testbench using `$fatal`
- Waveform generation using `$dumpvars` for GTKWave

---

## 📁 Project Structure

