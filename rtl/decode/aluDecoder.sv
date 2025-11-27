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
    input logic [6:0]   op,
    input logic [2:0]   funct3,
    input logic         funct7,

    output logic [3:0]  ALUControl
);

always_comb begin
    case (funct3)

        // funct7 = 0 --> add / addi
        // funct7 = 1 --> sub
        3'b000: begin
            if(op == 7'b0010011) ALUControl = 4'b0000;
            else begin
                ALUControl = funct7 ? 4'b0001 : 4'b0000;
            end
        end
        // sll / slli
        3'b001: begin
            ALUControl = 4'b0101;
        end

        // slt / slti
        3'b010: begin
            ALUControl = 4'b1000;
        end

        // sltu / sltiu
        3'b011: begin
            ALUControl = 4'b1001;
        end

        // xor / xori
        3'b100: begin
            ALUControl = 4'b0100;
        end

        // funct7 = 0 --> srl / slri
        // funct7 = 1 --> sra / srai
        3'b101: begin
            ALUControl = funct7 ? 4'b0110 : 4'b0111;
        end

        // or / ori
        3'b110: begin
            ALUControl = 4'b0011;
        end

        // and / andi
        3'b111: begin
            ALUControl = 4'b0010;
        end

        // default case
        default: begin
            ALUControl = 4'b0000;
        end
    endcase
end

endmodule
