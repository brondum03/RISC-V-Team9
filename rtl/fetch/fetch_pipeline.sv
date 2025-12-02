module fetch_pipeline #(
    parameter DATA_WIDTH = 32
)(
    input  logic                 clk,
    input  logic                 clear,      // flush
    input  logic                 stall,      // stall

    input  logic [31:0]          InstrF,
    input  logic [31:0]          PCF,
    input  logic [31:0]          PCPlus4F,

    output logic [31:0]          InstrD,
    output logic [31:0]          PCD,
    output logic [31:0]          PCPlus4D
);

    always_ff @(posedge clk) begin
        if (clear) begin
            InstrD      <= '0;
            PCD         <= '0;
            PCPlus4D    <= '0;
        end
        else if (stall) begin
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
