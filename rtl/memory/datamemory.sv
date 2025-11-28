module datamemory #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8
)(    
    input   logic [DATA_WIDTH-1:0]  write_data,
    input   logic [DATA_WIDTH-1:0]  address,
    input   logic                   addr_mode,  //0 for word, 1 for byte
    input   logic                   write_enable,
    input   logic                   clk,
    output  logic [DATA_WIDTH-1:0]  read_data
    
    
);
    logic [BYTE_WIDTH-1:0] memory [32'h0001FFFF:0]; 
    
    initial begin
        $readmemh("data.hex", memory, 32'h00010000); 
    end;

    always_comb begin
        if(addr_mode) begin //byte addressing
            read_data = {24'b0, memory[address[16:0]]}; //extends the 8 bits(byte) to 32 bits with 0
        end else begin
            read_data = {memory[address[16:0]+3], memory[address[16:0]+2], memory[address[16:0]+1], memory[address[16:0]]};
        end
    end

    always_ff @(posedge clk) begin
        if (write_enable) begin
            if (addr_mode) begin //byte mode
                memory[address[16:0]] <= write_data[7:0];
            end
            else begin
                memory[address[16:0]] <= write_data[7:0];
                memory[address[16:0]+1] <= write_data[15:8];
                memory[address[16:0]+2] <= write_data[23:16];
                memory[address[16:0]+3] <= write_data[31:24];
            end
        end 
    end

endmodule
