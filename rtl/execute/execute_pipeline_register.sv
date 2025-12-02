module execute_pipeline #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                       clk,
    input   logic                       flush,
    
    // inputs from decode stage 
    input   logic [DATA_WIDTH-1:0]      ALUResultE,
    input   logic [DATA_WIDTH-1:0]      WriteDataE,
    input   logic [DATA_WIDTH-1:0]      PCPlus4E,
    input   logic [4:0]                 RdE,
    
    // control signals from decode stage
    input   logic                       RegWriteE,
    input   logic [1:0]                 ResultSrcE,
    input   logic                       MemWriteE,
    input   logic [2:0]                 AddressingModeE,
    
    // output to memory stage
    output  logic [DATA_WIDTH-1:0]      ALUResultM,
    output  logic [DATA_WIDTH-1:0]      WriteDataM,
    output  logic [DATA_WIDTH-1:0]      PCPlus4M,
    output  logic [4:0]                 RdM,
    
    // control signals to memory stage
    output  logic                       RegWriteM,
    output  logic [1:0]                 ResultSrcM,
    output  logic                       MemWriteM,
    output  logic [2:0]                 AddressingModeM
);

    always_ff @(negedge clk) begin
        
        if (flush) begin // flush pipeline registers
            //data paths
            ALUResultM <= '0;
            WriteDataM <= '0;
            PCPlus4M <= '0;
            RdM <= '0;
            
            // control signals
            RegWriteM <= 1'b0;
            ResultSrcM <= 2'b00;
            MemWriteM <= 1'b0;
            AddressingModeM <= 3'b000;
        
        end else begin
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
    end

endmodule