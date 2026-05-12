`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2026 12:45:13 PM
// Design Name: 
// Module Name: alu_test
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

module ALU (
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [1:0] ALUK,
    output reg [15:0] out
);

    always @(*) begin
        case(ALUK)
            2'b00: out = A + B;
            2'b01: out = A & B;
            2'b10: out = ~A;
            2'b11: out = A; 
            default: out = 16'h0000;   
        endcase
    end
    
endmodule

