module mux #(
    DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0]  regOp2,
    input   logic [DATA_WIDTH-1:0]  ImmOp,
    input   logic                   ALUsrc,
    output  logic [DATA_WIDTH-1:0]  ALUop2
);
    assign out = sel ? in1 : in0;

endmodule
