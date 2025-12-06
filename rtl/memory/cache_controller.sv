// `include "../rtl/mux4.sv"

module cache_controller #(
    parameter SET_SIZE = 307,
    parameter DATA_WIDTH = 32,
    parameter ADRR_WIDTH = 32,
    parameter CACHE_ADDR_WIDTH = 5,
    parameter TAG_WIDTH = 23,
    parameter BLOCK_OFFSET_WIDTH = 2
)(
    input logic                             WriteEnable,
    input logic [DATA_WIDTH-1:0]            WriteData,
    input logic [CACHE_ADDR_WIDTH-1:0]      TargetSet,
    input logic [TAG_WIDTH-1:0]             TargetTag,  
    input logic [BLOCK_OFFSET_WIDTH-1:0]    TargetBlockOffset,
    input logic [2:0]                       addr_mode,                                  

    input logic [SET_SIZE-1:0]          SetData, 

    output logic                        DataOut,
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

    // hit logic
    logic                   Hit0;
    logic                   Hit1;     
    logic                   Hit;
    logic [DATA_WIDTH-1:0]  Data;                

    assign LRU_bit = SetData[306];
    // way 0 
    assign Dirty_bit_0 = SetData[152];
    assign Valid_bit_0 = SetData[151];
    assign Tag_0 = SetData[150:128];
    assign Word3_0 = SetData[127:96];
    assign Word2_0 = SetData[95:64];
    assign Word1_0 = SetData[63:32];
    assign Word0_0 = SetData[31:0];

    //way 1
    assign Dirty_bit_1 = SetData[305];
    assign Valid_bit_1 = SetData[304];
    assign Tag_1 = SetData[303:281];
    assign Word3_1 = SetData[280:249];
    assign Word2_1 = SetData[248:217];
    assign Word1_1 = SetData[216:185];
    assign Word0_1 = SetData[184:153];

    // hit logic
    assign Hit0 = (Valid_bit_0 && (Tag_0 == TargetTag));
    assign Hit1 = (Valid_bit_1 && (Tag_1 == TargetTag));
    assign Hit = Hit0 || Hit1;

    mux4 way0_mux(
        .in0(Word0_0),
        .in1(Word0_1),
        .in2(Word0_2),
        .in3(Word0_3),
        .sel(TargetBlockOffset),
        .out(Way0_Data)
    )
    
    mux4 way1_mux(
        .in0(Word1_0),
        .in1(Word1_1),
        .in2(Word1_2),
        .in3(Word1_3),
        .sel(TargetBlockOffset),
        .out(Way1_Data)
    )

    mux2 data_mux(
        .in0(Way0_Data),
        .in1(Way1_Data),
        .sel(Hit1),
        .out(Data)
    ) 

    always_comb begin
        if (!WriteEnable) begin  // read 
            if (Hit) begin  // if hit, read from cache
                DataOut = Data;
            end
            else (!Hit) begin   //if miss, load from data memory
                
        end
    end

endmodule