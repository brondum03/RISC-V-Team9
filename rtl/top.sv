module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0]
);
    //interconnect line (add on for your individual parts) -  follow syntax from the project brief 
    //Logic for Instruction memory
    logic [DATA_WIDTH-1:0] PC;    //program counter
    logic [DATA_WIDTH-1:0] Instr; //instruction from instruction memory
    //Logic for alu control unit
    logic [2:0] ALUControl;   //alu control from control unit
    logic RegWrite;
    logic Zero;
    logic ALUSrc;
    logic MemWrite;
    logic ResultSrc;
    logic [DATA_WIDTH-1:0] WriteData;
    logic [DATA_WIDTH-1:0] ImmExt;
    logic [DATA_WIDTH-1:0] SrcA;
    logic [DATA_WIDTH-1:0] SrcB;
    logic [DATA_WIDTH-1:0] ALUResult;
    logic [DATA_WIDTH-1:0] ReadData;
    logic [DATA_WIDTH-1:0] Result;
    
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

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU(
        .ALUop1(SrcA),   
        .ALUop2(SrcB), 
        .ALUctrl(ALUControl), 
        .ALUout(ALUResult), 
        .EQ(Zero) 
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

    instruction_memory #(
        .DATA_WIDTH(DATA_WIDTH)
    ) Instruction_Memory(
        .in(PC),
        .out(Instr)
    );

    programcounter #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ProgramCounter(
        .clk(clk),
        .rst(rst),
        .pcsrc(PCSrc),
        .immOP(ImmExt),
        .out(PC)
    );

    signextend sign_extension (
        .instr(instr),
        .ImmSrc(ImmSrc),
        .ImmOp(ImmExt)
    );



endmodule
