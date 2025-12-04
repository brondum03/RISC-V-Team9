`include "../rtl/mux2.sv"
`include "../rtl/adder.sv"
`include "../rtl/fetch/program_counter.sv"
`include "../rtl/fetch/instruction_memory.sv"
`include "../rtl/fetch/fetch_pipeline.sv"

module fetch_top#(
    parameter DATA_WIDTH = 32
)(
    input   logic                          clk,
    input   logic                          rst,
    input   logic                          trigger,
    input   logic                          StallF,
    input   logic                          StallD,
    input   logic                          FlushD,

    input   logic                          PCsrcE,
    input   logic [DATA_WIDTH-1:0]         PCTargetE,

    output  logic [DATA_WIDTH-1:0]         InstrD,
    output  logic [DATA_WIDTH-1:0]         PCD,
    output  logic [DATA_WIDTH-1:0]         PCPlus4D
);

logic [DATA_WIDTH-1:0]          PCNext;  
logic [DATA_WIDTH-1:0]          PCF;
logic [DATA_WIDTH-1:0]          PCPlus4F;
logic [DATA_WIDTH-1:0]          InstrF;

mux2 pcmux(
    .in0(PCPlus4F),
    .in1(PCTargetE),
    .sel(PCsrcE),
    .out(PCNext)
);

adder adder_plus4(
    .in0(PCF),
    .in1(4),
    .out(PCPlus4F)
);

program_counter ProgramCounter(
    .clk(clk),
    .rst(rst),
    .StallF(StallF),
    .trigger(trigger),
    .PCNext(PCNext),
    .out(PCF)
);

instruction_memory Instruction_Memory(
    .in(PCF),
    .out(InstrF)
);

fetch_pipeline Fetch_Pipeline(
    .clk(clk),
    .FlushD(FlushD),
    .rst(rst),
    .StallD(StallD),
    .trigger(trigger),
    .InstrF(InstrF),
    .PCF(PCF),
    .PCPlus4F(PCPlus4F),
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D)
);


endmodule
