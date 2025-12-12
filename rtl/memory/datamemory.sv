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
    (*verilator public_flat_rw*)
    logic [BYTE_WIDTH-1:0] memory [0:32'h0001FFFF]; 
    
    initial begin
        $readmemh("data.hex", memory, 32'h00010000); 
        // $readmemh("reference/data.mem", memory, 32'h00010000); 
    end
    logic [ADDR_WIDTH-1:0] aligned_addr;
    logic [7:0] debug_byte_10002;
    logic [ADDR_WIDTH-1:0]  byte_addr; 
    assign debug_byte_10002 = memory[32'h00010002];
    
    // Convert physical address → byte offset
    assign byte_addr = address; // physical -> byte offset
    // Align for word / halfword
    assign aligned_addr = byte_addr & ~17'h3; // word-aligned base (clear bottom 2 bits)
    always_comb begin
        read_data = 32'b0;     // default to avoid latch
        if (Mem_ReadRequest) begin
            read_data = {
                memory[aligned_addr + 3],
                memory[aligned_addr + 2],
                memory[aligned_addr + 1],
                memory[aligned_addr + 0]
            };
        end
    end


    always_ff @(posedge clk) begin
        if (write_enable) begin
            case (addr_mode)
                3'b000,3'b011: begin                                                              // SB 
                    memory[byte_addr] <= write_data[7:0];
                end
                3'b001,3'b100: begin                                                              // SH 
                    memory[byte_addr] <= write_data[7:0];
                    memory[byte_addr+1] <= write_data[15:8];
                end
                3'b010: begin                                                                     // SW 
                    memory[byte_addr] <= write_data[7:0];
                    memory[byte_addr+1] <= write_data[15:8];
                    memory[byte_addr+2] <= write_data[23:16];
                    memory[byte_addr+3] <= write_data[31:24];
                end
                default: ;
            endcase
        end
    end

endmodule
