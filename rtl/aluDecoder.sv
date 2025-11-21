/*
Ezekiel
*/

/*
ALUControl              Meaning
000                     ADD
001                     SUB
010                     AND
011                     OR
100                     XOR
101                     SLT
110                     SLTU
111                     (reserved or pass through pc)

*/

module aluDecoder(
    input logic [2:0]   funct3;
    input logic         funct7;
    input logic [1:0]   ALUOp;

    output logic [2:0]  ALUControl;
);

always_comb begin
    case (ALUOp)
        // 00 -> load / store / jalr / lui
        // always add 
        2'b00: begin
            ALUControl = 3'b000; 
        end
        
        // 01 -> branches
        // funct3 will determine the type of comparison
        2'b01: begin
            case(funct3)
                3'b000: begin // BEQ
                    ALUControl = 3'b001; // sub
                end

                3'b001: begin // BNE
                    ALUControl = 3'b001; // sub
                end

                3'b100: begin // BLT
                    ALUControl = 3'b101; // SLT
                end

                3'b101: begin // BGE
                    ALUControl = 3'b101; // SLT
                end

                3'b110: begin // BLTU
                    ALUControl = 3'b110; // SLTU
                end

                3'b111: begin // BGEU
                    ALUControl = 3'b110; // SLTU
                end

                default:
                    ALUControl = 3'b000;
            endcase
        end

        // 10 -> r type instructions
        // funct7 distinguishes add/sub
        2'b10: begin
            case(funct3)
                3'b000: ALUControl = funct7 ? 3'b001 : 3'b000; // SUB or ADD
                3'b111: ALUControl = 3'b010; // AND
                3'b110: ALUControl = 3'b011; // OR
                3'b100: ALUControl = 3'b100; // XOR
                3'b010: ALUControl = 3'b101; // SLT
                3'b011: ALUControl = 3'b110; // SLTU

                default: ALUControl = 3'b000;
            endcase
        end

        // 11 -> I type arithmetic
        // dependent on funct3
        2'b11: begin
            case (funct3)
                3'b000: ALUControl = 3'b000; // ADDI
                3'b111: ALUControl = 3'b010; // ANDI
                3'b110: ALUControl = 3'b011; // ORI
                3'b100: ALUControl = 3'b100; // XORI
                3'b010: ALUControl = 3'b101; // SLTI
                3'b011: ALUControl = 3'b110; // SLTIU

                default: ALUControl = 3'b000;
            endcase
        end

        default: begin
            ALUControl = 3'b000;
        end
    endcase
end

endmodule
