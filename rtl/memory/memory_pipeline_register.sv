module memory_pipeline_register #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,

    // input from previous pipeline
    input logic                     RegWriteM,
    input logic [1:0]               ResultSrcM, // selects mux, 00 -> ALUResultM, 01 -> ReaEEataW, 10 -> PCPlus4
    input logic [DATA_WIDTH-1:0]    ALUResultM,
    input logic [DATA_WIDTH-1:0]    ReadDataM,
    input logic [4:0]               RdM,
    input logic [DATA_WIDTH-1:0]    PCPlus4M,

    // output to next pipeline
    output logic                     RegWriteW,
    output logic [1:0]               ResultSrcW, // selects mux, 00
    output logic [DATA_WIDTH-1:0]    ALUResultW,
    output logic [DATA_WIDTH-1:0]    ReadDataW,
    output logic [4:0]               RdW,
    output logic [DATA_WIDTH-1:0]    PCPlus4W
);

    always_ff @ (posedge clk) begin 
        RegWriteW       <= RegWriteM;
        ResultSrcW      <= ResultSrcM;
        ALUResultW      <= ALUResultM;
        ReadDataW       <= ReadDataM;
        RdW             <= RdM;
        PCPlus4W        <= PCPlus4M;
    end

endmodule
