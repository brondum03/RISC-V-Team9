module pcsrc_logic (
    input   logic           ZeroE,
    input   logic [2:0]     BranchE,
    input   logic [1:0]     JumpE,
    input   logic           NegativeE,
    input   logic           Less_unsignedE,
    output  logic           PCSrcE
);

    logic   Branch;

    always_comb begin
        // determine if branch is taken
        case (BranchE)
            3'b001: Branch = ZeroE;             // beq
            3'b010: Branch = ~ZeroE;            // bne
            3'b011: Branch = NegativeE;         // blt
            3'b100: Branch = ~NegativeE;        // bge
            3'b101: Branch = Less_unsignedE;    // bltu 
            3'b110: Branch = ~Less_unsignedE;   // bgeu 
            default: Branch = 0;
        endcase
        PCSrcE = (|JumpE) | Branch;

    end

endmodule
