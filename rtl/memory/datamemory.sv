module datamemory #(
    parameter DATA_WIDTH = 32 
)(    
    input   logic clk,
    input   logic WE,
    input   logic [DATA_WIDTH-1:0] WD,
    input   logic [DATA_WIDTH-1:0] A,
    output  logic [DATA_WIDTH-1:0] RD
);
    logic [DATA_WIDTH-1:0] memory [2**DATA_WIDTH-1:0];
    
    always_ff @(posedge clk) begin
        if (WE)
            memory[A] <= WD;
    end

    assign RD = memory[A];        
    
endmodule
