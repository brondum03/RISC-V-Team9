module branch_predictor #(
    parameter ADDR_WIDTH = 32,
    parameter INDEX_BITS = 8  // 256-entry predictor table
)(
    input  logic                     clk,
    input  logic                     rst,
    
    // fetch stage: prediction
    input  logic [ADDR_WIDTH-1:0]    PCF,  // PC from fetch stage
    output logic                     PredictTakenF, // 1 = predict taken
    
    // execute stage: update
    input  logic                     BranchE, // checks if instruction in execute stage is a branch
    input  logic [ADDR_WIDTH-1:0]    PCE, // PC from execute stage
    input  logic                     BranchTakenE   // checks if branch taken
);

    // 2-bit saturating counters 
    logic [1:0] btb [2**TABLE_BITS-1:0];

    logic [TABLE_BITS-1:0] index_f;
    logic [TABLE_BITS-1:0] index_e;
    
    // use lower bits of PC (ignoring byte offset [1:0]) for index
    assign index_f = PCF[TABLE_BITS+1:2];
    assign index_e = PCE[TABLE_BITS+1:2];

    // predict taken if counter >= 2 (MSB is 1)
    assign PredictTakenF = btb[index_f][1];

    always_ff @(posedge clk) begin
        if (rst) begin
            // reset all counters to weakly not taken (01) or strongly taken (11)
            for (int i = 0; i < 2**TABLE_BITS; i++) begin
                btb[i] <= 2'b01; 
            end
        end
        else if (BranchE) begin
            // update state based on actual outcome
            case (bht[index_e])
                2'b00: bht[index_e] <= (BranchTakenE) ? 2'b01 : 2'b00; // SNT
                2'b01: bht[index_e] <= (BranchTakenE) ? 2'b10 : 2'b00; // WNT
                2'b10: bht[index_e] <= (BranchTakenE) ? 2'b11 : 2'b01; // WT
                2'b11: bht[index_e] <= (BranchTakenE) ? 2'b11 : 2'b10; // ST
            endcase
        end
    end

endmodule
