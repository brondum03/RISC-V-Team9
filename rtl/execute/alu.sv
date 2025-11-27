// ALUControl              Meaning
// 000                     ADD
// 001                     SUB
// 010                     AND
// 011                     OR
// 100                     XOR
// 101                     SLT
// 110                     SLTU
// 111                     (reserved or pass through pc)

module alu#(
    parameter DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0]  ALUop1,
    input   logic [DATA_WIDTH-1:0]  ALUop2,
    input   logic [2:0]             ALUctrl,
    output  logic [DATA_WIDTH-1:0]  ALUout,
    output  logic                   EQ
);

    always_comb begin
        case(ALUctrl)
            3'b000:   ALUout = ALUop1 + ALUop2; //add
            3'b001:   ALUout = ALUop1 - ALUop2; //sub
            3'b010:   ALUout = ALUop1 & ALUop2; //and
            3'b011:   ALUout = ALUop1 | ALUop2; //or
            3'b100:   ALUout = ALUop1 ^ ALUop2; //xor
            3'b101:   ALUout = ($signed(ALUop1) < $signed(ALUop2)) ? 1 : 0; //set less than (signed)
            3'b110:   ALUout = (ALUop1 < ALUop2) ? 1 : 0; //set less than (unsigned)
            default:  ALUout = {DATA_WIDTH{1'b0}};
        endcase
    end

    //the EQ flag will be used to determine if ALUop1 = ALUop2
    //after subtraction, if ALUout = 0, meaning both inputs are the same, then EQ will output 1
    assign EQ = (ALUout == {DATA_WIDTH{1'b0}}); 

endmodule
