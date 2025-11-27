    module fetch_top#(
        parameter DATA_WIDTH = 32
    )(
        input   logic                          clk,
        input   logic                          rst,
        input   logic [1:0]                    PCsrc,
        input   logic [DATA_WIDTH-1:0]         ImmExt,
        output  logic [DATA_WIDTH-1:0]         Instr,
        output  logic [DATA_WIDTH-1:0]         Result_in
    );
    logic [DATA_WIDTH-1:0]          PC; 

    program_counter ProgramCounter(
        .clk(clk),
        .rst(rst),
        .pcsrc(PCSrc),
        .immOP(ImmExt),
        .result_in(Result_in),
        .out(PC)
    );

    instruction_memory Instruction_Memory(
        .in(PC),
        .out(Instr)
    );

    endmodule