module execute_top #(
    parameter DATA_WIDTH = 32
)(
    input   logic [DATA_WIDTH-1:0]  RD1,
    input   logic [DATA_WIDTH-1:0]  RD2,
    input   logic [DATA_WIDTH-1:0]  ImmExt,
    input   logic [2:0]             ALUControl,
    input   logic                   ALUSrc,
    output  logic [DATA_WIDTH-1:0]  ALUResult,
    output  logic [DATA_WIDTH-1:0]  WriteData,
    output  logic                   Zero
    
);
    
    logic [DATA_WIDTH-1:0] SrcB;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU (
        .ALUop1(RD1),
        .ALUop2(SrcB),
        .ALUctrl(ALUControl),
        .ALUout(ALUResult),
        .EQ(Zero)
    );

    assign SrcB = ALUSrc ? ImmExt : RD2;
    assign WriteData = RD2; 

endmodule
