`include "../rtl/memory/datamemory.sv"

module memory_top #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8
)(
    input   logic [DATA_WIDTH-1:0]  ALUResult,
    input   logic [DATA_WIDTH-1:0]  WriteData,
    input   logic                   MemWrite,
    input   logic                   AddressingMode,
    input   logic                   clk,
    output  logic [DATA_WIDTH-1:0]  ReadData
);
    datamemory #(
        .DATA_WIDTH(DATA_WIDTH),
        .BYTE_WIDTH(BYTE_WIDTH)
    ) Data_Memory (
        .clk(clk),
        .write_enable(MemWrite),
        .write_data(WriteData),
        .address(ALUResult),
        .addr_mode(AddressingMode),
        .read_data(ReadData)
    );
endmodule
