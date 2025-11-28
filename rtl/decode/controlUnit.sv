/*
Ezekiel
*/
`include "./subControlUnit/aluDecoder.sv"
`include "./subControlUnit/mainDecoder.sv"

module controlUnit (
    input logic [6:0]   op,
    input logic         Zero,
    input logic         stall,
    input logic         negative,
    input logic [2:0]   funct3,
    input logic         funct7,

    output logic [1:0]  PCSrc, // 0->move to next, 1->branch, 2->jump, 3->stall
    output logic [1:0]  ResultSrc,
    output logic        MemWrite,
    output logic        ALUSrc,
    output logic [2:0]  ImmSrc,
    output logic        RegWrite,
    output logic        AddressingMode, // --> 0 for word, 1 for byte
    output logic [3:0]  ALUControl
);

    // internal wire connections
    logic       Branch;
    logic [1:0] ALUOp;

    // main decoder
    mainDecoder mainDec(
        .op        (op),
        .Zero      (Zero),
        .stall     (stall),
        .negative  (negative),
        .funct3    (funct3),

        .PCSrc     (PCSrc),
        .ResultSrc (ResultSrc),
        .MemWrite  (MemWrite),
        .ALUSrc    (ALUSrc),
        .ImmSrc    (ImmSrc),
        .RegWrite  (RegWrite),
        .AddressingMode (AddressingMode)
    );

    // alu decoder
    aluDecoder aluDec (
        .op         (op),
        .funct3     (funct3),
        .funct7     (funct7),

        .ALUControl (ALUControl)
    );
    
endmodule