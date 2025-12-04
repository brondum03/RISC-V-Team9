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
AddressingMode          Meaning
000                     byte
001                     half
010                     word
011                     byte unsigned
100                     half unsigned
*/

/*
BranchD
3'b001; // beq
3'b010; // bne
3'b011; // blt
3'b100; // bge
3'b101; // bltu
3'b110; // bgeu
*/

/*
JumpD
2'b00;      no jump
2'b01;      jal
2'b10;      jalr
2'b11;  
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

module controlUnit(
    input logic [6:0]   op,
    input logic [2:0]   funct3,
    input logic         funct7,

    output logic        RegWriteD,
    output logic [1:0]  ResultSrcD, // selects mux, 00 -> ALUResultM, 01 -> ReadDataW, 10 -> PCPlus4
    output logic        MemWriteD,
    output logic [1:0]  JumpD, // -> 00 for noJump, 01 for JAL, 10 for JALR
    output logic [2:0]  BranchD,
    output logic [3:0]  ALUControlD,
    output logic        ALUSrcD, // ALU register or Imm source
    output logic [2:0]  ImmSrcD, // immsrc for signExtendsv
    output logic [2:0]  AddressingModeD
);

    always_comb begin 
        case(op) 
            // first case opcode == 0110011
            7'b0110011 : begin 
                RegWriteD = 1;
                ResultSrcD = 2'b00;
                MemWriteD = 0;
                JumpD = 2'b00;
                BranchD = 3'b000;
                // ALUControlD decided below
                ALUSrcD = 0;
                ImmSrcD = 3'b000;
                AddressingModeD = 3'b000;
                case(funct3) 
                    3'd0:
                        case(funct7) 
                            1'b0 : ALUControlD = 4'b0000; // ADD
                            1'b1 : ALUControlD = 4'b0001; // SUB
                        endcase
                    3'd4:
                        ALUControlD = 4'b0100; // XOR
                    3'd6:
                        ALUControlD = 4'b0011; //OR
                    3'd7:
                        ALUControlD = 4'b0010; // AND
                    3'd1:
                        ALUControlD = 4'b0101; // shift logical left
                    3'd5:
                        case(funct7)
                            1'b0 : ALUControlD = 4'b0110; // shift right logical
                            1'b1 : ALUControlD = 4'b0111; // shift right arith
                        endcase
                    3'd2:
                        ALUControlD = 4'b1000; // shift less than
                    3'd3:
                        ALUControlD = 4'b1001; // shift less than (U)
                    default : ALUControlD = 4'b0000;
                endcase
            end
            // opcode = 0010011 FMT = I
            7'b0010011 : begin 
                RegWriteD = 1;
                ResultSrcD = 2'b00;
                MemWriteD = 0;
                JumpD = 2'b00;
                BranchD = 3'b000;
                // ALUControlD decided below
                ALUSrcD = 1; // takes Imm 
                ImmSrcD = 3'b000; // signExtend the immediate way
                AddressingModeD = 3'b000;
                case(funct3) 
                    3'd0:
                        ALUControlD = 4'b0000; // ADD
                    3'd4:
                        ALUControlD = 4'b0100; // XOR
                    3'd6:
                        ALUControlD = 4'b0011; //OR
                    3'd7:
                        ALUControlD = 4'b0010; // AND
                    3'd1:
                        ALUControlD = 4'b0101; // shift logical left
                    3'd5:
                        case(funct7)
                            1'b0 : ALUControlD = 4'b0110; // shift right logical
                            1'b1 : ALUControlD = 4'b0111; // shift right arith
                        endcase
                    3'd2:
                        ALUControlD = 4'b1000; // shift less than
                    3'd3:
                        ALUControlD = 4'b1001; // shift less than (U)
                    default : ALUControlD = 4'b0000;
                endcase
            end
            // opcode = 0000011 --> ld,lh,lw,lbu,lhu ...
            7'b0000011: begin
            // AddressingModeD decides how we parse it
                RegWriteD = 1;
                ResultSrcD = 2'b01;
                MemWriteD = 0;
                JumpD = 2'b00;
                BranchD = 3'b000;
                ALUControlD = 4'b0000; // add for M[rs1 + imm]
                ALUSrcD = 1; // takes Imm 
                ImmSrcD = 3'b000; // signExtend the immediate way
                case(funct3) 
                    3'd0: AddressingModeD = 3'b000; // lb
                    3'd1: AddressingModeD = 3'b001; // lh
                    3'd2: AddressingModeD = 3'b010; // lw
                    3'd4: AddressingModeD = 3'b011; // lbu
                    3'd5: AddressingModeD = 3'b100; // lhu
                    default : AddressingModeD = 3'b000;
                endcase
            end
            // opcode = 0100011
            7'b0100011: begin
                RegWriteD = 0;
                ResultSrcD = 2'b00;
                MemWriteD = 1;
                JumpD = 2'b00;
                BranchD = 3'b000;
                ALUControlD = 4'b0000; // add for M[rs1 + imm]
                ALUSrcD = 1; // takes Imm 
                ImmSrcD = 3'b001; // signExtend the store way
                case(funct3) 
                    3'd0: AddressingModeD = 3'b000; // sb
                    3'd1: AddressingModeD = 3'b001; // sh
                    3'd2: AddressingModeD = 3'b010; // sw
                    default : AddressingModeD = 3'b000;
                endcase
            end
            // opcode = 1100011 --> branch instructions
            7'b1100011: begin
                RegWriteD = 0;
                ResultSrcD = 2'b00; // no writeback dont care
                MemWriteD = 0;
                JumpD = 2'b00;
                // BranchD decided below
                ALUControlD = 4'b0001; // sub for branch
                ALUSrcD = 0; // takes compares registers
                ImmSrcD = 3'b010; // signExtend the branch way
                AddressingModeD = 3'b000;
                case(funct3) 
                    3'd0: BranchD = 3'b001; // beq
                    3'd1: BranchD = 3'b010; // bne
                    3'd4: BranchD = 3'b011; // blt
                    3'd5: BranchD = 3'b100; // bge
                    3'd6: BranchD = 3'b101; // bltu
                    3'd7: BranchD = 3'b110; // bgeu
                    default: BranchD = 3'b000;
                endcase
            end
            // opcode 1101111 --> JAL
            7'b1101111: begin 
                RegWriteD = 1;
                ResultSrcD = 2'b10; // PCPlus4W to be selected
                MemWriteD = 0;
                JumpD = 2'b01; 
                BranchD = 3'b000;
                ALUControlD = 4'b0000;
                ALUSrcD = 0; 
                ImmSrcD = 3'b100; // signExtend the jump way
                AddressingModeD = 3'b000;
            end
            // opcode 1100111 --> JALR
            7'b1100111: begin 
                RegWriteD = 1;
                ResultSrcD = 2'b10; // PCPlus4W to be selected
                MemWriteD = 0;
                JumpD = 2'b10; 
                BranchD = 3'b000;
                ALUControlD = 4'b0000;
                ALUSrcD = 0; 
                ImmSrcD = 3'b100; // signExtend the jump way
                AddressingModeD = 3'b000;
            end
            // opcode 0110111 --> lui
            7'b0110111: begin 
                RegWriteD = 1;
                ResultSrcD = 2'b00; // ALUResultM
                MemWriteD = 0;
                JumpD = 2'b00; 
                BranchD = 3'b000;
                ALUControlD = 4'b0000;
                ALUSrcD = 1; 
                ImmSrcD = 3'b011; // signExtend the jump way
                AddressingModeD = 3'b000;
            end
            // opcode 0010111 --> auipc
            7'b0010111: begin 
                RegWriteD = 1;
                ResultSrcD = 2'b00; // ALUResultM
                MemWriteD = 0;
                JumpD = 2'b00; 
                BranchD = 3'b000;
                ALUControlD = 4'b0000;
                ALUSrcD = 1; 
                ImmSrcD = 3'b011; // signExtend the jump way
                AddressingModeD = 3'b000;
            end

            default : begin 
                RegWriteD   = 0;
                ResultSrcD  = 0;
                MemWriteD   = 0;
                JumpD       = 0;
                BranchD     = 0;
                ALUControlD = 0;
                ALUSrcD     = 0;
                ImmSrcD     = 0;
                AddressingModeD = 0;
            end
        endcase
    end
endmodule
