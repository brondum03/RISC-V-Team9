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

logic [DATA_WIDTH-1:0] pc;

always_ff @(posedge clk) begin
    if (rst)
        pc <= 0;
    else if (!StallF && !trigger)
        pc <= PCNext;
end

assign out = pc;

endmodule
