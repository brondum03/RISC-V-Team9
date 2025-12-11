//RISC-V regfiles 
//a0 referes to x10 (regfile 10), used for function arguments / return values
//regfile x0 (regfile 0) should always contain constant value 0
module register #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                  clk,
    input   logic                  rst,
    input   logic [1:0]            WE, // split into [WE6, WE3]
    // for instruction 1
    input   logic [ADDR_WIDTH-1:0] AD1, //address 1 (read)
    input   logic [ADDR_WIDTH-1:0] AD2, //address 2 (read)
    input   logic [ADDR_WIDTH-1:0] AD3, //address 3 (write)
    input   logic [DATA_WIDTH-1:0] WD3, //write data for write address 3

    // for instruction 2
    input   logic [ADDR_WIDTH-1:0] AD4, //address 4 (read)
    input   logic [ADDR_WIDTH-1:0] AD5, //address 5 (read)
    input   logic [ADDR_WIDTH-1:0] AD6, //address 6 (write)
    input   logic [DATA_WIDTH-1:0] WD6, //write data for write address 6

    // these go into 1 ALU
    output  logic [DATA_WIDTH-1:0] RD1, //read data from address 1
    output  logic [DATA_WIDTH-1:0] RD2, //read data from address 2

    // these go into 1 ALU
    output  logic [DATA_WIDTH-1:0] RD4, //read data from address 1
    output  logic [DATA_WIDTH-1:0] RD5, //read data from address 2

    output  logic [DATA_WIDTH-1:0] a0
);

    logic [DATA_WIDTH-1:0] regfile [2**ADDR_WIDTH-1:0];   //32 registers in this case

    //write port of the register must be synchronous
    always_ff @(posedge clk) begin
        if(rst) begin 
            for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
                regfile[i] <= 0;
            end
        end
        else begin 
            if(WE[0] && AD3 != 0) begin // lsb for 1st instruction
                regfile[AD3] <= WD3;
            end
            if(WE[1] && AD6 != 0) begin // msb for 2nd instruction
                regfile[AD6] <= WD6;
            end
        end
    end

    //the two read ports of the regfile must be asynchronous
    assign RD1 = regfile[AD1];         
    assign RD2 = regfile[AD2];
    assign RD4 = regfile[AD4];
    assign RD5 = regfile[AD5];
    assign a0 = regfile[10];

endmodule
