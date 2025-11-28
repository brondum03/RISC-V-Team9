// `include "mux2.sv"

module program_counter #(
    parameter DATA_WIDTH = 32
)(
  // interface signals
  input  logic             clk,       
  input  logic             rst,
  input  logic [DATA_WIDTH-1:0] PCNext,
  output logic [DATA_WIDTH-1:0] out   
);

logic [DATA_WIDTH-1:0] PC;

always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= '0;
        end else begin
            PC <= PCNext;
        end
    end    

assign out = PCNext;

endmodule
