module hazard_unit(
    // read from register addresses for instruction in execute stage
    input logic [4:0]   Rs1E,
    input logic [4:0]   Rs2E,
    
    // write to register addresses for instructions in memory and writeback stages
    input logic [4:0]   RdM,
    input logic [4:0]   RdW,

    // not all instructions writeback to register(e.g. BEQ)
    // need RegWrite to know whether the destination register will actually be written 
    // and hence forward that value
    input logic         RegWriteM,
    input logic         RegWriteW,  

    input logic [1:0]   ResultSrcE,
    input logic [4:0]   RdE,
    input logic [4:0]   Rs1D,
    input logic [4:0]   Rs2D,
    input logic         PCSrcE,  // 1 when branch is taken (for control hazard)

    // forwarding
    output logic [1:0]  ForwardAE,
    output logic [1:0]  ForwardBE,
    
    // stall and flush signals
    output logic        StallF,
    output logic        StallD,
    output logic        FlushD,
    output logic        FlushE
);
    
    logic lwStall;
    // unused bit
    logic unused = ResultSrcE[1];

    always_comb begin

    // forwarding logic          
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
    
    // stall logic
    lwStall = ResultSrcE[0] & ((Rs1D == RdE) | (Rs2D == RdE));  //resultsrcE[0] = 1 for load instructions
    StallF = lwStall;
    StallD = lwStall;
    
    //flush logic
    FlushD = lwStall;
    FlushE = lwStall | PCSrcE;  // flush execute stage on branch taken, or load-use hazard

    end

endmodule
