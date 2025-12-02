`include "../rtl/fetch/fetch_top.sv"
`include "../rtl/decode/decode_top.sv"
`include "../rtl/execute/execute_top.sv"
`include "../rtl/memory/memory_top.sv"


module top #(
    parameter DATA_WIDTH = 32
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

    /*decode*/
    // control unit inputs
    logic                   Zero;
    logic                   Negative;
    logic                   MemWrite;
    logic                   ALUSrc;
    logic                   AddressingMode;
    logic [1:0]             ResultSrc;
    logic [3:0]             ALUControl;

    // Register file wires
    logic [DATA_WIDTH-1:0]  Result;
    logic [DATA_WIDTH-1:0]  RD1; 
    logic [DATA_WIDTH-1:0]  RD2; 
    logic [DATA_WIDTH-1:0]  ImmExt; 

    // execute
    logic [1:0] PCSrcE; // -> connected to mux which selects PCNext
    logic [DATA_WIDTH-1:0] ALUResult; 
    logic [DATA_WIDTH-1:0] WriteData;
    
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
    decode_top decode (
        // input
        .clk(clk),
        .rst(rst),
        .stall(trigger),
        .Instr(Instr),
        .WD3(Result),
        .Zero(Zero),   
        .negative(Negative),     
        
        // output
        .PCSrc(PCSrc),      // selects mux for PCNext
        .ResultSrc(ResultSrc),       // selects mux for ResultSrc
        .MemWrite(MemWrite),        // WE in data memory
        .ALUControl(ALUControl),      // input to ALU
        .ALUSrc(ALUSrc),          // selects mux for SrcB
        .AddressingMode(AddressingMode),
        .RD1(RD1),             // SrcA
        .RD2(RD2),             // 0 for mux that outputs SrcB
        .ImmExt(ImmExt),          // goes into PCTarget
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
