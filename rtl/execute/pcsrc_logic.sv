module pcsrc_logic (
    input   logic           ZeroE,
    input   logic [2:0]     BranchE,
    input   logic [1:0]     JumpE,
    input   logic           NegativeE,
    input   logic           Less_unsignedE,
    output  logic           PCSrcE
);

    always_comb begin   // check for jump instructions 
        case (JumpE)
            2'b01: PCSrcE = 1'b1;   // JAL 
            2'b10: PCSrcE = 1'b1;   // JALR
        default: begin  // then check for branch conditions
            case (BranchE)
                3'b001: PCSrcE = ZeroE;             // BEQ
                3'b010: PCSrcE = ~ZeroE;            // BNE
                3'b011: PCSrcE = NegativeE;         // BLT
                3'b100: PCSrcE = ~NegativeE;        // BGE
                3'b101: PCSrcE = Less_unsignedE;    // BLTU 
                3'b110: PCSrcE = ~Less_unsignedE;   // BGEU 
                default: PCSrcE = 1'b0;
            endcase
        end 
        endcase
    end

endmodule
