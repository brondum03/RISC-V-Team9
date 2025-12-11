module branch_target_buffer #(
    parameter ADDR_WIDTH = 32,
    parameter INDEX_BITS = 8
)(
    input  logic                     clk,
    input  logic                     rst,
    
    // lookup in fetch stage
    input  logic [ADDR_WIDTH-1:0]    pc_fetch,
    output logic                     hit,
    output logic [ADDR_WIDTH-1:0]    target_addr,
    
    // update from execute stage
    input  logic                     update_enable,
    input  logic [ADDR_WIDTH-1:0]    update_pc,
    input  logic [ADDR_WIDTH-1:0]    update_target
);

    typedef struct packed{
        logic                   valid;
        logic [ADDR_WIDTH-1:0]  tag;
        logic [ADDR_WIDTH-1:0]  target;
    } btb_entry;
    
    btb_entry btb_table [2**INDEX_BITS-1:0];
    
    logic [INDEX_BITS-1:0] fetch_index;
    logic [INDEX_BITS-1:0] update_index;
    logic [ADDR_WIDTH-INDEX_BITS-2-1:0] fetch_tag;
    
    assign fetch_index = pc_fetch[INDEX_BITS+1:2];
    assign update_index = update_pc[INDEX_BITS+1:2];
    assign fetch_tag = pc_fetch[ADDR_WIDTH-1:INDEX_BITS+2];
    
    // lookup
    assign hit = btb_table[fetch_index].valid && (btb_table[fetch_index].tag == fetch_tag);
    assign target_addr = btb_table[fetch_index].target;
    
    // update
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 2**INDEX_BITS; i++) begin
                btb_table[i].valid <= 1'b0;
            end
        end else if (update_enable) begin
            btb_table[update_index].valid <= 1'b1;
            btb_table[update_index].tag <= update_pc[ADDR_WIDTH-1:INDEX_BITS+2];
            btb_table[update_index].target <= update_target;
        end
    end

endmodule
