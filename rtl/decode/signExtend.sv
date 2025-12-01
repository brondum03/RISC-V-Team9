/*
Ezekiel
*/

/*
(000) --> I type, immediate

(001) --> S type, store instructions

(010) --> B type, branch instructions

(011) --> U type (“Upper immediate” instructions) load a 20-bit immediate into the upper bits (31:12) of a register.
2 types for U type
    - LUI --> load upper immediate --> rd = imm[31:12] << 12
    - AUIPC --> add upper immediate to PC --> rd = PC + (imm[31:12] << 12)

(100) --> J type, jump instructions
*/

module signExtend #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:7]    InstrD,
    input logic [2:0]               ImmSrcD,
    
    output logic [DATA_WIDTH-1:0]   ImmExtD
);
    always_comb begin
            case (ImmSrcD)
                3'b000:    ImmExtD = {{20{InstrD[31]}}, InstrD[31:20]}; // I-type
                3'b001:    ImmExtD = {{20{InstrD[31]}}, InstrD[31:25], InstrD[11:7]}; // S-type
                3'b010:    ImmExtD = {{20{InstrD[31]}}, InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0}; // B-type
                3'b011:    ImmExtD = {InstrD[31:12], 12'b0}; // U-type
                3'b100:    ImmExtD = {{11{InstrD[31]}}, InstrD[31], InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0}; // J-type
                default:   ImmExtD = {32'b0};
            endcase
    end

endmodule
