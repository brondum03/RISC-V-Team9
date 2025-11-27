    `include "../mux4.sv"
    `include "../adder.sv"
    
    module fetch_top#(
        parameter DATA_WIDTH = 32
    )(
        input   logic                          clk,
        input   logic                          rst,
        input   logic [1:0]                    PCsrc,
        input   logic [DATA_WIDTH-1:0]         ImmExt,
        input   logic [DATA_WIDTH-1:0]         ALUResult,
        output  logic [DATA_WIDTH-1:0]         Instr,
        output  logic [DATA_WIDTH-1:0]         PCPlus4
    );
    logic [DATA_WIDTH-1:0]          PC;
    logic [DATA_WIDTH-1:0]          PCTarget; 
    logic [DATA_WIDTH-1:0]          PCNext;  

    mux4 pcmux(
        .in0(PCPlus4),
        .in1(PCTarget),
        .in2(ALUResult),
        .in3(PC),
        .sel(PCSrc),
        .out(PCNext)
    );

    adder adder_branch(
        .in0(PC),
        .in1(ImmExt),
        .out(PCTarget)
    );

    adder adder_plus4(
        .in0(PC),
        .in1(4),
        .out(PCPlus4)
    );

    program_counter ProgramCounter(
        .clk(clk),
        .rst(rst),
        .PCNext(PCNext),
        .out(PC)
    );

    instruction_memory Instruction_Memory(
        .in(PC),
        .out(Instr)
    );

    endmodule