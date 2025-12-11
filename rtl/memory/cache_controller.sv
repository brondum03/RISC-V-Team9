module cache_controller #(
    parameter SET_SIZE = 277,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 17,
    parameter CACHE_ADDR_WIDTH = 5,
    parameter TAG_WIDTH = 8,
    parameter BLOCK_OFFSET_WIDTH = 2
)(
    input logic                             clk,
    input logic                             rst,
    
    // from CPU
    input logic                             WriteEnable,
    input logic [DATA_WIDTH-1:0]            WriteData,
    input logic [CACHE_ADDR_WIDTH-1:0]      TargetSet,
    input logic [TAG_WIDTH-1:0]             TargetTag,  
    input logic [BLOCK_OFFSET_WIDTH-1:0]    TargetBlockOffset,
    input logic [2:0]                       addr_mode,    
    input logic                             memory_used_E,  // from execute stage (not used here) 
                               

    // from SRAM
    input logic [SET_SIZE-1:0]              SetData,
    input logic                             mem_used,   // 1 = memory being used (read or write), 0 = no memory operation
    // from DRAM
    input logic [DATA_WIDTH-1:0]            Mem_ReadData,
    input logic                             Mem_Ready,

    // to CPU
    output logic [DATA_WIDTH-1:0]           DataOut,
    output logic                            cache_ready,
    
    // to SRAM
    output logic [SET_SIZE-1:0]             SRAM_WriteData,
    output logic                            SRAM_WriteEnable,
    output logic [CACHE_ADDR_WIDTH-1:0]     SRAM_Address,

    // to DRAM
    output logic [DATA_WIDTH-1:0]           Mem_WriteData,
    output logic [ADDR_WIDTH-1:0]           Mem_Address,
    output logic                            Mem_WriteEnable,
    output logic                            Mem_ReadRequest

);

    logic                   LRU_bit;
    // way 0
    logic                   Valid_bit_0;
    logic                   Dirty_bit_0;
    logic [DATA_WIDTH-1:0]  Word0_0, Word1_0, Word2_0, Word3_0;
    logic [TAG_WIDTH-1:0]   Tag_0;
    logic [DATA_WIDTH-1:0]  Way0_Data;
    // way 1
    logic                   Valid_bit_1;
    logic                   Dirty_bit_1;
    logic [DATA_WIDTH-1:0]  Word0_1, Word1_1, Word2_1, Word3_1;
    logic [TAG_WIDTH-1:0]   Tag_1; 
    logic [DATA_WIDTH-1:0]  Way1_Data;

    (* verilator public *)
    logic [2:0]             current_state_enc; // for debugging
    // hit logic
    logic                   Hit0;
    logic                   Hit1;     
    logic                   Hit;
    logic [DATA_WIDTH-1:0]  Data;                

    assign LRU_bit = SetData[276];

    // WAY 0 
    assign Dirty_bit_0 = SetData[137];
    assign Valid_bit_0 = SetData[136];
    assign Tag_0       = SetData[135:128];      // 8-bit tag

    assign Word3_0     = SetData[127:96];
    assign Word2_0     = SetData[95:64];
    assign Word1_0     = SetData[63:32];
    assign Word0_0     = SetData[31:0];

    // WAY 1
// WAY 1  (bits 275:138)
    assign Dirty_bit_1 = SetData[275];
    assign Valid_bit_1 = SetData[274];
    assign Tag_1       = SetData[273:266];      // 8-bit tag

    assign Word3_1     = SetData[265:234];
    assign Word2_1     = SetData[233:202];
    assign Word1_1     = SetData[201:170];
    assign Word0_1     = SetData[169:138];



    // hit logic
    assign Hit0 = (Valid_bit_0 && (Tag_0 == TargetTag));
    assign Hit1 = (Valid_bit_1 && (Tag_1 == TargetTag));
    assign Hit = Hit0 || Hit1;

    // select word based on offset
    always_comb begin
        case (TargetBlockOffset)
            2'd0: Way0_Data = Word0_0;
            2'd1: Way0_Data = Word1_0;
            2'd2: Way0_Data = Word2_0;
            2'd3: Way0_Data = Word3_0;
        endcase
        
        case (TargetBlockOffset)
            2'd0: Way1_Data = Word0_1;
            2'd1: Way1_Data = Word1_1;
            2'd2: Way1_Data = Word2_1;
            2'd3: Way1_Data = Word3_1;
        endcase
    end

    mux2 data_mux(
        .in0(Way0_Data),
        .in1(Way1_Data),
        .sel(Hit1),
        .out(Data)
    ); 

    // use a FSM to manage the states of the controller for simplicity
    typedef enum logic [2:0] {
        IDLE,
        CHECK_TAG,
        ALLOCATE,
        REFILL,
        WRITE_BACK
    } cache_state;

    cache_state current_state, next_state;
    assign current_state_enc = current_state;


    logic [1:0] refill_count;
    logic [1:0] writeback_count;

    logic                   evict_way;
    logic                   evict_dirty;
    logic [TAG_WIDTH-1:0]   evict_tag;



    always_ff @(posedge clk) begin
        if (rst) begin
            current_state <= IDLE;
            refill_count <= '0;
            writeback_count <= '0;
        end else begin
            current_state <= next_state;
            
            if (current_state == REFILL && Mem_Ready)
                refill_count <= refill_count + 1;       // ensures all 4 words in the block are fetched
            else if (current_state == IDLE)
                refill_count <= '0;

            if (current_state == WRITE_BACK && Mem_Ready)
                writeback_count <= writeback_count + 1; // ensures all 4 words in the block are written back
            else if (current_state == ALLOCATE)
                writeback_count <= '0;
        end
    end

    

    always_comb begin   
        // default parameters
        next_state = current_state; // stay in the current state until next_state updated
        cache_ready = 1'b0;
        DataOut = '0;

        SRAM_WriteEnable = 1'b0;
        SRAM_WriteData = SetData;  
        SRAM_Address = TargetSet;

        Mem_ReadRequest = 1'b0;
        Mem_WriteEnable = 1'b0;
        Mem_Address = '0;
        Mem_WriteData = '0;

        evict_way = LRU_bit;    // checks LRU bit to determine which way to evict
        evict_dirty = evict_way ? Dirty_bit_1 : Dirty_bit_0;    // checks dirty bit of the way to be evicted
        evict_tag = evict_way ? Tag_1 : Tag_0;  // tag of the way to be evicted

        case(current_state)
            IDLE: begin
                cache_ready = 1'b1;   // cpu can proceed
                if (memory_used_E)    // only proceed if memory is being used (read or write)    
                    next_state = CHECK_TAG;
                else
                    next_state = IDLE;

            end

            CHECK_TAG: begin
                if (Hit) begin  // cache hit
                    cache_ready = 1'b1;   // cpu can continue once data is available in cache
                    DataOut = Data;

                    if (WriteEnable) begin  // writing to cache
                        SRAM_WriteEnable = 1'b1;
                        SRAM_WriteData = SetData; // current data

                        if (Hit0) begin     // way 0
                            case (TargetBlockOffset)
                                2'd0: SRAM_WriteData[31:0] = WriteData;
                                2'd1: SRAM_WriteData[63:32] = WriteData;
                                2'd2: SRAM_WriteData[95:64] = WriteData;
                                2'd3: SRAM_WriteData[127:96] = WriteData;
                            endcase
                            SRAM_WriteData[137] = 1'b1;     // set dirty bit
                            SRAM_WriteData[276] = 1'b1;     // way 1 becomes LRU
                        end else if (Hit1) begin    // way 1
                            case (TargetBlockOffset)
                                2'd0: SRAM_WriteData[169:138] = WriteData;
                                2'd1: SRAM_WriteData[201:170] = WriteData;
                                2'd2: SRAM_WriteData[233:202] = WriteData;
                                2'd3: SRAM_WriteData[265:234] = WriteData;
                            endcase
                            SRAM_WriteData[275] = 1'b1;     // set dirty bit
                            SRAM_WriteData[276] = 1'b0;     // way 0 becomes LRU
                        end
                    
                    end else begin  // just reading from cache
                        SRAM_WriteEnable = 1'b1;
                        SRAM_WriteData = SetData;   // no change to data
                        SRAM_WriteData[276] = Hit0 ? 1'b1 : 1'b0;   // update LRU
                    end

                    next_state = IDLE;
                end else begin  // cache miss
                    cache_ready = 1'b0;   // cpu has to wait
                    next_state = ALLOCATE;
                end
            end

            ALLOCATE: begin 
                cache_ready = 1'b0;   // cpu has to wait
                // this stage checks if the way to be evicted is dirty
                // if dirty, writeback, if not just replace the block
                if (evict_dirty) begin  
                    next_state = WRITE_BACK;
                end else begin
                    next_state = REFILL;
                end
            end

            WRITE_BACK: begin   // writeback to memory
                cache_ready = 1'b0;   // cpu has to wait
                Mem_WriteEnable = 1'b1;
                Mem_Address = {evict_tag, TargetSet, writeback_count, 2'b00};   // writeback count ensures all 4 words are written back

                if (evict_way) begin    // way 1
                    case (writeback_count)
                        2'd0: Mem_WriteData = Word0_1;
                        2'd1: Mem_WriteData = Word1_1;
                        2'd2: Mem_WriteData = Word2_1;
                        2'd3: Mem_WriteData = Word3_1;
                    endcase 
                end else begin          // way 0
                    case (writeback_count)
                        2'd0: Mem_WriteData = Word0_0;
                        2'd1: Mem_WriteData = Word1_0;
                        2'd2: Mem_WriteData = Word2_0;
                        2'd3: Mem_WriteData = Word3_0;
                    endcase
                end

                if (Mem_Ready && writeback_count == 2'd3) begin // writeback complete
                    next_state = REFILL;
                end
            end

            REFILL: begin   // fetch from memory
                cache_ready = 1'b0;   // cpu has to wait
                Mem_ReadRequest = 1'b1;
                Mem_Address = {TargetTag, TargetSet, refill_count, 2'b00};   // refill count ensures all 4 words are fetched

                if (Mem_Ready) begin
                    SRAM_WriteEnable = 1'b1;
                    SRAM_WriteData = SetData;  
                    
                    if (evict_way) begin    // way 1
                        case (refill_count)
                            2'd0: SRAM_WriteData[169:138] = Mem_ReadData;
                            2'd1: SRAM_WriteData[201:170] = Mem_ReadData;
                            2'd2: SRAM_WriteData[233:202] = Mem_ReadData;
                            2'd3: SRAM_WriteData[265:234] = Mem_ReadData;
                        endcase
                        
                        if (refill_count == 2'd3) begin // once all 4 words fetched
                            SRAM_WriteData[274] = 1'b1;             // set way 1 valid bit
                            SRAM_WriteData[275] = 1'b0;             // reset dirty bit
                            SRAM_WriteData[273:266] = TargetTag;    // new tag
                            SRAM_WriteData[276] = 1'b0;             // way 0 becomes LRU
                        end
                    
                    end else begin  // way 0
                        case (refill_count)
                            2'd0: SRAM_WriteData[31:0] = Mem_ReadData;
                            2'd1: SRAM_WriteData[63:32] = Mem_ReadData;
                            2'd2: SRAM_WriteData[95:64] = Mem_ReadData;
                            2'd3: SRAM_WriteData[127:96] = Mem_ReadData;
                        endcase

                        if (refill_count == 2'd3) begin
                            SRAM_WriteData[136] = 1'b1;         
                            SRAM_WriteData[137] = 1'b0;         
                            SRAM_WriteData[135:128] = TargetTag; 
                            SRAM_WriteData[276] = 1'b1;         
                        end
                    end

                    if (refill_count == 2'd3) begin
                        next_state = CHECK_TAG;
                    end
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
