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
    output  logic [DATA_WIDTH-1:0]      a0
);

    //fetch
    logic PCSrc; // -> connected to mux which selects PCNext
    logic [DATA_WIDTH-1:0] Instr; //instruction from instruction memory
    logic [DATA_WIDTH-1:0] PCPlus4;

    //decode
    logic Zero;
    logic ALUSrc;
    logic [2:0] ALUControl;
    logic [DATA_WIDTH-1:0] RD1; 
    logic [DATA_WIDTH-1:0] RD2; 
    logic [DATA_WIDTH-1:0] ImmExt; 
    
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
    
    register #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) Register_File(
        .AD1(Instr[19:15]),
        .AD2(Instr[24:20]),
        .AD3(Instr[11:7]),
        .WE3(RegWrite),
        .WD3(Result),
        .RD1(SrcA),
        .RD2(WriteData)  
    );
    
    assign SrcB = ALUSrc ? ImmExt : WriteData;

    execute_top #(
        .DATA_WIDTH(DATA_WIDTH)
    ) execute(
        .RD1(RD1),   
        .RD2(RD2), 
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ALUResult(ALUResult), 
        .Zero(Zero), 
        .WriteData(WriteData)
    );

    datamemory #(
        .DATA_WIDTH(DATA_WIDTH)
    ) Data_Memory(
        .clk(clk),
        .WE(MemWrite),
        .WD(WriteData),
        .A(ALUResult),
        .RD(ReadData)
    );
    
    assign Result = ResultSrc ? ReadData : ALUResult;

    decode_top decode #(
        .DATA_WIDTH(DATA_WIDTH)
    )(
        // input
        .Zero(Zero),    // internal
        .clk(clk),     
        .WD3(Result),     // internal
        .Instr(Instr),

        // output
        .PCSrc(PCSrc),      // selects mux for PCNext
        .ResultSrc(),       // selects mux for ResultSrc
        .MemWrite(),        // WE in data memory
        .ALUControl(),      // input to ALU
        .ALUSrc(),          // selects mux for SrcB
        .RD1(),             // SrcA
        .RD2(),             // 0 for mux that outputs SrcB
        .ImmExt(),          // goes into PCTarget
    )

endmodule
