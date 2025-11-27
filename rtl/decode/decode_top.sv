/*
Ezekiel
decode_top.sv
*/

module decode_top #(
    parameter DATA_WIDTH = 32
)(
    input logic                     Zero,
    input logic                     stall,
    input logic                     negative,
    input logic                     clk,
    input logic [DATA_WIDTH-1:0]    WD3, 
    input logic [DATA_WIDTH-1:0]    Instr,

    output logic [1:0]              PCSrc,
    output logic [1:0]              ResultSrc,
    output logic                    MemWrite,
    output logic [3:0]              ALUControl,
    output logic                    ALUSrc,
    output logic                    AddressingMode,
    output logic [DATA_WIDTH-1:0]   RD1, 
    output logic [DATA_WIDTH-1:0]   RD2,
    output logic [DATA_WIDTH-1:0]   ImmExt
);

    // internal wire connections
    logic [2:0]                     ImmSrc;
    logic                           RegWrite;
    
    // controlUnit.sv
    controlUnit control_unit(
        // input
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7(Instr[30]),
        .Zero(Zero),
        .negative(negative),
        .stall(stall),
        // output
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .AddressingMode(AddressingMode)
    );

    // register.sv
    register register_file (
        // input 
        .clk(clk),
        .WE3(RegWrite),
        .AD1(Instr[19:15]),
        .AD2(Instr[24:20]),
        .AD3(Instr[11:7]),
        .WD3(result),
        // output
        .RD1(RD1),
        .RD2(RD2)
    );

    // signExtend.sv
    signExtend sign_extend(
        // input
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        // output 
        .ImmExt(ImmExt)
    );

endmodule