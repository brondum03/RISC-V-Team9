module execute_pipeline_register #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                       clk,
    
    // inputs from decode stage 
    input   logic [DATA_WIDTH-1:0]      ALUResultE,
    input   logic [DATA_WIDTH-1:0]      WriteDataE,
    input   logic [DATA_WIDTH-1:0]      PCPlus4E,
    input   logic [ADDR_WIDTH-1:0]      RdE,
    
    // control signals from decode stage
    input   logic                       RegWriteE,
    input   logic [1:0]                 ResultSrcE,
    input   logic                       MemWriteE,
    input   logic [2:0]                 AddressingModeE,
    
    // output to memory stage
    output  logic [DATA_WIDTH-1:0]      ALUResultM,
    output  logic [DATA_WIDTH-1:0]      WriteDataM,
    output  logic [DATA_WIDTH-1:0]      PCPlus4M,
    output  logic [ADDR_WIDTH-1:0]      RdM,
    
    // control signals to memory stage
    output  logic                       RegWriteM,
    output  logic [1:0]                 ResultSrcM,
    output  logic                       MemWriteM,
    output  logic [2:0]                 AddressingModeM
);

    always_ff @(negedge clk) begin
            
        // data paths
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        PCPlus4M <= PCPlus4E;
        RdM <= RdE;
            
        // control signals
        RegWriteM <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM <= MemWriteE;
        AddressingModeM <= AddressingModeE;
    end

endmodule
