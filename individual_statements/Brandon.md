# Personal Contribution Statement — Brandon Auyong

This document outlines my individual contributions to the RISC-V CPU project, structured according to the main tasks I worked on:
[**Single-Cycle**](#Single-Cycle) 
[**Pipelining**](#Pipelining)
[**Caching**](#Caching)
[**Branch Prediction**](#Branch-Predction)  

## Introduction
I played the role of an RTL engineer in this project, simulating hardware design through SystemVerilog together with teammates Jerry and Ezekiel. The past weeks have been extremely engaging and fulfilling. The practical experience of implementing hardware design learned in lectures and the satisfaction of seeing our modules run is addictive.

My main contributions to the project came in the execute and memory stages of our CPU. Notably, I developed the ALU and datamemory within the base CPU. In the pipelined design, I desgined the hazard unit for detection and handling of control and data hazards. I also designed the full cache and branch prediction CPU for our extensions. Throughout the project, Jerry, Ezekiel, and I worked closely to integrate and debug our code.

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

To address load-use hazards, whereby subsequent instructions are awaiting data from the memory stage, a hardware stall is necessary. To detect the (`lw`) instruction, the hazard unit looks at (`ResultSrcE`) which indicates reading from data memory. The pipeline registers are then 

````SystemVerilog
lwStall = ResultSrcE[0] & ((Rs1D == RdE) | (Rs2D == RdE));
StallF = lwStall;
StallD = lwStall;
````




