module branch_predictor #(
    parameter ADDR_WIDTH = 32,
    parameter TABLE_BITS = 8  // 256-entry predictor table
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

    // 2-bit prediction state for each entry in the btb
    logic [1:0] predictor_table [2**TABLE_BITS-1:0];    

    // index of the btb/predictor table (8 bits - 256 entries)
    logic [TABLE_BITS-1:0] index_f;
    logic [TABLE_BITS-1:0] index_e;
    
    // use lower bits of PC (ignoring byte offset [1:0]) for index, 
    assign index_f = PCF[TABLE_BITS+1:2];
    assign index_e = PCE[TABLE_BITS+1:2];

    // predict taken if MSB = 1 (MSB 1 = taken, MSB 0 = not taken)
    assign PredictTakenF = predictor_table[index_f][1];

    always_ff @(posedge clk) begin
        if (rst) begin
            // reset all counters to weakly not taken (01)
            for (int i = 0; i < 2**TABLE_BITS; i++) begin
                predictor_table[i] = 2'b01;    
            end
        end
        else if (BranchE) begin
            // update state based on actual outcome
            case (predictor_table[index_e])
                2'b00: predictor_table[index_e] <= (BranchTakenE) ? 2'b01 : 2'b00; // SNT - if taken, go to WNT. if not taken, stay SNT
                2'b01: predictor_table[index_e] <= (BranchTakenE) ? 2'b10 : 2'b00; // WNT - if taken, go to WT. if not taken, go to SNT
                2'b10: predictor_table[index_e] <= (BranchTakenE) ? 2'b11 : 2'b01; // WT - if taken, go to ST. if not taken, go to WNT
                2'b11: predictor_table[index_e] <= (BranchTakenE) ? 2'b11 : 2'b10; // ST - if taken, stay ath ST. if not taken, go to WT
            endcase
        end
    end

endmodule
