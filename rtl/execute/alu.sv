typedef enum logic [3:0] {
    ADD = 4'b0000,
    SUB = 4'b0001,
    AND = 4'b0010,
    OR  = 4'b0011,
    XOR = 4'b0100,
    SLL = 4'b0101, // shift left logical
    SRL = 4'b0110, // shift right logical
    SRA = 4'b0111, // shift right arithmetic (msb extended)
    SLT = 4'b1000, // set less than signed
    SLTU = 4'b1001 // set less than unsigned (zero extended)
} ALU_controls;

module alu#(
    parameter DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0]  ALUop1,
    input   logic [DATA_WIDTH-1:0]  ALUop2,
    input   logic [3:0]             ALUctrl,
    output  logic [DATA_WIDTH-1:0]  ALUout
);

    always_comb begin
        case(ALUctrl)
            ADD:   ALUout = ALUop1 + ALUop2; 
            SUB:   ALUout = ALUop1 - ALUop2; 
            AND:   ALUout = ALUop1 & ALUop2; 
            OR:    ALUout = ALUop1 | ALUop2; 
            XOR:   ALUout = ALUop1 ^ ALUop2; 
            SLL:   ALUout = ALUop1 << ALUop2;
            SRL:   ALUout = ALUop1 >> ALUop2;
            SRA: ALUout = $signed(ALUop1) >>> ALUop2;
            SLT:   ALUout = ($signed(ALUop1) < $signed(ALUop2)) ? {31'b0, 1'b1} : 32'b0;
            SLTU:  ALUout = ($unsigned(ALUop1) < $unsigned(ALUop2)) ? {31'b0, 1'b1} : 32'b0;      
            default:  ALUout = {DATA_WIDTH{1'b0}};
        endcase
    end

endmodule
