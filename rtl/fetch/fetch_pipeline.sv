module fetch_pipeline #(
    parameter DATA_WIDTH = 32
)(
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 trigger,
    input  logic                 FlushD,      // flush
    input  logic                 StallD,      // stall

    input  logic [DATA_WIDTH-1:0]          InstrF,
    input  logic [DATA_WIDTH-1:0]          PCF,
    input  logic [DATA_WIDTH-1:0]          PCPlus4F,
    input  logic                           PredictTakenF,
    input  logic [DATA_WIDTH-1:0]          PredictTargetF,

    output logic [DATA_WIDTH-1:0]          InstrD,
    output logic [DATA_WIDTH-1:0]          PCD,
    output logic [DATA_WIDTH-1:0]          PCPlus4D,
    output logic                           PredictTakenD,
    output logic [DATA_WIDTH-1:0]          PredictTargetD
);

    always_ff @(posedge clk) begin
        if (FlushD | rst) begin
            InstrD      <= '0;
            PCD         <= '0;
            PCPlus4D    <= '0;
            PredictTakenD <= '0;
            PredictTargetD <= '0;
        end
        else if (StallD | trigger) begin
            InstrD      <= InstrD;
            PCD         <= PCD;
            PCPlus4D    <= PCPlus4D;
            PredictTakenD <= PredictTakenD;
            PredictTargetD <= PredictTargetD;
        end
        else begin
            InstrD      <= InstrF;
            PCD         <= PCF;
            PCPlus4D    <= PCPlus4F;
            PredictTakenD <= PredictTakenF;
            PredictTargetD <= PredictTargetF;
        end
    end

endmodule
