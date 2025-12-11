 `include "../mux2.sv"
// `include "../rtl/adder.sv"
//`include "../rtl/fetch/program_counter.sv"
//`include "../rtl/fetch/instruction_memory.sv"

module fetch_top#(
    parameter DATA_WIDTH = 32
)(
    input   logic                          clk,
    input   logic                          rst,
    input   logic                          PCsrc,

    output  logic [DATA_WIDTH-1:0]         Instr1,
    output  logic [DATA_WIDTH-1:0]         Instr2
);
    logic [DATA_WIDTH-1:0]          PC;
    logic [DATA_WIDTH-1:0]          PCNext;  

mux2 pcmux(
    .in0(PC + 8),
    .in1(PC),
    .sel(PCsrc),
    .out(PCNext)
);

program_counter ProgramCounter(
    .clk(clk),
    .rst(rst),
    .PCNext(PCNext),
    .out(PC)
);

instruction_memory Instruction_Memory(
    .in(PC),
    .Instr1(Instr1),
    .Instr2(Instr2)
);

endmodule
