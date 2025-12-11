//`include "../rtl/mux2.sv"
`include "../rtl/memory/datamemory.sv"
//`include "../mux2.sv"

module memory_top #(
    parameter DATA_WIDTH = 32
)(
    input   logic                   clk,
    input   logic [1:0]             ResultSrc,
    input   logic [1:0]             MemWrite,
    input   logic [DATA_WIDTH-1:0]  ALUResult1,
    input   logic [DATA_WIDTH-1:0]  ALUResult2,
    input   logic [DATA_WIDTH-1:0]  WriteData1,
    input   logic [DATA_WIDTH-1:0]  WriteData2,   

    output  logic [DATA_WIDTH-1:0]  Result1,
    output  logic [DATA_WIDTH-1:0]  Result2
);
    logic [DATA_WIDTH-1:0] ReadData1;
    logic [DATA_WIDTH-1:0] ReadData2;

    datamemory #(
        .DATA_WIDTH(DATA_WIDTH)
    ) Data_Memory (
        .clk(clk),
        .write_enable(MemWrite),
        .write_data1(WriteData1),
        .address_1(ALUResult1),
        .write_data2(WriteData2),
        .address_2(ALUResult2),
        .read_data1(ReadData1),
        .read_data2(ReadData2)
    );

    mux2 mux_result1 (
        .in0(ALUResult1),
        .in1(ReadData1),
        .sel(ResultSrc[0]),
        .out(Result1)
    );

    mux2 mux_result2(
        .in0(ALUResult2),
        .in1(ReadData2),
        .sel(ResultSrc[1]),
        .out(Result2)
    );

endmodule
