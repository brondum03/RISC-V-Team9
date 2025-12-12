# Personal Contribution Statement — Ezekiel Lim

This document outlines my individual contributions to the RISC-V RV32I CPU project. It goes over the completed tasks, how and why design decisions were made, the strategies I used to overcome challenges and mistakes encountered while embarking on this project. At the end I have included the insights and lessons learnt from building the RISC-V CPU.

---

My work spans four major components:  

1. **Single-Cycle CPU Design & Integration**  
2. **Pipelined CPU – Decode Unit, ISA Completion, and Testing**  
3. **Cached Pipelined CPU – Functional Design and Debugging** 
4. **Extension of Single-Cycle CPU to Superscalar Processor that handles in process instructions** 

---

# 1. Single-Cycle CPU

My primary role in the single-cycle CPU was designing the decode logic, ensuring architectural correctness, and integrating my modules with Brandon, Jerry and Enqi's fetch, execute and memory submodules. I took a reference-driven approach by studying Harris & Harris as well as the official RV32I ISA reference card. This guided many early design decisions, signal definitions, and control-path structure.

---

## 1.1 Architectural Planning & Reference-Driven Design

Before coding, I read up on the single cycle CPU in Harris & Harris to understand the basics of how to implement a simple decode_top module and the considerations to take into account when doing so. 

As per the design in the book, I split the Control Unit up into an ALU Decoder and a Main Decoder. 
The following design is what I referenced initially to make design the decode module:

**[Insert Image Here: Single-Cycle CPU Block Diagram]**

**[Insert Image of aludecoder and maindecoder here]**

---

## 1.2 Decode Unit Implementation (`decode/` directory)

---

## Control Unit

I started with the control unit which i believed would have been the most time consuming and core aspect of the decode section. Initially, I split the control unit into `MainDecoder` and `ALUDecoder`. I used the following references when implementing and parsing the instruction bits.

**[Insert Image of riscV reference here]**

### ALU Decoder

Looking at the image above, I noticed that there were 10 instructions for R instructions. When comparing to the reference design, `ALUControl` only showed a 3 bit output (up to 8 combinations). This means that in order to account for all the instructions, the most straight forward approach was to increase ALUControl output to 4 bits (up to 16 combinations) and map that to each instruction. 

The following image is my input and output for the `ALUDecoder` and also which operation each `ALUControl` maps to:

**[Insert Image of ALUDecoder]**

### Main Decoder

When working on the `MainDecoder`, the initial step was to take a look at the core instruction formats and note how many instructions have to handle immediate extension as this would determine how I decide to implement the `signExtend` module. Looking at core instructions, I noted that there were a total of 6 instructions, R, I, S, B, U and J. However, R instructions do not require sign extension as they do not use immediates. As such, there are 5 instructions where immediate would have to be sign extended. When looking at the initial design, `ImmSrc` was 2 bits (maximum 4 types of instructions). As such, I increased `ImmSrc` to 3 bits so as to account for every type of instruction.

The following is how i mapped `ImmSrc` to the instruction type :

| ImmSrc (binary) | Instruction Type |
|-----------------|------------------|
| `000`           | **I-type**       |
| `001`           | **S-type**       | 
| `010`           | **B-type**       |
| `011`           | **U-type**       |
| `100`           | **J-type**       | 

As I was trying to start on working on the full instruction set from the get go, I started to consider `branch` and `jump` instructions affecting the `PC` as well. Initially `PCSrc` was 1 bit as it was simply to move to the next instruction `PC + 4` or the branched instruction `PCTarget`. I decided that to take into account stalling and jump instructions as well, we would require 2 bits for our `PCSrc` (maximum 4 types for `PCNext`).

The following is how I mapped `PCSrc` to what kind of `PCNext` to take :

| PCSrc (binary) | Meaning / Selected Next PC |
|----------------|----------------------------|
| `00`           | **PC + 4** (normal sequential execution) |
| `01`           | **PCTarget** (branch taken or JAL) |
| `10`           | **ALUResult** (JALR target) |
| `11`           | **PC** (stall — hold current PC) |

```verilog 

mux4 pcmux(
    .in0(PCPlus4),
    .in1(PCTarget),
    .in2(ALUResult),
    .in3(PC),
    .sel(PCsrc),
    .out(PCNext)
);

```

The final increase in bit width I had to do was on `ResultSrc` (compared to the Harris & Harris diagram). The initial `ResultSrc` was only 1 bit to choose between `ALUResult` and `ReadData`. However, to account for all the instructions we would have to add an additional bit. 
Initially, 
`ResultSrc = 0`, `ALUResult` is written back to register file (for R, I instructions and address calculations)
`ResultSrc = 1`, `ReadData` is written back to register file (for load instructions)

The issue now is that jump instructions cannot be implemented as such we increase to a 2 bit selector. 00 and 01 remain the same. 
`ResultSrc = 10`, `PC+4` is stored (for jump instructions, to store return address before jumping to the target)
`ResultSrc = 11`, `ImmExt` is stored (upper immediate storing due to the limitations of riscv with adding immediates more than 3 bytes)

The following is how I mapped `ResultSrc` to select `Result` in `memory_top`

| ResultSrc (binary) | Written Back Value | Instructions Affected |
|--------------------|--------------------|------------------------|
| `00`               | **ALUResult**      | R-type ops, I-type ALU ops, address calculations |
| `01`               | **ReadData**       | Load instructions (LB, LH, LW, LBU, LHU) |
| `10`               | **PC + 4**         | JAL, JALR (store return address before jumping) |
| `11`               | **ImmExt**         | U-type: LUI, AUIPC (handling upper-immediate values) |

On top of increasing the output bit width of `PCSrc`, `ResultSrc` and `ImmSrc`, In my main decoder I also introduced `AddressingMode` output (1 bit) which selected between 

| AddressingMode | Type |
|----------------|------|
|`0`             | Word |
|`1`             | Byte |


This was done in order to correctly parse the bits for the 5 tests given. 
The following is the snippet of code where `AddressingMode` was used in Load and Store instructions :

```verilog 

// I -> load operations --> lw, lb, lbu
7'b0000011: begin
    RegWrite = 1;
    ALUSrc = 1;
    ResultSrc = 1;
    ImmSrc = 3'b000;
    MemWrite = 1'b0;
    PCSrc = 2'b00;
    case(funct3)
        3'b010: AddressingMode = 1'b0;  // lw
        3'b100: AddressingMode = 1'b1;  // lbu
        default: AddressingMode = 1'b0;
    endcase
end
// S -> store operations --> sw, sb
7'b0100011: begin
    MemWrite = 1;
    ALUSrc = 1;
    ImmSrc = 3'b001;
    RegWrite = 1'b0;
    PCSrc = 2'b00;
    case(funct3) 
        3'b000: AddressingMode = 1'b1;  // sb
        3'b010: AddressingMode = 1'b0;  // sw
        default: AddressingMode = 1'b0;
    endcase
end

```

An additional input, `negative` was also added. This was done to implemented conditional branches which is showed in this snippet of code from `MainDecoder` :

```verilog
// B -> conditional branch operations -->> beq, bne, blt, bge
7'b1100011: begin
    RegWrite = 1'b0;
    ALUSrc = 1'b0;
    ImmSrc = 3'b010;
    MemWrite = 1'b0;
    case (funct3)
        3'b000: PCSrc = Zero ? 2'b01 : 2'b0;       // beq
        3'b001: PCSrc = ~Zero ? 2'b01 : 2'b0;      // bne
        3'b100: PCSrc = negative ? 2'b01 : 2'b0;   // blt 
        3'b101: PCSrc = ~negative ? 2'b01 : 2'b0;  // bge
        3'b110: PCSrc = negative ? 2'b01 : 2'b0;   // bltu
        3'b111: PCSrc = ~negative ? 2'b01 : 2'b0;  // bgeu
        default: PCSrc = 2'b0; // Default case
    endcase
end
```


The following is my Main Decoder submodule : 
**[Insert Image of Main Decoder]**



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