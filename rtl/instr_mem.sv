module instr_mem #(
    parameter instr_width = 32,
    parameter data_width = 8,
    parameter mem_size   = 4096
)(
  // interface signals
  input  logic [instr_width-1:0] in,       
  output logic [instr_width-1:0] out      
);

logic [data_width-1:0] mem [mem_size-1:0];

initial begin
    $readmemh("programs.hex", mem); 
end;

always_comb begin
    out  = {mem[in+3], mem[in+2], mem[in+1], mem[in+0]}; // 32-bit word from 4 bytes

end

endmodule
