/*
ALUControl              Meaning
0000 =                  ADD
0001 =                  SUB
0010 =                  AND
0011 =                  OR
0100 =                  XOR
0101 =                  SLL
0110 =                  SRL  // FIXED: Changed from 0101 to 0110
0111 =                  SRA
1000 =                  SLT
1001 =                  SLTU
*/

/*
FUNCT3
(000) --> I type, immediate
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
            MemWrite = 2'b00;
            PCSrc = 1'b1;
            ImmSrc = 6'b0;
            ResultSrc = 2'b00;
            PCSrc = 1'b0;
            ALUSrc = 2'b00;
            ALUControl = 8'b0;
            shiftImmFlag = 2'b00;
        end
        else begin
            // Default assignments
            RegWrite = 2'b00;
            ImmSrc = 6'b0;
            MemWrite = 2'b00;
            ResultSrc = 2'b00;
            PCSrc = 1'b0;
            ALUSrc = 2'b00;
            ALUControl = 8'b0;
            shiftImmFlag = 2'b00;
            // Handle instruction 1
            case(op1) 
                // R - Arithmetic and Logic
                7'b0110011 : begin 
                    // For R-type, ALUSrc = 0 (use register), ImmSrc doesn't matter
                    ALUSrc[0] = 1'b0;  // Use register for ALU input 2
                    
                    case(funct3_1) 
                        3'd0 : begin 
                            ALUControl[3:0] = funct7_1 ? 4'b0001 : 4'b0000;  // SUB if funct7=1 else ADD
                            RegWrite[0] = 1'b1;
                        end
                        3'd4 : begin 
                            ALUControl[3:0] = 4'b0100;  // XOR
                            RegWrite[0] = 1'b1;
                        end
                        3'd6 : begin 
                            ALUControl[3:0] = 4'b0011;  // OR
                            RegWrite[0] = 1'b1;
                        end
                        3'd7 : begin 
                            ALUControl[3:0] = 4'b0010;  // AND
                            RegWrite[0] = 1'b1;
                        end
                        3'd1 : begin 
                            ALUControl[3:0] = 4'b0101;  // SLL
                            RegWrite[0] = 1'b1;
                        end
                        3'd5 : begin 
                            ALUControl[3:0] = funct7_1 ? 4'b0111 : 4'b0110;  // SRA if funct7=1 else SRL
                            RegWrite[0] = 1'b1;
                        end
                        3'd2 : begin 
                            ALUControl[3:0] = 4'b1000;  // SLT
                            RegWrite[0] = 1'b1;
                        end
                        3'd3 : begin 
                            ALUControl[3:0] = 4'b1001;  // SLTU
                            RegWrite[0] = 1'b1;
                        end
                        default : begin 
                            ALUControl[3:0] = 4'b0000;  // Default to ADD
                            RegWrite[0] = 1'b0;
                        end
                    endcase
                end
                
                // I - Arithmetic and Logic
                7'b0010011 : begin 
                    // For I-type, ALUSrc = 1 (use immediate)
                    ALUSrc[0] = 1'b1;
                    // I-type immediate encoding (12-bit immediate, sign-extended)
                    ImmSrc[2:0] = 3'b000;  // I-type immediate
                    
                    case(funct3_1)
                        3'd0 : begin  // ADDI
                            ALUControl[3:0] = 4'b0000;  // ADD operation
                            RegWrite[0] = 1'b1;
                        end
                        3'd4 : begin  // XORI
                            ALUControl[3:0] = 4'b0100;
                            RegWrite[0] = 1'b1;
                        end
                        3'd6 : begin  // ORI
                            ALUControl[3:0] = 4'b0011;
                            RegWrite[0] = 1'b1;
                        end
                        3'd7 : begin  // ANDI
                            ALUControl[3:0] = 4'b0010;
                            RegWrite[0] = 1'b1;
                        end
                        3'd1 : begin  // SLLI
                            ALUControl[3:0] = 4'b0101;
                            RegWrite[0] = 1'b1;
                            shiftImmFlag[0] = 1'b1;  // Special handling for shift immediate
                        end
                        3'd5 : begin  // SRLI/SRAI
                            ALUControl[3:0] = funct7_1 ? 4'b0111 : 4'b0110;  // SRAI if funct7=1 else SRLI
                            RegWrite[0] = 1'b1;
                            shiftImmFlag[0] = 1'b1;  // Special handling for shift immediate
                        end
                        3'd2 : begin  // SLTI
                            ALUControl[3:0] = 4'b1000;
                            RegWrite[0] = 1'b1;
                        end
                        3'd3 : begin  // SLTIU
                            ALUControl[3:0] = 4'b1001;
                            RegWrite[0] = 1'b1;
                        end
                        default : begin
                            ALUControl[3:0] = 4'b0000;
                            RegWrite[0] = 1'b0;
                        end
                    endcase
                end

                default : begin 
                    RegWrite[0] = 1'b0;
                    ALUSrc[0] = 1'b0;
                end
            endcase

            // Handle instruction 2 (same logic as instruction 1)
            case(op2) 
                // R - Arithmetic and Logic
                7'b0110011 : begin 
                    ALUSrc[1] = 1'b0;  // Use register for ALU input 2
                    
                    case(funct3_2)  // FIXED: Changed funct3_1 to funct3_2
                        3'd0 : begin 
                            ALUControl[7:4] = funct7_2 ? 4'b0001 : 4'b0000;
                            RegWrite[1] = 1'b1;
                        end
                        3'd4 : begin 
                            ALUControl[7:4] = 4'b0100;
                            RegWrite[1] = 1'b1;
                        end
                        3'd6 : begin 
                            ALUControl[7:4] = 4'b0011;
                            RegWrite[1] = 1'b1;
                        end
                        3'd7 : begin 
                            ALUControl[7:4] = 4'b0010;
                            RegWrite[1] = 1'b1;
                        end
                        3'd1 : begin 
                            ALUControl[7:4] = 4'b0101;
                            RegWrite[1] = 1'b1;
                        end
                        3'd5 : begin 
                            ALUControl[7:4] = funct7_2 ? 4'b0111 : 4'b0110;
                            RegWrite[1] = 1'b1;
                        end
                        3'd2 : begin 
                            ALUControl[7:4] = 4'b1000;
                            RegWrite[1] = 1'b1;
                        end
                        3'd3 : begin 
                            ALUControl[7:4] = 4'b1001;
                            RegWrite[1] = 1'b1;
                        end
                        default : begin 
                            ALUControl[7:4] = 4'b0000;
                            RegWrite[1] = 1'b0;
                        end
                    endcase
                end
                
                // I - Arithmetic and Logic
                7'b0010011 : begin 
                    ALUSrc[1] = 1'b1;  // Use immediate
                    ImmSrc[5:3] = 3'b000;  // I-type immediate
                    
                    case(funct3_2)  // FIXED: Changed funct3_1 to funct3_2
                        3'd0 : begin  // ADDI
                            ALUControl[7:4] = 4'b0000;
                            RegWrite[1] = 1'b1;
                        end
                        3'd4 : begin  // XORI
                            ALUControl[7:4] = 4'b0100;
                            RegWrite[1] = 1'b1;
                        end
                        3'd6 : begin  // ORI
                            ALUControl[7:4] = 4'b0011;
                            RegWrite[1] = 1'b1;
                        end
                        3'd7 : begin  // ANDI
                            ALUControl[7:4] = 4'b0010;
                            RegWrite[1] = 1'b1;
                        end
                        3'd1 : begin  // SLLI
                            ALUControl[7:4] = 4'b0101;
                            RegWrite[1] = 1'b1;
                            shiftImmFlag[1] = 1'b1;
                        end
                        3'd5 : begin  // SRLI/SRAI
                            ALUControl[7:4] = funct7_2 ? 4'b0111 : 4'b0110;  // FIXED: Changed funct7_1 to funct7_2
                            RegWrite[1] = 1'b1;
                            shiftImmFlag[1] = 1'b1;
                        end
                        3'd2 : begin  // SLTI
                            ALUControl[7:4] = 4'b1000;
                            RegWrite[1] = 1'b1;
                        end
                        3'd3 : begin  // SLTIU
                            ALUControl[7:4] = 4'b1001;
                            RegWrite[1] = 1'b1;
                        end
                        default : begin
                            ALUControl[7:4] = 4'b0000;
                            RegWrite[1] = 1'b0;
                        end
                    endcase
                end

                default : begin 
                    RegWrite[1] = 1'b0;
                    ALUSrc[1] = 1'b0;
                end
            endcase
        end
    end
    
endmodule