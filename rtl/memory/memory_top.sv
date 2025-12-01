// `include "../rtl/mux4.sv"
`include "../rtl/memory/datamemory.sv"

module memory_top #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8,
    parameter ADDR_WIDTH = 17
)(
    input   logic                   clk,
    
    // inputs from EX/MEM pipeline register
    input   logic [DATA_WIDTH-1:0]    ALUResultM,
    input   logic [DATA_WIDTH-1:0]    WriteDataM,
    input   logic [DATA_WIDTH-1:0]    PCPlus4M,
    input   logic [4:0]               RdM,
    input   logic                     RegWriteM,
    input   logic [1:0]               ResultSrcM,
    input   logic                     MemWriteM,
    input   logic                     AddressingModeM,
    
    // outputs to MEM/WB pipeline register
    output logic                      RegWrite_outM,
    output logic [1:0]                ResultSrc_outM,
    output logic [DATA_WIDTH-1:0]     ALUResult_outM,
    output logic [DATA_WIDTH-1:0]     ReadData_outM,
    output logic [4:0]                Rd_outM,
    output logic [DATA_WIDTH-1:0]     PCPlus4_outM,
);
    
    // data memory access 
    datamemory #(
        .DATA_WIDTH(DATA_WIDTH),
        .BYTE_WIDTH(BYTE_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) Data_Memory (
        .clk(clk),
        .write_enable(MemWriteM),
        .write_data(WriteDataM),
        .address(ALUResultM[ADDR_WIDTH-1:0]),
        .addr_mode(AddressingModeM),
        .read_data(ReadDataM)
    );

    // passing signals to MEM/WB pipeline register
    assign RegWrite_outM       = RegWriteM;
    assign ResultSrc_outM      = ResultSrcM;
    assign ALUResult_outM      = ALUResultM;
    assign Rd_outM             = RdM;
    assign PCPlus4_outM        = PCPlus4M;
    
endmodule
