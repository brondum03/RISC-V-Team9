`include "../rtl/decode/controlUnit.sv"
`include "../rtl/decode/register.sv"
`include "../rtl/decode/signExtend.sv"


module decode_top #(
    parameter DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic                     stall,
    input logic                     rst,

    input logic [DATA_WIDTH-1:0]    Instr1,
    input logic [DATA_WIDTH-1:0]    WD3,

    input logic [DATA_WIDTH-1:0]    Instr2,
    input logic [DATA_WIDTH-1:0]    WD6,
    
    output logic                    PCSrc,
    output logic [1:0]              ResultSrc,
    output logic [1:0]              MemWrite,
    output logic [7:0]              ALUControl,
    output logic [1:0]              ALUSrc,

    output logic [DATA_WIDTH-1:0]   RD1, 
    output logic [DATA_WIDTH-1:0]   RD2,
    output logic [DATA_WIDTH-1:0]   ImmExt1,

    output logic [DATA_WIDTH-1:0]   RD4, 
    output logic [DATA_WIDTH-1:0]   RD5,
    output logic [DATA_WIDTH-1:0]   ImmExt2,

    output logic [DATA_WIDTH-1:0]   a0
);

    // internal wire connections
    logic [1:0] shiftImmFlag;
    logic [1:0] RegWrite;
    logic [5:0] ImmSrc;
    
    // controlUnit.sv
    controlUnit control_unit(
        // input
        .stall(stall),

        .op1(Instr1[6:0]),
        .funct3_1(Instr1[14:12]),
        .funct7_1(Instr1[30]),

        .op2(Instr2[6:0]),
        .funct3_2(Instr2[14:12]),
        .funct7_2(Instr2[30]),
        // output
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .shiftImmFlag(shiftImmFlag)
    );

    // register.sv
    register register_file (
        // input 
        .clk(clk),
        .rst(rst),
        .WE(RegWrite),

        .AD1(Instr1[19:15]),
        .AD2(Instr1[24:20]),
        .AD3(Instr1[11:7]),
        .WD3(WD3),

        .AD4(Instr2[19:15]),
        .AD5(Instr2[24:20]),
        .AD6(Instr2[11:7]),
        .WD6(WD6),

        // output
        .RD1(RD1),
        .RD2(RD2),
        
        .RD4(RD4),
        .RD5(RD5),

        .a0(a0)
    );

    // signExtend.sv
    signExtend sign_extend(
        // input
        .Instr1(Instr1),
        .Instr2(Instr2),
        .ImmSrc(ImmSrc),
        .shiftImmFlag(shiftImmFlag),
        // output 
        .ImmExt1(ImmExt1),
        .ImmExt2(ImmExt2)
    );

endmodule
