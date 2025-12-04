`include "../rtl/mux2.sv"
// `include "../rtl/mux4.sv"
`include "../rtl/execute/alu.sv"
`include "../rtl/execute/execute_pipeline_register.sv"
`include "../rtl/execute/pcsrc_logic.sv"
`include "../rtl/execute/hazard_unit.sv"
// `include "../rtl/adder.sv"

module execute_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                   clk,
    input   logic                   rst,                   

    // alu
    input   logic [DATA_WIDTH-1:0]  RD1E,
    input   logic [DATA_WIDTH-1:0]  RD2E,
    input   logic [DATA_WIDTH-1:0]  ResultW,
    input   logic [3:0]             ALUControlE,
    input   logic                   ALUSrcE,

    // adder
    input   logic [DATA_WIDTH-1:0]  PCE, 
    input   logic [DATA_WIDTH-1:0]  ImmExtE,
    input   logic [DATA_WIDTH-1:0]  PCPlus4E,
    input   logic [4:0]             RdE,
    
    // control signals
    input   logic [2:0]             AddressingModeE,
    input   logic [1:0]             ResultSrcE,
    input   logic                   RegWriteE,
    input   logic                   MemWriteE,

    // hazard unit 
    input   logic [4:0]             Rs1E,
    input   logic [4:0]             Rs2E,
    input   logic [4:0]             RdW,
    input   logic                   RegWriteW,
    input   logic [4:0]             Rs1D,
    input   logic [4:0]             Rs2D,

    // pc source
    input   logic [2:0]             BranchE,
    input   logic [1:0]             JumpE,  
        
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

    output logic                    StallF,
    output logic                    StallD,
    output logic                    FlushD,
    output logic                    FlushE
);

    logic [DATA_WIDTH-1:0]  ALUResultE;

    // pc source internal logic
    logic                   ZeroE;
    logic                   NegativeE;
    logic                   Less_unsignedE;
    
    // alu operand internal logic
    logic [DATA_WIDTH-1:0]  SrcAE;    
    logic [DATA_WIDTH-1:0]  SrcBE;
    logic [DATA_WIDTH-1:0]  Forward_mux_B_result;

    // forwarding internal logic
    logic [1:0]             ForwardAE;
    logic [1:0]             ForwardBE;
    
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu (
        .ALUop1(SrcAE),
        .ALUop2(SrcBE),
        .ALUctrl(ALUControlE),
        .ALUout(ALUResultE),
        .Zero(ZeroE),
        .Negative(NegativeE),
        .Less_unsigned(Less_unsignedE)
    );

    execute_pipeline_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) pipeline_register (
        .clk(clk),
        .ALUResultE(ALUResultE),
        .WriteDataE(Forward_mux_B_result),
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
    
    mux4 Forward_mux_A(
        .in0(RD1E),
        .in1(ResultW),
        .in2(ALUResultM),
        .in3(32'b0),
        .sel(ForwardAE),
        .out(SrcAE)
    );

    mux4 Forward_mux_B(
        .in0(RD2E),
        .in1(ResultW),
        .in2(ALUResultM),
        .in3(32'b0),
        .sel(ForwardBE),
        .out(Forward_mux_B_result)
    );

    mux2 SrcB_mux(
        .in0(Forward_mux_B_result),
        .in1(ImmExtE),
        .sel(ALUSrcE),
        .out(SrcBE)
    );

    adder PC_adder(
        .in0(PCE),
        .in1(ImmExtE),
        .out(PCTargetE)
    );

    hazard_unit hazard_unit(
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcE(ResultSrcE),
        .RdE(RdE),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    pcsrc_logic pcsrc_logic(
        .ZeroE(ZeroE),
        .BranchE(BranchE), 
        .JumpE(JumpE),
        .NegativeE(NegativeE),
        .Less_unsignedE(Less_unsignedE),   
        .PCSrcE(PCSrcE)
    );

endmodule
