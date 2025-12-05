module cache #(
    parameter DATA_WIDTH = 32,
    parameter ADRR_WIDTH = 32,
    parameter CACHE_SIZE = 1024,    // 1024 byte cache = 256 words
    parameter BLOCK_SIZE = 16,      // 16 bytes = 4 words
    parameter ASSOCIATIVITY = 2     // 2-way set associative cache
)(
    input logic                     clk,
    input logic                     rst,

    input logic [2:0]               AddressingMode,
    input logic                     MemWrite,
    input logic [ADDR_WIDTH-1:0]    Address,
    input logic [DATA_WIDTH-1:0]    WriteData,

    output logic [DATA_WIDTH-1:0]   ReadData,
); 

    // (b) block size = 4 words
    // (B) no. of blocks = 256/4 = 64 blocks
    // (N) N-way set associative = 2
    // (S) no. of sets =  64/2 = 32 sets
    // 5 bits of set indexing, 
    // 4 bits of offset (4 words x 4 bytes), 
    // remaining 23 bits for tag
    logic [3:0]     offset;
    logic [4:0]     set_index;
    logic [22:0]    tag;

    assign offset       = Address[3:0];
    assign set_index    = Address[4:8];
    assign tag          = Address[9:31];

endmodule
