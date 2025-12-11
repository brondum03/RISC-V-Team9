module instruction_memory #(
    parameter INSTR_WIDTH = 32,
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE  = 4096
)(
  // interface signals
  input  logic [INSTR_WIDTH-1:0] in,       
  output logic [INSTR_WIDTH-1:0] Instr1,
  output logic [INSTR_WIDTH-1:0] Instr2
);

logic [DATA_WIDTH-1:0] mem [MEM_SIZE-1:0];

initial begin
    $readmemh("program.hex", mem); 
end;

always_comb begin
    Instr1 = {mem[in+3], mem[in+2], mem[in+1], mem[in+0]}; // 32-bit word from 4 bytes
    Instr2 = {mem[in+7], mem[in+6], mem[in+5], mem[in+4]}; // 2nd instruction fetched
end

endmodule
