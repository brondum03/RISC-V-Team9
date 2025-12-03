module pcsrc_logic (
    input   logic           ZeroE,
    input   logic [2:0]     BranchE,
    input   logic           JumpE,
    input  logic           NegativeE,
    input  logic           less_unsignedE,
    output  logic           PCSrcE
);

    logic   branch;

    always_comb begin
        // determine if branch is taken
        case (BranchE)
            3'b001: branch = ZeroE;           // beq
            3'b010: branch = ~ZeroE;           // bne
            3'b011: branch = NegativeE;        // blt
            3'b100: branch = ~NegativeE;      // bge
            3'b101: branch = less_unsignedE;   // BLTU 
            3'b110: branch = ~less_unsignedE;  // BGEU 
            default: branch = 0;
        endcase
        PCSrcE = JumpE | branch;

    end

endmodule
