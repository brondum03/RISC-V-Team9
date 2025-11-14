module clktick #(
    parameter WIDTH = 32
)(
  // interface signals
  input  logic             clk,       
  input  logic             rst,      
  input  logic             pcsrc,
  input  logic [12:0]      immOP,
  output logic [WIDTH-1:0] out      
);

logic [WIDTH-1:0] PCReg;
logic [WIDTH-1:0] nextPC;
always_comb begin
    if (pcsrc) begin
        nextPC = PCReg + immOP;   // branch 
    end else begin
        nextPC = PCReg + 32'd4;    // normal increment by 4
    end
end

always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PCReg <= '0;
        end else begin
            PCReg <= nextPC;
        end
    end    

assign out = PCReg
endmodule
