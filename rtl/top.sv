module top #(
    DATA_WIDTH = 32,
    ADDR_WIDTH = 5
)(
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0]    
);
    //interconnect line (add on for your individual parts) -  follow syntax from the project brief 
    logic [DATA_WIDTH-1:0] PC;    //program counter
    logic [DATA_WIDTH-1:0] Instr; //instruction from instruction memory
    logic [2:0] ALUControl;   //alu control from control unit
    logic RegWrite;
    logic Zero;
    logic ALUSrc;
    logic [DATA_WIDTH-1:0] RD2;
    logic [DATA_WIDTH-1:0] ImmExt;
    logic [DATA_WIDTH-1:0] SrcA;
    logic [DATA_WIDTH-1:0] SrcB;
    logic [DATA_WIDTH-1:0] ALUResult;
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
        .RD2(RD2)  
    );
    
    assign SrcB = ALUSrc ? ImmExt : RD2;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU(
        .ALUop1(SrcA),   
        .ALUop2(SrcB), 
        .ALUctrl(ALUControl), 
        .ALUout(ALUResult), 
        .EQ(Zero) 
    );

endmodule
