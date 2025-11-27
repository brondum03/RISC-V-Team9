/*
Ezekiel
*/

module mainDecoder (
    input logic [6:0]       op;

    output logic        Branch;
    output logic        ResultSrc;
    output logic        MemWrite;
    output logic        ALUSrc;
    output logic [1:0]  ImmSrc;
    output logic        RegWrite;
    output logic [1:0]  ALUOp;
);

always_comb begin
    // default all signals
    Branch = 0;
    ResultSrc = 0;
    MemWrite = 0;
    ALUSrc = 0;
    ImmSrc = 2'b00;
    RegWrite = 0;
    ALUOp = 2'b00;

    case (op)
        // R -> register to register arithmetic and logical op -->add, sub, ans, or, xor
        7'b0110011: begin
            RegWrite = 1;
            ALUSrc = 0;
            ALUOp = 2'b10;
        end

        // I -> immediate arithmetic and logical op --> addi, andi, ori
        7'b0010011: begin
            RegWrite = 1;
            ALUSrc = 1;
            ImmSrc = 0;
            ALUOp = 2'b11;
        end

        // I -> load operations --> lw, lb, lbu, lh, lhu
        7'b0000011: begin
            RegWrite = 1;
            ALUSrc = 1;
            ResultSrc = 1;
            ImmSrc = 2'b00;
            ALUOp = 2'b00;
        end

        // I -> jump and link register --> jalr
        7'b1100111: begin
            RegWrite = 1;
            ALUSrc = 1;
            ImmSrc = 2'b00;
            ALUOp = 2'b00;
        end

        // S -> store operations --> sw, sb, sh
        7'b0100011: begin
            MemWrite = 1;
            ALUSrc = 1;
            ImmSrc = 2'b01;
            ALUOp = 2'b00;
        end

        // B -> conditional branch operations -->> beq, bne, blt, bge
        7'b1100011: begin
            Branch = 1;
            ALUSrc = 0;
            ImmSrc = 2'b10;
            ALUOp = 2'b01;
        end

        // U  -> load upper immediate --> lui
        7'b0110111: begin
            RegWrite = 1;
            ALUSrc = 1;
            ImmSrc = 2'b11;
            ALUOp = 2'b00;
        end

        // U -> add upper immediate to pc --> auipc
        7'b0010111: begin
            RegWrite = 1;
            ALUSrc = 1;
            ImmSrc = 2'b11;
            ALUOp = 2'b00;
        end

        // J -> jump and link --> jal
        7'b1101111: begin
            RegWrite = 1;
            ImmSrc = 3'b100;
            ALUSrc = 0;
            ALUOp = 2'b00;
        end
        
        default: begin
            Branch = 0;
            ResultSrc = 0;
            MemWrite = 0;
            ALUSrc = 0;
            ImmSrc = 2'b00;
            RegWrite = 0;
            ALUOp = 2'b00;
        end
    endcase
end
    
endmodule