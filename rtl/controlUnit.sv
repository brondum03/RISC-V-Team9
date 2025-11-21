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



    
endmodule