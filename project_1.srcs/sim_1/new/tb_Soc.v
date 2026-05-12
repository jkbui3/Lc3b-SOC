`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2026 10:39:17 AM
// Design Name: 
// Module Name: tb_Soc
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


module tb_Soc(

    );
    
    reg clk_100mhz;
    reg reset_btn;
    reg [15:0] sw;
    reg RsRx;

    wire [15:0] LED;
    wire RsTx;

    // Instantiate your exact top module
    FPGA_Top UUT (
        .clk_100mhz(clk_100mhz),
        .reset_btn(reset_btn),
        .sw(sw),
        .LED(LED),
        .RsRx(RsRx),
        .RsTx(RsTx)
    );

    // Generate a perfect 100MHz clock (10ns period)
    always #5 clk_100mhz = ~clk_100mhz;

    initial begin
        // 1. Initialize the physical world
        clk_100mhz = 0;
        reset_btn = 1;      // Hold the reset button down
        RsRx = 1;           // UART idle line is HIGH
        sw = 16'h0041;      // Flip Switch 6 and 0 UP (ASCII 'A')

        // 2. Wait 200ns, then let go of the reset button
        #200;
        reset_btn = 0;

        // 3. Let the CPU run for 2 milliseconds, then stop the simulation
        #2000000;
        $finish;
    end
endmodule
