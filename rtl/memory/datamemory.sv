module datamemory #(
    parameter DATA_WIDTH = 32
)(    
    input   logic [1:0]             write_enable,
    input   logic                   clk,

    input   logic [DATA_WIDTH-1:0]  write_data1,
    input   logic [DATA_WIDTH-1:0]  address_1,

    input   logic [DATA_WIDTH-1:0]  write_data2,
    input   logic [DATA_WIDTH-1:0]  address_2,

    output  logic [DATA_WIDTH-1:0]  read_data1,
    output  logic [DATA_WIDTH-1:0]  read_data2
);
    logic [DATA_WIDTH-1:0] memory [32'h0001FFFF:0]; 
    
    initial begin
        $readmemh("data.hex", memory, 32'h00010000); 
    end;

    always_comb begin
        read_data1 = memory[address_1];
        read_data2 = memory[address_2];
    end

    always_ff @(posedge clk) begin
        if (write_enable[0]) memory[address_1] <= write_data1;
        if (write_enable[1]) memory[address_2] <= write_data2;
    end

endmodule
