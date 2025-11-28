/*
Ezekiel
*/

module mainDecoder (
    input logic [6:0]   op,
    input logic         Zero,
    input logic         stall,
    input logic         negative,
    input logic [2:0]   funct3,

    output logic [1:0]  PCSrc, // 0->move to next, 1->branch, 2->jump, 3->stall
    output logic [1:0]  ResultSrc,
    output logic        MemWrite,
    output logic        ALUSrc,
    output logic [2:0]  ImmSrc,
    output logic        RegWrite,
    output logic        AddressingMode // --> 0 for word, 1 for byte
);

always_comb begin
    // default all signals
    
    if(stall) begin 
        RegWrite = 1'b0;
        ImmSrc = 3'b000;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        PCSrc = 2'b11;
        ALUSrc = 1'b0;
    end
    else begin
        RegWrite = 1'b0;
        ImmSrc = 3'b000;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        PCSrc = 2'b00;
        ALUSrc = 1'b0;
        AddressingMode = 1'b0;
    case (op)
        // R -> register to register arithmetic and logical op -->add, sub, ans, or, xor
        7'b0110011: begin
            RegWrite = 1'b1;
            ALUSrc = 1'b0;
            MemWrite = 1'b0;
            ResultSrc = 2'b00;
            PCSrc = 2'b00;
        end

        // I -> immediate arithmetic and logical op --> addi, andi, ori
        7'b0010011: begin
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ImmSrc = 3'b000;
            MemWrite = 1'b0;
            ResultSrc = 2'b00;
            PCSrc = 2'b00;
        end

        // I -> load operations --> lw, lb, lbu, lh, lhu
        7'b0000011: begin
            RegWrite = 1;
            ALUSrc = 1;
            ResultSrc = 1;
            ImmSrc = 3'b000;
            MemWrite = 1'b0;
            PCSrc = 2'b00;
            case(funct3)
                3'b010: AddressingMode = 1'b0;  // lw
                3'b100: AddressingMode = 1'b1;  // lbu
                default: AddressingMode = 1'b0;
            endcase
        end

        // I -> jump and link register --> jalr
        7'b1100111: begin
            RegWrite = 1;
            ALUSrc = 1;
            ImmSrc = 3'b000;
            MemWrite = 1'b0;
            ResultSrc = 2'b00;
            PCSrc = 2'b10;
        end

        // S -> store operations --> sw, sb, sh
        7'b0100011: begin
            MemWrite = 1;
            ALUSrc = 1;
            ImmSrc = 3'b001;
            RegWrite = 1'b0;
            PCSrc = 2'b00;
            case(funct3) 
                3'b000: AddressingMode = 1'b1;  // sb
                3'b010: AddressingMode = 1'b0;  // sw
                default: AddressingMode = 1'b0;
            endcase
        end

        // B -> conditional branch operations -->> beq, bne, blt, bge
        7'b1100011: begin
            RegWrite = 1'b0;
            ALUSrc = 1'b0;
            ImmSrc = 3'b010;
            MemWrite = 1'b0;
            case (funct3)
                3'b000: PCSrc = Zero ? 2'b01 : 2'b0;       // beq
                3'b001: PCSrc = ~Zero ? 2'b01 : 2'b0;      // bne
                3'b100: PCSrc = negative ? 2'b01 : 2'b0;   // blt 
                3'b101: PCSrc = ~negative ? 2'b01 : 2'b0;  // bge
                3'b110: PCSrc = negative ? 2'b01 : 2'b0;   // bltu
                3'b111: PCSrc = ~negative ? 2'b01 : 2'b0;  // bgeu
                default: PCSrc = 2'b0; // Default case
            endcase
        end

        // U  -> load upper immediate --> lui
        7'b0110111: begin
            RegWrite = 1'b1;
            ImmSrc = 3'b011;
            MemWrite = 1'b0;
            ResultSrc = 2'b11;
            PCSrc = 2'b00;
        end

        // J -> jump and link --> jal
        7'b1101111: begin
            RegWrite = 1'b1;
            ImmSrc = 3'b100;
            MemWrite = 1'b0;
            ResultSrc = 2'b10;
            PCSrc = 2'b01;
        end
        
        default: begin
            ResultSrc = 0;
            MemWrite = 0;
            ALUSrc = 0;
            ImmSrc = 3'b000;
            RegWrite = 0;
        end
    endcase
    end
end
    
endmodule