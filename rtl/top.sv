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
    logic  PCSrc; // 1 bit to select pc + 8 or stall
    logic [DATA_WIDTH-1:0] Instr1; //instruction from instruction memory
    logic [DATA_WIDTH-1:0] Instr2;

    /*decode*/
    // control unit inputs
    logic [1:0]             MemWrite;
    logic [1:0]             ALUSrc;
    logic [1:0]             ResultSrc;
    logic [7:0]             ALUControl;
    // Register file wires
    logic [DATA_WIDTH-1:0]  Result1;
    logic [DATA_WIDTH-1:0]  Result2;
    logic [DATA_WIDTH-1:0]  RD1; 
    logic [DATA_WIDTH-1:0]  RD2; 
    logic [DATA_WIDTH-1:0]  RD4;
    logic [DATA_WIDTH-1:0]  RD5;
    logic [DATA_WIDTH-1:0]  ImmExt1; 
    logic [DATA_WIDTH-1:0]  ImmExt2;

    // execute
    logic [DATA_WIDTH-1:0] ALUResult1; 
    logic [DATA_WIDTH-1:0] ALUResult2;
    
    fetch_top fetch (
        // input
        .clk(clk),
        .rst(rst),
        .PCsrc(PCSrc),
        // output
        .Instr1(Instr1),
        .Instr2(Instr2)
    ); 
    
    // complete decode_top
    decode_top decode (
        // input
        .clk(clk),
        .rst(rst),
        .stall(trigger),
        .Instr1(Instr1),
        .Instr2(Instr2),
        .WD3(Result1),    
        .WD6(Result2),
        
        // output
        .PCSrc(PCSrc),      // selects mux for PCNext
        .ResultSrc(ResultSrc),       // selects mux for ResultSrc
        .MemWrite(MemWrite),        // WE in data memory
        .ALUControl(ALUControl),      // input to ALU
        .ALUSrc(ALUSrc),          // selects mux for SrcB
        .RD1(RD1),             // SrcA
        .RD2(RD2),             // 0 for mux that outputs SrcB
        .ImmExt1(ImmExt1),
        .RD4(RD4),
        .RD5(RD5),
        .ImmExt2(ImmExt2),
        .a0(a0)
    );

    execute_top execute (
        // input
        .RD1(RD1),   
        .RD2(RD2), 
        .ImmExt1(ImmExt1),
        .RD4(RD4),   
        .RD5(RD5), 
        .ImmExt2(ImmExt2),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        // output
        .ALUResult1(ALUResult1), 
        .ALUResult2(ALUResult2)
    );

    memory_top memory (
        .clk(clk),
        .ALUResult1(ALUResult1),
        .ALUResult2(ALUResult2),
        .WriteData1(RD2),
        .WriteData2(RD5),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .Result1(Result1),
        .Result2(Result2)
    );

endmodule
