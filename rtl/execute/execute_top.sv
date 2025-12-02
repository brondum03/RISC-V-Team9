// `include "../rtl/mux2.sv"
`include "../rtl/execute/alu.sv"

module execute_top #(
    parameter DATA_WIDTH = 32
)(
    input   logic [DATA_WIDTH-1:0]  RD1E,
    input   logic [DATA_WIDTH-1:0]  RD2E,
    input   logic [DATA_WIDTH-1:0]  PCE, 
    input   logic [DATA_WIDTH-1:0]  ImmExtE,
    input   logic [DATA_WIDTH-1:0]  PCPlus4E,
    input   logic [3:0]             ALUControlE,
    input   logic [1:0]             ForwardAE,
    input   logic [1:0]             ForwardBE,
    input   logic                   ALUSrcE,
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   flush,
    
    output  logic [DATA_WIDTH-1:0]  ALUResultM,
    output  logic [DATA_WIDTH-1:0]  WriteDataM,
    output  logic [DATA_WIDTH-1:0]  PCPlus4M,
    output  logic [4:0]             RdM,
    output  logic [2:0]             AddressingModeM,
    output  logic [1:0]             ResultSrcM,
    output  logic                   RegWriteM,
    output  logic                   MemWriteM,

    output  logic [DATA_WIDTH-1:0]  PCTargetE,
    output  logic                   PCSrcE,
    output  logic                   ZeroE,
    output  logic                   NegativeE
    
);

    logic [DATA_WIDTH-1:0] SrcAE;    
    logic [DATA_WIDTH-1:0] SrcBE;
    logic [DATA_WIDTH-1:0] RD2_mux_result;
    logic [DATA_WIDTH-1:0] ALUResultE;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu (
        .ALUop1(SrcAE),
        .ALUop2(SrcBE),
        .ALUctrl(ALUControlE),
        .ALUout(ALUResultE),
        .Zero(ZeroE),
        .Negative(NegativeE)
    );

    execute_pipeline_register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) execute_pipeline_register (
        .clk(clk),
        .flush(flush),
        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .PCPlus4E(PCPlus4E),
        .RdE(RdE),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .AddressingModeE(AddressingModeE),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .AddressingModeM(AddressingModeM)
    );
    
    mux4 RD1_mux(
        .in0(RD1E),
        .in1(ResultW),
        .in2(ALUResultM),
        .in3(32'b0),
        .sel(ForwardAE),
        .out(SrcAE)
    );

    mux4 RD2_mux(
        .in0(RD2E),
        .in1(ResultW),
        .in2(ALUResultM),
        .in3(32'b0),
        .sel(ForwardBE),
        .out(RD2_mux_result)
    );

    mux2 SrcB_mux(
        .in0(RD2_mux_result),
        .in1(ImmExtE),
        .sel(ALUSrcE),
        .out(SrcBE)
    );

    adder PC_adder(
        .a(PCE),
        .b(ImmExtE),
        .sum(PCTargetE)
    );

    assign WriteDataE = RD2_mux_result;

endmodule
