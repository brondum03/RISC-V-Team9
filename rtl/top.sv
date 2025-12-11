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
    logic [1:0] PCSrc; // -> connected to mux which selects PCNext
    logic [DATA_WIDTH-1:0] Instr1; //instruction from instruction memory
    logic [DATA_WIDTH-1:0] Instr2;
    logic [DATA_WIDTH-1:0] PCPlus4;

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
    logic [DATA_WIDTH-1:0] ALUResult; 
    logic [DATA_WIDTH-1:0] WriteData;
    
    fetch_top fetch (
        // input
        .clk(clk),
        .rst(rst),
        .PCsrc(PCSrc),
        .ImmExt(ImmExt),
        .ALUResult(ALUResult),
        // output
        .Instr1(Instr1),
        .Instr2(Instr2),
        .PCPlus4(PCPlus4)
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
        .AddressingMode(AddressingMode),
        .ALUResult(ALUResult),
        .ImmExt(ImmExt),
        .PCPlus4(PCPlus4),
        .ResultSrc(ResultSrc),
        .WriteData(WriteData),
        .MemWrite(MemWrite),
        .Result(Result)
    );

endmodule
