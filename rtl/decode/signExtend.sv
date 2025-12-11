/*
Ezekiel
INCOMPLETE : working on control unit first
*/

module signExtend #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0]    Instr1,
    input logic [DATA_WIDTH-1:0]    Instr2,

    input logic [5:0]               ImmSrc,
    input logic [1:0]               shiftImmFlag,
    
    output logic [DATA_WIDTH-1:0]   ImmExt1,
    output logic [DATA_WIDTH-1:0]   ImmExt2
);

    always_comb begin
            if (shiftImmFlag[0] && (ImmSrc[2:0] == 3'b000)) begin 
                ImmExt1 = {{27{Instr1[24]}}, Instr1[24:20]};
            end
            else begin
                case (ImmSrc[2:0])
                    3'b000:    ImmExt1 = {{20{Instr1[31]}}, Instr1[31:20]}; // I-type
                    default:   ImmExt1 = Instr1;
                endcase
            end
            
            if(shiftImmFlag[1] && (ImmSrc[5:3] == 3'b000)) begin 
                ImmExt2 = {{27{Instr2[24]}}, Instr2[24:20]};
            end
            else begin
                case (ImmSrc[5:3])
                    3'b000:    ImmExt2 = {{20{Instr2[31]}}, Instr2[31:20]}; // I-type
                    default:   ImmExt2 = Instr2;
                endcase
            end
    end

endmodule
