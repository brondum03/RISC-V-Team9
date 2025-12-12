# Personal Contribution Statement — Brandon Auyong

This document outlines my individual contributions to the RISC-V CPU project, structured according to the main tasks I worked on:

1. [**Single-Cycle**](#Single-Cycle) 
2. [**Pipelining**](#Pipelining)
3. [**Caching**](#Caching)
4. [**Branch Prediction**](#Branch-Predction)  

## Introduction
I played the role of an RTL engineer in this project, simulating hardware design through SystemVerilog together with teammates Jerry and Ezekiel. The past weeks have been extremely engaging and fulfilling. The practical experience of implementing hardware design learned in lectures and the satisfaction of seeing our modules run is addictive.

My main contributions to the project came in the execute and memory stages of our CPU. Notably, I developed the **ALU** and **datamemory** within the base CPU. In the pipelined design, I desgined the **hazard unit** for detection and handling of control and data hazards. I also designed the full **cache** and **branch prediction** CPU for our extensions. Throughout the project, Jerry, Ezekiel, and I worked closely to integrate and debug our code.

I try to avoid excess code snippets here to keep it concise, but I have included relevant excerpts to illustrate key design decisions and implementations. 

## Single-Cycle
My primary responsibility during the single-cycle phase was the design and implementation of the Execution Stage and Memory Stage components. 

1. Arithmetic Logic Unit (`alu.sv`)

I designed the ALU to support the full RV32I instruction set required for the project.
I implemented a purely combinational module using a case statement to select operations based on the 4-bit ALUControl signal.

Operations: 
````SystemVerilog
            ADD:   ALUout = ALUop1 + ALUop2; 
            SUB:   ALUout = ALUop1 - ALUop2; 
            AND:   ALUout = ALUop1 & ALUop2; 
            OR:    ALUout = ALUop1 | ALUop2; 
            XOR:   ALUout = ALUop1 ^ ALUop2; 
            SLL:   ALUout = ALUop1 << ALUop2;
            SRL:   ALUout = ALUop1 >> ALUop2;
            SRA: ALUout = $signed(ALUop1) >>> ALUop2;
            SLT:   ALUout = ($signed(ALUop1) < $signed(ALUop2)) ? {31'b0, 1'b1} : 32'b0;
            SLTU:  ALUout = ($unsigned(ALUop1) < $unsigned(ALUop2)) ? {31'b0, 1'b1} : 32'b0;
````
Output flags for branch and jump instructions:
````SystemVerilog
            assign Zero = (ALUout == {DATA_WIDTH{1'b0}}); 
            assign Negative = (ALUout[DATA_WIDTH-1] == 1);
````

2. Data Memory (`datamemory.sv`)
I defined the memory as a logic array and initialized it using $readmemh to load test data (such as the Gaussian distribution array for the PDF reference program)

3. Testing and Debugging
These modules were then integrated in top.sv, together with top level files for fetch and decode. Together with Ezekiel, I first used command verilator--lint-only <filename> to test each module, resolving all the errors that surfaced. Likely due to lack of experience at that point, this process took a while before our CPU was able to pass all 5 provided tests. We had messy naming conventions which made the integration difficult. From this point forward, our group decided to reference the design and naming convention of the textbook Digital Design and Computer Architecture by Harris & Harris. The design in the textbook would act as the basis for us to build upon for the rest of the project.

## Pipelining
I began by defining the interfaces for the EX/MEM pipeline register, ensuring all necessary control signals (like RegWrite, MemWrite, and ResultSrc) and data signals (ALUResult, WriteData, Rd) were correctly propagated through the stages.
Under the execute stage, I was also responsible for the hazard unit and pcsrc logic (for branch and jump instructions)

1. Hazard Unit (`hazard_unit.sv`)
I first designed the hazard unit to handle data dependency, when instructions in the execute stage required data from instructions in the memory or writeback stage. This is overcome with forwarding the data in the memory or writeback stage to the execute stage, such that the CPU does not need to stall while waiting for the data to be written back to the registers.

````SystemVerilog
if((Rs1E == RdM) && RegWriteM & (Rs1E!=0))   // forward from memory stage 
        ForwardAE = 2'b10;
    else if((Rs1E == RdW) && RegWriteW && (Rs1E!=0))  // forward from writeback stage
        ForwardAE = 2'b01;
    else 
        ForwardAE = 2'b00;
````

This code is duplicated for signal (`ForwardBE`). Together, these two signals drive the 3-mux which dictates the inputs into the ALU within (`execute_top.sv`), whether they are forwarded or from the register file:

````SystemVerilog
mux4 Forward_mux_A(
        .in0(RD1E),
        .in1(ResultW),
        .in2(ALUResultM),
        .in3(32'b0),
        .sel(ForwardAE),
        .out(SrcAE)
    );
````

To address load-use hazards, whereby subsequent instructions are awaiting data from the memory stage, a hardware stall is necessary. To detect the (`lw`) instruction, the hazard unit looks at (`ResultSrcE`) which indicates reading from data memory. The pipeline registers are then stalled in the fetch and decode stages. 

````SystemVerilog
lwStall = ResultSrcE[0] & ((Rs1D == RdE) | (Rs2D == RdE));
StallF = lwStall;
StallD = lwStall;
````

At the same time, the execute stage is flushed to prevent incorrect execution:

````SystemVerilog
 FlushE = lwStall;
````

2. PCSrc Logic (`pcsrc_logic.sv`)
I designed the pcsrc logic to determine the next value of the program counter (PC) based on branch and jump instructions. The module takes in signals indicating whether the current instruction is a branch or jump, along with the Zero and Negative flags from the ALU. Based on these inputs, the module outputs a 2-bit (`PCSrc`) signal that dictates the source of the next PC value.

``` SystemVerilog
always_comb begin   // check for jump instructions 
        case (JumpE)
            2'b01: PCSrcE = 1'b1;  
            2'b10: PCSrcE = 1'b1;   
        default: begin  // then check for branch conditions
            case (BranchE)
                3'b001: PCSrcE = ZeroE;             // BEQ
                3'b010: PCSrcE = ~ZeroE;            // BNE
                3'b011: PCSrcE = NegativeE;         // BLT
                3'b100: PCSrcE = ~NegativeE;        // BGE
                3'b101: PCSrcE = Less_unsignedE;    // BLTU 
                3'b110: PCSrcE = ~Less_unsignedE;   // BGEU 
                default: PCSrcE = 1'b0;
            endcase
        end 
        endcase
    end
```

3. Integration and Testing
After implementing the hazard unit and pcsrc logic, I integrated these modules into the pipelined CPU design. Debugging this stage was challenging, as the interactions between pipeline stages could lead to subtle bugs. Jerry ultimately identified several issues which he painstakingly debugged, allowing us to pass all the given tests. After this experience, we became more proficient at debugging and integrating our modules for the subsequent caching and branch prediction stages. Additionally, we identified the need for better testbenches to catch bugs earlier in the process. Ezekiel took the lead in developing individual instruction testbenches for our modules.

## Caching
For the caching stage, I took the lead for designing and implementing the entire cache module (`cache_top.sv`) and integrating it into the CPU design. I relied heavily on Harris & Harris' textbook for the cache architecture and design principles. For my design considerations, I wanted to go above and beyond the project requirements by implementing a 2-way set associative cache with LRU replacement policy and a 4-word block size. 

This design choice was made to leverage **temporal and spatial locality**. A 2-way set associative cache can significantly reduce conflict misses compared to a direct-mapped cache, while increasing the block size would also be beneficial for programs with sequential memory access patterns. Implementing the LRU replacement policy further optimizes cache performance by ensuring that the least recently used data is replaced first, which is particularly effective in workloads with repeated access patterns. Finally, I designed the cache to be write-back with write-allocate, which helps to minimize write latency and improve overall performance.

1. Cache Top Level Module (`cache_top.sv`)
The 17-bit CPU address is parsed by `cache_top` into the following fields:

```
Address[16:0]:
┌────────────────┬───────────────┬──────────────┬─────────────┐
│    Tag [16:9]  │ Set Index[8:4]│Block Off[3:2]│Byte Off[1:0]│
│    (8 bits)    │   (5 bits)    │   (2 bits)   │  (2 bits)   │
└────────────────┴───────────────┴──────────────┴─────────────┘
```

| Field | Bits | Purpose |
|-------|------|---------|
| Tag | [16:9] | Identifies memory block for tag comparison |
| Set Index | [8:4] | Selects one of 32 cache sets |
| Block Offset | [3:2] | Selects word within 4-word block |
| Byte Offset | [1:0] | Selects byte within word (for LB/LH/SB/SH) |

2. Cache Controller (`cache_controller.sv`)
The cache controller manages read and write requests from the CPU, handling hits and misses. On a cache hit, it provides data directly from the cache. On a miss, it initiates a block fetch from main memory, updates the cache, and then serves the CPU request. The controller also manages write-backs for dirty blocks. This all done through a five-state finite state machine (FSM):

````SystemVerilog
typedef enum logic [2:0] {
        IDLE,
        CHECK_TAG,
        ALLOCATE,
        REFILL,
        WRITE_BACK
    } cache_state;
````
| State      | Description |
|------------|-------------|
| **Idle**       | The controller waits for CPU requests. Upon a read or write request, it transitions to the Check Tag state to determine if the requested data is in the cache. If it's a hit, it returns to Idle; if it's a miss, it moves to Allocate or Write Back states as needed. |
| **Check Tag**  | The controller compares the requested address's tag with the tags stored in the selected cache set. If a match is found and the valid bit is set, it's a hit; otherwise, it's a miss. It then responds accordingly, either serving the data or preparing to fetch from main memory. |
| **Allocate**   | On a cache miss, if the selected cache line is dirty, the controller transitions to the Write Back state to write the dirty block back to main memory. If not dirty, it moves directly to the Refill state to fetch the new block. |
| **Write Back** | The controller writes the dirty cache block back to main memory. After the write-back is complete, it transitions to the Refill state to fetch the new block from main memory. |
| **Refill**     | The controller fetches the required block from main memory and updates the cache. Once the block is loaded into the cache, it serves the CPU request and returns to the Idle state. |

Additionally, bits are used to keep track of valid and dirty status for each cache line, as well as LRU tracking for replacement decisions. These are snippets of the logic used:

````SystemVerilog
// after refilling way 0:
SRAM_WriteData[136] = 1'b1; // set valid bit    
SRAM_WriteData[137] = 1'b0; // set dirty bit to 0         
SRAM_WriteData[276] = 1'b1; // set LRU bit to indicate way 0 is most recently used (way 1 is LRU)
````

An additional pain point was handling byte and half-word accesses (LB, LH, SB, SH). I implemented logic to correctly extract or insert the relevant bytes within a 32-bit word based on the byte offset. This involved using bitwise operations and shifts to ensure data integrity during these smaller accesses. 

````SystemVerilog
logic [31:0] write_mask, shifted_wdata, merged;
    always_comb begin
        unique case (addr_mode)
            3'b000,3'b011: write_mask = 32'h000000FF << (8*TargetByteOffset);        // SB
            3'b001,3'b100: write_mask = 32'h0000FFFF << (8*TargetByteOffset[1]);     // SH
            3'b010:        write_mask = 32'hFFFFFFFF;                                // SW
            default:       write_mask = 32'h0;
        endcase
        unique case (addr_mode)
            3'b000,3'b011: shifted_wdata = WriteData << (8*TargetByteOffset);
            3'b001,3'b100: shifted_wdata = WriteData << (16*TargetByteOffset[1]);
            default:       shifted_wdata = WriteData;
        endcase
    end

    logic [7:0]  sel_byte;
    logic [15:0] sel_half;
    logic [31:0] load_data;

    always_comb begin
        sel_byte = Data >> (8*TargetByteOffset);
        sel_half = Data >> (16*TargetByteOffset[1]);
        unique case (addr_mode)
            3'b000: load_data = {{24{sel_byte[7]}}, sel_byte};   // LB
            3'b011: load_data = {24'b0, sel_byte};               // LBU
            3'b001: load_data = {{16{sel_half[15]}}, sel_half};  // LH
            3'b100: load_data = {16'b0, sel_half};               // LHU
            default: load_data = Data;                           // LW or others
        endcase
    end
````

3. SRAM Module (`cache_sram.sv`)
I designed the SRAM module to store cache lines, each consisting of data, tag, valid, dirty, and LRU bits. The module supports read and write operations based on the provided address and control signals. 
Each of the 32 sets contains 277 bits organized as follows:

```
Set[276:0]:
┌─────┬───────────────────────── Way 1 (138 bits) ─────────────────────────┬───────────────────────── Way 0 (138 bits) ───────────────────────┐
│ LRU │ Dirty │ Valid │   Tag   │  Word3  │  Word2  │  Word1  │  Word0    │ Dirty │ Valid │   Tag   │  Word3  │  Word2  │  Word1  │  Word0    │
│[276]│ [275] │ [274] │[273:266]│[265:234]│[233:202]│[201:170]│[169:138]  │ [137] │ [136] │[135:128]│[127:96] │ [95:64] │ [63:32] │  [31:0]   │
│1 bit│ 1 bit │ 1 bit │ 8 bits  │ 32 bits │ 32 bits │ 32 bits │ 32 bits   │ 1 bit │ 1 bit │ 8 bits  │ 32 bits │ 32 bits │ 32 bits │ 32 bits   │
└─────┴───────┴───────┴─────────┴─────────┴─────────┴─────────┴───────────┴───────┴───────┴─────────┴─────────┴─────────┴─────────┴───────────┘
```

4. Integration and Testing
After completing the cache design, I integrated it into our pipelined CPU by replacing the existing data memory module with the cache module. This required modifying the memory stage to interface with the cache controller. Debugging the cache integration was extremely challenging, as cache misses and hits introduced new timing considerations. However, with the help of Jerry and Ezekiel, we were able to identify and resolve issues, ultimately passing our series of tests. Debugging this stage greatly improved my understanding of cache architectures and their impact on CPU performance. Additionally, I learned the importance of methodical debugging with the help of GTKWave to visualize signal transitions. This helped us to narrow down issues related to timing and control signal propagation, which was especially important due to the sheer complexity of the cache design.

## Branch Prediction
For the branch prediction stage, I designed and implemented a 2-bit saturating counter-based branch predictor within the CPU. This predictor uses a simple state machine to track the history of branch outcomes and make predictions accordingly.

1. Branch Predictor Module (`branch_predictor.sv`)
The branch predictor maintains a table of 2-bit saturating counters indexed by the lower bits of the program counter (PC). I decided on a 256-entry predictor table, indexed by the lower 8 bits of the PC. This size provides a good balance between accuracy and resource usage.

For both the branch predictor table and the BTB, I used the following indexing:

```
PC[31:0]:
┌────────────────────────┬──────────────┬─────────────┐
│       Unused           │  Index [9:2] │ [1:0]       │
│                        │   (8 bits)   │ (ignored)   │
└────────────────────────┴──────────────┴─────────────┘
``` 

Each counter can be in one of four states: Strongly Taken, Weakly Taken, Weakly Not Taken, and Strongly Not Taken. Whenever a branch instruction is in the fetch stage, the predictor uses the current state of the corresponding counter to make a prediction. If the most significant bit of the counter is 1, it predicts that the branch will be taken; otherwise, it predicts not taken. This prediction is then sent to the fetch stage to determine the next PC value.

### State Encoding

| State | Value | Prediction | Description |
|-------|-------|------------|-------------|
| Strongly Not-Taken | `00` | Not-Taken | High confidence not-taken |
| Weakly Not-Taken | `01` | Not-Taken | Low confidence not-taken (initial state) |
| Weakly Taken | `10` | Taken | Low confidence taken |
| Strongly Taken | `11` | Taken | High confidence taken |

````SystemVerilog
// 256 entry predictor table
logic [1:0] predictor_table [2**TABLE_BITS-1:0];   

// prediction logic
assign PredictTakenF = predictor_table[index_f][1];
````

Whenever a branch instruction reaches the execute stage, the predictor updates the corresponding counter based on the actual outcome of the branch. The state transitions are as follows:

````SystemVerilog
else if (BranchE != 3'b000) begin   // if there is a branch instr
    // update state based on actual outcome
    case (predictor_table[index_e])
        2'b00: predictor_table[index_e] <= (BranchTakenE) ? 2'b01 : 2'b00; // SNT - if taken, go to WNT. if not taken, stay SNT
        2'b01: predictor_table[index_e] <= (BranchTakenE) ? 2'b10 : 2'b00; // WNT - if taken, go to WT. if not taken, go to SNT
        2'b10: predictor_table[index_e] <= (BranchTakenE) ? 2'b11 : 2'b01; // WT - if taken, go to ST. if not taken, go to WNT
        2'b11: predictor_table[index_e] <= (BranchTakenE) ? 2'b11 : 2'b10; // ST - if taken, stay ath ST. if not taken, go to WT
    endcase
end
````

2. BTB Module (`btb.sv`)
I also designed a Branch Target Buffer (BTB) to store the target addresses of recently taken branches. The BTB is indexed similarly to the branch predictor and stores the target address along with a valid bit to indicate if the entry is valid.

Whenever a branch instruction is fetched, the BTB is checked for a hit. If there is a hit, the predicted target address is provided to the fetch stage, which is passed along with the prediction from the branch predictor.

This is the logic for checking the BTB for a hit: 

````SystemVerilog
always_comb begin
    // read entry at the current index
    btb_entry_t entry_f = btb_array[index_f];

    // check for hit: valid bit is set AND tags match
    if (entry_f.valid && (entry_f.tag == tag_f)) begin
        BTBHitF        = 1'b1;
        PredictTargetF = entry_f.target;
    end else begin
        BTBHitF        = 1'b0;
        PredictTargetF = {PC_WIDTH{1'b0}};  //if no hit, the branch wouldn't be taken so this is just a placeholder
    end
end
````

Likewise, whenever there is a branch instruction in the execute stage, the BTB is updated based on whether the branch was taken or not. If the branch was taken, the BTB entry is updated with the new target address and the valid bit is set. 

````SystemVerilog
else if (BranchE != 3'b000) begin  // updates on any branch instructions
    btb_array[index_e].valid  <= 1'b1;
    btb_array[index_e].tag    <= tag_e;
    btb_array[index_e].target <= BranchTargetE;
end
````
3. Misprediction Handling (within `hazard_unit.sv` and `pcsrc_logic.sv`)
To handle mispredictions, I modified the hazard unit to detect when the actual branch outcome differs from the prediction. In such cases, the pipeline is flushed, and the PC is updated to the correct target address. This ensures that the CPU continues execution from the correct instruction following a misprediction.

Within the hazard unit, I added the following logic to detect mispredictions and generate flush signals:

````SystemVerilog
branch_is_active = (BranchE != 3'b000);
mispredicted = branch_is_active && ((PredictTakenE != BranchTakenE) || (BranchTakenE && (PredictTargetE != BranchTargetE)));
        
//flush logic
FlushD = mispredicted;
FlushE = lwStall | mispredicted;
````

4. Integration and Testing
After implementing the branch predictor and BTB, I integrated these modules into our pipelined CPU design. This involved modifying the fetch stage to utilize the predictions and target addresses provided by the branch predictor and BTB. This is the logic within `fetch_top.sv` that selects the next PC value based on predictions and mispredictions:

````SystemVerilog
assign branch_is_active = (BranchE != 3'b000);
assign mispredicted = branch_is_active && ((PredictTakenE != BranchTakenE) || (BranchTakenE && (PredictTargetE != BranchTargetE)));

// PC select logic
always_comb begin
    if (mispredicted)begin  // recover from misprediction
        PCNext = BranchTakenE ? BranchTargetE : (PCE + 4);
    end else if (JumpTakenE) begin
        PCNext = PCTargetE;
    end else if (predict_taken && btb_hit) begin    // predict taken with valid target
        PCNext = btb_target;
    end else begin  // default state
        PCNext = PCPlus4F;  
    end 
end
````

Once this was integrated, I deduced three simple tests to validate the branch predictor and BTB functionality:
1. A loop that iterates a fixed number of times, testing the predictor's ability to learn a taken branch pattern.
2. A conditional branch that alternates between taken and not taken, testing the predictor's adaptability
3. A sequence of branches with varying target addresses, testing the BTB's ability to store and retrieve target addresses correctly.

The alternating assembly code is shown below:
````Assembly
.text
.globl _start

_start:
    li      x5, 0          # t0 = counter
    li      x6, 10         # t1 = limit
    li      x7, 1          # t2 = toggle

alt_loop:
    beqz    x7, alt_skip   # if toggle == 0, skip
    addi    x7, x7, -1     # toggle = 0
    j       alt_next

alt_skip:
    addi    x7, x7, 1      # toggle = 1

alt_next:
    addi    x5, x5, 1      # counter++
    blt     x5, x6, alt_loop

    mv      x10, x5        # a0 = t0

done:
    nop
    nop
    nop
    j       done
````

Upon passing these tests, I confirmed the functionality of the branch predictor and BTB within our CPU design. I acknowledge that plenty of testing is yet to be done for this implementation, which I plan to undertake in the future without time constraint. This includes trying to measure the hit and miss rates of the predictor and BTB under various workloads, as well as stress-testing with more complex branching patterns. 

## Conclusion
What a long 3 weeks this has been. I can confidently say I have poured my heart and soul into this project, learning a tremendous amount about CPU architecture, hardware design, and teamwork. I really mean it when I say that this has been one of the most rewarding experiences of my academic career so far. 

To summarise my greatest takeaways:
1. Strong understanding of CPU architecture: From single-cycle to pipelining, caching, and branch prediction, I have gained a deep understanding of how modern CPUs are designed and optimized for performance.
2. Practical hardware design skills: Implementing these designs in SystemVerilog has given me hands-on experience with hardware description languages and familiarised myself with some of the potential tradeoffs in design choices.
3. Debugging and problem-solving: The challenges we faced during integration and testing have honed my debugging skills and taught me the importance of systematic problem-solving in hardware design.
4. Teamwork and collaboration: Working closely with Jerry and Ezekiel on the RTL design has reinforced the value of effective communication and collaboration in achieving complex project goals. 

Additionally, the practical experience gained through this project were extremely useful in preparing me for the industry - it has already came in useful in an interview I did sometime during the project. I extend my thanks to Jerry and Ezekiel, who spent long nights with me debugging and integrating our designs. Their support and collaboration were invaluable throughout this journey. En Qi was also a great help in testing our designs, and creating testbenches for us to validate our modules. Overall, this project has been an incredible learning experience, and I am proud of what we have accomplished as a team.


