`include "../rtl/fetch/fetch_top.sv"
`include "../rtl/decode/decode_top.sv"
`include "../rtl/execute/execute_top.sv"
`include "../rtl/memory/memory_top.sv"


module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                       clk,
    input   logic                       rst,
    input   logic                       trigger,
    output  logic [DATA_WIDTH-1:0]      a0
);

    //fetch > decode
    logic [DATA_WIDTH-1:0]  InstrD;     // instruction from instruction memory
    logic [DATA_WIDTH-1:0]  PCPlus4D;
    logic [DATA_WIDTH-1:0]  PCD;
    logic                   PredictTakenD;
    logic [DATA_WIDTH-1:0]  PredictTargetD;

    // decode > execute
    logic [DATA_WIDTH-1:0]  RD1E;
    logic [DATA_WIDTH-1:0]  RD2E;
    logic [DATA_WIDTH-1:0]  ResultW;
    logic [3:0]             ALUControlE;
    logic                   ALUSrcE;
    logic [DATA_WIDTH-1:0]  PCE;
    logic [DATA_WIDTH-1:0]  ImmExtE;
    logic [DATA_WIDTH-1:0]  PCPlus4E;
    logic [ADDR_WIDTH-1:0]  RdE;
    logic [2:0]             AddressingModeE;
    logic [1:0]             ResultSrcE;
    logic                   RegWriteE;
    logic                   MemWriteE;
    logic [ADDR_WIDTH-1:0]  Rs1E;
    logic [ADDR_WIDTH-1:0]  Rs2E;
    logic [4:0]             RdW;
    logic                   RegWriteW;
    logic [4:0]             Rs1D;
    logic [4:0]             Rs2D;
    logic [2:0]             BranchE;
    logic [1:0]             JumpE; 
    
    logic                   PredictTakenE;
    logic [DATA_WIDTH-1:0]  PredictTargetE;
    logic                   BranchTakenE;
    logic                   JumpTakenE;
    logic [DATA_WIDTH-1:0]  BranchTargetE;

    // execute > memory
    logic [DATA_WIDTH-1:0]  ALUResultM;
    logic [DATA_WIDTH-1:0]  WriteDataM;
    logic [DATA_WIDTH-1:0]  PCPlus4M;
    logic [4:0]             RdM;
    logic [2:0]             AddressingModeM;
    logic [1:0]             ResultSrcM;
    logic                   RegWriteM;
    logic                   MemWriteM;
    logic [DATA_WIDTH-1:0]  PCTargetE;
    logic                   StallF;
    logic                   StallD;
    logic                   FlushD;
    logic                   FlushE;
    
    fetch_top fetch (
        // input
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .PCTargetE(PCTargetE),
        
        .BranchE(BranchE),
        .BranchTakenE(BranchTakenE),
        .PredictTakenE(PredictTakenE),
        .PredictTargetE(PredictTargetE),
        .PCE(PCE),
        .BranchTargetE(BranchTargetE),
        .JumpTakenE(JumpTakenE),
        // output
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        
        .PredictTargetD(PredictTargetD),
        .PredictTakenD(PredictTakenD)
    ); 
    
    decode_top #(
        DATA_WIDTH, ADDR_WIDTH
    ) decode (
        // input
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .ResultW(ResultW),
        .RdW(RdW),
        .FlushE(FlushE),
        .FlushD(FlushD),
        
        .PredictTakenD(PredictTakenD),
        .PredictTargetD(PredictTargetD),
        // output
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .AddressingModeE(AddressingModeE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .Rs1D_o(Rs1D),
        .Rs2D_o(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),
        .ImmExtE(ImmExtE),

        .PredictTakenE(PredictTakenE),
        .PredictTargetE(PredictTargetE),

        .a0(a0)
    );

    execute_top execute (
        // input
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .RD1E(RD1E),   
        .RD2E(RD2E), 
        .ResultW(ResultW),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .PCE(PCE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E),
        .RdE(RdE),
        .AddressingModeE(AddressingModeE),
        .ResultSrcE(ResultSrcE),
        .RegWriteE(RegWriteE),
        .MemWriteE(MemWriteE),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .BranchE(BranchE),
        .JumpE(JumpE),

        .PredictTakenE(PredictTakenE),
        .PredictTargetE(PredictTargetE),
        // output
        .ALUResultM(ALUResultM), 
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM),
        .AddressingModeM(AddressingModeM),
        .ResultSrcM(ResultSrcM),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .PCTargetE(PCTargetE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .JumpTakenE(JumpTakenE),
        .BranchTakenE(BranchTakenE),
        .BranchTargetE(BranchTargetE)
    );

    memory_top memory (
        .clk(clk),
        .rst(rst),
        .trigger(trigger),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM), 
        .RegWriteM(RegWriteM), 
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .AddressingModeM(AddressingModeM),
        .ResultW(ResultW),
        .RegWriteW(RegWriteW),    
        .RdW(RdW)
    );

endmodule
