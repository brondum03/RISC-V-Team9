module program_counter #(
    parameter DATA_WIDTH = 32
)(
  // interface signals
  input  logic             clk,       
  input  logic             rst,
  input  logic             trigger,
  input  logic             StallF,
  input  logic [DATA_WIDTH-1:0] PCNext,
  output logic [DATA_WIDTH-1:0] out   
);

logic [DATA_WIDTH-1:0] PC;

always_ff @(posedge clk) begin
    if (rst)
        PC <= 32'hBFC00000;
    else if (!StallF && !trigger)
        PC <= PCNext;
end

assign out = PC;

endmodule
