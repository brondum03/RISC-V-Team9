//ALU has 2 functions, addi and bne
//for addi, i just add the two inputs
//for bne, two check if two inputs are equal, i subtract one from the other
//then check if the output is zero, indicating they are equal
module alu#(
    parameter DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0] ALUop1,
    input   logic [DATA_WIDTH-1:0] ALUop2,
    input   logic [2:0] ALUctrl,
    output  logic [DATA_WIDTH-1:0] ALUout,
    output  logic EQ
);

    localparam addition = 3b'001;
    localparam subtract_with_flag = 3b'010;

    always_comb begin
        case(ALUctrl)
            addition:   ALUout = ALUop1 + ALUop2;
            
            subtract_with_flag: ALUout = ALUop1 - ALUop2
            
            default:    ALUout = {DATA_WIDTH{1b'0}}
        endcase
    end

    //the EQ flag will be used to determine if ALUop1 = ALUop2
    //after subtraction, if ALUout = 0, meaning both inputs are the same, then EQ will output 1
    assign EQ = (ALUout == {DATA_WIDTH{1'b0}}) 

endmodule
