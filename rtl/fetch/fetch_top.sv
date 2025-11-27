    module fetch_top#(
        parameter DATA_WIDTH = 32,
    )(
        input   logic                          clk,
        input   logic                          rst,
        input   logic                          PCsrc,
        input   logic [DATA_WIDTH-1:0]         ImmExt,
        output  logic [DATA_WIDTH-1:0]         Instr
    );
    logic [DATA_WIDTH-1:0]          PC; 
    

    program_counter #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ProgramCounter(
        .clk(clk),
        .rst(rst),
        .pcsrc(PCSrc),
        .immOP(ImmExt),
        .out(PC)
    );

    instruction_memory #(
        .DATA_WIDTH(DATA_WIDTH)
    ) Instruction_Memory(
        .in(PC),
        .out(Instr)
    );

    endmodule