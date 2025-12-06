module cache #(
    parameter DATA_WIDTH = 32,
    parameter ADRR_WIDTH = 32,
    parameter CACHE_SIZE = 1024,    // 1024 byte cache = 256 words
    parameter BLOCK_SIZE = 16,      // 16 bytes = 4 words
    parameter WORD_SIZE = 4,        // 4 bytes / word
    parameter ASSOCIATIVITY = 2     // 2-way set associative cache
)(
    input logic                     clk,
    input logic                     rst,

    input logic [2:0]               AddressingMode,        
    input logic                     CPU_WriteEnable,    // write enable (0=read, 1=write) 
    input logic [ADDR_WIDTH-1:0]    CPU_Address,        // address from CPU
    input logic [DATA_WIDTH-1:0]    CPU_WriteData,      // data from CPU

    input logic [DATA_WIDTH-1:0]    Read_from_RAM,      // read data from RAM

    output logic [DATA_WIDTH-1:0]   WriteData_to_RAM,   // word being evicted
    output logic                    WriteEnable_to_RAM, // write enable = 1 when word is written back to RAM
    output logic [ADDR_WIDTH-1:0]   Adress_to_RAM,      // evicted word address in RAM

    output logic [DATA_WIDTH-1:0]   ReadData            // read data 
); 

    // (b) block size = 4 words
    // (B) no. of blocks = 256/4 = 64 blocks
    // (N) N-way set associative = 2
    // (S) no. of sets =  64/2 = 32 sets
    // 5 bits of set indexing, 
    // 4 bits of offset (2bits block offset, 2bits byte offset) 
    // remaining 23 bits for tag
    localparam BLOCK_WORDS = BLOCK_SIZE / 4;                            // 4 words per block
    localparam NUM_SETS = CACHE_SIZE / (BLOCK_SIZE * ASSOCIATIVITY);    // 32 sets
    localparam INDEX_BITS = $clog2(NUM_SETS);                           // 5 bits for index
    localparam BYTE_OFFSET_BITS = $clog2(WORD_SIZE);                    // 2 bits byte offset
    localparam BLOCK_OFFSET_BITS = $clog2(BLOCK_WORDS);                 // 2 bits block offset 
    localparam TAG_BITS = ADDR_WIDTH - INDEX_BITS - OFFSET_BITS;        // 23 bits for tag
    
    logic [TAG_BITS-1:0]     tag;
    logic [INDEX_BITS-1:0]   set_index;
    logic 
    logic [OFFSET_BITS-1:0]  byte_offset;

    assign tag    = Address[ADDR_WIDTH-1 : INDEX_BITS+OFFSET_BITS];
    assign index  = Address[INDEX_BITS+OFFSET_BITS-1 : OFFSET_BITS];
    assign offset = Address[OFFSET_BITS-1 : 0];

    

endmodule
