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

    //fetch
    logic [DATA_WIDTH-1:0] InstrD; //instruction from instruction memory
    logic [DATA_WIDTH-1:0] PCPlus4D;
    logic [DATA_WIDTH-1:0] PCD;

    // decode  --> all inputs into execute stage (BRANDON)
    logic                   PCSrcE;
    logic                   RegWriteE;
    logic [1:0]             ResultSrcE;
    logic                   MemWriteE;
    logic [1:0]             JumpE;
    logic [2:0]             BranchE;
    logic [3:0]             ALUControlE;
    logic                   ALUSrcE;
    logic [2:0]             AddressingModeE;
    logic [DATA_WIDTH-1:0]  RD1E;
    logic [DATA_WIDTH-1:0]  RD2E;
    logic [DATA_WIDTH-1:0]  PCE;
    logic [ADDR_WIDTH-1:0]  Rs1E;
    logic [ADDR_WIDTH-1:0]  Rs2E;
    logic [ADDR_WIDTH-1:0]  RdE;
    logic [DATA_WIDTH-1:0]  PCPlus4E;
    logic [DATA_WIDTH-1:0]  ImmExtE;
    
    // memory outputs 
    logic [DATA_WIDTH-1:0] ResultW;
    logic                  RegWriteW;
    logic [4:0]            RdW;

    // memory inputs 
    logic [DATA_WIDTH-1:0] PCPlus4M;
    logic [4:0]            RdM;
    logic                  RegWriteM;
    logic [1:0]            AddressingModeM;
    logic [DATA_WIDTH-1:0] ALUResultM;
    logic [DATA_WIDTH-1:0] WriteDataM;
    logic [1:0]            ResultSrcM;
    logic                  MemWriteM;

    fetch_top fetch (
        .clk(clk),
        .rst(rst),
        .stall(trigger),
        .PCsrcE(PCSrcE),
        .PCTargetE(ALUResult),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    ); 
    
    // complete decode_top
    decode_top #(
        DATA_WIDTH, ADDR_WIDTH
    ) decode (
        // input
        .clk(clk),
        .rst(rst),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .ResultW(ResultW),
        .RdW(RdW),
        .PCSrcE(PCSrcE),
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
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),
        .ImmExtE(ImmExtE),
        .a0(a0)
    );

    execute_top execute (
        .RD1(RD1),   
        .RD2(RD2), 
        .ImmExt(ImmExt),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ALUResult(ALUResult), 
        .Zero(Zero), 
        .WriteData(WriteData),
        .Negative(Negative)
    );

    memory_top memory (
        .clk(clk),
        .ALUResultM(ALUResult),
        .WriteDataM(WriteData),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM), 
        .RegWriteM(RegWriteM), 
        .ResultSrcM(ResultSrc),
        .MemWriteM(MemWriteM),
        .AddressingModeM(AddressingModeM),
        .ResultW(ResultW),
        .RegWriteW(RegWriteW),    
        .RdW(RdW)
    );

endmodule
