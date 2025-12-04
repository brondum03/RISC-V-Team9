module fetch_pipeline #(
    parameter DATA_WIDTH = 32
)(
    input  logic                 clk,
    input  logic                 FlushD,      // flush
    input  logic                 StallD,      // stall

    input  logic [DATA_WIDTH-1:0]          InstrF,
    input  logic [DATA_WIDTH-1:0]          PCF,
    input  logic [DATA_WIDTH-1:0]          PCPlus4F,

    output logic [DATA_WIDTH-1:0]          InstrD,
    output logic [DATA_WIDTH-1:0]          PCD,
    output logic [DATA_WIDTH-1:0]          PCPlus4D
);

    always_ff @(posedge clk) begin
        if (FlushD) begin
            InstrD      <= '0;
            PCD         <= '0;
            PCPlus4D    <= '0;
        end
        else if (StallD) begin
            InstrD      <= InstrD;
            PCD         <= PCD;
            PCPlus4D    <= PCPlus4D;
        end
        else begin
            InstrD      <= InstrF;
            PCD         <= PCF;
            PCPlus4D    <= PCPlus4F;
        end
    end

endmodule
