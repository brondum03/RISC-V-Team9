//RISC-V regfiles 
//a0 referes to x10 (regfile 10), used for function arguments / return values
//regfile x0 (regfile 0) should always contain constant value 0
module register #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input   logic                  clk,
    input   logic [ADDR_WIDTH-1:0] AD1, //address 1 (read)
    input   logic [ADDR_WIDTH-1:0] AD2, //address 2 (read)
    input   logic [ADDR_WIDTH-1:0] AD3, //address 3 (write)
    input   logic                  WE3, //write enable for write address 3
    input   logic [DATA_WIDTH-1:0] WD3, //write data for write address 3 --> takes in from rdW

    output  logic [DATA_WIDTH-1:0] RD1, //read data from address 1
    output  logic [DATA_WIDTH-1:0] RD2,  //read data from address 2

    output  logic [DATA_WIDTH-1:0] a0
);

    logic [DATA_WIDTH-1:0] regfile [2**ADDR_WIDTH-1:0];   //32 registers in this case

    //write port of the register must be synchronous
    always_ff @(posedge clk) begin
            if(WE3 == 1'b1 && AD3 != {ADDR_WIDTH{1'b0}}) begin
                regfile[AD3] <= WD3;
            end
    end

    //the two read ports of the regfile must be asynchronous
    assign RD1 = regfile[AD1];         
    assign RD2 = regfile[AD2];
    assign a0 = regfile[10];

endmodule
