`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2026 10:18:59 AM
// Design Name: 
// Module Name: Mem
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


module Mem(
    input wire clk,
    input wire MIO_EN,
    input wire R_W,
    input wire DATA_SIZE,
    input wire [15:0] MAR,
    input wire [15:0] MDR_OUT,
    
    output wire [15:0] IN_DATA, 
    output wire R
);

    // RAM array
    reg [15:0] ram [0:32767];
    
    initial begin
  
       // $readmemh("program.mem", ram, 16'h1800); 
       $readmemh("program.mem", ram);  
    end
    
    wire we0 = (MIO_EN & R_W & ~DATA_SIZE) | (MIO_EN & R_W & DATA_SIZE & ~MAR[0]);
    wire we1 = (MIO_EN & R_W & ~DATA_SIZE) | (MIO_EN & R_W & DATA_SIZE & MAR[0]);
    
    // SRAM Mem block - Synchronous Writes ONLY
    always @(posedge clk) begin
        if (MIO_EN) begin
            // handle writes
            if (we0) ram[MAR[15:1]][7:0] <= MDR_OUT[7:0];
            if (we1) ram[MAR[15:1]][15:8] <= MDR_OUT[15:8];
        end
    end
    
    // Combinational Read
    // If MIO_EN is high and R_W is low (Read mode), output the data.
    assign IN_DATA = (MIO_EN & ~R_W) ? ram[MAR[15:1]] : 16'h0000;
    
    // 1 cycle ready now instead of lc3b's 5 
    assign R = MIO_EN;
    
endmodule
