module execute_pipeline_register #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                       clk,
    input   logic                       rst,
    input   logic                       trigger,
    
    // inputs from decode stage 
    input   logic [DATA_WIDTH-1:0]      ALUResultE,
    input   logic [DATA_WIDTH-1:0]      WriteDataE,
    input   logic [DATA_WIDTH-1:0]      PCPlus4E,
    input   logic [ADDR_WIDTH-1:0]      RdE,
    
    // control signals from decode stage
    input   logic                       RegWriteE,
    input   logic [1:0]                 ResultSrcE,
    input   logic                       MemWriteE,
    input   logic                       MemReadE,
    input   logic [2:0]                 AddressingModeE,

    input   logic                       StallM,     // stall signal to be triggered if cache is not loaded  
    
    // output to memory stage
    output  logic [DATA_WIDTH-1:0]      ALUResultM,
    output  logic [DATA_WIDTH-1:0]      WriteDataM,
    output  logic [DATA_WIDTH-1:0]      PCPlus4M,
    output  logic [ADDR_WIDTH-1:0]      RdM,
    
    // control signals to memory stage
    output  logic                       RegWriteM,
    output  logic [1:0]                 ResultSrcM,
    output  logic                       MemWriteM,
    output  logic                       MemReadM,
    output  logic [2:0]                 AddressingModeM
);

    always_ff @(posedge clk) begin
        
        if(rst) begin 
            // data paths
            ALUResultM <= 0;
            WriteDataM <= 0;
            PCPlus4M <= 0;
            RdM <= 0;
                
            // control signals
            RegWriteM <= 0;
            ResultSrcM <= 0;
            MemWriteM <= 0;
            MemReadM <= 0;
            AddressingModeM <= 0;
        end
        else if(!trigger && !StallM) begin 
            // data paths
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            PCPlus4M <= PCPlus4E;
            RdM <= RdE;
                
            // control signals
            RegWriteM <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM <= MemWriteE;
            MemReadM <= MemReadE;
            AddressingModeM <= AddressingModeE;
        end
    end

endmodule
