`include "./fetch/fetch_top.sv"
`include "./decode/decode_top.sv"
`include "./execute/execute_top.sv"
`include "./memory/memory_top.sv"

module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                       clk,
    input   logic                       rst,
    input   logic                       stall,
    output  logic [DATA_WIDTH-1:0]      a0
);

    //fetch
    logic PCSrc; // -> connected to mux which selects PCNext
    logic [DATA_WIDTH-1:0] Instr; //instruction from instruction memory
    logic [DATA_WIDTH-1:0] PCPlus4;

    /*decode*/
    // control unit inputs
    logic                   negative;
    logic                   Zero;
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

    //execute
    logic [DATA_WIDTH-1:0] ALUResult; 
    logic [DATA_WIDTH-1:0] WriteData;

    
    fetch_top fetch (
        .PCsrc(PCSrc),
        .clk(clk),
        .rst(rst),
        .ImmExt(ImmExt),
        .Instr(Instr),
        .Result_in(Result)
    ); 
    
    // complete decode_top
    decode_top decode (
        // input
        .clk(clk),
        .stall(stall),
        .Instr(Instr),
        .WD3(Result),
        .Zero(Zero),   
        .negative(negative),     
        
        // output
        .PCSrc(PCSrc),      // selects mux for PCNext
        .ResultSrc(ResultSrc),       // selects mux for ResultSrc
        .MemWrite(MemWrite),        // WE in data memory
        .ALUControl(ALUControl),      // input to ALU
        .ALUSrc(ALUSrc),          // selects mux for SrcB
        .AddressingMode(AddressingMode),
        .RD1(RD1),             // SrcA
        .RD2(RD2),             // 0 for mux that outputs SrcB
        .ImmExt(ImmExt)          // goes into PCTarget
    );

    execute_top execute (
        .RD1(RD1),   
        .RD2(RD2), 
        .ImmExt(ImmExt),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ALUResult(ALUResult), 
        .Zero(Zero), 
        .WriteData(WriteData)
    );

    memory_top memory (
        .clk(clk),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .MemWrite(MemWrite),
        .ReadData(ReadData)
    );
    
    mux2 result (
        .in0(ALUResult),
        .in1(ReadData),
        .sel(ResultSrc),
        .out(Result)
    );

endmodule
