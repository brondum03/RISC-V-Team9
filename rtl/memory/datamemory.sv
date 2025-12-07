module datamemory #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8,
    parameter ADDR_WIDTH = 17
)(    
    input   logic [DATA_WIDTH-1:0]  write_data,
    input   logic [ADDR_WIDTH-1:0]  address,
    input   logic [2:0]             addr_mode,
    input   logic                   write_enable,
    input   logic                   clk,
    input   logic                   Mem_ReadRequest,
    output  logic [DATA_WIDTH-1:0]  read_data
    
    
);
    logic [BYTE_WIDTH-1:0] memory [32'h0001FFFF:0]; 
    
    initial begin
        $readmemh("data.hex", memory, 32'h00010000); 
    end

    always_comb begin
        logic [31:0] word;
        if(Mem_ReadRequest) begin
            word = { memory[address+3], memory[address+2], memory[address+1], memory[address] };
            case (addr_mode)
                3'b000: read_data = {{24{memory[address][7]}}, memory[address]};                      // LB
                3'b001: read_data = {{16{memory[address+1][7]}}, memory[address+1], memory[address]}; // LH
                3'b010: read_data = word;                                                             // LW
                3'b011: read_data = {24'b0, memory[address]};                                         // LBU
                3'b100: read_data = {16'b0, memory[address+1], memory[address]};                      // LHU
                default: read_data = word;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (write_enable) begin
            case (addr_mode)
                3'b000,3'b011: begin                                                              // SB 
                    memory[address] <= write_data[7:0];
                end
                3'b001,3'b100: begin                                                              // SH 
                    memory[address] <= write_data[7:0];
                    memory[address+1] <= write_data[15:8];
                end
                3'b010: begin                                                                     // SW 
                    memory[address] <= write_data[7:0];
                    memory[address+1] <= write_data[15:8];
                    memory[address+2] <= write_data[23:16];
                    memory[address+3] <= write_data[31:24];
                end
                default: ;
            endcase
        end
    end

endmodule
