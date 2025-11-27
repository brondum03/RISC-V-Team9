module program_counter #(
    parameter WIDTH = 32
)(
  // interface signals
  input  logic             clk,       
  input  logic             rst,      
  input  logic [1:0]       pcsrc,
  input  logic [WIDTH-1:0] immOP,
  input  logic [WIDTH-1:0] result_in,
  output logic [WIDTH-1:0] out      
);

logic [WIDTH-1:0] PCReg;
logic [WIDTH-1:0] nextPC;
always_comb begin
    case (pcsrc) 
    2'b00:   nextPC = PCReg + 32'd4;
    2'b01:   nextPC = PCReg + immOP;
    2'b10:   nextPC = PCReg + result_in;
    2'b11:   nextPC = PCReg;
    default: nextPC = PCReg + 32'd4;
    endcase
end

always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PCReg <= '0;
        end else begin
            PCReg <= nextPC;
        end
    end    

assign out = PCReg;

endmodule
