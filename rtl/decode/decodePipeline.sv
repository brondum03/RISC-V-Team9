module decodePipeline #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input logic     clk,
    input logic     rst,
    input logic     trigger,
    input logic     FlushE,

    // output from control unit
    input logic        RegWriteD,
    input logic [1:0]  ResultSrcD, // selects mux, 00 -> ALUResultM, 01 -> ReaEEataW, 10 -> PCPlus4
    input logic        MemWriteD,
    input logic [1:0]  JumpD, // -> 00 for noJump, 01 for JAL, 10 for JALR
    input logic [2:0]  BranchD,
    input logic [3:0]  ALUControlD,
    input logic        ALUSrcD, // ALU register or Imm source
    input logic [2:0]  AddressingModeD,
    // input from register
    input  logic [DATA_WIDTH-1:0] RD1D, //read data from address 1
    input  logic [DATA_WIDTH-1:0] RD2D,  //read data from address 2
    // input from previous pipeline
    input logic [DATA_WIDTH-1:0]    PCD,
    input logic [ADDR_WIDTH-1:0]    Rs1D,
    input logic [ADDR_WIDTH-1:0]    Rs2D,
    input logic [ADDR_WIDTH-1:0]    RdD,
    input logic [DATA_WIDTH-1:0]    PCPlus4D,
    // input from signExtend
    input logic [DATA_WIDTH-1:0]    ImmExtD,

    // signals for branch prediction
    input logic                     PredictTakenD,
    input logic [DATA_WIDTH-1:0]    PredictTargetD,

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
    // output from signExtend
    output logic [DATA_WIDTH-1:0]    ImmExtE,
    // signals for branch prediction
    output logic                     PredictTakenE,
    output logic [DATA_WIDTH-1:0]    PredictTargetE
);

    always_ff @ (posedge clk) begin 
        if(!FlushE && !rst && !trigger) begin 
            RegWriteE       <= RegWriteD;
            ResultSrcE      <= ResultSrcD;
            MemWriteE       <= MemWriteD;
            JumpE           <= JumpD;
            BranchE         <= BranchD;
            ALUControlE     <= ALUControlD;
            ALUSrcE         <= ALUSrcD;
            AddressingModeE <= AddressingModeD;
            RD1E       <= RD1D;
            RD2E       <= RD2D;
            PCE        <= PCD;
            Rs1E       <= Rs1D;
            Rs2E       <= Rs2D;
            RdE        <= RdD;
            PCPlus4E   <= PCPlus4D;
            ImmExtE    <= ImmExtD;
            PredictTakenE <= PredictTakenD;
            PredictTargetE <= PredictTargetD;
        end
        else if(FlushE || rst) begin 
            // // Flush pipeline — set everything to 0
            RegWriteE       <= 1'b0;
            ResultSrcE      <= 2'b00;
            MemWriteE       <= 1'b0;
            JumpE           <= 2'b00;
            BranchE         <= 3'b000;
            ALUControlE     <= 4'b0000;
            ALUSrcE         <= 1'b0;
            AddressingModeE <= 3'b000;
            RD1E       <= '0;
            RD2E       <= '0;
            PCE        <= '0;
            Rs1E       <= '0;
            Rs2E       <= '0;
            RdE        <= '0;
            PCPlus4E   <= '0;
            ImmExtE    <= '0;
            PredictTakenE <= '0;
            PredictTargetE <= '0;
        end
    end

endmodule
