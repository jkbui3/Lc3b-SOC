`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 11:29:23 AM
// Design Name: 
// Module Name: Reg_file
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


module Reg_file(
    input wire clk,
    input wire reset,
    input wire LD_REG, 
    input wire [2:0] DR,
    input wire [2:0] SR1,
    input wire [2:0] SR2,
    input wire [15:0] BUS_IN,    // Data coming in from BUS
    
    output wire [15:0] SR1_OUT,     // Data going to ALU A
    output wire [15:0] SR2_OUT      // Data goung to ALU B/ MUX
);

    reg [15:0] registers [0:7];
    
    integer i;          
    
    // Seq logic synchronous for RST only
    
    always @(posedge clk) begin
        if (reset) begin
            // zero out all 8 registers on reset
            for (i = 0; i < 8; i = i + 1) begin
                if (i == 6)
                    registers[i] <= 16'h3000;
                else 
                    registers[i] <= 16'h0000;
            end
        end
        
        else if (LD_REG) begin
            registers[DR] <= BUS_IN;
        end
    end
    
    // Comb read logic asynchronous
   
    assign SR1_OUT = registers[SR1];
    assign SR2_OUT = registers[SR2];
    
endmodule
