module hazard_unit(
    input logic [4:0]   Rs1E,
    input logic [4:0]   Rs2E,
    
    input logic [4:0]   RdM,
    input logic [4:0]   RdW,

    // not all instructions writeback to register(e.g. BEQ)
    // need RegWrite to know whether the destination register will actually be written 
    // and hence forward that value
    input logic         RegWriteM,
    input logic         RegWriteW,  

    // forwarding
    output logic [1:0]  ForwardAE,
    output logic [1:0]  ForwardBE
);

    always_comb begin
    
    if((Rs1E == RdM) & RegWriteM & (Rs1E!=0))   // forward from memory stage 
        ForwardAE = 2'b10;
    else if((Rs1E == RdW) & RegWriteW & (Rs1E!=0))  // forward from writeback stage
        ForwardAE = 2'b01;
    else 
        ForwardAE = 2'b00;

    if((Rs2E == RdM) & RegWriteM & (Rs2E!=0))
        ForwardBE = 2'b10;
    else if((Rs2E == RdW) & RegWriteW & (Rs2E!=0))
        ForwardBE = 2'b01;
    else 
        ForwardBE = 2'b00;    
    
    end

endmodule
