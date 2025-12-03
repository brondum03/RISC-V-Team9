/*
Ezekiel
decode_top.sv
*/

// start pipelining decode

`include "../rtl/decode/controlUnit.sv"
`include "../rtl/decode/register.sv"
`include "../rtl/decode/signExtend.sv"
`include "../rtl/decode/decodePipeline.sv"


module decode_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input logic                     clk,
    input logic                     rst,
    input logic [DATA_WIDTH-1:0]    InstrD,
    input logic [DATA_WIDTH-1:0]    PCD,
    input logic [DATA_WIDTH-1:0]    PCPlus4D,

    input logic                     RegWriteW, // WE3
    input logic [DATA_WIDTH-1:0]    ResultW, // WD3
    input logic [4:0]               RdW, // AD3

    // PCSrcE indicates if there is a jump or branch 
    input logic                     PCSrcE, // FlushE = lwStall | PCSrcE
    // used to drive the flush. if PCSrc = 1 then the next instr is invalid bc jump was taken

    // output from control unit
    output logic        RegWriteE,
    output logic [1:0]  ResultSrcE, // selects mux, 00 -> ALUResultM, 01 -> ReaEEataW, 10 -> PCPlus4
    output logic        MemWriteE,
    output logic [1:0]  JumpE, // -> 00 for noJump, 01 for JAL, 10 for JALR
    output logic [2:0]  BranchE,
    output logic [3:0]  ALUControlE,
    output logic        ALUSrcE, // ALU register or Imm source
    output logic [2:0]  AddressingModeE,
    // output from register
    output  logic [DATA_WIDTH-1:0] RD1E, //read data from address 1
    output  logic [DATA_WIDTH-1:0] RD2E,  //read data from address 2
    // output from previous pipeline
    output logic [DATA_WIDTH-1:0]    PCE,
    output logic [ADDR_WIDTH-1:0]    Rs1E,
    output logic [ADDR_WIDTH-1:0]    Rs2E,
    output logic [ADDR_WIDTH-1:0]    RdE,
    output logic [DATA_WIDTH-1:0]    PCPlus4E,
    //output from signExtend
    output logic [DATA_WIDTH-1:0]    ImmExtE,
    output logic [DATA_WIDTH-1:0]    a0
);

    // internal wire connections
    logic RegWriteD;
    logic [1:0] ResultSrcD;
    logic MemWriteD;
    logic [1:0] JumpD;
    logic [2:0] BranchD;
    logic [3:0] ALUControlD;
    logic ALUSrcD;
    logic [2:0] AddressingModeD;
    logic [2:0] ImmSrcD;
    
    logic [DATA_WIDTH-1:0] RD1;
    logic [DATA_WIDTH-1:0] RD2;

    logic [DATA_WIDTH-1:0] ImmExtD;
    
    // controlUnit.sv
    controlUnit control_unit(
        // input
        .op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[30]),
        // output
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD), // ALU register or Imm source
        .ImmSrcD(ImmSrcD), // immsrc for signExtendsv
        .AddressingModeD(AddressingModeD)
    );

    // register.sv
    register register_file (
        // input 
        .clk(clk),
        .WE3(RegWriteW),
        .AD1(InstrD[19:15]),
        .AD2(InstrD[24:20]),
        .AD3(RdW),
        .WD3(ResultW),
        // output
        .RD1(RD1),
        .RD2(RD2),
        .a0(a0)
    );

    // signExtend.sv
    signExtend sign_extend(
        // input
        .InstrD(InstrD[31:7]),
        .ImmSrcD(ImmSrcD),
        // output 
        .ImmExtD(ImmExtD)
    );

    decodePipeline decode_pipeline(
        // input
        .clk(clk),
        .clear(PCSrcE | rst),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .AddressingModeD(AddressingModeD),
        .RD1D(RD1),
        .RD2D(RD2),
        .PCD(PCD),
        .Rs1D(InstrD[19:15]),
        .Rs2D(InstrD[24:20]),
        .RdD(InstrD[11:7]),
        .PCPlus4D(PCPlus4D),
        .ImmExtD(ImmExtD),

        // output 
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .AddressingModeE(AddressingModeE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),
        .ImmExtE(ImmExtE)
    );

endmodule
