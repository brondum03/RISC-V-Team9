module pcsrc_logic (
    input   logic           ZeroE,
    input   logic           BranchE,
    input   logic           JumpE,
    output  logic [1:0]     PCSrcE
);

    logic   if_branch;

    always_comb begin
        if_branch = BranchE & ZeroE;
        PCSrcE = if_branch | JumpE;
    end

endmodule
