module branch_target_buffer #(
    parameter TABLE_BITS = 8,      // 256 entries
    parameter PC_WIDTH = 32
)(
    input  logic                clk,
    input  logic                rst,

    input  logic [PC_WIDTH-1:0] PCF,            // current PC in fetch
    output logic [PC_WIDTH-1:0] PredictTargetF, // predicted target address
    output logic                BTBHitF,        // 1 if we have a valid entry for this PC

    input  logic [PC_WIDTH-1:0] PCE,            // PC of instruction in execute
    input  logic [PC_WIDTH-1:0] BranchTargetE,  // address of instruction branched to
    input  logic                BranchTakenE,    // check if branch taken
    input  logic [2:0]          BranchE
);

    // number of entries
    localparam NUM_ENTRIES = 2**TABLE_BITS;
    // tag width = 32 - 2 (byte offset) - TABLE_BITS (index) = 22
    localparam TAG_WIDTH = PC_WIDTH - 2 - TABLE_BITS;

    typedef struct packed {
        logic                   valid;  
        logic [TAG_WIDTH-1:0]   tag;
        logic [PC_WIDTH-1:0]    target;
    } btb_entry_t;

    btb_entry_t btb_array [NUM_ENTRIES-1:0];

    logic [TABLE_BITS-1:0] index_f;
    logic [TAG_WIDTH-1:0]  tag_f;    
    logic [TABLE_BITS-1:0] index_e;
    logic [TAG_WIDTH-1:0]  tag_e;

    // extract index and tag from PCs (ignore byte offset)
    assign index_f = PCF[TABLE_BITS+1:2];
    assign tag_f   = PCF[PC_WIDTH-1 : TABLE_BITS+2];

    assign index_e = PCE[TABLE_BITS+1:2];
    assign tag_e   = PCE[PC_WIDTH-1 : TABLE_BITS+2];
    
    // reading from btb
    always_comb begin
        // read entry at the current index
        btb_entry_t entry_f = btb_array[index_f];

        // check for hit: valid bit is set AND tags match
        if (entry_f.valid && (entry_f.tag == tag_f)) begin
            BTBHitF        = 1'b1;
            PredictTargetF = entry_f.target;
        end else begin
            BTBHitF        = 1'b0;
            PredictTargetF = {PC_WIDTH{1'b0}};  //if no hit, the branch wouldn't be taken so this is just a placeholder
        end
    end

    // writing to btb when branch is taken
    always_ff @(posedge clk) begin
        if (rst) begin  // wipe all entries
            for (int i = 0; i < NUM_ENTRIES; i++) begin
                btb_array[i].valid = 1'b0;
            end
        end
        else if (BranchTakenE && (BranchE != 3'b000)) begin  // updates on any branch instructions
            btb_array[index_e].valid  <= 1'b1;
            btb_array[index_e].tag    <= tag_e;
            btb_array[index_e].target <= BranchTargetE;
        end
    end
endmodule
