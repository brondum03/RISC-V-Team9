// `include "../rtl/mux4.sv"
`include "../rtl/memory/datamemory.sv"

module memory_top #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8
)(
    input   logic [DATA_WIDTH-1:0]  ALUResult,
    input   logic [DATA_WIDTH-1:0]  WriteData,
    input   logic [DATA_WIDTH-1:0]  ImmExt,
    input   logic [DATA_WIDTH-1:0]  PCPlus4,
    input   logic                   MemWrite,
    input   logic                   AddressingMode,
    input   logic                   clk,
    input   logic [1:0]             ResultSrc,
    output  logic [DATA_WIDTH-1:0]  Result
);
    logic [DATA_WIDTH-1:0] ReadData;

    datamemory #(
        .DATA_WIDTH(DATA_WIDTH),
        .BYTE_WIDTH(BYTE_WIDTH)
    ) Data_Memory (
        .clk(clk),
        .write_enable(MemWrite),
        .write_data(WriteData),
        .address(ALUResult[16:0]),
        .addr_mode(AddressingMode),
        .read_data(ReadData)
    );

    mux4 result (
        .in0(ALUResult),
        .in1(ReadData),
        .in2(PCPlus4),
        .in3(ImmExt),
        .sel(ResultSrc),
        .out(Result)
    );
endmodule
