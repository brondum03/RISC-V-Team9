
/*
ALUControl              Meaning
0000 =                  ADD
0001 =                  SUB
0010 =                  AND
0011 =                  OR
0100 =                  XOR
0101 =                  SLL
0101 =                  SRL
0111 =                  SRA
1000 =                  SLT
1001 =                  SLTU
*/


/*
FUNCT3
(000) --> I type, immediate

(001) --> S type, store instructions

(010) --> B type, branch instructions

(011) --> U type (“Upper immediate” instructions) load a 20-bit immediate into the upper bits (31:12) of a register.
2 types for U type
    - LUI --> load upper immediate --> rd = imm[31:12] << 12
    - AUIPC --> add upper immediate to PC --> rd = PC + (imm[31:12] << 12)

(100) --> J type, jump instructions
*/

// LSB FOR INSTRUCTION 1
// MSB FOR INSTRUCTION 2

module controlUnit (
    input logic         stall,

    input logic [6:0]   op1,
    input logic [2:0]   funct3_1,
    input logic         funct7_1,

    input logic [6:0]   op2,
    input logic [2:0]   funct3_2,
    input logic         funct7_2,

    output logic        PCSrc, 
    output logic [1:0]  ResultSrc,
    output logic [1:0]  MemWrite, // 0 -> none write // 1 -> WE1 // 2 -> WE2 // 3 -> WE1 and WE2
    output logic [1:0]  ALUSrc, // 00, 01, 10, 11 --> split bit for srcMux selectors
    output logic [5:0]  ImmSrc, // 3 bits each [2:0] for Instr1 [5:3] for Instr2
    output logic [1:0]  RegWrite, // 0 -> none write // 1 -> WE3 // 2 -> WE6 // 3 -> WE3 and WE6
    output logic [7:0]  ALUControl, // 4 bits each --> [3:0] for Instr1 [7:4] for Instr2
    output logic [1:0]  shiftImmFlag // 2 bits parse it and check if need to extend immediate for shift instruction
);  

    always_comb begin 
        if(stall) begin 
            RegWrite = 2'b00;
            ImmSrc = 6'b0;
            MemWrite = 2'b00;
            ResultSrc = 2'b00;
            PCSrc = 1'b1;
            ALUSrc = 2'b0;
        end
        else begin
            RegWrite = 2'b00;
            ImmSrc = 6'b0; 
            MemWrite = 2'b00; 
            ResultSrc = 2'b00;
            PCSrc = 1'b0;
            ALUSrc = 2'b00;
            ALUControl = 8'b0;
            shiftImmFlag = 2'b00;

            // get the ALUControls for each instruction first instruction ALUControl[3:0] --> ALL LSBS      
            case(op1) 
                // R - Arithmetic and Logic
                7'b0110011 : begin 
                    case(funct3_1) 
                        3'd0 : begin ALUControl[3:0] =  funct7_1 ? 4'b0001 : 4'b0000; RegWrite[0] = 1;  end// if funct7_1 (sub) else (add) 
                        3'd4 : begin ALUControl[3:0] =  4'b0100; RegWrite[0] = 1; end// xor
                        3'd6 : begin ALUControl[3:0] =  4'b0011; RegWrite[0] = 1; end// or
                        3'd7 : begin ALUControl[3:0] =  4'b0010; RegWrite[0] = 1; end// and
                        3'd1 : begin ALUControl[3:0] =  4'b0101; RegWrite[0] = 1; end// sll
                        3'd5 : begin ALUControl[3:0] =  funct7_1 ? 4'b0111 : 4'b0110; RegWrite[0] = 1; end// srl / sra
                        3'd2 : begin ALUControl[3:0] =  4'b1000; RegWrite[0] = 1; end// slt
                        3'd3 : begin ALUControl[3:0] =  4'b1001; RegWrite[0] = 1; end// sltu

                        default : ALUControl[3:0] = 4'b0000;
                    endcase
                end
                // I - Arithmetic and Logic
                7'b0010011 : begin 
                    case(funct3_1)
                        3'd0 : begin ALUControl[3:0] =  funct7_1 ? 4'b0001 : 4'b0000; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; end// if funct7_1 (sub) else (add) 
                        3'd4 : begin ALUControl[3:0] =  4'b0100; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; end// xor
                        3'd6 : begin ALUControl[3:0] =  4'b0011; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; end// or
                        3'd7 : begin ALUControl[3:0] =  4'b0010; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; end// and
                        3'd1 : begin ALUControl[3:0] =  4'b0101; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; shiftImmFlag[0] = 1; end// sll
                        3'd5 : begin ALUControl[3:0] =  funct7_1 ? 4'b0111 : 4'b0110; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; shiftImmFlag[0] = 1; end// srl / sra
                        3'd2 : begin ALUControl[3:0] =  4'b1000; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; end// slt
                        3'd3 : begin ALUControl[3:0] =  4'b1001; RegWrite[0] = 1; ImmSrc[2:0] = 3'b0; end// sltu
                    endcase
                end

                default : begin end

            endcase

            case(op2) 
                // R - Arithmetic and Logic
                7'b0110011 : begin 
                    case(funct3_2) 
                        3'd0 : begin ALUControl[7:4] = funct7_2 ? 4'b0001 : 4'b0000; RegWrite[1] = 1;  end// if funct7_1 (sub) else (add) 
                        3'd4 : begin ALUControl[7:4] = 4'b0100; RegWrite[1] = 1; end// xor
                        3'd6 : begin ALUControl[7:4] = 4'b0011; RegWrite[1] = 1; end// or
                        3'd7 : begin ALUControl[7:4] = 4'b0010; RegWrite[1] = 1; end// and
                        3'd1 : begin ALUControl[7:4] = 4'b0101; RegWrite[1] = 1; end// sll
                        3'd5 : begin ALUControl[7:4] = funct7_2 ? 4'b0111 : 4'b0110; RegWrite[1] = 1; end// srl / sra
                        3'd2 : begin ALUControl[7:4] = 4'b1000; RegWrite[1] = 1; end// slt
                        3'd3 : begin ALUControl[7:4] = 4'b1001; RegWrite[1] = 1; end// sltu

                        default : ALUControl[7:4] = 4'b0000;
                    endcase
                end
                // I - Arithmetic and Logic
                7'b0010011 : begin 
                    case(funct3_1)
                        3'd0 : begin ALUControl[7:4] = funct7_2 ? 4'b0001 : 4'b0000; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; end// if funct7_1 (sub) else (add) 
                        3'd4 : begin ALUControl[7:4] = 4'b0100; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; end// xor
                        3'd6 : begin ALUControl[7:4] = 4'b0011; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; end// or
                        3'd7 : begin ALUControl[7:4] = 4'b0010; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; end// and
                        3'd1 : begin ALUControl[7:4] = 4'b0101; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; shiftImmFlag[1] = 1; end// sll
                        3'd5 : begin ALUControl[7:4] = funct7_1 ? 4'b0111 : 4'b0110; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; shiftImmFlag[1] = 1; end// srl / sra
                        3'd2 : begin ALUControl[7:4] = 4'b1000; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; end// slt
                        3'd3 : begin ALUControl[7:4] = 4'b1001; RegWrite[1] = 1; ImmSrc[5:3] = 3'b0; end// sltu
                    endcase
                end

                default : begin end
            endcase
        end
    end
    
endmodule
