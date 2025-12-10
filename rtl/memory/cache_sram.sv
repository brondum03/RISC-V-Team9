
module cache_sram #(
    parameter CACHE_ADDR_WIDTH = 5,     // 2^5 (32) sets
    parameter SET_SIZE = 277            // 277 bits in a set - 1 bit LRU + 2 way * (1 dirty bit + 1 valid bit + 8 bit tag + 4*32bit data)
)(
    input logic                         clk,
    input logic [CACHE_ADDR_WIDTH-1:0]  Address,    
    input logic [SET_SIZE-1:0]          WriteData,
    input logic                         WriteEnable,
    input logic                         ReadEnable,
    output logic [SET_SIZE-1:0]         ReadData
);
    logic [SET_SIZE-1:0] set_array [2**CACHE_ADDR_WIDTH-1:0];   // 32 sets of 277 bits

    always_comb begin
        if(ReadEnable) begin
            ReadData = set_array[Address];
        end else begin
            ReadData = {SET_SIZE{1'b0}};
        end
    end

    always_ff @(posedge clk) begin
        if(WriteEnable) begin
            set_array[Address] <= WriteData;
        end
    end

endmodule
