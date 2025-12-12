# Personal Contribution Statement — Ezekiel Lim

This document outlines my individual contributions to the RISC-V RV32I CPU project.  
My work spans three major components:  

1. **Single-Cycle CPU Design & Integration**  
2. **Pipelined CPU – Decode Unit, ISA Completion, and Testing**  
3. **Cached Pipelined CPU – Functional Design, Debugging, and Verification**  

I also include a section on **mistakes and lessons learned**, as well as **personal reflections**.

---

# 1. Single-Cycle CPU

My primary role in the single-cycle CPU was designing the decode logic, ensuring architectural correctness, and integrating my modules with Brandon and Jerry’s fetch and execute subsystems. I took a reference-driven approach by studying Harris & Harris as well as the official RV32I ISA reference card. This guided many early design decisions, signal definitions, and control-path structure.

---

## 1.1 Architectural Planning & Reference-Driven Design

Before coding, I produced a complete design plan for the single-cycle processor, including:

- Instruction formats  
- Immediate extraction logic  
- Control-signal mapping for every RV32I instruction  
- A unified decode unit interface for later pipelining  
- A clear separation between datapath logic and control logic  

**[Insert Image Here: Single-Cycle CPU Block Diagram]**

---

## 1.2 Decode Unit Implementation (`decode/` directory)

I implemented the decode logic for all RV32I instructions:  
R-type, I-type, S-type, B-type, U-type, J-type, and special instructions such as LUI/AUIPC and JALR.

My implementation consisted of:

### Instruction Field Extraction
- opcode  
- funct3  
- funct7  
- rs1, rs2, rd  
- immediate selection (I-imm, S-imm, B-imm, U-imm, J-imm)

### Control Signal Generation  
I generated all decode signals needed by later pipeline stages:

- `RegWrite`  
- `MemWrite`  
- `MemRead`  
- `ResultSrc` (ALU, PC+4, memory, immediate)  
- `Jump` (JAL, JALR)  
- `Branch` (BEQ/BNE/BLT/BGE/BLTU/BGEU)  
- `ALUSrc`  
- `ALUControl` (full mapping for RV32I)  
- Addressing modes for loads/stores  

**[Insert Image Here: Opcode → Control Signal Mapping Table]**

---

## 1.3 Integration Work

I collaborated with Brandon and Jerry to integrate my decode logic with:

- Program counter logic  
- Instruction memory  
- The ALU and register file  
- The writeback multiplexer  
- The hazard-free single-cycle datapath  

This standardised our signal naming conventions and ensured the CPU was structured for a smooth transition into pipelining.

---

## 1.4 Mistakes & Fixes (Single Cycle)

One important issue I discovered while writing tests was an incorrect implementation of **SRAI** (arithmetic right shift immediate).  
The CPU initially performed a *logical* right shift instead of *arithmetic*, causing sign-extension failures.

**[Insert Before/After Image Here: SRAI Incorrect vs Correct Implementation]**

Finding this bug early prevented the same error from propagating into the pipelined version.

---

## 1.5 Reflection (Single Cycle)

The single-cycle CPU gave me a strong foundation in understanding instruction decoding, datapath signal flow, and the architectural guarantees required by RV32I. Designing decode from scratch forced me to thoroughly understand instruction formats and their interactions.

---

# 2. Pipelined CPU

My largest contribution to the overall project was implementing the **decode stage for the pipelined CPU** and ensuring that the **full RV32I ISA** worked correctly under pipelining hazards, forwarding, and flushing.

I also wrote 10 assembly tests (tests 6–15) covering all instruction types.

---

## 2.1 Pipelined Decode Module (`decode/` folder)

I extended my single-cycle decoder into a decode stage that supports:

- Decode pipeline register (D → E)
- Flush and stall logic integration  
- Immediate generation per pipeline stage  
- Branch/jump control propagation  
- Register file reads under forwarding constraints  

I worked closely with Jerry, who handled fetch and branch logic, to ensure our decode signals matched the requirements of the execute and memory stages.

**[Insert Image Here: Pipeline Diagram Highlighting Decode Stage Signals]**

---

## 2.2 Ensuring Full ISA Coverage

A major responsibility of mine was verifying that **every instruction in the full RV32I base architecture** was implemented correctly in the pipelined design. This included:

- All ALU ops (ADD/SUB, SLT, SLTU, XOR, OR, AND, SLL, SRL, SRA)  
- All immediate ops  
- All branch conditions (signed/unsigned)  
- LUI/AUIPC  
- JAL/JALR  
- All loads/stores  

I created a cross-check document mapping each RV32I instruction to datapath and control signals, ensuring nothing was missing.

---

## 2.3 Assembly Tests (Tests 6–15)

To validate the CPU, I authored tests 6–15 entirely in assembly, each designed to capture one category of instruction:

- Shift operations  
- Branch families (BEQ/BNE, BLT/BGE, BLTU/BGEU)  
- Load/store with different addressing modes  
- AUIPC / LUI  
- Jump correctness  
- Sign-extension behaviour  
- Pipeline-hazard situations  

**[Insert Image Here: Screenshot of Tests or Waveform of Passing Test]**

Writing these tests is where I discovered the **SRAI bug**, which I then fixed.

---

## 2.4 Collaboration & Integration

I worked very closely with Jerry and Brandon during pipelining.  
While Jerry handled pipeline control (branching, PCSrc, flushing) and Brandon implemented execution/memory elements, I ensured that:

- Decode signals were correct  
- No instruction class was missing  
- ImmGen and ALUControl always matched the ISA  
- Hazard unit received correct metadata from decode  

This division of work made debugging structured and efficient.

---

# 3. Cached Pipelined CPU

My third major contribution was working on the **decode compatibility, memory interface**, and **debugging the cached pipelined CPU** after integration.

I helped ensure that:

- Cache control logic matched the CPU’s MemRead/MemWrite conventions  
- Addressing modes were correctly applied to loads/stores  
- Pipeline stalls during cache misses did not corrupt decode or execute stages  
- Dirty/valid/tag behaviours worked with our ISA semantics  

---

## 3.1 Cache Debugging: Identifying Pipeline Corruptions

After integrating the cache, we encountered issues where:

- ALUResultM was being flushed incorrectly  
- Memory stage values were overwritten during cache stalls  
- Decode/execute stages were progressing when they should freeze  
- Loads/stores produced inconsistent results  

Through waveform analysis and tracing decode signals, I discovered that **mem_stall** was not being propagated to freeze the pipeline.

---

## 3.2 Fix: Stall + Flush Logic Reconciliation

We solved the pipeline corruption by defining:

- `mem_stall` freezes F, D, and E pipeline registers  
- Memory stage *does not flush* during cache stall  
- Writeback stage does not receive invalid values  
- Cache “ready” signal unblocks pipeline only when safe  

**[Insert Image Here: GTKWave Screenshot Showing Correct Stall Behaviour]**

---

## 3.3 Ensuring ISA correctness with cache enabled

After fixing the stall logic, I reran my assembly tests and ensured that:

- LBU/SB  
- LH/SH  
- LW/SW  
- JALR + load combinations  
- Multi-cycle miss paths  

all behaved correctly.

This phase gave me the strongest understanding of timing, hazards, and memory-system behaviour.

---

# 4. Mistakes I Made & What I Learned

This section can stay honest but constructive.

## 4.1 Underestimating the complexity of decode  
I initially believed decode was “simple,” but implementing full ISA semantics revealed subtle interactions, especially with pipeline timing.

## 4.2 Incomplete initial testing  
My earliest tests only covered basic instructions, allowing SRAI to slip through. Writing much more rigorous tests (tests 6–15) taught me the value of targeted verification.

## 4.3 Misalignment between decode and memory stages  
During cache integration, I incorrectly assumed that decode signals would not impact memory timing. The bug proved otherwise.

(You can expand and personalise this section.)

---

# 5. Personal Reflection & Takeaways

This project gave me:

### 1. A deep understanding of computer architecture  
Not just “what each block does,” but **why each signal exists**, why timing matters, and how subtle misalignments cause unpredictable behaviour.

### 2. Confidence in debugging and waveform analysis  
By the end of the project, I could track stall, flush, hazards, and decode behaviour across hundreds of cycles.

### 3. Appreciation for clear interfaces and modular design  
The decision to create clean top modules (`decode_top`, `fetch_top`, `execute_top`) made integration much easier.

### 4. Value of ownership  
Implementing decode and ISA correctness end-to-end taught me that clear ownership leads to deeper understanding and fewer design conflicts.

### 5. Stronger collaboration skills  
Working with Brandon and Jerry—each handling different CPU subsystems—felt like a real hardware engineering workflow.

---