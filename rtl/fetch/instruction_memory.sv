module instruction_memory #(
    parameter INSTR_WIDTH = 32,
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE  = 4096
)(
  // interface signals
  input  logic [INSTR_WIDTH-1:0] in,       
  output logic [INSTR_WIDTH-1:0] out      
);

logic [DATA_WIDTH-1:0] mem [MEM_SIZE-1:0];

initial begin
    $readmemh("programs.hex", mem); 
end;

always_comb begin
    out  = {mem[in+3], mem[in+2], mem[in+1], mem[in+0]}; // 32-bit word from 4 bytes

end

endmodule
