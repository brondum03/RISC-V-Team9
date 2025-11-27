`include "./execute/execute_top.sv"

module execute_top #(
    parameter DATA_WIDTH = 32
)(
    input   logic [DATA_WIDTH-1:0]  SrcA,
    input   logic [DATA_WIDTH-1:0]  SrcB,
    input   logic [2:0]             ALUControl,
    output  logic [DATA_WIDTH-1:0]  ALUResult,
    output  logic                   Zero
);

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU_inst (
        .ALUop1(SrcA),
        .ALUop2(SrcB),
        .ALUctrl(ALUControl),
        .ALUout(ALUResult),
        .EQ(Zero)
    );

endmodule
