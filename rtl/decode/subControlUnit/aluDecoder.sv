/*
Ezekiel
*/

/*
ALUControl              Meaning
0000 =                  ADD
0001 =                  SUB
0010 =                  AND
0011 =                  OR
0100 =                  XOR
0101 =                  SLL
0110 =                  SRA
0111 =                  SRL
1000 =                  SLT
1001 =                  SLTU

*/

module aluDecoder(
    input logic [6:0]   op,
    input logic [2:0]   funct3,
    input logic         funct7,

    output logic [3:0]  ALUControl
);

always_comb begin
    case(op)
        7'b0000011,  // Load (need ADD for address calc)
        7'b0100011,  // Store (need ADD for address calc)
        7'b1100111:  // JALR (need ADD for target address)
            ALUControl = 4'b0000;  // ADD
        
        7'b1100011:  // Branch (need SUB for comparison)
            ALUControl = 4'b0001;  // SUB
        
        7'b0110011,  // R-type
        7'b0010011:  // I-type arithmetic
            begin
                case (funct3)
                    3'b000: begin
                        if(op == 7'b0010011) ALUControl = 4'b0000;
                        else ALUControl = funct7 ? 4'b0001 : 4'b0000;
                    end
                    3'b001: ALUControl = 4'b0101;  // sll / slli
                    3'b010: ALUControl = 4'b1000;  // slt / slti
                    3'b011: ALUControl = 4'b1001;  // sltu / sltiu
                    3'b100: ALUControl = 4'b0100;  // xor / xori
                    3'b101: ALUControl = funct7 ? 4'b0110 : 4'b0111;  // srl/sra
                    3'b110: ALUControl = 4'b0011;  // or / ori
                    3'b111: ALUControl = 4'b0010;  // and / andi
                    default: ALUControl = 4'b0000;
                endcase
            end
        
        default: ALUControl = 4'b0000;  // Default to ADD
    endcase
end

endmodule
