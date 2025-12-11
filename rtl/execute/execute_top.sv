`include "../mux2.sv"

module execute_top #(
    parameter DATA_WIDTH = 32
)(
    input   logic [DATA_WIDTH-1:0]  ImmExt1,
    input   logic [DATA_WIDTH-1:0]  RD1,
    input   logic [DATA_WIDTH-1:0]  RD2,

    input   logic [DATA_WIDTH-1:0]  ImmExt2,
    input   logic [DATA_WIDTH-1:0]  RD4,
    input   logic [DATA_WIDTH-1:0]  RD5,

    input   logic [7:0]             ALUControl,
    input   logic [1:0]             ALUSrc,

    output  logic [DATA_WIDTH-1:0]  ALUResult1,
    output  logic [DATA_WIDTH-1:0]  ALUResult2
);
    
    logic [DATA_WIDTH-1:0] SrcB_1;
    logic [DATA_WIDTH-1:0] SrcB_2;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU1 (
        .ALUop1(RD1),
        .ALUop2(SrcB_1),
        .ALUctrl(ALUControl[3:0]),
        .ALUout(ALUResult1)
    );

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU2 (
        .ALUop1(RD4),
        .ALUop2(SrcB_2),
        .ALUctrl(ALUControl[7:4]),
        .ALUout(ALUResult2)
    );

    mux2 mux_srcB_1 (
        .in0(RD2),
        .in1(ImmExt1),
        .sel(ALUSrc[0]),
        .out(SrcB_1)
    );

    mux2 mux_srcB_2 (
        .in0(RD4),
        .in1(ImmExt2),
        .sel(ALUSrc[1]),
        .out(SrcB_2)
    );

endmodule
