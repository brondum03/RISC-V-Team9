/*
Ezekiel
decode_top.sv
*/

module decode_top #(
    parameter DATA_WIDTH = 32,
)(
    // input for control unit
    input logic                     zero,
    // input for register
    input logic                     clk,
    input logic [DATA_WIDTH-1:0]    WD3, 
    
    input logic [DATA_WIDTH-1:0]    instr,

    // output for control unit
    output logic                    PCSrc,
    output logic                    ResultSrc,
    output logic                    MemWrite,
    output logic [2:0]              ALUControl,
    output logic                    ALUSrc,
    // output for register file
    output logic [DATA_WIDTH-1:0]   RD1, 
    output logic [DATA_WIDTH-1:0]   RD2,
    // output for sign extend
    output logic [DATA_WIDTH-1:0]   ImmExt,
);

    // internal wire connections
    logic [2:0]                     ImmSrc;
    logic                           RegWrite;
    
    // controlUnit.sv
    controlUnit control_unit(
        // input
        .op(instr[6:0]);
        .funct3(instr[14:12]);
        .funct7(funct7[30]);
        .zero(zero);
        // output
        .PCSrc(PCSrc);
        .ResultSrc(ResultSrc);
        .MemWrite(MemWrite);
        .ALUControl(ALUControl);
        .ALUSrc(ALUSrc);
        .ImmSrc(ImmSrc);
        .RegWrite(RegWrite);
    );

    // register.sv
    register register_file (
        // input 
        .clk(clk);
        .AD1(instr[19:15]);
        .AD2(instr[24:20]);
        .AD3(instr[11:7]);
        .WE3(RegWrite);
        .WD3(WD3);
        // output
        .RD1(RD1);
        .RD2(RD2);
    );

    // signExtend.sv
    signExtend sign_extend(
        // input
        .instr(instr);
        .ImmSrc(ImmSrc);
        // output 
        .ImmExt(ImmExt)
    );

    assign PCSrc = Branch & zero;
    
endmodule