`include "../rtl/adder.sv"
`include "../rtl/fetch/program_counter.sv"
`include "../rtl/fetch/instruction_memory.sv"
`include "../rtl/fetch/fetch_pipeline.sv"
`include "../rtl/fetch/branch_predictor.sv"
`include "../rtl/fetch/branch_target_buffer.sv"

module fetch_top#(
    parameter DATA_WIDTH = 32
)(
    input   logic                          clk,
    input   logic                          rst,
    input   logic                          trigger,
    input   logic                          StallF,
    input   logic                          StallD,
    input   logic                          FlushD,

    input   logic [DATA_WIDTH-1:0]         PCTargetE,
    
    input   logic [2:0]                    BranchE,
    input   logic                          BranchTakenE,
    input   logic                          PredictTakenE,
    input   logic [DATA_WIDTH-1:0]         PredictTargetE,
    input   logic [DATA_WIDTH-1:0]         PCE,
    input   logic [DATA_WIDTH-1:0]         BranchTargetE,
    input   logic                          JumpTakenE,

    output  logic [DATA_WIDTH-1:0]         InstrD,
    output  logic [DATA_WIDTH-1:0]         PCD,
    output  logic [DATA_WIDTH-1:0]         PCPlus4D,

    output  logic [DATA_WIDTH-1:0]         PredictTargetD,
    output  logic                          PredictTakenD
);

logic [DATA_WIDTH-1:0]          PCF;
logic [DATA_WIDTH-1:0]          PCNext;  
logic [DATA_WIDTH-1:0]          PCPlus4F;
logic [DATA_WIDTH-1:0]          InstrF;

logic                           predict_taken;
logic                           btb_hit;
logic [DATA_WIDTH-1:0]          btb_target;

branch_predictor branch_predictor(
    .clk(clk),
    .rst(rst),
    .PCF(PCF),
    .BranchE(BranchE),
    .PCE(PCE),
    .BranchTakenE(BranchTakenE),
    // output
    .PredictTakenF(predict_taken)
);

branch_target_buffer btb(
    .clk(clk),
    .rst(rst),
    .PCF(PCF),
    .PCE(PCE),
    .BranchTargetE(BranchTargetE), 
    .BranchTakenE(BranchTakenE),
    .BranchE(BranchE),
    // outputs
    .PredictTargetF(btb_target),
    .BTBHitF(btb_hit)
);

logic mispredicted;
logic branch_is_active;
assign branch_is_active = (BranchE != 3'b000);
assign mispredicted = branch_is_active && ((PredictTakenE != BranchTakenE) || (BranchTakenE && (PredictTargetE != BranchTargetE)));

// PC select logic
always_comb begin
    if (mispredicted)begin  // recover from misprediction
        PCNext = BranchTakenE ? BranchTargetE : (PCE + 4);
    end else if (JumpTakenE) begin
        PCNext = PCTargetE;
    end else if (predict_taken && btb_hit) begin    // predict taken with valid target
        PCNext = btb_target;
    end else begin  // default state
        PCNext = PCPlus4F;  
    end 
end

adder PCPlus4(
    .in0(PCF),
    .in1(4),
    .out(PCPlus4F)
);

program_counter ProgramCounter(
    .clk(clk),
    .rst(rst),
    .StallF(StallF),
    .trigger(trigger),
    .PCNext(PCNext),
    .out(PCF)
);

instruction_memory Instruction_Memory(
    .in(PCF),
    .out(InstrF)
);

logic                           PredictTakenF;
logic [DATA_WIDTH-1:0]          PredictTargetF;
assign PredictTakenF = predict_taken & btb_hit;
assign PredictTargetF = btb_target;

fetch_pipeline Fetch_Pipeline(
    .clk(clk),
    .FlushD(FlushD),
    .rst(rst),
    .StallD(StallD),
    .trigger(trigger),
    .InstrF(InstrF),
    .PCF(PCF),
    .PCPlus4F(PCPlus4F),
    .PredictTakenF(PredictTakenF),
    .PredictTargetF(PredictTargetF),
    
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D),
    .PredictTakenD(PredictTakenD),
    .PredictTargetD(PredictTargetD)
);


endmodule
