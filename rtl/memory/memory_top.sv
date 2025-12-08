// `include "../rtl/mux4.sv"
`include "../rtl/memory/datamemory.sv"
`include "../rtl/memory/memory_pipeline_register.sv"

module memory_top #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8,
    parameter ADDR_WIDTH = 17
)(
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   trigger,
    
    // inputs from EX/MEM pipeline register
    input   logic [DATA_WIDTH-1:0]    ALUResultM,
    input   logic [DATA_WIDTH-1:0]    WriteDataM,
    input   logic [DATA_WIDTH-1:0]    PCPlus4M,
    input   logic [4:0]               RdM,
    input   logic                     RegWriteM,
    input   logic [1:0]               ResultSrcM,
    input   logic                     MemWriteM,
    input   logic [2:0]               AddressingModeM,
    
    // from to MEM/WB pipeline register
    output logic [DATA_WIDTH-1:0]     ResultW,
    output logic                      RegWriteW,    
    output logic [4:0]                RdW,
    output logic                      CPU_Ready
);
// wires to pipeline register
logic [1:0]                 ResultSrcW;
logic [DATA_WIDTH-1:0]      ALUResultW;
logic [DATA_WIDTH-1:0]      PCPlus4W;
logic [DATA_WIDTH-1:0]      ReadDataW;

// wires between cache to dram
logic [DATA_WIDTH-1:0]      Mem_ReadData;
logic [ADDR_WIDTH-1:0]      Mem_Address;
logic [DATA_WIDTH-1:0]      Mem_WriteData;
logic                       Mem_WriteEnable;  
logic                       Mem_ReadRequest;

logic [DATA_WIDTH-1:0]      ReadDataM;

// data memory access 
datamemory #(
    .DATA_WIDTH(DATA_WIDTH),
    .BYTE_WIDTH(BYTE_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) Data_Memory (
    .clk(clk),
    .write_enable(Mem_WriteEnable),
    .write_data(Mem_WriteData),
    .address(Mem_Address),
    .addr_mode(AddressingModeM),    
    .read_data(Mem_ReadData),
    .Mem_ReadRequest(Mem_ReadRequest)
);

cache_top cache (
    .clk(clk),
    .rst(rst),
    
    .AddressingMode(AddressingModeM),   // need to implement (?)
    .CPU_WriteEnable(MemWriteM),
    .CPU_Address(ALUResultM[16:0]),
    .CPU_WriteData(WriteDataM),
    
    .Mem_ReadData(Mem_ReadData),
    
    .CPU_ReadData(ReadDataM),
    .CPU_Ready(CPU_Ready),   // stall entire cpu if cpu is not ready
    
    .Mem_WriteData(Mem_WriteData),
    .Mem_Address(Mem_Address),
    .Mem_WriteEnable(Mem_WriteEnable),
    .Mem_ReadRequest(Mem_ReadRequest)
);

memory_pipeline_register #(
    .DATA_WIDTH(DATA_WIDTH)
) memory_pipeline_register(
    .clk(clk),
    .rst(rst),
    .trigger(trigger),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .ALUResultM(ALUResultM),
    .ReadDataM(ReadDataM),
    .RdM(RdM),
    .PCPlus4M(PCPlus4M),
    .StallW(~CPU_Ready),

    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW),
    .ALUResultW(ALUResultW),
    .ReadDataW(ReadDataW),
    .RdW(RdW),
    .PCPlus4W(PCPlus4W)
);

mux4 #(
    .DATA_WIDTH(DATA_WIDTH)
) result_mux (
    .sel(ResultSrcW),
    .in0(ALUResultW),
    .in1(ReadDataW),
    .in2(PCPlus4W),
    .in3('0),
    .out(ResultW)
);

endmodule
