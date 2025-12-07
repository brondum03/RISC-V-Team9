module cache_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter CACHE_SIZE = 1024,    // 1024 byte cache = 256 words
    parameter BLOCK_SIZE = 16,      // 16 bytes = 4 words
    parameter WORD_SIZE = 4,        // 4 bytes / word
    parameter ASSOCIATIVITY = 2     // 2-way set associative cache
)(
    input logic                     clk,
    input logic                     rst,

    // from cpu
    input logic [2:0]               AddressingMode,        
    input logic                     CPU_WriteEnable,    // write enable (0=read, 1=write) 
    input logic [ADDR_WIDTH-1:0]    CPU_Address,       
    input logic [DATA_WIDTH-1:0]    CPU_WriteData,   

    input logic [DATA_WIDTH-1:0]    Mem_ReadData,   

    // to cpu
    output logic [DATA_WIDTH-1:0]   CPU_ReadData,
    output logic                    CPU_Ready,

    // to dram
    output logic [DATA_WIDTH-1:0]   Mem_WriteData,  
    output logic [ADDR_WIDTH-1:0]   Mem_Address,
    output logic                    Mem_WriteEnable,
    output logic                    Mem_ReadRequest
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
    localparam OFFSET_BITS = BYTE_OFFSET_BITS + BLOCK_OFFSET_BITS;                
    localparam TAG_BITS = ADDR_WIDTH - INDEX_BITS - OFFSET_BITS;        // 23 bits for tag
    localparam SET_SIZE = 307;
    
    logic [TAG_BITS-1:0]            tag;
    logic [INDEX_BITS-1:0]          set_index;
    logic [BLOCK_OFFSET_BITS-1:0]   block_offset;
    logic [BYTE_OFFSET_BITS-1:0]    byte_offset;

    assign tag           = CPU_Address[ADDR_WIDTH-1 : INDEX_BITS+OFFSET_BITS];
    assign set_index     = CPU_Address[INDEX_BITS+OFFSET_BITS-1 : OFFSET_BITS];
    assign block_offset  = CPU_Address[BLOCK_OFFSET_BITS+BYTE_OFFSET_BITS-1 : BYTE_OFFSET_BITS];
    assign byte_offset   = CPU_Address[BYTE_OFFSET_BITS-1 : 0];

    // sram signals
    logic [SET_SIZE-1:0]            SRAM_DataOut;
    logic [SET_SIZE-1:0]            SRAM_WriteData;
    logic [INDEX_BITS-1:0]          SRAM_Address;
    logic                           SRAM_WriteEnable;

    // controller signals


    cache_sram #(
        .CACHE_ADDR_WIDTH(INDEX_BITS),
        .SET_SIZE(SET_SIZE)
    ) sram (
        .clk(clk),
        .Address(SRAM_Address),
        .WriteData(SRAM_WriteData),
        .WriteEnable(SRAM_WriteEnable),
        .ReadEnable(1'b1),
        .ReadData(SRAM_DataOut)
    );
    
    cache_controller #(
        .SET_SIZE(SET_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .CACHE_ADDR_WIDTH(INDEX_BITS),
        .TAG_WIDTH(TAG_BITS),
        .BLOCK_OFFSET_WIDTH(BLOCK_OFFSET_BITS)
    ) cache_controller(
        .clk(clk),
        .rst(rst),
        // from cpu
        .WriteEnable(CPU_WriteEnable),
        .WriteData(CPU_WriteData),
        .TargetSet(set_index),
        .TargetTag(tag),
        .TargetBlockOffset(block_offset),
        .addr_mode(AddressingMode),
        // from sram
        .SetData(SRAM_DataOut),
        // from dram
        .Mem_ReadData(Mem_ReadData),
        .Mem_Ready(1'b1),   // asynchronous read - memory is always ready
        // to cpu
        .DataOut(CPU_ReadData),
        .CPU_Ready(CPU_Ready),
        // to sram
        .SRAM_WriteData(SRAM_WriteData),
        .SRAM_WriteEnable(SRAM_WriteEnable),
        .SRAM_Address(SRAM_Address),
        // to dram
        .Mem_WriteData(Mem_WriteData),
        .Mem_Address(Mem_Address),
        .Mem_WriteEnable(Mem_WriteEnable),
        .Mem_ReadRequest(Mem_ReadRequest)
    );

endmodule
