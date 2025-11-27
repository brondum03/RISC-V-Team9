include "./memory/memory_top.sv"

module memory_top #(
    parameter DATA_WIDTH = 32
)(
    input   logic [DATA_WIDTH-1:0]  ALUResult,
    input   logic [DATA_WIDTH-1:0]  WriteData,
    input   logic                   MemWrite,
    input   logic                   clk,
    output  logic [DATA_WIDTH-1:0]  ReadData
);
    datamemory #(
        .DATA_WIDTH(DATA_WIDTH)
    ) Data_Memory (
        .clk(clk),
        .WE(MemWrite),
        .WD(WriteData),
        .A(ALUResult),
        .RD(ReadData)
    );
endmodule
