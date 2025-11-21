/*
Ezekiel
*/

module controlUnit (
    input logic [6:0]   op;
    input logic [2:0]   funct3;
    input logic         funct7;
    input logic         zero;

    output logic        PCSrc;
    output logic        ResultSrc;
    output logic        MemWrite;
    output logic [2:0]  ALUControl;
    output logic        ALUSrc;
    output logic [1:0]  ImmSrc;
    output logic        RegWrite;
);

    // internal wire connections
    logic       Branch;
    logic [1:0] ALUOp;

    // main decoder
    mainDecoder mainDec(
        .op        (op),
        .Branch    (Branch),
        .ResultSrc (ResultSrc),
        .MemWrite  (MemWrite),
        .ALUSrc    (ALUSrc),
        .ImmSrc    (ImmSrc),
        .RegWrite  (RegWrite),
        .ALUOp     (ALUOp)
    );

    // alu decoder
    aluDecoder aluDec (
        .op         (op),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUOp      (ALUOp),
        .ALUControl (ALUControl)
    );

    assign PCSrc = Branch & zero;
    
endmodule