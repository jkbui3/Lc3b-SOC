`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 10:09:47 AM
// Design Name: 
// Module Name: SHF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SHF(
    input wire [15:0] IN,
    input wire [3:0] AMT,
    input wire [1:0] SHF_OP,
    output reg [15:0] OUT
);
    
    always @(*) begin
        case(SHF_OP)
            // LSHF
            2'b00: OUT = IN << AMT;
            
            // RSHFL
            2'b01: OUT = IN >> AMT;
            
            // RSHFA
            2'b11: OUT = $signed(IN) >>> AMT;
            
            default: OUT = 16'h0000;
        endcase
    end
endmodule
