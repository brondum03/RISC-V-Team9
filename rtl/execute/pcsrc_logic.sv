module pcsrc_logic (
    input   logic           ZeroE,
    input   logic [2:0]     BranchE,
    input   logic [1:0]     JumpE,
    input   logic           NegativeE,
    input   logic           Less_unsignedE,
    output  logic           PCSrcE,
    output  logic           BranchTakenE
);

    logic   JumpTakenE;
    always_comb begin   // check for jump instructions 
        case (JumpE) 
            2'b01: JumpTakenE = 1'b1;   // JAL 
            2'b10: JumpTakenE = 1'b1;   // JALR
            default: JumpTakenE = 1'b0; 
        endcase

        case (BranchE) 
            3'b001: BranchTakenE = ZeroE;             // BEQ
            3'b010: BranchTakenE = ~ZeroE;            // BNE
            3'b011: BranchTakenE = NegativeE;         // BLT
            3'b100: BranchTakenE = ~NegativeE;        // BGE
            3'b101: BranchTakenE = Less_unsignedE;    // BLTU 
            3'b110: BranchTakenE = ~Less_unsignedE;   // BGEU 
            default: BranchTakenE = 1'b0;
        endcase

        PCSrcE = JumpTakenE | BranchTakenE;
    end

endmodule
