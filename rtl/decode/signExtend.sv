/*
Ezekiel
INCOMPLETE : working on control unit first
*/

module signExtend #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0]    Instr,
    input logic [2:0]               ImmSrc,
    
    output logic [DATA_WIDTH-1:0]   ImmExt
);
    always_comb begin
            case (ImmSrc)
                3'b000:    ImmExt = {{20{Instr[31]}}, Instr[31:20]}; // I-type
                3'b001:    ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]}; // S-type
                3'b010:    ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; // B-type
                3'b011:    ImmExt = {Instr[31:12], 12'b0}; // U-type
                3'b100:    ImmExt = {{11{Instr[31]}}, Instr[31], Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // J-type
                default:   ImmExt = {{20{Instr[31]}}, Instr[31:20]};
            endcase
    end

endmodule