`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2026 06:24:56 PM
// Design Name: 
// Module Name: Sim_Top
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


module Sim_Top(
    input wire clk,
    input wire reset,
    input wire INT,
    input wire [7:0] INTV
    );
    
    wire [15:0] MEM_ADDR;
    wire [15:0] OUT_DATA;
    wire [15:0] IN_DATA;
    wire MIO_EN;
    wire R_W;
    wire DATA_SIZE;
    wire MEM_READY;
    
    Top Lc3b_core (
        .clk(clk),
        .reset(reset),
        .INT(INT),
        .INTV(INTV),
        .MEM_ADDR(MEM_ADDR),
        .OUT_DATA(OUT_DATA),
        .IN_DATA(IN_DATA),
        .MIO_EN(MIO_EN),
        .DATA_SIZE(DATA_SIZE),
        .R_W(R_W),
        .MEM_READY(MEM_READY)
    );
    
    Mem SYS_RAM (
        .clk(clk),
        .MIO_EN(MIO_EN),
        .R_W(R_W),
        .DATA_SIZE(DATA_SIZE),
        .MAR(MEM_ADDR),
        .MDR_OUT(OUT_DATA),
        .IN_DATA(IN_DATA),
        .R(MEM_READY)
    );
      
endmodule
